-- Asks a formatter or linter whether it owns a path.
--
-- rumdl and dprint apply their config's `exclude` only when handed a real path.
-- conform and nvim-lint drive both over stdin, where the exclude is silently
-- ignored, so saving a file the repo deliberately excludes -- a captured test
-- fixture, a generated lockfile -- would rewrite it. Each tool is asked
-- directly instead.

local M = {}

-- A tool gets this long to answer before it is treated as unable to. Generous
-- because dprint compiles its wasm plugins on first use -- measured at 2538ms
-- cold against 38ms warm -- and a killed run banks nothing, so a tighter budget
-- turns a plugin version bump into a permanent silent failure. Only a genuinely
-- stuck tool ever pays it, and GIVE_UP_AFTER bounds how often. Override with
-- vim.g.project_tooling_timeout_ms; a child that leaves grandchildren holding
-- its pipes costs twice this, since nvim waits the budget again after killing it.
local DEFAULT_TIMEOUT_MS = 10000

-- Retrying a dead tool costs a full timeout on every probe, and conform probes
-- twice per save, so stop after this many failures for a file and cache the
-- negative instead.
local GIVE_UP_AFTER = 3

-- [tool] = spec, registered once so a cached answer can never belong to a
-- different question than the one being asked.
local specs = {}

-- [tool][path] = boolean. Only decided answers land here, so an unknown is
-- retried on the next probe. Owned outright rather than taken from
-- LazyVim.memoize, whose cache is a bare module-local with no eviction or
-- invalidation: editing a tool's excludes would otherwise never take effect
-- until nvim restarts.
local answers = {}

-- [tool][path] = { reason = string, count = integer }. The count rises on every
-- failure while the reason only governs whether to speak, so a tool whose error
-- text varies -- a line number, an offset, a temp path -- still reaches the
-- give-up bound.
local failures = {}

---Paths arrive from conform as buffer names and come back from dprint resolved,
---and on macOS /tmp is itself a symlink. Everything is keyed and compared in
---resolved form so those spellings cannot split one file into two entries.
---@param path string
---@return string
local function canonical(path)
  local real = vim.uv.fs_realpath(path)
  if real then
    return real
  end
  -- Only `forget` reaches this branch: `owns` refuses a path that is not on
  -- disk, so a root that does not exist yet still resolves to the key its
  -- files will be cached under.
  local dir = vim.uv.fs_realpath(vim.fs.dirname(path))
  return dir and vim.fs.joinpath(dir, vim.fs.basename(path)) or vim.fs.normalize(path)
end

---@param store table
---@param tool string
local function bucket(store, tool)
  store[tool] = store[tool] or {}
  return store[tool]
end

---@return integer
local function timeout_ms()
  local configured = vim.g.project_tooling_timeout_ms
  if type(configured) == "number" and configured > 0 then
    return configured
  end
  if configured ~= nil then
    vim.notify_once(
      ("vim.g.project_tooling_timeout_ms must be a positive number, got %s; using %dms"):format(
        vim.inspect(configured),
        DEFAULT_TIMEOUT_MS
      ),
      vim.log.levels.WARN,
      { title = "project-tooling" }
    )
  end
  return DEFAULT_TIMEOUT_MS
end

---Classifies a finished `vim.system` result. Pure: it neither spawns nor
---notifies, so every rule below is exercisable without a real tool.
---
---`ok_codes` lists the exit codes that carry an answer: rumdl reports "needs
---formatting" as 1, so a blanket nonzero test reads a routine answer as a
---broken tool. Process-level failure is classified here rather than by
---`ok_codes`, which cannot see it: a signalled child reports code 0.
---@param res table|nil `vim.system():wait()` result; nil when a grandchild held the pipes
---@param ok_codes integer[]
---@param elapsed_ms number
---@param budget_ms integer
---@return {stdout: string, stderr: string}|nil
---@return string|nil reason set when the result is nil
function M.classify(res, ok_codes, elapsed_ms, budget_ms)
  -- nvim synthesizes code 124 on timeout and the kill it sends arrives as a
  -- signal, while a tool exiting 124 on its own arrives with signal 0 well
  -- inside the budget. Reading the second as a timeout throws away its answer.
  if res == nil or (res.code == 124 and ((res.signal or 0) ~= 0 or elapsed_ms >= budget_ms)) then
    return nil, ("did not finish within %dms"):format(budget_ms)
  end
  if (res.signal or 0) ~= 0 then
    return nil, ("was killed by signal %d"):format(res.signal)
  end
  if not vim.tbl_contains(ok_codes, res.code) then
    local detail = (vim.trim(res.stderr or ""):match("^[^\n]*") or ""):sub(1, 120)
    return nil, ("exited %d%s"):format(res.code, detail ~= "" and (": " .. detail) or "")
  end
  return { stdout = res.stdout or "", stderr = res.stderr or "" }
end

---@param cmd string[]
---@param path string
---@param ok_codes integer[]
---@return {stdout: string, stderr: string}|nil
---@return string|nil reason
local function run(cmd, path, ok_codes)
  local budget = timeout_ms()
  local started = vim.uv.hrtime()
  local spawned, res = pcall(function()
    return vim.system(cmd, { cwd = vim.fs.dirname(path), text = true }):wait(budget)
  end)
  if not spawned then
    local err = tostring(res)
    if err:find("(cmd)", 1, true) then
      -- EACCES carries the same marker: a tool that is present but not
      -- executable must not be reported as missing.
      if err:find("EACCES", 1, true) then
        return nil, ("is not executable (check permissions on %s)"):format(cmd[1])
      end
      return nil, ("is not on PATH (install it or fix %s)"):format(cmd[1])
    end
    if err:find("(cwd)", 1, true) then
      return nil, ("could not enter %s"):format(vim.fs.dirname(path))
    end
    return nil, err
  end
  return M.classify(res, ok_codes, (vim.uv.hrtime() - started) / 1e6, budget)
end

---Records a failure, naming what it costs before the detail -- "formatting
---stopped" is the symptom a user notices, and nothing else connects it to the
---tool. Speaks once per distinct reason; counts every time.
---@return boolean settled true once retrying has been abandoned
local function report(tool, path, reason, lost)
  local seen = bucket(failures, tool)[path]
  local count = (seen and seen.count or 0) + 1
  bucket(failures, tool)[path] = { reason = reason, count = count }
  if not seen or seen.reason ~= reason then
    vim.notify(
      ("%s: %s for %s -- %s"):format(tool, lost, vim.fs.basename(path), reason),
      vim.log.levels.WARN,
      { title = "project-tooling" }
    )
  end
  if count == GIVE_UP_AFTER then
    vim.notify(
      ("%s has failed %d times for %s; not asking again until its config changes or :ProjectToolingReset (raise vim.g.project_tooling_timeout_ms if it is merely slow)"):format(
        tool,
        GIVE_UP_AFTER,
        vim.fs.basename(path)
      ),
      vim.log.levels.WARN,
      { title = "project-tooling" }
    )
  end
  return count >= GIVE_UP_AFTER
end

---Registers how a tool is asked. Validated here so a malformed spec fails at
---startup rather than inside a formatter condition on some later save.
---@param tool string
---@param spec { cmd: fun(path: string): string[], ok_codes: integer[], lost: string, decide: fun(out: {stdout: string, stderr: string}, path: string): boolean }
function M.register(tool, spec)
  assert(type(spec.cmd) == "function", ("tool_owner.register(%s): cmd must be a function of path"):format(tool))
  assert(type(spec.decide) == "function", ("tool_owner.register(%s): decide must be a function"):format(tool))
  assert(type(spec.ok_codes) == "table", ("tool_owner.register(%s): ok_codes must be a list"):format(tool))
  assert(type(spec.lost) == "string", ("tool_owner.register(%s): lost must describe what stops"):format(tool))
  specs[tool] = spec
  -- A reloaded or edited spec asks a different question; answers to the old one
  -- are not answers to this one.
  answers[tool], failures[tool] = nil, nil
end

---Asks a registered tool whether it owns `path`, caching decided answers.
---
---A tool that cannot answer must not pass for one answering "no": dprint going
---quiet stops formatting, and rumdl going quiet lints files the repo excludes.
---An unanswered probe returns nil, which every caller treats as "not owned"
---without caching it, so the next probe retries.
---@param tool string
---@param path string
---@return boolean|nil owned nil when the tool could not answer
function M.owns(tool, path)
  local spec = specs[tool]
  if not spec then
    vim.notify_once(
      ("tool_owner: %s was never registered"):format(tool),
      vim.log.levels.ERROR,
      { title = "project-tooling" }
    )
    return nil
  end
  -- Emptiness is tested before canonicalization, which would otherwise resolve
  -- "" through dirname "." to the cwd and hand the tool a whole directory.
  if path == "" then
    return nil
  end
  path = canonical(path)
  -- A buffer not yet written has nothing for the tool to inspect. dprint
  -- answers exit 0 with no output and rumdl exits 2, so probing would cache a
  -- "not owned" manufactured entirely by the file's absence -- silently for
  -- dprint, on the first probe. Say so, or the skipped formatting on a new
  -- file's first save looks like the formatter is broken.
  local stat = vim.uv.fs_stat(path)
  if not stat then
    vim.notify_once(
      ("%s: %s for %s until it has been written to disk"):format(tool, spec.lost, vim.fs.basename(path)),
      vim.log.levels.INFO,
      { title = "project-tooling" }
    )
    return nil
  end
  if stat.type ~= "file" then
    return nil
  end
  local decided = bucket(answers, tool)[path]
  if decided ~= nil then
    return decided
  end
  local out, reason = run(spec.cmd(path), path, spec.ok_codes)
  if out then
    -- decide is the extension point, so a throw there is the tool's problem to
    -- report, not an error escaping into conform's condition and losing a save.
    local ok, owned = pcall(spec.decide, out, path)
    if not ok then
      if report(tool, path, ("could not read its answer: %s"):format(owned), spec.lost) then
        bucket(answers, tool)[path] = false
        return false
      end
      return nil
    end
    bucket(failures, tool)[path] = nil
    bucket(answers, tool)[path] = owned
    return owned
  end
  if report(tool, path, reason, spec.lost) then
    -- Caching false is what stops every later save paying the timeout again.
    bucket(answers, tool)[path] = false
    return false
  end
  return nil
end

---Drops everything remembered about paths under `root`, so a changed config
---takes effect without restarting nvim.
---@param root string
---@return integer dropped
function M.forget(root)
  local prefix = canonical(root):gsub("/$", "")
  local dropped = 0
  for _, store in ipairs({ answers, failures }) do
    for _, per_path in pairs(store) do
      for path in pairs(per_path) do
        if path == prefix or vim.startswith(path, prefix .. "/") then
          per_path[path] = nil
          dropped = dropped + 1
        end
      end
    end
  end
  return dropped
end

function M.reset()
  answers, failures = {}, {}
end

return M
