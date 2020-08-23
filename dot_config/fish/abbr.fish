function a
  abbr -a -g $argv
end

# asdf
a ala 'asdf list-all'
a ain 'asdf install nodejs'
a air 'asdf isntall ruby'

# Config dir access
a cdot 'cd $DOTFILES'
a cdxc 'cd $XDG_CONFIG_HOME'
a cdfi 'cd $XDG_CONFIG_HOME/fish'
a cdnv 'cd $XDG_CONFIG_HOME/nvim'
a cdxd 'cd $XDG_DATA_HOME'
a cdxa 'cd $XDG_CACHE_HOME'

# https://fishshell.com/docs/current/commands.html#fish_update_completions
a ucl 'fish_update_completions'

# General UNIX
a c 'clear'
a mkdir 'mkdir -pv'
a mv 'mv -iv'

a cha 'chezmoi apply'
a chc 'chezmoi cd'
a chd 'chezmoi data'
a chdiff 'chezmoi diff'
a che 'e ~/.config/chezmoi/chezmoi.toml'
a chi 'chezmoi init'
a chu 'chezmoi update'
a chv 'chezmoi verify'

# GIT
a g 'git'
a ga 'git add'
a gb 'git branch'
a gbd 'git branch -d'
a gbdd 'git branch -D'
a gbl 'git blame'
a gch 'git checkout'
a gchb 'git checkout -b'
a gcm 'git commit -m'
a gcl 'git clone'
a gca 'git commit --amend -m'
a gcp 'git cherry-pick'
a gd 'git diff'
a gf 'git fetch'
a gl 'git log'
a gm 'git merge'
a gp 'git push'
a gpf 'git push --force-with-lease'
a gpl 'git pull'
a gr 'git remote'
a grb 'git rebase'
a gs 'git status'
a gst 'git stash'

# Misc
a neo 'neofetch'
a ra 'ranger'

# Moving around
a ... 'cd ../../'
a .... 'cd ../../../'
a ..... 'cd ../../../../'
a - 'cd -'

# Neovim
a vi 'nvim'

# Tmux
a tl 'tmux ls'
a tlw 'tmux list-windows'

# Brew package manager
a bc    'brew cleanup'
a bu    'brew update'
a bd    'brew doctor'
a bg    'brew upgrade --all'
a bo    'brew outdated'
a brews 'brew list -1'
a bs0   'brew services stop'
a bs1   'brew services start'
a bs    'brew services'
a bsc   'brew services cleanup'
a bsl   'brew services list'
a bsr   'brew services restart'

# Yarn
a y 'yarn'
a ya 'yarn add'
a yad 'yarn add -D'
a yap 'yarn add --peer'
a yb 'yarn build'
a yba 'yarn build --analyze'
a yc 'yarn create'
a ycc 'yarn cache clean'
a yd 'yarn dev'
a yg 'yarn generate'
a yga 'yarn global add'
a ygls 'yarn global list'
a ygrm 'yarn global remove'
a ygu 'yarn global upgrade'
a yh 'yarn help'
a yi 'yarn init'
a yin 'yarn install'
a yls 'yarn list'
a yout 'yarn outdated'
a yp 'yarn pack'
a yrm 'yarn remove'
a yrun 'yarn run'
a ys 'yarn serve'
a yst 'yarn start'
a yt 'yarn test'
a ytc 'yarn test --coverage'
a yuc 'yarn global upgrade; and yarn cache clean'
a yui 'yarn upgrade-interactive'
a yup 'yarn upgrade'
a yupl 'yarn upgrade --latest'
a yv 'yarn version'
a yw 'yarn workspace'
a yws 'yarn workspaces'

functions -e a