welcome:
    # This is the first recipe, so it will be run when used without args
    echo Use 'just -l' to see the available recipes.

git:
	sudo apt install -y git

	# Set up config
	git config --global init.defaultBranch main

	# Set up global exclude file
	git config --global core.excludesFile "$HOME/.git-exclude-global"
	touch "$HOME/.git-exclude-global"
	grep -qxF '__pycache__/' "$HOME/.git-exclude-global" || echo '__pycache__/' >> "$HOME/.git-exclude-global"
	grep -qxF '.idea/' "$HOME/.git-exclude-global" || echo '.idea/' >> "$HOME/.git-exclude-global"

	git config --global alias.adog "log --all --decorate --oneline --graph"
	git config --global alias.adam "!func(){ git add -u && git commit --amend --no-edit; }; func"

cargo:
    curl https://sh.rustup.rs -sSf | sh

editor:
	cp dotfiles/.editorconfig "$HOME"

golang:
	sudo apt install -y golang-go

cli-tools: exa bat duf delta fd dust tree

git-tools: delta gitui

sysadmin: btop

btop:
	sudo apt install -y btop

dust: cargo
	# A more intuitive version of du in rust
	# https://github.com/bootandy/dust
	cargo install du-dust

fd:
	# A simple, fast and user-friendly alternative to 'find'
	# https://github.com/sharkdp/fd
	sudo apt install -y fd-find

exa:
	echo "Installing exa"

bat:
	echo "Installing bat"

duf:
	# Disk Usage/Free Utility - a better 'df' alternative
	# https://github.com/muesli/duf
	sudo apt install -y duf

delta: git cargo
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

bandwhich: cargo
	# NOT WORKING: wlp5s0: No such device (os error 19)
	# Terminal bandwidth utilization tool
	# https://github.com/imsnif/bandwhich
	cargo install bandwhich
	sudo setcap cap_sys_ptrace,cap_dac_read_search,cap_net_raw,cap_net_admin+ep $(which bandwhich)

dasel: golang
	# Select, put and delete data from JSON, TOML, YAML, XML and CSV files with a single tool.
	# https://github.com/TomWright/dasel
	GOBIN=$HOME/.local/bin go install github.com/tomwright/dasel/v2/cmd/dasel@master

gitui: cargo
	# https://github.com/extrawurst/gitui
	cargo install gitui

tree:
    sudo apt install -y tree

vm: tree duf fd btop editor git

leftwm: git cargo
    cargo install leftwm

    cat << EOF > /usr/share/xsessions/leftwm.desktop
    [Desktop Entry]
    Encoding=UTF-8
    Name=LeftWM
    Comment=A window manager for the adventurer
    Exec=$HOME/.cargo/bin/leftwm
    Type=Application
    DesktopNames=LeftWM
    EOF

    mkdir -p ~/.config/leftwm/themes
    git clone https://github.com/calebgasser/zexanima-leftwm-theme ~/.config/leftwm/themes/zexanima-leftwm-theme
    pushd
    cd ~/.config/leftwm/themes
    ln -s zexanima-leftwm-theme current
    popd

