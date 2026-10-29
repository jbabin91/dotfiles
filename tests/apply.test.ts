import { spawnSync } from 'node:child_process';
import {
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  readlinkSync,
  rmSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import { join, relative } from 'node:path';
import { expect } from 'vitest';

import { CHEZMOI, REPO, test, withChezmoi } from './helpers/fixture.ts';

withChezmoi('against a real chezmoi', () => {
  test('deploys every managed file into an empty $HOME', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    for (const rel of [
      '.zshrc',
      '.zshenv',
      '.config/starship.toml',
      '.editorconfig',
      '.gitattributes',
      '.gitconfig',
      '.gitignore',
      '.config/git/allowed_signers',
      '.config/git/template.txt',
      '.config/bat/config',
      '.config/fastfetch/config.jsonc',
      '.config/fff-gpui/config.toml',
      '.config/sesh/sesh.toml',
      '.config/ghostty/config',
      '.config/ghostty/font/monolisa',
      // Ghostty names its opacity fragments 70% through 100%; chezmoi has no
      // attribute prefix for a percent sign, but the name survives a round
      // trip only if nothing along the way treats it as a format specifier.
      '.config/ghostty/opacity/95%',
      '.config/ghostty/font/jetbrains-mono',
      '.config/ghostty/font/victor',
      '.config/ghostty/opacity/70%',
      '.config/ghostty/opacity/75%',
      '.config/ghostty/opacity/80%',
      '.config/ghostty/opacity/85%',
      '.config/ghostty/opacity/90%',
      '.config/ghostty/opacity/100%',
      '.config/zsh/.zsh_plugins.txt',
      '.config/zellij/layouts/default.kdl',
      '.config/zellij/layouts/claude-orch.kdl',
      '.config/tmux/tmux.conf',
      '.config/tmux/scripts/sesh-connect.sh',
      '.config/tmux/scripts/session-kill.sh',
      '.config/tmux/plugins/tmux-which-key/config.yaml',
    ]) {
      expect(existsSync(join(f.home, rel)), rel).toBe(true);
    }
    // The size, not only existence: a source that stops being empty deploys a
    // non-empty ~/.hushlogin, which an existence check passes.
    expect(statSync(join(f.home, '.hushlogin')).size).toBe(0);
    // tmux.conf runs these with run-shell; chezmoi sets the bit only from the
    // executable_ prefix, not from the source file's mode.
    for (const script of ['sesh-connect.sh', 'session-kill.sh']) {
      expect(statSync(join(f.home, '.config/tmux/scripts', script)).mode & 0o111, script).not.toBe(
        0,
      );
    }
  });

  test('deploys every managed file byte-identical to its source', ({ fixture }) => {
    // Existence proves a path was written, not what landed there. Measured:
    // a source that renders to different non-empty bytes deploys and passes
    // every existence assertion above. chezmoi supplies the target-to-source
    // map, so the attribute prefixes are never re-implemented here.
    const f = fixture({ useRealChezmoi: true });
    expect(f.run().status).toBe(0);
    const listing = spawnSync(
      CHEZMOI!,
      [
        'managed',
        '--source',
        join(f.repo, 'home'),
        '--destination',
        f.home,
        '--config',
        join(f.home, '.config', 'chezmoi', 'chezmoi.toml'),
        '--include=files',
        '--path-style=all',
        '--format=json',
      ],
      // Built, not inherited, like every other child here: an unpinned --config
      // still reads $HOME/.config/chezmoi/chezmoi.toml, so an unparseable one
      // on the developer's machine fails this test for an unrelated reason.
      { encoding: 'utf8', env: { HOME: f.home, PATH: `${f.stubDir}:/usr/bin:/bin` } },
    );
    expect(listing.status).toBe(0);
    const managed = JSON.parse(listing.stdout) as Record<
      string,
      { absolute: string; sourceAbsolute: string }
    >;
    expect(Object.keys(managed).length).toBeGreaterThan(0);
    // No .tmpl exemption on purpose: nothing here is templated, so this also
    // pins that, and a future template has to be allowlisted deliberately --
    // a template being exactly the thing that can change content in transit.
    const mangled = Object.entries(managed)
      .filter(([, p]) => !readFileSync(p.absolute).equals(readFileSync(p.sourceAbsolute)))
      .map(([target]) => target);
    expect(mangled).toEqual([]);
  });

  test('links each config a tool rewrites to its path in the repo', ({ fixture }) => {
    // Exact, not "every listed link resolves": a deleted symlink_ entry, or one
    // turned into a copy, drops out of chezmoi's listing and would pass that.
    const expected: Record<string, string> = {
      Brewfile: 'general/Brewfile',
      '.cspell.json': 'general/.cspell.json',
      '.cspell/personal-words.txt': 'general/.cspell/personal-words.txt',
      '.cspell/misc.txt': 'general/.cspell/misc.txt',
      'AGENTS.md': 'general/agents/AGENTS.global.md',
      '.codex/AGENTS.md': 'general/agents/AGENTS.global.md',
      '.agents/docs': 'general/agents/docs',
      '.config/kitty': 'config/kitty',
      '.config/mise': 'config/mise',
      '.config/btop': 'config/btop',
      '.config/nvim': 'config/nvim',
      '.config/zellij/config.kdl': 'config/zellij/config.kdl',
      '.config/zed/settings.json': 'config/zed/settings.json',
      '.config/zed/keymap.json': 'config/zed/keymap.json',
      '.config/zed/tasks.json': 'config/zed/tasks.json',
    };
    const f = fixture({ useRealChezmoi: true });
    expect(f.run().status).toBe(0);
    const listing = spawnSync(
      CHEZMOI!,
      [
        'managed',
        '--source',
        join(f.repo, 'home'),
        '--destination',
        f.home,
        '--config',
        join(f.home, '.config', 'chezmoi', 'chezmoi.toml'),
        '--include=symlinks',
      ],
      { encoding: 'utf8', env: { HOME: f.home, PATH: `${f.stubDir}:/usr/bin:/bin` } },
    );
    expect(listing.status).toBe(0);
    const actual = Object.fromEntries(
      listing.stdout
        .trim()
        .split('\n')
        .map((rel) => [rel, relative(f.repo, readlinkSync(join(f.home, rel)))]),
    );
    expect(actual).toEqual(expected);
    // A typo in a template deploys a dangling link that nothing else reads.
    const missing = Object.values(expected).filter((p) => !existsSync(join(REPO, p)));
    expect(missing).toEqual([]);
  });

  test('a write through a symlink_ entry lands in the repo', ({ fixture }) => {
    // The reason these configs are links rather than copies: `mise use`,
    // lazy.nvim and Zed rewrite them, and the repo has to see that.
    const f = fixture({ useRealChezmoi: true });
    expect(f.run().status).toBe(0);
    writeFileSync(join(f.home, '.config/mise/config.toml'), '# written by mise use\n');
    expect(readFileSync(join(f.repo, 'config/mise/config.toml'), 'utf8')).toBe(
      '# written by mise use\n',
    );
  });

  test('pins the destination against a stale persisted destDir', ({ fixture }) => {
    // Without --destination, init's apply stage honours this and sends every
    // file elsewhere while the script still exits 0 with empty stderr.
    const f = fixture({ useRealChezmoi: true });
    const decoy = join(f.dir, 'decoy');
    mkdirSync(decoy, { recursive: true });
    mkdirSync(join(f.home, '.config/chezmoi'), { recursive: true });
    writeFileSync(join(f.home, '.config/chezmoi/chezmoi.toml'), `destDir = "${decoy}"\n`);

    const r = f.run();
    expect(r.status).toBe(0);
    expect(existsSync(join(f.home, '.zshrc'))).toBe(true);
    expect(readdirSync(decoy)).toEqual([]);
  });

  test('refuses when the source manages nothing', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    rmSync(join(f.repo, 'home'), { recursive: true, force: true });
    mkdirSync(join(f.repo, 'home'));
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('manages no .zshrc');
  });

  test('refuses when .zshrc is excluded by .chezmoiignore', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    writeFileSync(join(f.repo, 'home/.chezmoiignore'), '.zshrc\n');
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('.chezmoiignore');
  });
});
