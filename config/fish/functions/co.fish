function co -d "quick cd into $PROJECTS"
	switch $argv[1]
	case ''
		cd $PROJECTS
	case '*'
		cd $PROJECTS/$argv[1]
	end
end

function __co_complete
	set arg (commandline -ct)
	set saved_pwd $PWD

	builtin cd $PROJECTS
		and complete -C "cd $arg"

	builtin cd $saved_pwd
end

complete --command co --arguments '(__co_complete)'
