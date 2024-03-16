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

# Java Home
# export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home"

# Android Studio
# export ANDROID_HOME=$HOME/Library/Android/sdk
# export PATH=$PATH:$ANDROID_HOME/emulator
# export PATH=$PATH:$ANDROID_HOME/platform-tools

# PNPM
export PNPM_HOME="/Users/jacebabin/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# bun completions
[ -s "/Users/jacebabin/.bun/_bun" ] && source "/Users/jacebabin/.bun/_bun"

# Bun
export BUN_INSTALL="/Users/jacebabin/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
