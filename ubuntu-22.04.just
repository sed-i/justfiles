git:
	sudo apt install git

	# Set up global exclude file
	git config --global core.excludesFile "$HOME/.git-exclude-global"
	touch "$HOME/.git-exclude-global"
	grep -qxF '__pycache__/' "$HOME/.git-exclude-global" || echo '__pycache__/' >> "$HOME/.git-exclude-global"
	grep -qxF '.idea/' "$HOME/.git-exclude-global" || echo '.idea/' >> "$HOME/.git-exclude-global"

	git config --global alias.adog log --all --decorate --oneline --graph
	git config --global alias.adam !func(){ git add -u && git commit --amend --no-edit; }; func

editor:
	cp dotfiles/.editorconfig "$HOME"

golang:
	sudo apt install golang-go

cli-tools: exa bat duf delta fd dust

git-tools: delta gitui

sysadmin: btop

btop:
	sudo apt install btop

dust:
	# A more intuitive version of du in rust 
	# https://github.com/bootandy/dust
	cargo install du-dust

fd:
	# A simple, fast and user-friendly alternative to 'find' 
	# https://github.com/sharkdp/fd
	sudo apt install fd-find

exa:
	echo "Installing exa"

bat:
	echo "Installing bat"

duf:
	# Disk Usage/Free Utility - a better 'df' alternative 
	# https://github.com/muesli/duf
	sudo apt install duf

delta: git
	# A syntax-highlighting pager for git, diff, and grep output
	# https://github.com/dandavison/delta
	
	cargo install git-delta
	git config --global core.pager delta
	git config --global interactive.diffFilter delta --color-only
	git config --global diff.colorMoved default

	# use n and N to move between diff sections
	git config --global delta.navigate true
	git config --global delta.side-by-side true
	git config --global delta.line-numbers true

bandwhich:
	# NOT WORKING: wlp5s0: No such device (os error 19)
	# Terminal bandwidth utilization tool
	# https://github.com/imsnif/bandwhich
	cargo install bandwhich
	sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep $(which bandwhich)

dasel: golang
	# Select, put and delete data from JSON, TOML, YAML, XML and CSV files with a single tool.
	# https://github.com/TomWright/dasel
	GOBIN=$HOME/.local/bin go install github.com/tomwright/dasel/v2/cmd/dasel@master

gitui:
	# https://github.com/extrawurst/gitui
	cargo install gitui