# Install deps:
# sudo apt install git just
# mkdir -p ~/code/misc && cd ~/code/misc
# git clone https://github.com/sed-i/justfiles
# cd justfiles

# Usage:
# just -f ubuntu-24.04.just charm-dev
# just -f ubuntu-24.04.just desktop

update:
    sudo apt update

neovim:
    sudo apt install -y neovim

bare: update neovim
    sudo apt install -y git curl tree btop htop ripgrep fd-find eza bat duf

    # A simple, fast and user-friendly alternative to 'find'
    # https://github.com/sharkdp/fd

    # A modern replacement for 'ls'
    # https://github.com/eza-community/eza

    # A cat(1) clone with wings.
    # https://github.com/sharkdp/batt

    # Disk Usage/Free Utility - a better 'df' alternative
    # https://github.com/muesli/duf

delta: git
    # A syntax-highlighting pager for git, diff, and grep output
    # https://github.com/dandavison/delta
    sudo apt install -y git-delta

    git config --global core.pager delta
    git config --global interactive.diffFilter delta --color-only
    git config --global diff.colorMoved default
    # use n and N to move between diff sections
    git config --global delta.navigate true
    git config --global delta.side-by-side true
    git config --global delta.line-numbers true
    
beyondcompare: bare
    sudo apt install -y libqt5printsupport5
    curl -L -o /tmp/bcompare-5.0.2.30045_amd64.deb https://www.scootersoftware.com/files/bcompare-5.0.2.30045_amd64.deb && sudo dpkg --refuse-downgrade -i /tmp/bcompare-5.0.2.30045_amd64.deb
    
    git config --global merge.tool bc
    git config --global diff.tool bc
    

git: bare
    sudo apt install -y git
    
    # Config
    git config --global user.email 82407168+sed-i@users.noreply.github.com
    git config --global user.name sed-i

    git config --global user.signingkey "$HOME/.secrets/github-canonical-ssh.pub"
    git config --global gpg.format ssh
    git config --global commit.gpgsign true

    git config --global init.defaultBranch main
    git config --global pull.ff only

    git config --global core.excludesFile "$PWD/dotfiles/git/git-exclude-global"
    git config --global core.hooksPath "$PWD/dotfiles/git/hooks"

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
    #sudo apt install -y rustup
    #rustup toolchain install stable

aliases: bare
    ln -sf "$PWD/dotfiles/aliases" "$HOME/.aliases"
    
    touch "$HOME/.bash_aliases"
    grep -qxF '. ~/.aliases/git.sh' "$HOME/.bash_aliases" || echo '. ~/.aliases/git.sh' >> "$HOME/.bash_aliases"
    grep -qxF '. ~/.aliases/juju.sh' "$HOME/.bash_aliases" || echo '. ~/.aliases/juju.sh' >> "$HOME/.bash_aliases"
    grep -qxF '. ~/.aliases/misc.sh' "$HOME/.bash_aliases" || echo '. ~/.aliases/misc.sh' >> "$HOME/.bash_aliases"
    
    test -f "$HOME/.config/nushell/config.nu" && echo "" >> "$HOME/.config/nushell/config.nu"
    test -f "$HOME/.config/nushell/config.nu" && grep -qxF '$env.EDITOR = "nvim"' "$HOME/.config/nushell/config.nu" || echo '$env.EDITOR = "nvim"' >> "$HOME/.config/nushell/config.nu"
    test -f "$HOME/.config/nushell/config.nu" && grep -qxF 'source ~/.aliases/git.nu' "$HOME/.config/nushell/config.nu" || echo 'source ~/.aliases/git.nu' >> "$HOME/.config/nushell/config.nu"
    test -f "$HOME/.config/nushell/config.nu" && grep -qxF 'source ~/.aliases/juju.nu' "$HOME/.config/nushell/config.nu" || echo 'source ~/.aliases/juju.nu' >> "$HOME/.config/nushell/config.nu"
    test -f "$HOME/.config/nushell/config.nu" && grep -qxF 'source ~/.aliases/misc.nu' "$HOME/.config/nushell/config.nu" || echo 'source ~/.aliases/misc.nu' >> "$HOME/.config/nushell/config.nu"


dev: bare rust sysadmin
    # Config
    ln -sf "$PWD/dotfiles/.editorconfig" "$HOME/.editorconfig"

    # Toolkits
    sudo apt install -y golang-go python3-virtualenv

    # A more intuitive version of du in rust
    # https://github.com/bootandy/dust
    # cargo install du-dust

    # Git terminal UI
    # https://github.com/extrawurst/gitui
    # cargo install gitui

    # Nushell
    # https://github.com/nushell/nushell
    # sudo apt install -y pkg-config libssl-dev
    # cargo install nu

tui-fonts:
    sudo apt install -y fonts-firacode

kitty: tui-fonts
    sudo apt install -y kitty kitty-doc kitty-terminfo
    mkdir -p "$HOME/.config/kitty"
    ln -sf "$PWD/dotfiles/kitty.conf" "$HOME/.config/kitty/kitty.conf"


desktop: git kitty
    sudo apt install -y gedit rhythmbox notepadqq gimp inkscape xournalpp keepassxc
    sudo snap install multipass
    sudo snap install signal-desktop
    sudo snap install obsidian --classic


charm-dev: git delta neovim aliases
    sudo apt install -y kitty-terminfo
