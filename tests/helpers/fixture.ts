import { spawnSync } from 'node:child_process';
import { cpSync, mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { test as base } from 'vitest';

const REPO = join(dirname(fileURLToPath(import.meta.url)), '..', '..');

/** Files `./install` needs, copied so a test that writes cannot reach the real repo. */
const REPO_FILES = ['install', 'install.conf.yaml', '.chezmoiroot', 'home'];

/**
 * dotbot must never actually run: it deploys symlinks, runs brew bundle and
 * installs mise. It does resolve the `-c` config the way dotbot would, so a
 * script that failed to anchor its own cwd is caught rather than passing on a
 * stub that ignores its arguments.
 */
const NOOP_UV = `#!/bin/sh
printf '%s\\n' "$@" > "$(dirname "$0")/../uv-args"
while [ "$#" -gt 0 ]; do
  case "$1" in
    -c) [ -f "$2" ] || { echo "stub uv: config not found from $(pwd): $2" >&2; exit 2; }; shift ;;
  esac
  shift
done
exit 0
`;

export type RunResult = {
  status: number | null;
  signal: NodeJS.Signals | null;
  stdout: string;
  stderr: string;
};

export type FixtureOptions = {
  /** Raw bytes for `.chezmoiroot`; nothing normalizes them on the way in. */
  chezmoiroot?: string;
  omitChezmoiroot?: boolean;
  /** Executables placed first on the child's PATH, keyed by command name. */
  stubs?: Record<string, string>;
  /** Files seeded into the fixture HOME, keyed by path relative to it. */
  home?: Record<string, string>;
  /** Copy the installed chezmoi onto the fixture PATH instead of stubbing it. */
  useRealChezmoi?: boolean;
};

export type Fixture = {
  dir: string;
  repo: string;
  home: string;
  stubDir: string;
  stub: (name: string, body: string) => string;
  run: (args?: string[], env?: Record<string, string | undefined>) => RunResult;
  cleanup: () => void;
};

/**
 * Builds an isolated tree and returns a runner for `./install`.
 *
 * The child gets an explicit `env` rather than an inherited one — the equivalent
 * of `env -i`. Without it the real `$HOME`, the real chezmoi on PATH and mise's
 * shims leak in, and the result means nothing.
 */
export function createFixture(opts: FixtureOptions = {}): Fixture {
  const dir = mkdtempSync(join(tmpdir(), 'dotfiles-test-'));
  const repo = join(dir, 'repo');
  const home = join(dir, 'home');
  const stubDir = join(dir, 'stub');

  for (const d of [repo, home, stubDir]) mkdirSync(d, { recursive: true });
  for (const name of REPO_FILES) {
    cpSync(join(REPO, name), join(repo, name), { recursive: true });
  }

  if (opts.omitChezmoiroot) {
    rmSync(join(repo, '.chezmoiroot'), { force: true });
  } else if (opts.chezmoiroot !== undefined) {
    writeFileSync(join(repo, '.chezmoiroot'), opts.chezmoiroot);
  }

  const stub = (name: string, body: string): string => {
    const path = join(stubDir, name);
    writeFileSync(path, body, { mode: 0o755 });
    return path;
  };

  stub('uv', NOOP_UV);
  if (opts.useRealChezmoi) {
    const real = realChezmoi();
    if (!real) throw new Error('useRealChezmoi: no working chezmoi on PATH');
    // Symlinked, not copied: it is ~38MB and code-signed, and a freshly copied
    // signed Mach-O intermittently fails to exec on macOS.
    symlinkSync(real, join(stubDir, 'chezmoi'));
  }
  for (const [name, body] of Object.entries(opts.stubs ?? {})) stub(name, body);

  for (const [rel, body] of Object.entries(opts.home ?? {})) {
    const target = join(home, rel);
    mkdirSync(dirname(target), { recursive: true });
    writeFileSync(target, body);
  }

  return {
    dir,
    repo,
    home,
    stubDir,
    stub,
    run(args: string[] = [], env: Record<string, string | undefined> = {}): RunResult {
      // Built explicitly, never inherited. An `undefined` value drops the
      // variable, which is how the $HOME-unset case is expressed.
      const base: Record<string, string | undefined> = {
        HOME: home,
        PATH: `${stubDir}:/usr/bin:/bin`,
        ...env,
      };
      const childEnv = Object.fromEntries(
        Object.entries(base).filter((entry): entry is [string, string] => entry[1] !== undefined),
      );
      const result = spawnSync('/bin/bash', [join(repo, 'install'), ...args], {
        env: childEnv,
        encoding: 'utf8',
        // Deliberately not the repo: `install` resolves CONFIG relative to its
        // own cwd, so running from elsewhere proves its `cd` is doing the work.
        cwd: dir,
      });
      return {
        status: result.status,
        signal: result.signal,
        stdout: result.stdout ?? '',
        stderr: result.stderr ?? '',
      };
    },
    cleanup() {
      rmSync(dir, { recursive: true, force: true });
    },
  };
}

/** Path to a working chezmoi, or null when none is installed. */
export function realChezmoi(): string | null {
  const found = spawnSync('/bin/sh', ['-c', 'command -v chezmoi'], { encoding: 'utf8' });
  const path = (found.stdout ?? '').trim();
  if (!path) return null;
  return spawnSync(path, ['--version'], { encoding: 'utf8' }).status === 0 ? path : null;
}

export type ChezmoiBehaviour = {
  version?: string;
  init?: string;
  verify?: string;
};

/**
 * A chezmoi stub. Each key maps a subcommand to the shell run when it is called;
 * anything unlisted exits 0, matching real chezmoi for the calls install makes.
 */
export function chezmoiStub(behaviour: ChezmoiBehaviour = {}): string {
  const arm = (name: string, body?: string) => (body ? `  ${name}) ${body} ;;\n` : '');
  return (
    '#!/bin/sh\ncase "$1" in\n' +
    arm('--version', behaviour.version ?? 'echo "chezmoi version v0.0.0-stub"; exit 0') +
    arm('init', behaviour.init) +
    arm('verify', behaviour.verify) +
    'esac\nexit 0\n'
  );
}

/**
 * `test` with a `fixture` factory injected. Cleanup is registered by the
 * fixture rather than a module-level afterEach, so it stays correct if these
 * ever run concurrently, and it only builds anything for tests that ask for it.
 */
export const test = base.extend<{ fixture: (opts?: FixtureOptions) => Fixture }>({
  fixture: async ({ task }, use) => {
    const made: Fixture[] = [];

    await use((opts?: FixtureOptions) => {
      const created = createFixture(opts);
      made.push(created);
      return created;
    });

    // A failure's evidence is the tree itself -- the fixture HOME, the stubs
    // and what the run left behind. Deleting it hands CI an assertion message
    // and nothing to inspect.
    // `task.result`, not `onTestFailed`: measured, the latter does not fire when
    // registered from a fixture's scope.
    const broke = task.result?.state === 'fail';
    for (const created of made) {
      if (broke) console.error(`fixture kept for inspection: ${created.dir}`);
      else created.cleanup();
    }
  },
});
