import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { expect } from 'vitest';

import { test, withChezmoi } from './helpers/fixture.ts';

/** A tool stub that prints `body` for `<cmd...>`, records each call, and fails otherwise. */
const completer = (calls: string, cmd: string, body: string) =>
  `#!/bin/sh\necho "$0 $*" >> "${calls}"\n[ "$*" = "${cmd}" ] && { printf '%s\\n' '${body}'; exit 0; }\nexit 1\n`;

withChezmoi('shell completions', () => {
  test('writes ~/.zfunc only for the tools installed', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('rex', completer(calls, 'completion zsh', '#compdef rex'));
    f.stub('varlock', completer(calls, 'complete zsh', '#compdef varlock'));
    const r = f.run();
    expect(r.stderr).toBe('');
    expect(r.status).toBe(0);
    expect(readdirSync(join(f.home, '.zfunc')).sort()).toEqual(['_rex', '_varlock']);
    expect(readFileSync(join(f.home, '.zfunc/_rex'), 'utf8')).toBe('#compdef rex\n');
  });

  test('regenerates only after a tool is upgraded', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    const calls = join(f.dir, 'calls');
    f.stub('rex', completer(calls, 'completion zsh', '#compdef rex'));
    expect(f.run().status).toBe(0);
    expect(f.run().status).toBe(0);
    expect(readFileSync(calls, 'utf8').match(/rex completion/g)).toHaveLength(1);
    // A different binary size stands in for an upgrade.
    f.stub('rex', completer(calls, 'completion zsh', '#compdef rex # v2'));
    expect(f.run().status).toBe(0);
    expect(readFileSync(join(f.home, '.zfunc/_rex'), 'utf8')).toBe('#compdef rex # v2\n');
  });

  test.for([
    ['exits nonzero', '#!/bin/sh\nprintf partial\nexit 1\n'],
    ['prints an error and exits 0', '#!/bin/sh\necho "error: unknown command"\n'],
  ])('a generator that %s keeps the previous file and is retried', ([, body], { fixture }) => {
    const f = fixture({ useRealChezmoi: true, home: { '.zfunc/_rex': 'previous\n' } });
    f.stub('rex', body);
    const r = f.run();
    expect(r.stderr).toContain('completions: rex completion zsh failed');
    expect(r.status).not.toBe(0);
    expect(readFileSync(join(f.home, '.zfunc/_rex'), 'utf8')).toBe('previous\n');
    expect(readdirSync(join(f.home, '.zfunc'))).toEqual(['_rex']);
    // Not recorded as done, so the next apply tries again.
    f.stub('rex', completer(join(f.dir, 'calls'), 'completion zsh', '#compdef rex'));
    expect(f.run().status).toBe(0);
    expect(readFileSync(join(f.home, '.zfunc/_rex'), 'utf8')).toBe('#compdef rex\n');
  });

  test('clears a staging file a killed run left behind', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true, home: { '.zfunc/._rex.tmp.123': 'partial' } });
    f.stub('rex', completer(join(f.dir, 'calls'), 'completion zsh', '#compdef rex'));
    expect(f.run().status).toBe(0);
    expect(readdirSync(join(f.home, '.zfunc'))).toEqual(['_rex']);
  });

  test('makes the first pnpm completion call complete', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    f.stub(
      'pnpm',
      `#!/bin/sh\n[ "$*" = "completion zsh" ] && printf '#compdef pnpm pn\\ncompdef _pnpm_completion pnpm pn\\n'\n`,
    );
    expect(f.run().status).toBe(0);
    expect(readFileSync(join(f.home, '.zfunc/_pnpm'), 'utf8')).toContain(
      '[[ $zsh_eval_context == *func ]] && _pnpm_completion "$@"',
    );
  });

  test('creates nothing when no tool is installed', ({ fixture }) => {
    const f = fixture({ useRealChezmoi: true });
    expect(f.run().status).toBe(0);
    expect(existsSync(join(f.home, '.zfunc'))).toBe(false);
  });
});
