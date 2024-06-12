# Install deps:
# sudo apt install git just
# mkdir -p ~/code/misc && cd ~/code/misc
# git clone https://github.com/sed-i/justfiles
# cd justfiles

# Usage:
# just -f ubuntu-24.04.just git sysadmin dev desktop

git:
    sudo apt install -y git

    # Config
    git config --global user.email 82407168+sed-i@users.noreply.github.com
    git config --global user.name sed-i

    git config --global user.signingkey "$HOME/.secrets/github-canonical-ssh.pub"
    git config --global gpg.format ssh
    git config --global commit.gpgsign true

    git config --global init.defaultBranch main
    git config --global pull.ff only

    git config --global core.excludesFile "$HOME/.git-exclude-global"
    touch "$HOME/.git-exclude-global"
    grep -qxF '__pycache__/' "$HOME/.git-exclude-global" || echo '__pycache__/' >> "$HOME/.git-exclude-global"
    grep -qxF '.idea/' "$HOME/.git-exclude-global" || echo '.idea/' >> "$HOME/.git-exclude-global"

    git config --global cola.spellcheck false
    git config --global credential.helper "store --file=$HOME/.secrets/.git-credentials"


    # Aliases
    git config --global alias.alias "config --get-regexp alias"
    git config --global alias.adog "log --all --decorate --oneline --graph"
    git config --global alias.adam "!func(){ git add -u && git commit --amend --no-edit; }; func"
    git config --global alias.co checkout
    git config --global alias.st status
    git config --global alias.sdiff "difftool --staged --dir-diff"


rust:
    sudo apt install -y rustup
    rustup toolchain install stable

aliases:
    ln -sf "$PWD/dotfiles/aliases" "$HOME/.aliases"
    
    touch "$HOME/.bash_aliases"
    grep -qxF '. ~/.aliases/git.sh' "$HOME/.bash_aliases" || echo '. ~/.aliases/git.sh' >> "$HOME/.bash_aliases"
    grep -qxF '. ~/.aliases/juju.sh' "$HOME/.bash_aliases" || echo '. ~/.aliases/juju.sh' >> "$HOME/.bash_aliases"
    grep -qxF '. ~/.aliases/misc.sh' "$HOME/.bash_aliases" || echo '. ~/.aliases/misc.sh' >> "$HOME/.bash_aliases"
    
    test -f "$HOME/.config/nushell/config.nu" && grep -qxF '$env.EDITOR = "nvim"' "$HOME/.config/nushell/config.nu" || echo '$env.EDITOR = "nvim"' >> "$HOME/.config/nushell/config.nu"
    test -f "$HOME/.config/nushell/config.nu" && grep -qxF 'source ~/.aliases/git.nu' "$HOME/.config/nushell/config.nu" || echo 'source ~/.aliases/git.nu' >> "$HOME/.config/nushell/config.nu"
    test -f "$HOME/.config/nushell/config.nu" && grep -qxF 'source ~/.aliases/juju.nu' "$HOME/.config/nushell/config.nu" || echo 'source ~/.aliases/juju.nu' >> "$HOME/.config/nushell/config.nu"
    test -f "$HOME/.config/nushell/config.nu" && grep -qxF 'source ~/.aliases/misc.nu' "$HOME/.config/nushell/config.nu" || echo 'source ~/.aliases/misc.nu' >> "$HOME/.config/nushell/config.nu"

sysadmin: aliases
    sudo apt install -y btop tree ripgrep curl

    # A simple, fast and user-friendly alternative to 'find'
    # https://github.com/sharkdp/fd
    sudo apt install -y fd-find

    # A modern replacement for 'ls'
    # https://github.com/eza-community/eza
    sudo apt install -y eza

    # A cat(1) clone with wings.
    # https://github.com/sharkdp/bat
    sudo apt install -y bat

    # Disk Usage/Free Utility - a better 'df' alternative
    # https://github.com/muesli/duf
    sudo apt install -y duf


dev: git rust sysadmin
    # Config
    ln -sf "$PWD/dotfiles/.editorconfig" "$HOME/.editorconfig"

    # Toolkits
    sudo apt install -y golang-go python3-virtualenv neovim

    # A more intuitive version of du in rust
    # https://github.com/bootandy/dust
    cargo install du-dust

    # Git terminal UI
    # https://github.com/extrawurst/gitui
    cargo install gitui

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

    # Nushell
    # https://github.com/nushell/nushell
    sudo apt install -y pkg-config libssl-dev
    cargo install nu

tui-fonts:
    sudo apt install -y fonts-firacode

kitty: tui-fonts
    sudo apt install -y kitty
    mkdir -p "$HOME/.config/kitty"
    ln -sf "$PWD/dotfiles/kitty.conf" "$HOME/.config/kitty/kitty.conf"


desktop: git kitty
    sudo apt install -y gedit rhythmbox notepadqq gimp inkscape xournalpp keepassxc
    sudo snap install multipass
    sudo snap install signal-desktop
    sudo snap install obsidian --classic

    # BeyondCompare
    sudo sh -c 'TEMPDIR=$(mktemp -d) wget -O "$TEMPDIR/bcompare-4.4.7.28397_amd64.deb" https://www.scootersoftware.com/files/bcompare-4.4.7.28397_amd64.deb && sudo apt -y install "$TEMPDIR/bcompare-4.4.7.28397_amd64.deb"'
    git config --global merge.tool bc
    git config --global diff.tool bc

    # Megasync
    sudo sh -c 'TEMPDIR=$(mktemp -d) wget -O "$TEMPDIR/megasync-xUbuntu_24.04_amd64.deb" https://mega.nz/linux/repo/xUbuntu_24.04/amd64/megasync-xUbuntu_24.04_amd64.deb && sudo apt install -y "$TEMPDIR/megasync-xUbuntu_24.04_amd64.deb"'

    sudo sh -c 'TEMPDIR=$(mktemp -d) wget -O "$TEMPDIR/nautilus-megasync-xUbuntu_24.04_amd64.deb" https://mega.nz/linux/repo/xUbuntu_24.04/amd64/nautilus-megasync-xUbuntu_24.04_amd64.deb && sudo apt install -y "$TEMPDIR/nautilus-megasync-xUbuntu_24.04_amd64.deb"'

    # Tailscale
    # Add Tailscale's GPG key
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    # Add the tailscale repository
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
    # Install Tailscale
    sudo apt update && sudo apt install -y tailscale

    # Mullvad browser
    wget -qO- https://mullvad.net/en/download/browser/linux-x86_64/latest | tar xJ -C ~/Downloads/

    # Jetbrains
    sudo apt install libfuse2
    wget -qO- https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.3.1.31116.tar.gz | tar xz -C ~/Downloads
    ~/Downloads/jetbrains-toolbox-2.3.1.31116/jetbrains-toolbox


