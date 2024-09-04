## Setup
First, install [`just`](https://github.com/casey/just#packages), for example:

```bash
# Ubuntu 24.04+
sudo apt install git just

# Or,
cargo install just
```

Then, set up a local clone:
```bash
mkdir -p ~/code/misc
cd ~/code/misc
git clone https://github.com/sed-i/justfiles.git
cd ~/code/misc/justfiles
```

Then, install by category:
```bash
just -f ubuntu-24.04.just charm-dev
# Or
just -f ubuntu-24.04.just desktop
```
