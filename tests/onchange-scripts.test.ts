import { existsSync, readFileSync, readlinkSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { expect } from 'vitest';

import { test, withChezmoi } from './helpers/fixture.ts';

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
