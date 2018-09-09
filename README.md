# mcpelauncher

### How to Use

```bash
# Add Repo
sudo dpkg --add-architecture i386
wget -O - https://thebrokenrail.github.io/mcpelauncher/conf/key | sudo apt-key add -
sudo add-apt-repository 'deb https://thebrokenrail.github.io/mcpelauncher/ bionic main'
sudo apt update

# Install
sudo apt install sudo apt install msa-daemon msa-ui-qt mcpelauncher-client mcpelauncher-ui-qt mcpelauncher-ui-qt-icon mcpelauncher-linux-bin

# Install Server
sudo apt install mcpelauncher-server
```
### Info

This has only been tested on Ubuntu 18.04.
