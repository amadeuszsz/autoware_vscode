# Autoware Development Environment

A comprehensive development environment setup for Autoware projects using VS Code Dev Containers with Docker support.

## Overview

This repository provides a complete development environment for Autoware projects, featuring:

- **Docker-based development containers** with pre-configured Autoware environment
- **VS Code project** configuration for seamless development experience
- **System optimization using Ansible** for host machine configuration

## Quick Start

### 1. Requirements

- **Ubuntu 22.04 or 24.04** operating system
- **NVIDIA GPU** only if you plan to use the `universe-devel-cuda` profile

### 2. Host Setup

```bash
# Clone this repository
sudo apt -y update && sudo apt -y install git
git clone https://github.com/tier4/autoware_vscode.git ~/autoware_vscode

# Install dependencies using Ansible (recommended)
sudo apt purge ansible
sudo apt -y update && sudo apt -y install pipx
python3 -m pipx ensurepath
pipx install --include-deps --force "ansible==10.*"
pipx ensurepath && source ~/.bashrc

# Configure the host
cd ~/autoware_vscode
ansible-playbook ansible/playbooks/setup_host.yaml -K
```

### 3. Workspace Setup

```bash
# Clone your Autoware-based project (we use the main Autoware repository as an example)
git clone https://github.com/autowarefoundation/autoware.git ~/autoware
mkdir -p ~/autoware/src && cd ~/autoware

# Note: your repos files may be located in a different path
vcs import src < repositories/autoware.repos
vcs import src < repositories/autoware-nightly.repos

# Setup your development environment
cd ~/autoware_vscode && ./setup_workspace.sh --yes ~/autoware

# Pull docker image (you might need to reboot to apply group Docker permissions)
docker pull ghcr.io/autowarefoundation/autoware:universe-devel-cuda
```

### 4. Code Development

1. Open VS Code
2. Open Dev Container:
   - Open command palette (`Ctrl+Shift+P`)
   - Type and select `Dev Containers: Open Folder in Container...`
   - Select your Autoware workspace
   - Choose a Dev Container configuration:
     - `core-devel`: lightweight core Autoware setup
     - `universe-devel`: full Autoware Universe setup without CUDA
     - `universe-devel-cuda`: full Autoware Universe setup with CUDA
   - Wait until the container is built and the startup tasks finish
3. Build the workspace:
   - Open command palette (`Ctrl+Shift+P`)
   - Type and select `Tasks: Run Task`
   - Select `Build: Workspace (Release)`
   - Wait till the build is complete
4. Trigger clangd indexing:
   - Open any C++ related file in VS Code
   - Wait till the indexing is complete
5. Start development!

## Notes

- `setup_workspace.sh` stores backups in `/tmp/autoware_vscode/backup/`.
- The default mounted host paths are `~/autoware_data`, `~/autoware_map`, `~/.ssh`, `~/.webauto`, `~/.config/Lichtblick`, and `~/.ccache`.
- VS Code runs the ROS dependency install task and the CSpell refresh task on folder open.

## Documentation

Additional documentation is available in the [docs/](docs/) directory:

- [Debugging](docs/debugging.md) - Debugging Autoware code
- [Terminal Multiplexer](docs/terminal-multiplexer.md) - Working with terminal multiplexers
- [Visualization](docs/visualization.md) - Using visualization tools
