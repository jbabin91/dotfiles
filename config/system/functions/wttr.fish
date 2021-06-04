function wttr -d "Prints out the weather"
	switch $argv[1]
	case ''
		curl https://wttr.in/phoenix
	case '*'
		curl https://wttr.in/$argv[1]
	end
end
