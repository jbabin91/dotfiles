# Intent (skill loading from npm packages)

`intent` (installed globally) discovers skills that npm packages ship under the `tanstack-intent` convention (TanStack, tRPC, Apollo and others) by reading the project's `node_modules`. In a directory with a `package.json`, once per session:

1. Run `intent list --json`. If it returns no skills, stop here.
2. If a skill clearly matches the task, run `intent load <package>#<skill>` and follow the `SKILL.md` it prints.
3. If it returned skills but neither `CLAUDE.md` nor `AGENTS.md` at the project root contains `<!-- intent-skills:start -->`, add one tip to your first response: _"Tip: this project hasn't run `intent install` yet — running it once will persist skill-loading guidance into `AGENTS.md` so future sessions skip discovery."_

# Comment policy

Comments are useful when they add value. Keep them clean and minimal.

A good comment:

- Is accurate (matches the code; remove if stale)
- Earns its place: without it, the next reader would get something wrong, or have to run or search something to learn it
- Is concise (one or two lines unless documenting a complex invariant)
- States a rule once, beside the code that enforces it; elsewhere, names that code instead of restating the rule

Avoid:

- Restating what the code does
- Section markers like `// ===== HELPERS =====`
- Hedge words, apologies, "obviously", "basically", "just"
- "Note:" / "Important:" prefixes when surrounding text already conveys importance
- TODOs without ticket references
- Cross-references that belong in the PR description ("added for X", "used by Y")
- Change-history narration ("previously", "no longer", "as it did before the refactor"); state the current invariant, and put the story in the commit message
- Multi-line comments on trivial code
- AI-flavored phrasings ("Here we...", "Let's...", "This...")
- Labels on test cases or inputs that already read clearly
- Narrating the assertion or call on the next line
- Summarizing a function short enough to read
- Facts the code holds and will change: counts, lists presented as complete, positions ("above"), the ticket a measurement came from. Point at the list or file instead; a measured version or number stays, since nothing else tells the reader

If a comment is not clearly worth keeping, delete it. A review pass never makes a comment longer.

# Fix-vs-defer policy

When addressing review findings (from the review-cycle skill, PR comments, or any other reviewer), default to fixing inline. Defer to a follow-up only if:

- The fix is substantially more work than writing the follow-up itself
- The fix requires architectural changes spanning files outside this PR scope
- The fix requires a new dependency or schema migration not in this PR
- The fix would invalidate unrelated tests

If you can describe the fix in one sentence, just do the fix. When deferring, briefly state which criterion applies.

# Working style

- **Recommend, then act.** Research output is a recommendation, never a decision. Direction and scope (what to build, which approach) need the user's explicit yes; echo their stated preference exactly, and don't treat answers to scoping questions as settling the core choice. Carrying out a recommendation nobody objected to is not a new decision: state it once with its reason and proceed. Ask again only when two readings lead to materially different work or the step is hard to reverse.
- **Make every artifact earn its place.** Don't manufacture docs, ADRs, skills, agents, config, or process that isn't pulling weight; prefer deleting or deferring over adding. If something doesn't clearly earn its place, say so instead of building it.
- **Root cause over knobs.** Lead with the zero-config fix; a new config key or a manual step is a cost to justify, not a default.
- **No `--flags` on skills or slash commands.** Take natural-language arguments: voice-to-text can't produce flags and Claude Code doesn't autocomplete them. Separate bare commands beat one command with modes.
- **Files through the file tools.** Read with Read, change with Edit or Write; use Bash for commands, not for reading or editing files (`sed -i`, `perl -i`, a script that writes files). Hooks that check edits, such as comment and settings guards, attach to Edit and Write and miss a scripted edit.

# Shell gotchas

- The Bash tool's zsh has `noclobber` on: `> existing-file` is refused and the command exits non-zero. Create files with Write, or run a script under `bash`; use `>|` only deliberately. Don't change the user's `noclobber`.
- A hook that refuses a Bash call skips all of it, a heredoc included, so a later `git commit -F file` reads a stale message at exit 0. Write the message with Write, then check `git log -1 --format='%s %G?'`.

# Version control

- For ChatGPT/Codex, omit AI attribution from commit messages and pull request titles/bodies unless explicitly requested: no AI `Co-authored-by` trailers or “Generated with/by” footers. Preserve human co-author credits, required license notices, and the user's configured Git author and signing identity. Do not rewrite existing history to remove attribution unless asked.
- Branches and commits group work by what ships and reverts together, not by session or ticket. A branch is one reviewable unit, named `<type>/<short-description>`: related fixes from one investigation, and follow-ups after review, share it as separate commits; work that needs its own revert, reviewer, or decision gets its own branch. Branches that depend on each other ship as a github/gh-stack stack, one layer per branch, bottom first; independent branches ship as parallel PRs off the default branch. Each layer carries its own bump file, opens ready for review unless asked for drafts, and merges bottom-up with `gh stack merge`. A layer comes current by `gh stack rebase` or `gh stack sync`, never by merging the default branch into it. A force push asks first and uses `--force-with-lease`; only `gh stack push`/`sync` on the job's own stack branches after a `gh stack rebase` is exempt. Each commit is one logical step that builds and passes tests (bisectable), `type(scope): summary`; refactors and behavior changes are separate commits. Under squash-merge the PR body becomes the commit on main, so it lists every change the branch carries, one line each; the branch's commits stay on the PR. Don't amend, rebase, force-push, or delete another agent's branch unless asked.
- Signals (ship ≠ push ≠ merge). Discussing shape is not authorization to push.
  - Commits need no signal. Review the uncommitted delta, then commit it as the next logical group — local only, no push, no PR. Review before every commit. Hold off when the user says so ("don't commit", "not yet") or when review leaves findings that need their decision.
  - `ship it` / `push it` — invoke `/pr-kit:ship` via the Skill tool. `ship it` publishes (first push, creates the PR); `push it` updates an open PR. Neither re-creates a PR, merges, or arms auto-merge unless asked.
  - Merge — only on an explicit ask. Green CI / review ≠ merge. Auto-merge only if asked at PR create or later.
- Never `git config` inside a repo you did not create. Isolate fixture git with `git -c …` or a command-prefix / subshell `GIT_CONFIG_GLOBAL` (not `export` — Cursor's shell keeps environment variables, and a blank global config skips `commit.gpgSign`). Before a real `git commit`, `GIT_CONFIG_GLOBAL` and `GIT_CONFIG_NOSYSTEM` are unset. After write access, check `git config --local --list` and `git log --format='%an <%ae>'` before push — a local identity survives cleanup and mis-authors commits. After the commit, `git log -1 --format='%G?'` is not `N`.
- Never `git checkout --` / `git restore` on a file with other unstaged work; restore temp mutations from a copy taken first. Measured: one `sed` revert wiped three unrelated edits.
- Beads: close at `ship it` (or on `push it` for a new follow-up bead), not at merge, then `bd dolt push`. The bead↔commit link is the `Closes <id>` trailer; history is `bd history <id> --events`. Until merge, Dolt says closed while main lacks the code, so don't start dependents from `bd ready` early.

# CI

- Gate branch protection on one aggregate "CI Summary" job that `needs:` every other job (`if: always()`, fails on failure or cancelled only), never on individual job contexts. A new job missing from `needs:` is invisible to the gate.

# Evidence policy

A claim about what a command does cites a run of that command.

A manifest, config file, lockfile, script entry, CI workflow, or flag in documentation says what someone configured or intended. It does not say what the tool does with it, and the two disagree often enough that the gap is where wrong claims come from. `doctest = false` in a Cargo manifest does not stop `cargo test --doc` from running the doctests — cargo compiles the crate and runs them anyway, and the flag only removes them from plain `cargo test`. A `skip` in a workflow does not prove the job was skipped on this run, and a `package.json` script does not prove what the script does when invoked. A declaration is never evidence for behavior.

- Run it, then quote what it printed. Name the command and the observed output, not the file you read it from.
- A run you did not observe is not a run. A stale file, a redirect the shell refused, a cached artifact, and a job that skipped all look like success from a distance — check that what you are reading came from the invocation you just made.
- When you cannot run it, say so. A claim the environment cannot exercise — another OS, another shell, a remote service — is labeled inferred rather than measured, or verified against authoritative documentation. Never state it flatly.
- Dated or external claims (versions, prices, "latest", tool behavior) get checked against current sources before you state them.
- A green test proves nothing until mutating the guard it names makes that test fail. Ask what else could satisfy its assertion.

A claim whose measurement was merely out of budget keeps its place, labeled inferred. A claim about tool behavior that nobody exercised and nothing documents is not a weak claim but a question — ask it rather than asserting it.

# Reference docs

Read the linked file before acting when its trigger applies:

- Creating a new open-source project, repo or package name: [~/.agents/docs/oakoss.md](~/.agents/docs/oakoss.md)
- Choosing or setting up a tool that drives Claude Code (orchestrators, SDK harnesses, CI agents): [~/.agents/docs/claude-code-billing.md](~/.agents/docs/claude-code-billing.md)
