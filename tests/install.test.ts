import {
  chmodSync,
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  rmSync,
  writeFileSync,
} from 'node:fs';
import { join } from 'node:path';
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

  test('a silent dotbot failure still explains what may be incomplete', ({ fixture }) => {
    const f = fixture({ stubs: { uv: '#!/bin/sh\nexit 42\n' } });
    const r = f.run();
    // 42, not 1: a hardcoded `exit 1` in the handler would pass either way.
    expect(r.status).toBe(42);
    expect(r.stderr).toContain('dotbot exited 42');
    expect(r.stderr).toContain('chezmoi was not run');
  });

  test('arguments scope the run to dotbot and skip the chezmoi bootstrap', ({ fixture }) => {
    const f = fixture({ stubs: { curl: '#!/bin/sh\nexit 99\n' } });
    const r = f.run(['--help']);
    expect(r.status).toBe(0);
    expect(r.stderr).toContain('chezmoi: skipped, arguments scope dotbot only');
    expect(existsSync(join(f.home, '.zshrc'))).toBe(false);
    // dotbot must actually receive the flag: dropping `"${@}"` from the call
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
    const r = f.run();
    expect(r.status).toBe(1);
    expect(readdirSync(f.home)).toEqual([]);
  });
});

describe('chezmoi bootstrap', () => {
  test('reports a download failure with curl’s own status', ({ fixture }) => {
    const f = fixture({ stubs: { curl: '#!/bin/sh\nexit 22\n' } });
    const r = f.run();
    expect(r.status).toBe(22);
    expect(r.stderr).toContain('could not download https://get.chezmoi.io (curl exited 22)');
    expect(r.stderr).toContain('symlinks are in place');
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
    expect(r.stderr).toContain('may hold some, all or none of zsh and starship');
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
  test('deploys zsh and starship into an empty $HOME', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    for (const rel of ['.zshrc', '.zshenv', '.config/starship.toml']) {
      expect(existsSync(join(f.home, rel))).toBe(true);
    }
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
