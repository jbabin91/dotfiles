#!/usr/bin/env fish
if command -qa exa
  abbr -a gl 'git pull --prune'
  abbr -a glg 'git log --graph --decorate --oneline --abbrev-commit'
  abbr -a glga 'glg --all'
  abbr -a gp 'git push origin HEAD'
  abbr -a gpa 'git push origin --all'
  abbr -a gd 'git diff'
  abbr -a gc 'git commit -s'
  abbr -a gca 'git commit -s -a'
  abbr -a gco 'git checkout'
  abbr -a gb 'git branch -v'
  abbr -a ga 'git add'
  abbr -a gaa 'git add -A'
  abbr -a gcm 'git commit -am'
  abbr -a gs 'git status -sb'
  abbr -a yolo 'git commit -m "(curl -s http://whatthecommit.com/index.txt)"'
end
