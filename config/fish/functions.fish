function sudo!!
    eval sudo $history[1]
end

# `shellswitch [bash|zsh|fish]`
function shellswitch
    chsh -s (brew --prefix)/bin/$argv
end

function bubc
    brew upgrade && brew cleanup
end

function bubo
    brew update && brew outdated
end

function bubu
    bubo && bubc
end

# Update brew and flutter
function ud
    bubu && flutter upgrade
end
