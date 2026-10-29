import { spawnSync } from 'node:child_process';
import {
  chmodSync,
  existsSync,
  lstatSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  readlinkSync,
  rmSync,
  statSync,
  symlinkSync,
  writeFileSync,
} from 'node:fs';
import { dirname, join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect } from 'vitest';

import { chezmoiStub, realChezmoi, test } from './helpers/fixture.ts';

/**
 * Every guard is asserted on its stderr, not only its exit status. Mutation
 * testing measured five of seven guards as message-only: deleting them leaves
 * the exit code unchanged, so a status-only suite passes against a build with
 * the guard removed.
 */

// Reported as skipped rather than passing: an early `return` would make these
// green on a machine without chezmoi while asserting nothing.
const REPO = join(dirname(fileURLToPath(import.meta.url)), '..');
const CHEZMOI = realChezmoi();
const needsChezmoi = test.skipIf(!CHEZMOI);
const withChezmoi = describe.skipIf(!CHEZMOI);

describe('preconditions', () => {
  test('refuses to run without $HOME rather than failing later as a broken chezmoi', ({
    fixture,
  }) => {
    const f = fixture();
    const r = f.run([], { HOME: undefined });
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('$HOME is unset or not a directory');
  });

  test('names uv when it is missing, instead of a bare command-not-found', ({ fixture }) => {
    const f = fixture();
    rmSync(join(f.stubDir, 'uv'));
    const r = f.run();
    expect(r.status).toBe(127);
    expect(r.stderr).toContain('uv is required to run dotbot');
  });

  test('a silent dotbot failure says chezmoi was not run', ({ fixture }) => {
    const f = fixture({ stubs: { uv: '#!/bin/sh\nexit 42\n' } });
    const r = f.run();
    // 42, not 1: a hardcoded `exit 1` in the handler would pass either way.
    expect(r.status).toBe(42);
    expect(r.stderr).toContain('dotbot exited 42');
    expect(r.stderr).toContain('chezmoi was not run, so no links, files, brew or mise');
  });

  test('arguments scope the run to dotbot and skip the chezmoi bootstrap', ({ fixture }) => {
    const f = fixture({ stubs: { curl: '#!/bin/sh\nexit 99\n' } });
    const r = f.run(['--help']);
    expect(r.status).toBe(0);
    expect(r.stderr).toContain('chezmoi: skipped, arguments scope dotbot only');
    expect(existsSync(join(f.home, '.zshrc'))).toBe(false);
    // dotbot must receive the flag: dropping `"${@}"` from the call
    // breaks every scoped run the script documents, silently.
    expect(readFileSync(join(f.dir, 'uv-args'), 'utf8').split('\n')).toContain('--help');
  });
});

describe('.chezmoiroot', () => {
  // chezmoi trims the file's contents, so the guard must too: rejecting any of
  // these would refuse a root chezmoi itself accepts.
  needsChezmoi.for([
    ['plain', 'home\n'],
    ['trailing space', 'home \n'],
    ['leading space', ' home\n'],
    ['CRLF checkout', 'home\r\n'],
    ['surrounding tabs', '\thome\t\n'],
    ['no trailing newline', 'home'],
  ])('accepts %s', ([, chezmoiroot], { fixture }) => {
    const f = fixture({ chezmoiroot, useRealChezmoi: true });
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(existsSync(join(f.home, '.zshrc'))).toBe(true);
  });

  test.for([
    ['missing', { omitChezmoiroot: true }],
    ['empty', { chezmoiroot: '' }],
    ['whitespace only', { chezmoiroot: '   \n' }],
    ['naming a missing directory', { chezmoiroot: 'nope\n' }],
  ] as const)('refuses when %s', ([, opts], { fixture }) => {
    const f = fixture({ ...opts, stubs: { chezmoi: chezmoiStub() } });
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('missing, unreadable, or names no directory');
  });

  test('refuses when .chezmoiroot is a directory', ({ fixture }) => {
    const f = fixture({ omitChezmoiroot: true, stubs: { chezmoi: chezmoiStub() } });
    mkdirSync(join(f.repo, '.chezmoiroot'));
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('missing, unreadable, or names no directory');
  });

  test('refuses when it is unreadable', ({ fixture }) => {
    const f = fixture({ stubs: { chezmoi: chezmoiStub() } });
    chmodSync(join(f.repo, '.chezmoiroot'), 0o000);
    const r = f.run();
    chmodSync(join(f.repo, '.chezmoiroot'), 0o644);
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('missing, unreadable, or names no directory');
  });

  needsChezmoi('a missing root leaves $HOME untouched', ({ fixture }) => {
    // Without the pre-apply check, `chezmoi init` exits 0 having written the
    // whole repo into $HOME -- ~/install, ~/install.conf.yaml, ~/home/.zshrc.
    const f = fixture({ omitChezmoiroot: true, useRealChezmoi: true });
    const before = readdirSync(f.home, { recursive: true });
    const r = f.run();
    expect(r.status).toBe(1);
    expect(readdirSync(f.home, { recursive: true })).toEqual(before);
  });
});

describe('chezmoi bootstrap', () => {
  test('reports a download failure with curl’s own status', ({ fixture }) => {
    const f = fixture({ stubs: { curl: '#!/bin/sh\nexit 22\n' } });
    const r = f.run();
    expect(r.status).toBe(22);
    expect(r.stderr).toContain('could not download https://get.chezmoi.io (curl exited 22)');
    expect(r.stderr).toContain('nothing was linked or deployed');
  });

  test('rejects a 2xx body that is not a script, and says how big it was', ({ fixture }) => {
    const f = fixture({
      // Contains `#!` away from column 1, so an unanchored grep would accept it.
      stubs: {
        curl: '#!/bin/sh\nprintf "<html>error: run #!/bin/sh yourself</html>" > "$4"\nexit 0\n',
      },
    });
    const r = f.run();
    expect(r.status).toBe(1);
    // The byte count must not carry BSD wc's leading padding.
    expect(r.stderr).toMatch(/returned \d+ bytes that are not a script/);
  });

  test('propagates the installer’s own exit status', ({ fixture }) => {
    const f = fixture({
      stubs: { curl: '#!/bin/sh\nprintf "#!/bin/sh\\nexit 3\\n" > "$4"\nexit 0\n' },
    });
    const r = f.run();
    expect(r.status).toBe(3);
    expect(r.stderr).toContain('installer exited 3');
    expect(r.stderr).toContain('nothing was linked or deployed');
  });

  test('catches an installer that exits 0 but installs nothing', ({ fixture }) => {
    const f = fixture({
      stubs: { curl: '#!/bin/sh\nprintf "#!/bin/sh\\nexit 0\\n" > "$4"\nexit 0\n' },
    });
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('installer exited 0 but left no working binary');
  });

  test('catches an installer that leaves a zero-byte executable', ({ fixture }) => {
    // A truncated download stays executable and exits 0 on every call, so the
    // guard runs the binary rather than testing for it.
    const f = fixture({
      stubs: {
        curl: `#!/bin/sh
printf '#!/bin/sh\\nmkdir -p "$HOME/.local/bin"\\n: > "$HOME/.local/bin/chezmoi"\\nchmod +x "$HOME/.local/bin/chezmoi"\\n' > "$4"
exit 0
`,
      },
    });
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('installer exited 0 but left no working binary');
  });

  test('reports mktemp failing before any download is attempted', ({ fixture }) => {
    const f = fixture({ stubs: { mktemp: '#!/bin/sh\nexit 1\n' } });
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('mktemp failed, cannot stage the installer');
  });

  test('replaces a chezmoi that is on PATH but will not run', ({ fixture }) => {
    const f = fixture({
      stubs: { chezmoi: '#!/bin/sh\nexit 127\n', curl: '#!/bin/sh\nexit 7\n' },
    });
    const r = f.run();
    expect(r.stderr).toContain('is on PATH but will not run; installing a fresh copy');
    expect(r.status).toBe(7);
  });

  test('announces reinstalling over a broken ~/.local/bin/chezmoi', ({ fixture }) => {
    const f = fixture({
      home: { '.local/bin/chezmoi': '' },
      stubs: { curl: '#!/bin/sh\nexit 7\n' },
    });
    chmodSync(join(f.home, '.local/bin/chezmoi'), 0o755);
    const r = f.run();
    expect(r.stderr).toContain('exists but will not run; reinstalling over it');
  });

  test('says nothing about ~/.local/bin/chezmoi when there is none', ({ fixture }) => {
    // The common case: a clean machine. Dropping the existence probe makes the
    // script claim a file it never found "exists but will not run".
    const f = fixture({ stubs: { curl: '#!/bin/sh\nexit 7\n' } });
    const r = f.run();
    expect(r.stderr).not.toContain('exists but will not run');
  });

  needsChezmoi('uses a working chezmoi already on PATH without downloading', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const marker = join(f.dir, 'curl-ran');
    f.stub('curl', `#!/bin/sh\n: > "${marker}"\nexit 7\n`);
    const r = f.run();
    expect(r.status).toBe(0);
    expect(existsSync(marker)).toBe(false);
    expect(existsSync(join(f.home, '.local/bin/chezmoi'))).toBe(false);
  });
});

describe('post-apply verification', () => {
  test('propagates a failing chezmoi init and says what was not deployed', ({ fixture }) => {
    const f = fixture({ stubs: { chezmoi: chezmoiStub({ init: 'exit 5' }) } });
    const r = f.run();
    expect(r.status).toBe(5);
    expect(r.stderr).toContain('chezmoi init exited 5');
    // Hedged deliberately: init applies incrementally, so a nonzero exit says
    // nothing about how much of $HOME it already wrote.
    expect(r.stderr).toContain('may hold some, all or none of its files');
  });

  test('a pre-existing ~/.zshrc does not pass for a successful apply', ({ fixture }) => {
    // The assertion this replaced was `[ -e "$HOME/.zshrc" ]`, which $HOME
    // almost always satisfies -- it passed with rc 0 while the apply wrote
    // nothing at all.
    const f = fixture({
      home: { '.zshrc': '# hand-written, not chezmoi\n' },
      stubs: { chezmoi: chezmoiStub({ verify: 'exit 1' }) },
    });
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('chezmoi verify exited 1');
  });

  test('a signalled verify is not reported as drift', ({ fixture }) => {
    const f = fixture({
      stubs: { chezmoi: chezmoiStub({ verify: 'kill -TERM $$; sleep 5' }) },
    });
    const r = f.run();
    expect(r.status).toBe(143);
    expect(r.stderr).toContain('over 128 means killed by signal');
  });

  test('names .zshrc specifically when the source manages everything else', ({ fixture }) => {
    const f = fixture({
      stubs: {
        chezmoi: chezmoiStub({
          verify: 'eval "last=\\${$#}"; case "$last" in *.zshrc) exit 1 ;; *) exit 0 ;; esac',
        }),
      },
    });
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('manages no .zshrc');
    expect(r.stderr).toContain('.chezmoiignore');
  });
});

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

  test('is idempotent across a second run', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    expect(f.run().status).toBe(0);
    const second = f.run();
    expect(second.status).toBe(0);
    expect(second.stderr).toBe('');
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

/** A stub that appends its name and arguments to `calls`, then exits with `status`. */
const recorder = (calls: string, name: string, status = 0) =>
  `#!/bin/sh\necho "${name} $*" >> "${calls}"\nexit ${status}\n`;

withChezmoi('run_onchange_ scripts', () => {
  test('apply the Brewfile, mise tools and tmux plugins', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('brew', recorder(calls, 'brew'));
    f.stub('tpack', recorder(calls, 'tpack'));
    writeFileSync(join(f.home, '.local/bin/mise'), recorder(calls, 'mise'), { mode: 0o755 });
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    const ran = readFileSync(calls, 'utf8');
    expect(ran).toContain(
      `brew bundle --file=${join(f.repo, 'home')}/../general/Brewfile --no-upgrade`,
    );
    expect(ran).toContain('mise install');
    expect(ran).toContain('tpack install');
  });

  test('run again only when the file they hash changes', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('brew', recorder(calls, 'brew'));
    expect(f.run().status).toBe(0);
    expect(f.run().status).toBe(0);
    expect(readFileSync(calls, 'utf8').match(/^brew /gm)).toHaveLength(1);
    writeFileSync(join(f.repo, 'general/Brewfile'), 'brew "jq"\n', { flag: 'a' });
    expect(f.run().status).toBe(0);
    expect(readFileSync(calls, 'utf8').match(/^brew /gm)).toHaveLength(2);
  });

  test('a failing brew still leaves the files deployed, and names itself', ({ fixture }) => {
    // The failure this replaced: a disabled cask stopped dotbot's shell
    // section, so chezmoi never ran and ~/.gitconfig stayed undeployed.
    const f = fixture({ useRealChezmoi: true });
    f.stub('brew', recorder(join(f.dir, 'calls'), 'brew', 1));
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('brew-bundle.sh: exit status 1');
    expect(existsSync(join(f.home, '.gitconfig'))).toBe(true);
  });

  test('a skip for missing brew is not final once brew reaches PATH', ({ fixture }) => {
    // The skip exits 0, so chezmoi records it; only the brew path in the
    // rendered script makes the next apply run it again.
    const f = fixture({ useRealChezmoi: true });
    const first = f.run();
    expect(first.status).toBe(0);
    expect(first.stdout).toContain('brew: not on PATH; the Brewfile was not applied');
    const calls = join(f.dir, 'calls');
    f.stub('brew', recorder(calls, 'brew'));
    expect(f.run().status).toBe(0);
    expect(readFileSync(calls, 'utf8')).toMatch(/^brew bundle /m);
  });

  test('links the which-key menu config into the plugin directory tpack made', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const plugin = join(f.home, '.local/share/tmux/plugins/tmux-which-key-abc');
    f.stub('tpack', `#!/bin/sh\nmkdir -p "${plugin}"\n`);
    expect(f.run().status).toBe(0);
    // Through ~/.config/tmux rather than the repo, so moving the repo cannot
    // leave it dangling.
    expect(readlinkSync(join(plugin, 'config.yaml'))).toBe(
      join(f.home, '.config/tmux/plugins/tmux-which-key/config.yaml'),
    );
  });

  test('reinstalls mise when its binary has gone missing', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    expect(f.run().status).toBe(0);
    rmSync(join(f.home, '.local/bin/mise'));
    const marker = join(f.dir, 'curl-ran');
    f.stub(
      'curl',
      `#!/bin/sh\n: > "${marker}"\nprintf '#!/bin/sh\\nprintf "#!/bin/sh\\\\nexit 0\\\\n" > "$HOME/.local/bin/mise"\\nchmod +x "$HOME/.local/bin/mise"\\n' > "$4"\n`,
    );
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(existsSync(marker)).toBe(true);
    expect(existsSync(join(f.home, '.local/bin/mise'))).toBe(true);
  });
});

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
    // dotbot swept ~ itself but not its subdirectories other than ~/.config.
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
    // Deleting it would make the next apply stop and ask about it.
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

withChezmoi('before-scripts', () => {
  const KARABINER = '.config/karabiner/karabiner.json';
  const repoCopy = (f: { repo: string }) => join(f.repo, 'config', 'karabiner', 'karabiner.json');

  test('copies a changed live Karabiner config into the repo', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true, home: { [KARABINER]: '{"live":1}\n' } });
    mkdirSync(dirname(repoCopy(f)), { recursive: true });
    writeFileSync(repoCopy(f), '{"repo":1}\n');
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(r.stdout).toContain('karabiner: live → dotfiles');
    expect(readFileSync(repoCopy(f), 'utf8')).toBe('{"live":1}\n');
    // In sync, the next apply has nothing to say.
    expect(f.run().stdout).not.toContain('karabiner');
  });

  test('seeds the Karabiner config from the repo when none is live', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    mkdirSync(dirname(repoCopy(f)), { recursive: true });
    writeFileSync(repoCopy(f), '{"repo":1}\n');
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(r.stdout).toContain('karabiner: dotfiles → live (bootstrap)');
    expect(lstatSync(join(f.home, KARABINER)).isSymbolicLink()).toBe(false);
    expect(readFileSync(join(f.home, KARABINER), 'utf8')).toBe('{"repo":1}\n');
  });

  test('replaces a leftover Karabiner link instead of writing through it', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    mkdirSync(dirname(repoCopy(f)), { recursive: true });
    writeFileSync(repoCopy(f), '{"repo":1}\n');
    mkdirSync(join(f.home, '.config/karabiner'), { recursive: true });
    symlinkSync(repoCopy(f), join(f.home, KARABINER));
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(lstatSync(join(f.home, KARABINER)).isSymbolicLink()).toBe(false);
    expect(readFileSync(repoCopy(f), 'utf8')).toBe('{"repo":1}\n');
  });

  test('a failed Karabiner copy warns and still deploys', ({ fixture }) => {
    const f = fixture({
      useRealChezmoi: true,
      home: { '.config/karabiner': 'not a directory\n' },
    });
    mkdirSync(dirname(repoCopy(f)), { recursive: true });
    writeFileSync(repoCopy(f), '{"repo":1}\n');
    const r = f.run();
    expect(r.stderr).toContain('karabiner: could not sync');
    expect(r.status).toBe(0);
    expect(existsSync(join(f.home, '.zshrc'))).toBe(true);
  });

  test('keeps a working Karabiner link when its replacement cannot be read', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true, home: { 'elsewhere.json': '{"else":1}\n' } });
    mkdirSync(dirname(repoCopy(f)), { recursive: true });
    writeFileSync(repoCopy(f), '{"repo":1}\n');
    chmodSync(repoCopy(f), 0o000);
    mkdirSync(join(f.home, '.config/karabiner'), { recursive: true });
    symlinkSync(join(f.home, 'elsewhere.json'), join(f.home, KARABINER));
    try {
      const r = f.run();
      expect(r.stderr).toContain('karabiner: could not sync');
      expect(r.status).toBe(0);
      expect(readFileSync(join(f.home, KARABINER), 'utf8')).toBe('{"else":1}\n');
      expect(readdirSync(join(f.home, '.config/karabiner'))).toEqual(['karabiner.json']);
    } finally {
      chmodSync(repoCopy(f), 0o644);
    }
  });

  test('warns instead of copying into a directory at the Karabiner path', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    mkdirSync(dirname(repoCopy(f)), { recursive: true });
    writeFileSync(repoCopy(f), '{"repo":1}\n');
    mkdirSync(join(f.home, KARABINER), { recursive: true });
    const r = f.run();
    expect(r.stderr).toContain('karabiner: could not sync');
    expect(r.status).toBe(0);
    expect(readdirSync(join(f.home, KARABINER))).toEqual([]);
  });

  test('does not copy an empty live Karabiner config over the repo', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true, home: { [KARABINER]: '' } });
    mkdirSync(dirname(repoCopy(f)), { recursive: true });
    writeFileSync(repoCopy(f), '{"repo":1}\n');
    const r = f.run();
    expect(r.stderr).toContain('is empty');
    expect(r.status).toBe(0);
    expect(readFileSync(repoCopy(f), 'utf8')).toBe('{"repo":1}\n');
  });

  test('the Karabiner sync refuses to run without chezmoi', () => {
    const r = spawnSync('/bin/sh', [join(REPO, 'home/run_before_karabiner-sync.sh')], {
      env: { HOME: '/nonexistent', PATH: '/usr/bin:/bin' },
      encoding: 'utf8',
    });
    expect(r.status).not.toBe(0);
    expect(r.stderr).toContain('CHEZMOI_SOURCE_DIR: is unset');
  });

  test('seeds ~/.claude/CLAUDE.md during the apply', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(r.stdout).toContain('claude: created ~/.claude/CLAUDE.md');
    expect(readFileSync(join(f.home, '.claude/CLAUDE.md'), 'utf8')).toContain('@~/AGENTS.md');
  });
});

test('stubbing over a symlink replaces the link, not the file it points at', ({ fixture }) => {
  const f = fixture();
  const target = join(f.dir, 'real-binary');
  writeFileSync(target, 'original');
  symlinkSync(target, join(f.stubDir, 'tool'));
  f.stub('tool', '#!/bin/sh\nexit 0\n');
  expect(readFileSync(target, 'utf8')).toBe('original');
});
