import { spawnSync } from 'node:child_process';
import {
  existsSync,
  lstatSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  symlinkSync,
  writeFileSync,
} from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect } from 'vitest';

import { test } from './helpers/fixture.ts';

const SCRIPT = join(
  dirname(fileURLToPath(import.meta.url)),
  '..',
  'home',
  'run_before_claude-md-seed.sh',
);

function seed(home: string) {
  return spawnSync('/bin/sh', [SCRIPT], {
    env: { HOME: home, PATH: '/usr/bin:/bin' },
    encoding: 'utf8',
  });
}

describe('run_before_claude-md-seed.sh', () => {
  test('creates CLAUDE.md importing ~/AGENTS.md when it is missing', ({ fixture }) => {
    const f = fixture();
    const r = seed(f.home);
    expect(r.status).toBe(0);
    expect(r.stdout).toContain('claude: created ~/.claude/CLAUDE.md importing ~/AGENTS.md');
    expect(readFileSync(join(f.home, '.claude', 'CLAUDE.md'), 'utf8')).toMatch(
      /\n@~\/AGENTS\.md\n$/,
    );
  });

  // Claude-only rules live in this file; a broken guard would overwrite them.
  test('leaves an existing CLAUDE.md untouched', ({ fixture }) => {
    const f = fixture({ home: { '.claude/CLAUDE.md': 'mine\n' } });
    const r = seed(f.home);
    expect(r.status).toBe(0);
    expect(r.stdout).toBe('');
    expect(readFileSync(join(f.home, '.claude', 'CLAUDE.md'), 'utf8')).toBe('mine\n');
  });

  test('warns without failing the apply when it cannot write', ({ fixture }) => {
    const f = fixture({ home: { '.claude': 'not a directory\n' } });
    const r = seed(f.home);
    expect(r.status).toBe(0);
    expect(r.stderr).toContain('claude: could not create');
  });

  test('leaves no partial CLAUDE.md behind when the write fails', ({ fixture }) => {
    const f = fixture();
    const stubs = join(f.dir, 'failing-mv');
    mkdirSync(stubs);
    writeFileSync(join(stubs, 'mv'), '#!/bin/sh\nexit 1\n', { mode: 0o755 });
    const r = spawnSync('/bin/sh', [SCRIPT], {
      env: { HOME: f.home, PATH: `${stubs}:/usr/bin:/bin` },
      encoding: 'utf8',
    });
    expect(r.status).toBe(0);
    expect(r.stderr).toContain('claude: could not create');
    // Empty, so the next apply seeds it again rather than keeping a fragment.
    expect(readdirSync(join(f.home, '.claude'))).toEqual([]);
  });

  test('leaves a dangling CLAUDE.md link alone rather than writing through it', ({ fixture }) => {
    const f = fixture();
    const target = join(f.dir, 'elsewhere', 'CLAUDE.md');
    mkdirSync(dirname(target), { recursive: true });
    mkdirSync(join(f.home, '.claude'));
    symlinkSync(target, join(f.home, '.claude', 'CLAUDE.md'));
    const r = seed(f.home);
    expect(r.status).toBe(0);
    expect(r.stdout).toBe('');
    expect(lstatSync(join(f.home, '.claude', 'CLAUDE.md')).isSymbolicLink()).toBe(true);
    expect(existsSync(target)).toBe(false);
  });
});
