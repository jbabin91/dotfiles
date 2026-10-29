import { readdirSync } from 'node:fs';
import { defineConfig } from 'cz-git';

const dirsIn = (path) =>
  readdirSync(new URL(path, import.meta.url), { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name);

// A tool's scope is its directory name, read from both places a tool's config
// can live, so migrating one between them keeps its scope. Deduplicated
// because `git` is named explicitly and also exists under home/dot_config/.
const scopes = [
  ...new Set([...dirsIn('config'), ...dirsIn('home/dot_config'), 'git', 'brew', 'cspell', 'deps']),
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
