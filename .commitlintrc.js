import { readdirSync } from 'node:fs';
import { defineConfig } from 'cz-git';

// Every directory under config/ is a scope, so adding a tool never needs an
// edit here. Scopes outside config/ live in general/ or apply repo-wide.
const scopes = [
  ...readdirSync(new URL('config', import.meta.url), { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name),
  'git',
  'brew',
  'cspell',
  'deps',
].sort();

export default defineConfig({
  extends: ['@commitlint/config-conventional'],
  prompt: {
    alias: {
      deps: 'chore(deps): bump dependencies',
      brew: 'chore(brew): update Brewfile',
    },
    allowCustomScopes: false,
    allowEmptyScopes: true,
    scopes,
  },
  rules: {
    'header-max-length': [2, 'always', 200],
    'body-max-line-length': [0, 'always'],
    // Off for the same reason as the body: a prose line that happens to begin
    // `word:` is parsed as a footer, and the 100-char default then fails the
    // commit outright. Real footers here are short trailers like `Closes dot-x`.
    'footer-max-line-length': [0, 'always'],
  },
});
