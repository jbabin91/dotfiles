#!/usr/bin/env fish
switch (uname)
case Darwin
	sed "s;/Users/jacebabin;$HOME;g" $DOTFILES/config/iterm/com.googlecode.iterm2.plist.example >$DOTFILES/config/iterm/com.googlecode.iterm2.plist
		and defaults write com.googlecode.iterm2 PrefsCustomFolder -string $DOTFILES/iterm
		and defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
end