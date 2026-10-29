import {
  chmodSync,
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  symlinkSync,
  writeFileSync,
} from 'node:fs';
import { join } from 'node:path';
import { describe, expect } from 'vitest';

import { chezmoiStub, managedFromRoot, needsChezmoi, test } from './helpers/fixture.ts';

describe('preconditions', () => {
  test('refuses to run without $HOME rather than failing later as a broken chezmoi', ({
    fixture,
  }) => {
    const f = fixture();
    const r = f.run([], { HOME: undefined });
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('$HOME is unset or not a directory');
  });

  test('refuses arguments rather than deploying with them ignored', ({ fixture }) => {
    const calls = 'chezmoi-calls';
    const f = fixture();
    f.stub('chezmoi', chezmoiStub({ init: `echo init >> "$HOME/../${calls}"` }));
    const r = f.run(['--dry-run']);
    expect(r.status).toBe(2);
    expect(r.stderr).toContain('./install takes no arguments');
    expect(existsSync(join(f.dir, calls))).toBe(false);
  });

  test('refuses arguments before bootstrapping a missing chezmoi', ({ fixture }) => {
    const marker = 'curl-ran';
    const f = fixture({ stubs: { curl: `#!/bin/sh\n: > "$HOME/../${marker}"\nexit 99\n` } });
    const r = f.run(['--help']);
    expect(r.status).toBe(2);
    expect(r.stderr).toContain('./install takes no arguments');
    expect(existsSync(join(f.dir, marker))).toBe(false);
    expect(existsSync(join(f.home, '.local/bin/chezmoi'))).toBe(false);
  });
});

describe('.chezmoiroot', () => {
  // Every other real apply uses a plain root. A CRLF checkout is the realistic
  // variant, and the one a stricter check in install would reject.
  needsChezmoi('a CRLF checkout still applies home/', ({ fixture }) => {
    const f = fixture({ chezmoiroot: 'home\r\n', useRealChezmoi: true });
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(existsSync(join(f.home, '.zshrc'))).toBe(true);
  });

  // install leaves the contents to chezmoi, so the rest probe chezmoi directly:
  // each must still resolve to home/.
  needsChezmoi.for([
    ['trailing space', 'home \n'],
    ['leading space', ' home\n'],
    ['surrounding tabs', '\thome\t\n'],
    ['no trailing newline', 'home'],
  ])('chezmoi accepts a root with %s', ([, chezmoiroot], { fixture }) => {
    const f = fixture({ chezmoiroot });
    const r = managedFromRoot(f, '--include=files');
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(r.stdout.split('\n')).toContain('.zshrc');
  });

  test('refuses when .chezmoiroot is missing', ({ fixture }) => {
    const f = fixture({ omitChezmoiroot: true, stubs: { chezmoi: chezmoiStub() } });
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('.chezmoiroot is missing or not a regular file; refusing');
  });

  test('refuses when .chezmoiroot is a directory', ({ fixture }) => {
    const f = fixture({ omitChezmoiroot: true, stubs: { chezmoi: chezmoiStub() } });
    mkdirSync(join(f.repo, '.chezmoiroot'));
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('.chezmoiroot is missing or not a regular file; refusing');
  });

  // Left to chezmoi, which reads the file itself; each must still fail the run
  // with nothing deployed.
  needsChezmoi.for([
    ['empty', '', '.chezmoiroot: : invalid path'],
    ['whitespace only', '   \n', '.chezmoiroot: : invalid path'],
    ['naming a missing directory', 'nope\n', 'manages no .zshrc'],
  ])('fails when it is %s', ([, chezmoiroot, message], { fixture }) => {
    const f = fixture({ chezmoiroot, useRealChezmoi: true });
    const r = f.run();
    expect(r.status).not.toBe(0);
    expect(r.stderr).toContain(message);
    expect(existsSync(join(f.home, '.zshrc'))).toBe(false);
  });

  needsChezmoi('fails when it is unreadable', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    chmodSync(join(f.repo, '.chezmoiroot'), 0o000);
    try {
      const r = f.run();
      expect(r.status).not.toBe(0);
      expect(r.stderr).toContain('permission denied');
      expect(existsSync(join(f.home, '.zshrc'))).toBe(false);
    } finally {
      chmodSync(join(f.repo, '.chezmoiroot'), 0o644);
    }
  });

  needsChezmoi('a missing root leaves $HOME untouched', ({ fixture }) => {
    // Without the pre-apply check, `chezmoi init` exits 0 having written the
    // whole repo into $HOME -- ~/install, ~/home/.zshrc.
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

  test('reports drift the whole-tree verify finds', ({ fixture }) => {
    const f = fixture({ stubs: { chezmoi: chezmoiStub({ verify: 'exit 1' }) } });
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('chezmoi verify exited 1');
  });

  test('propagates verify’s own exit status, signals included', ({ fixture }) => {
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

test('stubbing over a symlink replaces the link, not the file it points at', ({ fixture }) => {
  const f = fixture();
  const target = join(f.dir, 'real-binary');
  writeFileSync(target, 'original');
  symlinkSync(target, join(f.stubDir, 'tool'));
  f.stub('tool', '#!/bin/sh\nexit 0\n');
  expect(readFileSync(target, 'utf8')).toBe('original');
});
