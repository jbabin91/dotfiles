import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, test as base } from 'vitest';

// Overridable so mutation runs can point at a copy instead of the real file.
const ZSHENV =
  process.env.DOTFILES_ZSHENV ??
  join(dirname(fileURLToPath(import.meta.url)), '..', 'home', 'dot_zshenv');

// Probed with the PATH the child is given, not the inherited one: otherwise a
// zsh that exists only in /opt/homebrew/bin reports "present" and the child
// then fails on a confusing PATH assertion instead of skipping.
const CHILD_PATH = '/usr/bin:/bin';
const hasZsh =
  spawnSync('/bin/sh', ['-c', 'command -v zsh'], {
    env: { PATH: CHILD_PATH },
    encoding: 'utf8',
  }).status === 0;

type Sourced = { status: number | null; path: string[]; stderr: string; home: string };

type MiseStub = string | ((home: string) => string) | null;

const test = base.extend<{ sourceZshenv: (miseStub: MiseStub) => Sourced }>({
  sourceZshenv: async ({ task }, use) => {
    const dirs: string[] = [];
    await use((miseStub: MiseStub) => {
      const dir = mkdtempSync(join(tmpdir(), 'zshenv-test-'));
      dirs.push(dir);
      const home = join(dir, 'home');
      const bin = join(home, '.local', 'bin');
      mkdirSync(bin, { recursive: true });
      if (miseStub !== null) {
        const body = typeof miseStub === 'function' ? miseStub(home) : miseStub;
        writeFileSync(join(bin, 'mise'), body, { mode: 0o755 });
      }

      // `print -r --` rather than echo: a PATH entry could contain a backslash.
      const result = spawnSync(
        'zsh',
        ['-c', `source ${JSON.stringify(ZSHENV)} >/dev/null; print -r -- "$PATH"`],
        { env: { HOME: home, PATH: CHILD_PATH }, encoding: 'utf8' },
      );
      return {
        home,
        status: result.status,
        path: (result.stdout ?? '').trim().split(':'),
        stderr: result.stderr ?? '',
      };
    });
    // Same policy as the install fixture: a failure's evidence is the tree.
    for (const dir of dirs) {
      if (task.result?.state === 'fail') console.error(`fixture kept for inspection: ${dir}`);
      else rmSync(dir, { recursive: true, force: true });
    }
  },
});

/** A mise that activates normally: `activate zsh --shims` prints a PATH export. */
const workingMise = (home: string) => `#!/bin/sh
case "$1 $2" in
  "activate zsh") printf 'export PATH="%s/.local/share/mise/shims:$PATH"\\n' "${home}" ;;
esac
exit 0
`;

/** Prints half an export, then fails. The `&&` is what stops eval running it. */
const crashingMise = `#!/bin/sh
case "$1 $2" in
  "activate zsh") printf 'export PATH="/injected'; exit 1 ;;
esac
exit 0
`;

/** A truncated mise: still executable, prints nothing, exits 0 on every call. */
const silentMise = '#!/bin/sh\nexit 0\n';

/** Activates normally, but writes a warning containing a command substitution. */
const noisyMise = (home: string) => `#!/bin/sh
case "$1 $2" in
  "activate zsh")
    printf 'export PATH="%s/.local/share/mise/shims:$PATH"\\n' "${home}"
    echo 'mise WARN  missing: \`touch ${home}/EXECUTED\`' >&2
    ;;
esac
exit 0
`;

describe.skipIf(!hasZsh)('dot_zshenv PATH construction', () => {
  test('puts ~/.local/bin ahead of the system path, not merely on it', ({ sourceZshenv }) => {
    // Appending instead of prepending still satisfies "is on PATH", while
    // letting a system-packaged tool outrank a uv-installed one.
    const r = sourceZshenv(silentMise);
    expect(r.status).toBe(0);
    const local = r.path.findIndex((p) => p.endsWith('/.local/bin'));
    expect(local).toBeGreaterThanOrEqual(0);
    expect(local).toBeLessThan(r.path.indexOf('/usr/bin'));
  });

  test('activates mise, and the shims outrank ~/.local/bin', ({ sourceZshenv }) => {
    // The ordering is the whole point: ~/.local/bin must come first so `mise`
    // is found at all, and activation then prepends the shims ahead of it.
    const r = sourceZshenv(workingMise);
    expect(r.status).toBe(0);
    const shims = r.path.findIndex((p) => p.endsWith('/.local/share/mise/shims'));
    const local = r.path.findIndex((p) => p.endsWith('/.local/bin'));
    expect(shims).toBeGreaterThanOrEqual(0);
    expect(shims).toBeLessThan(local);
  });

  test('reports on stderr when mise runs but does not activate', ({ sourceZshenv }) => {
    // The measured failure: a truncated mise stays executable, prints nothing
    // and exits 0, so every pinned tool silently drops to its system version.
    // Only PATH distinguishes that from a successful no-op activation.
    const r = sourceZshenv(silentMise);
    expect(r.status).toBe(0);
    expect(r.stderr).toContain('mise did not activate');
    expect(r.path.some((p) => p.endsWith('/.local/share/mise/shims'))).toBe(false);
  });

  test('does not evaluate what mise writes to stderr', ({ sourceZshenv }) => {
    // The capture redirects stderr to /dev/null because its output is eval'd:
    // real mise warnings carry backticks (`missing: \`node@24\``), so folding
    // stderr into the capture would run them as shell in every shell started.
    const r = sourceZshenv(noisyMise);
    expect(r.status).toBe(0);
    expect(existsSync(join(r.home, 'EXECUTED'))).toBe(false);
    expect(r.path.some((p) => p.endsWith('/.local/share/mise/shims'))).toBe(true);
  });

  test('does not eval a partial line when mise exits nonzero', ({ sourceZshenv }) => {
    const r = sourceZshenv(crashingMise);
    expect(r.status).toBe(0);
    expect(r.path.some((p) => p.includes('/injected'))).toBe(false);
  });

  test('says nothing when mise is absent entirely', ({ sourceZshenv }) => {
    const r = sourceZshenv(null);
    expect(r.status).toBe(0);
    expect(r.stderr).not.toContain('mise did not activate');
  });
});

const VARS = ['FORCE_COLOR', 'GIT_EDITOR', 'GIT_SEQUENCE_EDITOR', 'RIPGREP_CONFIG_PATH'] as const;

/** Sources dot_zshenv with stdout on a pipe and reports each of VARS, or null when unset. */
function sourceWithoutTty(
  env: Record<string, string> = {},
  home?: (home: string) => void,
): Record<(typeof VARS)[number], string | null> {
  const dir = mkdtempSync(join(tmpdir(), 'zshenv-test-'));
  try {
    const homeDir = join(dir, 'home');
    mkdirSync(homeDir);
    home?.(homeDir);
    const report = VARS.map((v) => `print -r -- "\${${v}+set:}\${${v}}"`).join('; ');
    const r = spawnSync('zsh', ['-c', `source ${JSON.stringify(ZSHENV)} >/dev/null; ${report}`], {
      env: { HOME: homeDir, PATH: CHILD_PATH, ...env },
      encoding: 'utf8',
    });
    const lines = (r.stdout ?? '').split('\n');
    return Object.fromEntries(
      VARS.map((v, i) => [v, lines[i]?.startsWith('set:') ? lines[i].slice(4) : null]),
    ) as Record<(typeof VARS)[number], string | null>;
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

describe.skipIf(!hasZsh)('dot_zshenv without a terminal', () => {
  test('leaves FORCE_COLOR unset, so tools keep escapes out of pipes', () => {
    expect(sourceWithoutTty().FORCE_COLOR).toBeNull();
  });

  test('keeps an explicit FORCE_COLOR', () => {
    expect(sourceWithoutTty({ FORCE_COLOR: '0' }).FORCE_COLOR).toBe('0');
  });

  test('makes git fail fast instead of opening an editor nobody can see', () => {
    const r = sourceWithoutTty();
    expect(r.GIT_EDITOR).toBe('false');
    expect(r.GIT_SEQUENCE_EDITOR).toBe('false');
  });

  test('keeps an editor the caller set', () => {
    const r = sourceWithoutTty({ GIT_EDITOR: 'true', GIT_SEQUENCE_EDITOR: 'true' });
    expect(r.GIT_EDITOR).toBe('true');
    expect(r.GIT_SEQUENCE_EDITOR).toBe('true');
  });

  test('exports RIPGREP_CONFIG_PATH only when ~/.rgrc exists', () => {
    expect(sourceWithoutTty().RIPGREP_CONFIG_PATH).toBeNull();
    const withRc = sourceWithoutTty({}, (h) => writeFileSync(join(h, '.rgrc'), ''));
    expect(withRc.RIPGREP_CONFIG_PATH).toMatch(/\/home\/\.rgrc$/);
  });
});
