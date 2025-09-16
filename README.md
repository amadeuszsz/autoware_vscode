# Autoware Development Environment

A comprehensive development environment setup for Autoware projects using VS Code Dev Containers with Docker support.

## Overview

This repository provides a complete development environment for Autoware projects, featuring:

- **Docker-based development containers** with pre-configured Autoware environment
- **VS Code project** configuration for seamless development experience
- **System optimization using Ansible** for host machine configuration

## Quick Start

### 1. Requirements

- **Ubuntu 22.04** operating system
- **NVIDIA GPU** for CUDA support

### 2. Setup Your Environment

```bash
# Clone this repository
git clone https://github.com/autowarefoundation/autoware_vscode.git ~/autoware_vscode

# Install dependencies using Ansible (recommended)
sudo apt purge ansible
sudo apt -y update && sudo apt -y install pipx
python3 -m pipx ensurepath
pipx install --include-deps --force "ansible==6.*"
cd ~/autoware_vscode && ansible-galaxy collection install -f -r "ansible-galaxy-requirements.yaml"
ansible-playbook autoware_vscode.dev_env.setup_host -K
```

### 3. Setup any Autoware-based project

```bash
git clone https://github.com/autowarefoundation/autoware.git ~/autoware
mkdir -p ~/autoware/src && cd ~/autoware
vcs import src < autoware.repos
vcs import src < autoware-nightly.repos

# Setup your development environment
cd ~/autoware_vscode && ./setup_workspace.sh

# Pull docker image
docker pull ghcr.io/autowarefoundation/autoware:universe-devel-cuda
```

### 4. Start Development

1. Open VS Code
2. Open Dev Container:
   - Open command palette (`Ctrl+Shift+P`)
   - Type and select `Dev Containers: Open Folder in Container...`
   - Select your Autoware workspace
   - Choose Dev Containers configuration (recommended: `universe-devel-cuda`) and wait till it's built.
3. Build the workspace:
   - Open command palette (`Ctrl+Shift+P`)
   - Type and select `Tasks: Run Task`
   - Select `Build: Workspace (Release)`
   - Wait till the build is complete
4. Trigger clangd indexing:
   - Open command palette (`Ctrl+Shift+P`)
   - Type and select `clangd: Restart language server`
   - Wait till the indexing is complete
5. Start development!

## Documentation

Additional documentation is available in the [docs/](docs/) directory:

- [Debugging](docs/debugging.md) - Debugging Autoware code
- [Terminal Multiplexer](docs/terminal-multiplexer.md) - Working with terminal multiplexers
- [Visualization](docs/visualization.md) - Using visualization tools
