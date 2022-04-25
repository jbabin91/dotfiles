function pubkey
	more ~/.ssh/github.pub | pbcopy
		and echo (set_color brblue)'-> Public key copied to clipboard'
end
