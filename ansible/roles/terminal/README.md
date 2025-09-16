# terminal

This role installs and configures terminal multiplexers (tmux or zellij) for Autoware development environments.

## Inputs

| Variable           | Description                     | Default        |
| ------------------ | ------------------------------- | -------------- |
| `install_tmux`     | Whether to install tmux         | `true`         |
| `install_zellij`   | Whether to install zellij       | `false`        |
| `tmux_config_file` | Path to tmux configuration file | `~/.tmux.conf` |

## Manual Installation

```bash
# Install tmux
sudo apt update
sudo apt install -y tmux xclip

# Configure tmux
cat > ~/.tmux.conf << 'EOF'
# Improve colors
set -g default-terminal "screen-256color"

# Set scrollback buffer size
set -g history-limit 50000

# Enable mouse support
set -g mouse on

# Start window and pane indices at 1
set -g base-index 1
set -g pane-base-index 1

# Broadcast to all panes
bind C-x setw synchronize-panes

# Easy config reload
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Vim-like pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Copy-paste integration
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
EOF

# Optional: Install zellij
curl -s https://raw.githubusercontent.com/zellij-org/zellij/main/install.sh | bash
```
