# vscode

This role installs Visual Studio Code and extensions defined in the Autoware devcontainer configuration.

## Inputs

| Variable                 | Description                    | Default                                                         |
| ------------------------ | ------------------------------ | --------------------------------------------------------------- |
| `devcontainer_json_path` | Path to devcontainer.json file | `workspace/.devcontainer/universe-devel-cuda/devcontainer.json` |

## Manual Installation

```bash
# Install prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https wget gpg

# Add Microsoft GPG key and repository
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# Install VS Code
sudo apt-get update
sudo apt-get install -y code

# Install extensions (example)
code --install-extension ms-vscode.cpptools-extension-pack
code --install-extension ms-python.python
```
