# git

This role installs Git and configures an enhanced shell prompt with Git integration, providing real-time information about Git repositories directly in your terminal.

## Inputs

| Variable                  | Description                                | Default     |
| ------------------------- | ------------------------------------------ | ----------- |
| `bashrc_file`             | Path to bashrc file to modify              | `~/.bashrc` |
| `install_bash_completion` | Whether to install bash-completion         | `true`      |
| `include_host_prefix`     | Whether to include (host) prefix in prompt | `true`      |

## Manual Installation

Install Git and configure Git prompt:

```bash
# Install Git
sudo apt update
sudo apt install -y git

# Install bash-completion package (includes git-prompt)
sudo apt install -y bash-completion

# Add git prompt configuration to ~/.bashrc (with host prefix)
cat >> ~/.bashrc << 'EOF'
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="verbose"
export GIT_PS1_DESCRIBE_STYLE=contains
export GIT_PS1_SHOWCOLORHINTS=1
PRE='\[\033[01;31m\](host) \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]'
export PROMPT_COMMAND="__git_ps1 '${VIRTUAL_ENV:+($(basename "$VIRTUAL_ENV")) }$PRE' '$ '"
EOF

# Apply changes to current shell
source ~/.bashrc
```

For configuration without host prefix, use this block instead:

```bash
cat >> ~/.bashrc << 'EOF'
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="verbose"
export GIT_PS1_DESCRIBE_STYLE=contains
export GIT_PS1_SHOWCOLORHINTS=1
PRE='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]'
export PROMPT_COMMAND="__git_ps1 '${VIRTUAL_ENV:+($(basename "$VIRTUAL_ENV")) }$PRE' '$ '"
EOF
```
