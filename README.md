# mcpelauncher [![CircleCI](https://circleci.com/gh/TheBrokenRail/mcpelauncher-apt/tree/master.svg?style=svg)](https://circleci.com/gh/TheBrokenRail/mcpelauncher-apt/tree/master)

### How to Use

```bash
# Add Repo
sudo dpkg --add-architecture i386
wget -O - https://thebrokenrail.github.io/mcpelauncher-apt/conf/key | sudo apt-key add -
sudo add-apt-repository 'deb https://thebrokenrail.github.io/mcpelauncher-apt/ bionic main'
sudo apt update

# Install
sudo apt install msa-daemon msa-ui-qt mcpelauncher-client mcpelauncher-ui-qt mcpelauncher-ui-qt-icon mcpelauncher-linux-bin

# Install Server
sudo apt install mcpelauncher-server
```
### Info

This has only been tested on Ubuntu 18.04.
