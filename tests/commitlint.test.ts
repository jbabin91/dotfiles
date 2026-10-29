import { spawnSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, test } from 'vitest';

const REPO = join(dirname(fileURLToPath(import.meta.url)), '..');

// Loaded the way commitlint loads it -- in a child node, from the repo root --
// rather than imported here, which would need a declaration file for a config
// that deliberately has none.
function scopes(): string[] {
  const r = spawnSync(
    process.execPath,
    [
      '--input-type=module',
      '-e',
      "import c from './.commitlintrc.js'; process.stdout.write(JSON.stringify(c.prompt.scopes));",
    ],
    // Built, not inherited: NODE_OPTIONS in the ambient environment prints to
    // stderr, which this asserts is empty.
    { cwd: REPO, encoding: 'utf8', env: { PATH: '/usr/bin:/bin' } },
  );
  expect(r.stderr).toBe('');
  expect(r.status).toBe(0);
  return JSON.parse(r.stdout) as string[];
}

describe('commitlint scope derivation', () => {
  // The cz-git prompt sets allowCustomScopes: false, so a name missing here is
  // a name the prompt rejects. Migrating a tool between the two config roots
  // used to drop its scope silently -- measured, six vanished in one move.
  test('covers tools under both config roots', () => {
    const s = scopes();
    expect(s).toEqual(
      expect.arrayContaining(['kitty', 'ghostty', 'brew', 'cspell', 'deps', 'git']),
    );
  });

  test('carries no duplicates across the two roots', () => {
    // `git` is both an explicit entry and a directory under home/dot_config.
    const s = scopes();
    expect(s).toContain('git');
    expect(new Set(s).size).toBe(s.length);
  });
});
