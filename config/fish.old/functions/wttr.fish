function wttr -d "Prints out the weather"
	switch $argv[1]
	case ''
		curl -s https://wttr.in/phoenix | awk 'NR==2,NR==7'
	case '*'
		curl https://wttr.in/$argv[1] | awk 'NR==2,NR==7'
	end
end
