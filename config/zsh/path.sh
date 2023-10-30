# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# Set PATH so it includes user's local bin if it exists
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

# Include user scripts
if [ -d "$HOME/.scripts" ]; then
  PATH="$HOME/.scripts:$PATH"
fi

# Android Studio
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH=$ANDROID_HOME/emulator:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/platforms:$PATH
export PATH=$ANDROID_HOME/tools/bin:$PATH
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH

# PNPM
export PNPM_HOME="/Users/jacebabin/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# bun completions
[ -s "/Users/jacebabin/.bun/_bun" ] && source "/Users/jacebabin/.bun/_bun"

# Bun
export BUN_INSTALL="/Users/jacebabin/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

