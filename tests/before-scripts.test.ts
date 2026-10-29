import { spawnSync } from 'node:child_process';
import {
  chmodSync,
  existsSync,
  lstatSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  readlinkSync,
  symlinkSync,
  writeFileSync,
} from 'node:fs';
import { dirname, join, relative } from 'node:path';
import { describe, expect } from 'vitest';

import { type Fixture, REPO, test, withChezmoi } from './helpers/fixture.ts';

withChezmoi('dead-link sweep', () => {
  test('removes dead links into the repo and leaves every other link', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    mkdirSync(join(f.home, '.config/tool'), { recursive: true });
    const links = {
      top: join(f.home, '.gone'),
      nested: join(f.home, '.config/tool/gone.conf'),
      relative: join(f.home, '.config/rel'),
      parentGone: join(f.home, '.config/parent-gone'),
      chain: join(f.home, '.chain'),
      hop: join(f.home, '.config/hop'),
      foreign: join(f.home, '.config/foreign'),
      sibling: join(f.home, '.config/sibling'),
      escapes: join(f.home, '.config/escapes'),
      outward: join(f.home, '.config/outward'),
      danglingDotdot: join(f.home, '.config/dangling-dotdot'),
      live: join(f.home, '.config/live'),
      deep: join(f.home, 'Library/gone'),
    };
    mkdirSync(join(f.home, 'Library'));
    symlinkSync(join(f.repo, 'config/moved'), links.top);
    symlinkSync(join(f.repo, 'config/tool/gone.conf'), links.nested);
    symlinkSync(relative(dirname(links.relative), join(f.repo, 'gone')), links.relative);
    symlinkSync(
      relative(dirname(links.parentGone), join(f.repo, 'deleted-dir/gone')),
      links.parentGone,
    );
    symlinkSync(links.hop, links.chain);
    symlinkSync(join(f.repo, 'missing'), links.hop);
    symlinkSync(join(f.dir, 'elsewhere'), links.foreign);
    symlinkSync(`${f.repo}-old/gone`, links.sibling);
    // Concatenated: join() would fold the `..` before the link ever held it.
    symlinkSync(`${f.repo}/deleted-dir/../../elsewhere`, links.escapes);
    // Folding the `..` exposes repo/escape, which leads out of the repo.
    symlinkSync(join(f.dir, 'elsewhere'), join(f.repo, 'escape'));
    symlinkSync(`${f.repo}/deleted-dir/../escape/gone`, links.outward);
    // The `..` applies to where the dangling repo/escape leads, not to repo.
    symlinkSync(`${f.repo}/escape/../gone`, links.danglingDotdot);
    symlinkSync(join(f.repo, 'install'), links.live);
    // The sweep covers ~ itself but no subdirectory other than ~/.config.
    symlinkSync(join(f.repo, 'gone'), links.deep);

    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    const left = Object.entries(links)
      .filter(([, p]) => lstatSync(p, { throwIfNoEntry: false }))
      .map(([name]) => name);
    expect(left).toEqual([
      'foreign',
      'sibling',
      'escapes',
      'outward',
      'danglingDotdot',
      'live',
      'deep',
    ]);
    expect(r.stdout).toContain(`removed dead link ${links.top}`);
  });

  test('leaves a chezmoi symlink_ entry whose target is missing to chezmoi', ({ fixture }) => {
    // The fixture copies no config/kitty, so ~/.config/kitty deploys dead.
    // Deleting it would make the next apply stop and ask about it. A clean
    // second apply also covers ./install being idempotent.
    const f = fixture({ useRealChezmoi: true });
    expect(f.run().status).toBe(0);
    const second = f.run();
    expect(second.stderr).toBe('');
    expect(second.status).toBe(0);
    expect(readlinkSync(join(f.home, '.config/kitty'))).toBe(join(f.repo, 'config/kitty'));
  });

  test('warns about a link it cannot remove and still deploys', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const locked = join(f.home, '.config/locked');
    mkdirSync(locked, { recursive: true });
    symlinkSync(join(f.repo, 'gone'), join(locked, 'dead'));
    chmodSync(locked, 0o555);
    try {
      const r = f.run();
      expect(r.stderr).toContain(`could not remove ${join(locked, 'dead')}`);
      expect(r.status).toBe(0);
      expect(existsSync(join(f.home, '.zshrc'))).toBe(true);
    } finally {
      chmodSync(locked, 0o755);
    }
  });

  test('refuses to run without chezmoi', () => {
    const r = spawnSync('/bin/zsh', [join(REPO, 'home/run_before_dead-links.zsh')], {
      env: { HOME: '/nonexistent', PATH: '/usr/bin:/bin' },
      encoding: 'utf8',
      // Without the guard the source glob walks the whole filesystem.
      timeout: 10_000,
    });
    expect(r.status).not.toBe(0);
    expect(r.stderr).toContain('CHEZMOI_SOURCE_DIR: is unset');
  });

  test('runs before the install scripts, so a failing one cannot skip it', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    f.stub('brew', '#!/bin/sh\nexit 1\n');
    const link = join(f.home, '.gone');
    symlinkSync(join(f.repo, 'gone'), link);
    expect(f.run().status).toBe(1);
    expect(lstatSync(link, { throwIfNoEntry: false })).toBeUndefined();
  });
});

const KARABINER = '.config/karabiner/karabiner.json';
const repoCopy = (f: Fixture) => join(f.repo, 'config', 'karabiner', 'karabiner.json');
const withRepoCopy = (f: Fixture) => {
  mkdirSync(dirname(repoCopy(f)), { recursive: true });
  writeFileSync(repoCopy(f), '{"repo":1}\n');
};

/** Runs the sync script the way chezmoi does, without an apply around it. */
const sync = (f: Fixture, env: Record<string, string> = {}) =>
  spawnSync('/bin/sh', [join(f.repo, 'home/run_before_karabiner-sync.sh')], {
    env: { HOME: f.home, CHEZMOI_SOURCE_DIR: join(f.repo, 'home'), PATH: '/usr/bin:/bin', ...env },
    encoding: 'utf8',
  });

withChezmoi('before-scripts during an apply', () => {
  test('sync a changed live Karabiner config into the repo, then stay quiet', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true, home: { [KARABINER]: '{"live":1}\n' } });
    withRepoCopy(f);
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(r.stdout).toContain('karabiner: live → dotfiles');
    expect(readFileSync(repoCopy(f), 'utf8')).toBe('{"live":1}\n');
    expect(f.run().stdout).not.toContain('karabiner');
  });

  test('a failed Karabiner sync still lets the apply deploy', ({ fixture }) => {
    // The sync tests below assert its exit 0; this one that chezmoi carries on.
    const f = fixture({ useRealChezmoi: true, home: { '.config/karabiner': 'not a directory\n' } });
    withRepoCopy(f);
    const r = f.run();
    expect(r.stderr).toContain('karabiner: could not sync');
    expect(r.status).toBe(0);
    expect(existsSync(join(f.home, '.zshrc'))).toBe(true);
  });

  test('seed ~/.claude/CLAUDE.md', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(r.stdout).toContain('claude: created ~/.claude/CLAUDE.md');
    expect(readFileSync(join(f.home, '.claude/CLAUDE.md'), 'utf8')).toContain('@~/AGENTS.md');
  });
});

describe('Karabiner sync', () => {
  test('seeds the config from the repo when none is live', ({ fixture }) => {
    const f = fixture();
    withRepoCopy(f);
    const r = sync(f);
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(r.stdout).toContain('karabiner: dotfiles → live (bootstrap)');
    expect(lstatSync(join(f.home, KARABINER)).isSymbolicLink()).toBe(false);
    expect(readFileSync(join(f.home, KARABINER), 'utf8')).toBe('{"repo":1}\n');
  });

  test('replaces a leftover link instead of writing through it', ({ fixture }) => {
    const f = fixture();
    withRepoCopy(f);
    mkdirSync(join(f.home, '.config/karabiner'), { recursive: true });
    symlinkSync(repoCopy(f), join(f.home, KARABINER));
    const r = sync(f);
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(lstatSync(join(f.home, KARABINER)).isSymbolicLink()).toBe(false);
    expect(readFileSync(repoCopy(f), 'utf8')).toBe('{"repo":1}\n');
  });

  test('a failed copy warns without failing the apply', ({ fixture }) => {
    const f = fixture({ home: { '.config/karabiner': 'not a directory\n' } });
    withRepoCopy(f);
    const r = sync(f);
    expect(r.stderr).toContain('karabiner: could not sync');
    expect(r.status).toBe(0);
  });

  test('keeps a working link when its replacement cannot be read', ({ fixture }) => {
    const f = fixture({ home: { 'elsewhere.json': '{"else":1}\n' } });
    withRepoCopy(f);
    chmodSync(repoCopy(f), 0o000);
    mkdirSync(join(f.home, '.config/karabiner'), { recursive: true });
    symlinkSync(join(f.home, 'elsewhere.json'), join(f.home, KARABINER));
    try {
      const r = sync(f);
      expect(r.stderr).toContain('karabiner: could not sync');
      expect(r.status).toBe(0);
      expect(readFileSync(join(f.home, KARABINER), 'utf8')).toBe('{"else":1}\n');
      expect(readdirSync(join(f.home, '.config/karabiner'))).toEqual(['karabiner.json']);
    } finally {
      chmodSync(repoCopy(f), 0o644);
    }
  });

  test('warns instead of copying into a directory at the config path', ({ fixture }) => {
    const f = fixture();
    withRepoCopy(f);
    mkdirSync(join(f.home, KARABINER), { recursive: true });
    const r = sync(f);
    expect(r.stderr).toContain('karabiner: could not sync');
    expect(r.status).toBe(0);
    expect(readdirSync(join(f.home, KARABINER))).toEqual([]);
  });

  test('does not copy an empty live config over the repo', ({ fixture }) => {
    const f = fixture({ home: { [KARABINER]: '' } });
    withRepoCopy(f);
    const r = sync(f);
    expect(r.stderr).toContain('is empty');
    expect(r.status).toBe(0);
    expect(readFileSync(repoCopy(f), 'utf8')).toBe('{"repo":1}\n');
  });

  test('refuses to run without chezmoi', () => {
    const r = spawnSync('/bin/sh', [join(REPO, 'home/run_before_karabiner-sync.sh')], {
      env: { HOME: '/nonexistent', PATH: '/usr/bin:/bin' },
      encoding: 'utf8',
    });
    expect(r.status).not.toBe(0);
    expect(r.stderr).toContain('CHEZMOI_SOURCE_DIR: is unset');
  });
});
