import { existsSync, mkdirSync, readFileSync, readlinkSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { expect } from 'vitest';

import {
  REX_AGENT_RESUME_MARKER,
  REX_AGENT_RESUME_REF,
  test,
  withChezmoi,
} from './helpers/fixture.ts';

/** A stub that appends its name and arguments to `calls`, then exits with `status`. */
const recorder = (calls: string, name: string, status = 0) =>
  `#!/bin/sh\necho "${name} $*" >> "${calls}"\nexit ${status}\n`;

/** A rex that the completions script accepts, and whose every other command exits `status`. */
const rex = (calls: string, status = 0) =>
  `#!/bin/sh\necho "rex $*" >> "${calls}"\n[ "$*" = "completion zsh" ] && { echo '#compdef rex'; exit 0; }\nexit ${status}\n`;

/** rex-agent-resume installer bodies, each recording its ref and leaving the empty marker upstream's leaves. */
const installer = (calls: string, { plugin = true, out = '', status = 0 } = {}) =>
  [
    '#!/bin/sh',
    `echo "installer $REX_AGENT_RESUME_REF" >> "${calls}"`,
    'mkdir -p "$HOME/.local/share/rex-agent-resume"',
    `: > "$HOME/${REX_AGENT_RESUME_MARKER}"`,
    plugin ? ': > "$HOME/.local/share/rex-agent-resume/plugin.lua"' : '',
    out ? `echo "${out}"` : '',
    `exit ${status}`,
  ].join('\n');

/** A curl that records the URL (`curl -fsSL <url> -o <file>`) and serves `body` as the download. */
const serving = (
  f: { dir: string; stub: (name: string, body: string) => void },
  calls: string,
  body: string,
) => {
  const src = join(f.dir, 'install.sh');
  writeFileSync(src, body);
  f.stub('curl', `#!/bin/sh\necho "curl $2" >> "${calls}"\ncp "${src}" "$4"\n`);
};

const curls = (calls: string) => readFileSync(calls, 'utf8').match(/^curl /gm) ?? [];

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

  test('installs rex-agent-resume at the pinned ref, once', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('rex', rex(calls));
    serving(f, calls, installer(calls));
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    // plugin.lua now exists, which changes the script's hash and runs it again.
    expect(f.run().status).toBe(0);
    const ran = readFileSync(calls, 'utf8');
    expect(
      ran.match(/^curl .*\/YangJonghun\/rex-agent-resume\/([0-9a-f]+)\/install\.sh$/gm),
    ).toEqual([
      `curl https://raw.githubusercontent.com/YangJonghun/rex-agent-resume/${REX_AGENT_RESUME_REF}/install.sh`,
    ]);
    expect(ran).toContain(`installer ${REX_AGENT_RESUME_REF}`);
    expect(readFileSync(join(f.home, REX_AGENT_RESUME_MARKER), 'utf8')).toBe(
      `${REX_AGENT_RESUME_REF}\n`,
    );
  });

  test('skips rex-agent-resume without rex, and installs once rex reaches PATH', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const first = f.run();
    expect(first.status).toBe(0);
    expect(first.stdout).toContain('rex-agent-resume: rex not on PATH; it was not installed');
    const calls = join(f.dir, 'calls');
    f.stub('rex', rex(calls));
    f.stub('curl', recorder(calls, 'curl', 22));
    const r = f.run();
    expect(r.status).not.toBe(0);
    expect(r.stderr).toContain('rex-agent-resume: could not download');
  });

  test('finds rex inside the Rex app when it is not on PATH', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const first = f.run();
    expect(first.stdout).toContain('rex-agent-resume: rex not on PATH; it was not installed');
    const calls = join(f.dir, 'calls');
    const bundle = join(
      f.home,
      'Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS',
    );
    mkdirSync(bundle, { recursive: true });
    writeFileSync(join(bundle, 'rex'), rex(calls), { mode: 0o755 });
    serving(f, calls, installer(calls));
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(readFileSync(calls, 'utf8')).toMatch(/^rex ls$/m);
    expect(readFileSync(join(f.home, REX_AGENT_RESUME_MARKER), 'utf8')).toBe(
      `${REX_AGENT_RESUME_REF}\n`,
    );
  });

  test('reinstalls when plugin.lua goes missing', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('rex', rex(calls));
    serving(f, calls, installer(calls));
    expect(f.run().status).toBe(0);
    expect(f.run().status).toBe(0);
    expect(curls(calls)).toHaveLength(1);
    rmSync(join(f.home, '.local/share/rex-agent-resume/plugin.lua'));
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(curls(calls)).toHaveLength(2);
    expect(existsSync(join(f.home, '.local/share/rex-agent-resume/plugin.lua'))).toBe(true);
  });

  test('a rex server that cannot start fails the apply before any download', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('rex', rex(calls, 1));
    serving(f, calls, installer(calls));
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('rex-agent-resume.sh: exit status 1');
    expect(curls(calls)).toEqual([]);
  });

  test('a failing installer is reported, not recorded, and retried', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('rex', rex(calls));
    serving(f, calls, installer(calls, { out: 'boom', status: 3 }));
    const r = f.run();
    expect(r.status).not.toBe(0);
    expect(r.stderr).toContain('boom');
    expect(r.stderr).toContain('rex-agent-resume: installer exited 3');
    expect(readFileSync(join(f.home, REX_AGENT_RESUME_MARKER), 'utf8')).toBe('');
    serving(f, calls, installer(calls));
    expect(f.run().status).toBe(0);
    expect(curls(calls)).toHaveLength(2);
  });

  test('an installer that exits 0 without plugin.lua fails the apply', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('rex', rex(calls));
    serving(f, calls, installer(calls, { plugin: false }));
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('rex-agent-resume: installer exited 0 but left no');
    expect(readFileSync(join(f.home, REX_AGENT_RESUME_MARKER), 'utf8')).toBe('');
  });

  test('an agent the installer could not hook is warned about, not fatal', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('rex', rex(calls));
    serving(
      f,
      calls,
      installer(calls, { out: '[rex-agent-resume] droid: failed: not plain JSON' }),
    );
    const r = f.run();
    expect(r.status).toBe(0);
    expect(r.stderr).toContain('droid: failed: not plain JSON');
    expect(readFileSync(join(f.home, REX_AGENT_RESUME_MARKER), 'utf8')).toBe(
      `${REX_AGENT_RESUME_REF}\n`,
    );
  });

  test('a shebang-less download is refused before it runs', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('rex', rex(calls));
    serving(f, calls, `<html>rate limited</html>\necho "installer ran" >> "${calls}"\n`);
    const r = f.run();
    expect(r.status).toBe(1);
    expect(r.stderr).toContain('is not a script');
    expect(readFileSync(calls, 'utf8')).not.toContain('installer');
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
