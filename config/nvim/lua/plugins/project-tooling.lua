-- Tool choice follows the repository, not the editor. A repo that ships a
-- config for a formatter gets that formatter; everything else gets the default.
-- Without this, markdownlint-cli2 lints a rumdl-configured repo against rules
-- that repo's config disables, and prettier rewrites files a non-Node formatter
-- owns.
--
-- Precedence per filetype is: the repo's dedicated formatter (rumdl, dprint),
-- then prettier if the repo still configures it, then oxfmt as the default.

local RUMDL = { ".rumdl.toml", "rumdl.toml" }
local DPRINT = { "dprint.json", ".dprint.json", "dprint.jsonc", ".dprint.jsonc" }

-- Prettier also reads a `prettier` key in package.json, which no filename can
-- express; prettier_configured checks for it separately.
local PRETTIER = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.json5",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.toml",
  ".prettierrc.js",
  ".prettierrc.mjs",
  ".prettierrc.cjs",
  ".prettierrc.ts",
  ".prettierrc.mts",
  ".prettierrc.cts",
  "prettier.config.js",
  "prettier.config.mjs",
  "prettier.config.cjs",
  "prettier.config.ts",
  "prettier.config.mts",
  "prettier.config.cts",
}

---@param markers string[]
---@param path string file path to search upward from
local function configured(markers, path)
  return vim.fs.find(markers, { path = path, upward = true })[1] ~= nil
end

---@param path string
local function prettier_configured(path)
  if configured(PRETTIER, path) then
    return true
  end
  local manifests = vim.fs.find("package.json", { path = path, upward = true, limit = math.huge })
  for _, manifest in ipairs(manifests) do
    local ok, pkg = pcall(vim.json.decode, table.concat(vim.fn.readfile(manifest), "\n"))
    if ok and type(pkg) == "table" and pkg.prettier ~= nil then
      return true
    end
  end
  return false
end

---Formatter list resolved against the repo's config files.
---@param owners table[] {markers, formatters} pairs, highest precedence first
---@param on_prettier string[] formatters when the repo still configures prettier
---@param default string[]
local function pick(owners, on_prettier, default)
  return function(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    local path = name ~= "" and name or vim.fn.getcwd()
    for _, owner in ipairs(owners) do
      if configured(owner[1], path) then
        return owner[2]
      end
    end
    return prettier_configured(path) and on_prettier or default
  end
end

-- rumdl and dprint apply their config's `exclude` only when handed a real path.
-- conform and nvim-lint drive both over stdin, where the exclude is silently
-- ignored, so saving a file the repo deliberately excludes -- a captured test
-- fixture, a generated lockfile -- would rewrite it. Each tool is asked
-- directly whether it owns the path. Memoized: one ~20ms call per file.

---@param cmd string[]
---@param path string
local function run(cmd, path)
  local res = vim.system(cmd, { cwd = vim.fs.dirname(path), text = true }):wait()
  return res.stdout or "", res.stderr or ""
end

local dprint_owns = LazyVim.memoize(function(path)
  local stdout = run({ "dprint", "file-paths", path }, path)
  return vim.trim(stdout) ~= ""
end)

-- `rumdl fmt --check` names filtered paths on stderr and says nothing about the
-- files it would process. `check --output json` cannot answer this: an excluded
-- file and a clean one are both `[]`.
local rumdl_owns = LazyVim.memoize(function(path)
  local _, stderr = run({ "rumdl", "fmt", "--check", path }, path)
  return not stderr:find("filtered out", 1, true)
end)

---LazyVim's `lang.typescript.oxc` extra appends oxfmt to every filetype it
---claims, which would leave prettier and oxfmt both writing the same buffer in
---a repo that still configures prettier. The prettier branch is that list minus
---oxfmt.
---@param list string[]|nil
local function without_oxfmt(list)
  local kept = vim.tbl_filter(function(name)
    return name ~= "oxfmt"
  end, list or {})
  return #kept > 0 and kept or { "prettier" }
end

-- oxfmt 0.49 parses all of these over stdin. astro is left out: it is the one
-- filetype oxfmt rejects with "Unsupported file type for stdin-filepath", so it
-- keeps LazyVim's prettier entry untouched.
local OXFMT_FILETYPES = {
  "css",
  "graphql",
  "html",
  "javascript",
  "javascriptreact",
  "less",
  "scss",
  "svelte",
  "typescript",
  "typescriptreact",
  "vue",
}

-- cspell mirrors the VS Code extension's default, which enables every file type
-- (`cSpell.enabledFileTypes` defaults to `{"*": true}`), toggled with <leader>us.
-- It runs from its own autocmd rather than `linters_by_ft` so it fires on read
-- and write only: the CLI costs a flat ~1.1s per run -- Node startup plus
-- dictionary load, independent of file size -- and nvim-lint would otherwise
-- repeat that on every InsertLeave.
--
-- Config discovery needs no wiring. nvim-lint passes `stdin://<real path>`, so
-- cspell walks up from the actual file and finds ~/.cspell.json exactly as the
-- CLI does.

-- Both files are symlinks into the dotfiles repo and both are declared with
-- `addWords: true` in ~/.cspell.json, so either is a valid destination.
local CSPELL_DICTS = {
  { label = "personal dictionary", path = vim.fn.expand("~/.cspell/personal-words.txt") },
  { label = "misc dictionary", path = vim.fn.expand("~/.cspell/misc.txt") },
}
local cspell_enabled = true

local function cspell_lint()
  if not cspell_enabled or vim.fn.executable("cspell") == 0 then
    return
  end
  if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == "" or vim.b.bigfile then
    return
  end
  require("lint").try_lint({ "cspell" })
end

-- davidmh/cspell.nvim provided this as a none-ls code action, but it was
-- archived in December 2025; @vlabo/cspell-lsp, the only cspell LSP, is
-- deprecated in favour of codebook, which reads its own config rather than
-- cspell's. Appending to the dictionary directly is what is left, wired back
-- onto <leader>ca through the none-ls source at the bottom of this file.
---@param dict table one of CSPELL_DICTS
---@param word string
local function cspell_add(dict, word)
  local lines = vim.fn.filereadable(dict.path) == 1 and vim.fn.readfile(dict.path) or {}
  for _, line in ipairs(lines) do
    if line == word then
      return vim.notify(word .. " is already known", vim.log.levels.INFO, { title = "cspell" })
    end
  end
  -- The dictionary is kept sorted; inserting in place keeps the dotfiles diff to
  -- the one line that was added.
  local at = #lines + 1
  for i, line in ipairs(lines) do
    if line:lower() > word:lower() then
      at = i
      break
    end
  end
  table.insert(lines, at, word)
  vim.fn.writefile(lines, dict.path)
  vim.notify(("Added %s to %s"):format(word, dict.label), vim.log.levels.INFO, { title = "cspell" })
  cspell_lint()
end

---The cspell diagnostic covering a position, if there is one.
---@param bufnr integer
---@param lnum integer 0-indexed row
---@param col integer 0-indexed byte column
local function cspell_diagnostic_at(bufnr, lnum, col)
  for _, d in ipairs(vim.diagnostic.get(bufnr, { lnum = lnum })) do
    if d.source == "cspell" and col >= d.col and col < (d.end_col or d.col) then
      return d
    end
  end
end

-- Replacement for `z=`, which the disabled built-in speller took with it.
-- cspell already computes corrections; the linter below carries them through in
-- `user_data`, so this reads structured data rather than scraping a message.

---Offers cspell's corrections for the word under the cursor, falling back to the
---built-in `z=` when no cspell diagnostic covers it.
local function cspell_correct()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local d = cspell_diagnostic_at(0, row - 1, col)
  if not d then
    return vim.cmd("normal! z=")
  end
  local words = (d.user_data or {}).suggestions or {}
  if #words == 0 then
    return vim.notify("cspell has no suggestion here", vim.log.levels.INFO, { title = "cspell" })
  end
  vim.ui.select(words, { prompt = "Replace with" }, function(choice)
    if choice then
      vim.api.nvim_buf_set_text(0, d.lnum, d.col, d.lnum, d.end_col, { choice })
      cspell_lint()
    end
  end)
end

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      local ft = opts.formatters_by_ft

      -- The prettier branch reuses whatever list LazyVim's extras already built
      -- for the filetype, so enabling another lang extra keeps working.
      for _, lang in ipairs(OXFMT_FILETYPES) do
        ft[lang] = pick({}, without_oxfmt(ft[lang]), { "oxfmt" })
      end

      -- rumdl owns markdown outright where it is configured: one writer per file
      -- type, so nothing oscillates with it. markdown-toc rides along in every
      -- branch because it rewrites only the block between `<!-- toc -->`
      -- markers and is a no-op without them.
      for _, lang in ipairs({ "markdown", "markdown.mdx" }) do
        ft[lang] = pick(
          { { RUMDL, { "rumdl", "markdown-toc" } } },
          without_oxfmt(ft[lang]),
          { "oxfmt", "markdown-toc" }
        )
      end

      -- dprint passes through file types its config excludes or has no plugin
      -- for, so the whole set can route through it unconditionally.
      for _, lang in ipairs({ "json", "jsonc", "yaml" }) do
        ft[lang] = pick({ { DPRINT, { "dprint" } } }, without_oxfmt(ft[lang]), { "oxfmt" })
      end
      -- astro is the one filetype oxfmt rejects over stdin ("Unsupported file
      -- type for stdin-filepath"), so the oxc extra's entry for it is removed
      -- rather than switched.
      ft.astro = without_oxfmt(ft.astro)

      -- oxfmt does not read toml; without dprint this falls back to taplo's LSP
      -- formatting, which is what LazyVim's toml extra already provides.
      opts.formatters = opts.formatters or {}
      opts.formatters.dprint = {
        condition = function(_, ctx)
          return dprint_owns(ctx.filename)
        end,
      }
      opts.formatters.rumdl = {
        condition = function(_, ctx)
          return rumdl_owns(ctx.filename)
        end,
      }

      ft.toml = pick({ { DPRINT, { "dprint" } } }, ft.toml or {}, ft.toml or {})
    end,
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    init = function()
      -- Not `on_very_lazy`: those callbacks run before LazyVim loads its own
      -- keymaps and autocmds, so a mapping or FileType handler registered there
      -- loses to LazyVim's. `LazyVimKeymaps` and `LazyVimAutocmds` fire after
      -- both LazyVim's defaults and the user's config files have loaded.
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimAutocmds",
        callback = function()
          vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
            group = vim.api.nvim_create_augroup("cspell", { clear = true }),
            callback = function()
              cspell_lint()
            end,
          })
          -- LazyVim turns Neovim's own speller on for these filetypes. Its
          -- dictionary is plain English: on three files here it flagged 48 words
          -- cspell knows, among them npm, pnpm, toml, semver, and mise.
          vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("cspell_spell_off", { clear = true }),
            pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
            callback = function()
              vim.opt_local.spell = false
            end,
          })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimKeymaps",
        callback = function()
          -- Takes over <leader>us from LazyVim's `spell` option toggle: cspell is
          -- the speller whose output is worth reading. `:set spell` still gets the
          -- built-in back for `z=`, which cspell has no code action for.
          Snacks.toggle({
            name = "Spelling (cspell)",
            get = function()
              return cspell_enabled
            end,
            set = function(state)
              cspell_enabled = state
              if state then
                cspell_lint()
              else
                vim.diagnostic.reset(require("lint").get_namespace("cspell"))
              end
            end,
          }):map("<leader>us")
          vim.keymap.set("n", "z=", cspell_correct, { desc = "Spelling suggestions (cspell)" })
        end,
      })
    end,

    opts = {
      linters_by_ft = {
        markdown = { "markdownlint-cli2", "rumdl" },
      },
      linters = {
        -- The bundled JSON reporter replaces nvim-lint's errorformat parsing.
        -- It writes to stdout when no `outFile` is set and carries row, col,
        -- length, and a ranked `suggestions` array, so `z=` reads structured
        -- data instead of scraping "Suggestions: [world*, ...]" out of a
        -- message. `--show-suggestions` is still needed: without it each issue
        -- carries only cspell's single best guess.
        cspell = {
          args = {
            "lint",
            "--no-progress",
            "--no-summary",
            "--show-suggestions",
            "--reporter",
            "@cspell/cspell-json-reporter",
            function()
              return "stdin://" .. vim.api.nvim_buf_get_name(0)
            end,
          },
          parser = function(output, bufnr)
            local ok, decoded = pcall(vim.json.decode, output)
            if not ok or type(decoded) ~= "table" or type(decoded.issues) ~= "table" then
              return {}
            end
            local diagnostics = {}
            for _, issue in ipairs(decoded.issues) do
              local lnum = math.max(0, (issue.row or 1) - 1)
              local line = vim.api.nvim_buf_get_lines(bufnr or 0, lnum, lnum + 1, false)[1] or ""
              -- cspell counts in UTF-16 code units; diagnostics want bytes.
              local col = (issue.col or 1) - 1
              local converted, byte = pcall(vim.str_byteindex, line, "utf-16", col, false)
              col = converted and byte or col
              table.insert(diagnostics, {
                lnum = lnum,
                col = col,
                end_lnum = lnum,
                end_col = col + #(issue.text or ""),
                message = ("Unknown word (%s)"):format(issue.text or "?"),
                source = "cspell",
                severity = issue.isFlagged and vim.diagnostic.severity.WARN or vim.diagnostic.severity.INFO,
                user_data = { text = issue.text, suggestions = issue.suggestions or {} },
              })
            end
            return diagnostics
          end,
        },
        rumdl = {
          condition = function(ctx)
            return configured(RUMDL, ctx.filename) and rumdl_owns(ctx.filename)
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(ctx)
            return not configured(RUMDL, ctx.filename)
          end,
        },
      },
    },
  },

  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      -- none-ls registers as a primary formatter at priority 200 against
      -- conform's 100, so any none-ls source takes the whole filetype and the
      -- switching above never runs. markdownlint arrives twice for a related
      -- reason: nvim-lint already runs it, under a different diagnostic source
      -- name. Formatting and markdown diagnostics belong to conform and
      -- nvim-lint; none-ls keeps stylua, shfmt, and fish.
      opts.sources = vim.tbl_filter(function(source)
        return source.name ~= "prettier" and source.name ~= "markdownlint-cli2"
      end, opts.sources or {})

      -- Empty `filetypes` registers as `_all`, matching cspell's own coverage.
      -- none-ls attaches wherever a source is available, so this pulls its
      -- client into every named buffer; harmless, because LazyVim only treats
      -- none-ls as the primary formatter for filetypes with a formatting
      -- source, and a code action is not one.
      table.insert(opts.sources, {
        name = "cspell_add_word",
        method = require("null-ls").methods.CODE_ACTION,
        filetypes = {},
        generator = {
          fn = function(params)
            local d = cspell_diagnostic_at(params.bufnr, params.row - 1, params.col)
            local word = d and (d.user_data or {}).text
            if not word then
              return
            end
            return vim.tbl_map(function(dict)
              return {
                title = ("Add %s to cspell %s"):format(word, dict.label),
                action = function()
                  cspell_add(dict, word)
                end,
              }
            end, CSPELL_DICTS)
          end,
        },
      })
    end,
  },
}
