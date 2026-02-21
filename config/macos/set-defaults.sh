#!/bin/sh
# Sets macOS defaults for a new machine.
#
# Run ./config/macos/set-defaults.sh and restart for changes to take effect.

if [ "$(uname -s)" != "Darwin" ]; then
	exit 0
fi

echo ""
echo "› System:"

echo "  › Disable press-and-hold for keys in favor of key repeat"
defaults write -g ApplePressAndHoldEnabled -bool false

echo "  › Set a really fast key repeat"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

echo "  › Set dark interface style"
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

echo "  › Disable smart quotes and smart dashes"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "  › Disable auto-correct"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "  › Don't automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false

echo "  › Show the ~/Library folder"
chflags nohidden ~/Library

echo "  › Avoid the creation of .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo ""
echo "› Finder:"

echo "  › Always open everything in Finder's list view"
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

echo "  › Show status bar"
defaults write com.apple.finder ShowStatusBar -bool true

echo "  › Show path bar"
defaults write com.apple.finder ShowPathbar -bool true

echo "  › Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "  › Save to disk by default, instead of iCloud"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo ""
echo "› Dock:"

echo "  › Set icon size of Dock items to 44 pixels"
defaults write com.apple.dock tilesize -int 44

echo "  › Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true

echo ""
echo "› Restart affected apps"
for app in "Dock" "Finder" "SystemUIServer"; do
	killall "$app" >/dev/null 2>&1
done

echo ""
echo "Done. Some changes may require a logout/restart to take effect."
