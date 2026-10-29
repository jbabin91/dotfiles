import { spawnSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, test } from 'vitest';

const ZSHRC = join(dirname(fileURLToPath(import.meta.url)), '..', 'home', 'dot_zshrc');
const CHILD_PATH = '/usr/bin:/bin';
const hasZsh =
  spawnSync('/bin/sh', ['-c', 'command -v zsh'], { env: { PATH: CHILD_PATH }, encoding: 'utf8' })
    .status === 0;

// Only the function, not the whole file: sourcing .zshrc loads antidote and
// every plugin, which a test environment does not have.
const LS_FN = (() => {
  const src = readFileSync(ZSHRC, 'utf8');
  const start = src.indexOf('function ls {');
  return src.slice(start, src.indexOf('\n}\n', start) + 2);
})();

/** Runs `ls -a src` with stdin on /dev/null; stub eza and ls report which ran. */
function lsWithoutTty(): string {
  const dir = mkdtempSync(join(tmpdir(), 'zshrc-test-'));
  try {
    const bin = join(dir, 'bin');
    mkdirSync(bin);
    for (const name of ['eza', 'ls']) {
      writeFileSync(join(bin, name), `#!/bin/sh\necho "${name} $*"\n`, { mode: 0o755 });
    }
    const r = spawnSync('zsh', ['-f', '-c', `${LS_FN}\nls -a src </dev/null`], {
      env: { PATH: `${bin}:${CHILD_PATH}` },
      encoding: 'utf8',
    });
    return (r.stdout ?? '').trim();
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

describe.skipIf(!hasZsh)('ls', () => {
  test('falls back to the system ls when stdin is not a terminal', () => {
    expect(LS_FN).toContain('function ls {');
    expect(lsWithoutTty()).toBe('ls -a src');
  });
});
