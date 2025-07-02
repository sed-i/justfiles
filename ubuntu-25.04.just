# Install deps:
# sudo apt install git just
# mkdir -p ~/code/misc && cd ~/code/misc
# git clone https://github.com/sed-i/justfiles
# cd justfiles

# Usage:
# sudo just -f ubuntu-25.04.just desktop

# Most recipes in this justfile are run with sudo, but the intention
# is to have changes applied not to "root" but to the original user.
user := `echo ${SUDO_USER:-$USER}`
home := "/home" / user


_curl:
    sudo apt install -y curl

_neovim:
    sudo apt install -y neovim

dev-utils: _curl _neovim
    sudo apt install -y htop bat ripgrep

_desktop_cli_utils: dev-utils

_nushell:
    sudo snap install --classic nushell
    mkdir -p ~/.config/nushell/
    nu -c "config nu --default" > {{home}}/.config/nushell/config.nu
    nu -c "config env --default" > {{home}}/.config/nushell/env.nu
    
    grep -qxF '$env.EDITOR = "nvim"' "{{home}}/.config/nushell/config.nu" || echo '$env.EDITOR = "nvim"' >> "{{home}}/.config/nushell/config.nu"
    grep -qxF 'source ~/.aliases/git.nu' "{{home}}/.config/nushell/config.nu" || echo 'source ~/.aliases/git.nu' >> "{{home}}/.config/nushell/config.nu"
    grep -qxF 'source ~/.aliases/juju.nu' "{{home}}/.config/nushell/config.nu" || echo 'source ~/.aliases/juju.nu' >> "{{home}}/.config/nushell/config.nu"
    grep -qxF 'source ~/.aliases/misc.nu' "{{home}}/.config/nushell/config.nu" || echo 'source ~/.aliases/misc.nu' >> "{{home}}/.config/nushell/config.nu"
    grep -qxF 'source ~/.aliases/terraform.nu' "{{home}}/.config/nushell/config.nu" || echo 'source ~/.aliases/terraform.nu' >> "{{home}}/.config/nushell/config.nu"

_aliases:
    ln -sfn "$PWD/dotfiles/aliases" "{{home}}/.aliases"
    
    touch "{{home}}/.bash_aliases"
    grep -qxF '. ~/.aliases/git.sh' "{{home}}/.bash_aliases" || echo '. ~/.aliases/git.sh' >> "{{home}}/.bash_aliases"
    grep -qxF '. ~/.aliases/juju.sh' "{{home}}/.bash_aliases" || echo '. ~/.aliases/juju.sh' >> "{{home}}/.bash_aliases"
    grep -qxF '. ~/.aliases/misc.sh' "{{home}}/.bash_aliases" || echo '. ~/.aliases/misc.sh' >> "{{home}}/.bash_aliases"


tailscale: _curl
    # Ref: https://tailscale.com/kb/1527/install-ubuntu-2504
    # Add Tailscale's package signing key and repository:
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/plucky.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/plucky.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
    
    # Install
    sudo apt update
    sudo apt install -y tailscale
    
    echo "Remember to run `sudo tailscale up` when you're ready!" 


megasync:
    wget https://mega.nz/linux/repo/xUbuntu_25.04/amd64/megasync-xUbuntu_25.04_amd64.deb && sudo apt install -y "$PWD/megasync-xUbuntu_25.04_amd64.deb" && rm "$PWD/megasync-xUbuntu_25.04_amd64.deb"


mullvad-browser: _curl
    #!/usr/bin/env bash
    # Ref: https://mullvad.net/en/download/browser/linux
    # Download the Mullvad signing key
    sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc

    # Add the Mullvad repository server to apt
    echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable stable main" | sudo tee /etc/apt/sources.list.d/mullvad.list

    # Install the package
    sudo apt update
    sudo apt install -y mullvad-browser


desktop: _desktop_cli_utils _nushell tailscale megasync mullvad-browser
    sudo apt install -y rhythmbox gimp inkscape xournalpp keepassxc fonts-linuxlibertine fonts-freefont-otf ttf-mscorefonts-installer fonts-firacode
    sudo snap install multipass
    sudo snap install signal-desktop
    sudo snap install obsidian --classic

# [no-cd] = Run with the working directory set to directory in which just was invoked
[no-cd]
rip: abcde
    # -a = action
    # -p = pad track numbers with zeros
    # -V = verbosity
    abcde -VV -a default,cue,embedalbumart -o flac:"--best --verify" -p

[private]
abcde:
    sudo apt install -y abcde flac imagemagick mkcue
    sudo systemctl disable postfix
    sudo systemctl stop postfix

