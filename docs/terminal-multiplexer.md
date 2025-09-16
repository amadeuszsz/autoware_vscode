# Terminal Multiplexer

This document explains how to use terminal multiplexers like tmux and zellij for managing terminal sessions in your Autoware development workflow. Which one to choose depends on your personal preference; both are powerful tools. Tmux is more widely used and has been around longer, while Zellij offers a more modern experience with additional features.

# Tmux Guide

## Basic Tmux Commands

### Starting Tmux

```bash
# Start a new tmux session
tmux

# Start a named session
tmux new -s session_name
```

### Key Bindings

All tmux commands start with a prefix key combination. By default, this is `Ctrl+b`, but our custom configuration uses a more ergonomic setup:

| Command                                         | Description                                                                                     |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `Ctrl+b`                                        | Prefix key - press this before any other command                                                |
| `Ctrl+b` then `c`                               | Create a new tab                                                                                |
| `Ctrl+b` then `0-9`                             | Switch to window 0-9                                                                            |
| `Ctrl+b` then `%`                               | Split window vertically                                                                         |
| `Ctrl+b` then `"`                               | Split window horizontally                                                                       |
| `Ctrl+b` then `arrow keys`                      | Navigate between panes                                                                          |
| `Ctrl+b` then `arrow keys` while holding `Ctrl` | Resize panes                                                                                    |
| `Ctrl+b` then `Ctrl+x`                          | Toggle synchronized input to all panes (broadcasting)                                           |
| `Ctrl+b` then `d`                               | Detach from session                                                                             |
| `Ctrl+b` then `[`                               | Enter copy mode (use arrow keys to navigate, "Space" to start selection, "y" to copy selection) |

### Session Management

```bash
# List all sessions
tmux ls

# Attach to a session
tmux attach -t session_name

# Kill a session
tmux kill-session -t session_name
```

## Example Autoware Workflow with Tmux

### Setting Up a Development Layout

1. Run VS Code with Dev Containers to activate container environment.

2. Start tmux:

   ```bash
   tmux
   ```

3. Create a layout for development with multiple panes:
   - `Ctrl+b` then `%` to split vertically
   - `Ctrl+b` then `"` to split horizontally
   - `Ctrl+b` then arrow keys to navigate between panes

4. Enter the devcontainer in all panes:
   - `Ctrl+b` then `Ctrl+x` to enable broadcasting
   - `cd ~/autoware` (or your workspace path)
   - `./.devcontainer/enter.sh`
   - `Ctrl+b` then `Ctrl+x` to disable broadcasting

### Example Development Session

1. Start tmux with a new session name:

   ```bash
   tmux new -s autoware
   ```

2. Split the terminal into four panes:
   - `Ctrl+b` then `%` (split vertically)
   - `Ctrl+b` then arrow keys to the right pane
   - `Ctrl+b` then `"` (split horizontally)
   - `Ctrl+b` then arrow keys to the bottom-right pane
   - `Ctrl+b` then `"` (split horizontally again)

3. Enter the devcontainer in all panes:
   - `Ctrl+b` then `Ctrl+x` (enable broadcasting)
   - `cd ~/autoware`
   - `./.devcontainer/enter.sh`
   - `Ctrl+b` then `Ctrl+x` (disable broadcasting)

## Advanced Tmux Features

### Copying

1. Enter copy mode:
   - `Ctrl+b` then `[`
2. Navigate to the start of the text
3. Press `Space` to start selection
4. Highlight the text you want to copy
5. Press `y` to copy to clipboard

### Nested Tmux Sessions

When using tmux on a remote server that also has tmux:

1. Use `Ctrl+b` then `b` to send commands to the inner session
2. For example: `Ctrl+b` then `b` then `c` creates a new window in the inner session

## Additional Resources

- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [Tmux Getting Started](https://github.com/tmux/tmux/wiki/Getting-Started)

# Zellij Guide

## Basic Zellij Commands

### Starting Zellij

```bash
# Start a new zellij session
zellij

# Start a named session
zellij --session session_name

# List sessions
zellij list-sessions

# Attach to a session
zellij attach session_name
```

### Key Bindings

Zellij uses a modal interface:

| Command  | Description        |
| -------- | ------------------ |
| `Ctrl+p` | Enter pane mode    |
| `Ctrl+t` | Enter tab mode     |
| `Ctrl+s` | Enter scroll mode  |
| `Ctrl+o` | Enter session mode |
| `Ctrl+q` | Quit Zellij        |

### Session Management

```bash
# List all sessions
zellij list-sessions

# Create a new named session
zellij --session my_session

# Attach to a session
zellij attach my_session

# Kill a session
zellij kill-session my_session
```

## Example Autoware Workflow with Zellij

1. Start a new named session:

   ```bash
   zellij --session autoware
   ```

2. Create a layout with multiple panes:
   - `Ctrl+p` to enter pane mode
   - Split panes with shortcuts as described in the bottom status bar

3. Enter the devcontainer in all panes:
   - `Ctrl+t` to enter tab mode, then `s` to synchronize
   - `cd ~/autoware`
   - `./.devcontainer/enter.sh`
   - `Ctrl+t` then `s` to disable synchronization

## Additional Resources

- [Zellij Documentation](https://zellij.dev/documentation/)
- [Zellij GitHub Repository](https://github.com/zellij-org/zellij)
