function brew -w brew
	switch $argv[1]
	case cleanup
		brew-cleanup
	case bump
		brew-bump
	case '*'
		command brew $argv
	end
end

function bb -d "Shortcut for brew bump"
  brew bump
end

function bc -d "Shortcut for brew cleanup"
  brew cleanup
end
