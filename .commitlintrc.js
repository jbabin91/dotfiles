import { defineConfig } from 'cz-git';

export default defineConfig({
  extends: ['@commitlint/config-conventional'],
  prompt: {
    alias: {
      deps: 'chore(deps): bump dependencies',
      brew: 'chore(brew): update Brewfile',
    },
    allowCustomScopes: false,
    allowEmptyScopes: true,
    scopes: [
      'zsh',
      'git',
      'brew',
      'ghostty',
      'kitty',
      'starship',
      'karabiner',
      'mise',
      'bat',
      'tmux',
      'fastfetch',
      'cspell',
      'deps',
    ],
  },
  rules: {
    'header-max-length': [2, 'always', 200],
    'body-max-line-length': [0, 'always'],
  },
});
