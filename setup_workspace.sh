#!/usr/bin/env bash

# Autoware Workspace Setup Script
#
# Usage:
#   ./setup_workspace.sh [--yes] [WORKSPACE_PATH]
#   ./setup_workspace.sh --help

set -euo pipefail

show_help() {
    cat <<'EOF'
Autoware Workspace Setup Script

This script copies the VS Code and Dev Container templates into an Autoware
workspace and prepares the default host-side mount directories.

USAGE:
  ./setup_workspace.sh [WORKSPACE_PATH]
  ./setup_workspace.sh --yes [WORKSPACE_PATH]
  ./setup_workspace.sh --help

OPTIONS:
  --yes, -y   Answer "yes" to all prompts.
  --help, -h  Show this help information.

EXAMPLES:
  ./setup_workspace.sh
  ./setup_workspace.sh ~/autoware
  ./setup_workspace.sh --yes ~/autoware

BACKUP LOCATION:
  /tmp/autoware_vscode/backup/TIMESTAMP/
EOF
}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="/tmp/autoware_vscode/backup"

AUTO_YES=false
BACKUP_TIMESTAMP=""
workspace_path=""

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

get_backup_timestamp() {
    if [[ -z $BACKUP_TIMESTAMP ]]; then
        BACKUP_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
    fi
    echo "$BACKUP_TIMESTAMP"
}

ask_question() {
    local question="$1"
    local response

    if [[ $AUTO_YES == true ]]; then
        echo -e "\n${YELLOW}$question${NC}"
        echo -e "${GREEN}[AUTO: YES]${NC}"
        return 0
    fi

    echo -e "\n${YELLOW}$question${NC}"
    echo -en "${BLUE}[y/N/A] (Y=yes once, N=no, A=all yes):${NC} "
    read -r response

    case "${response:-n}" in
    [yY] | [yY][eE][sS]) return 0 ;;
    [aA] | [aA][lL][lL])
        AUTO_YES=true
        print_info "All remaining questions will be answered 'yes'"
        return 0
        ;;
    *) return 1 ;;
    esac
}

backup_workspace_config() {
    local source_dir="$1"
    local config_name="$2"

    if [[ ! -d $source_dir ]]; then
        print_info "No existing $config_name found in workspace, skipping backup"
        return 0
    fi

    local timestamp
    local backup_dir

    timestamp="$(get_backup_timestamp)"
    backup_dir="${BACKUP_ROOT}/${timestamp}/${config_name}"

    mkdir -p "$(dirname "$backup_dir")"
    print_info "Moving existing $config_name to backup: $backup_dir"
    mv "$source_dir" "$backup_dir"
    print_success "Moved to: $backup_dir"
}

check_dependencies() {
    local missing_deps=()

    if ! command -v code >/dev/null 2>&1; then
        missing_deps+=("VS Code")
    fi

    if ! command -v docker >/dev/null 2>&1; then
        missing_deps+=("Docker")
    fi

    if ! command -v vcs >/dev/null 2>&1; then
        missing_deps+=("vcstool")
    fi

    if ! command -v nvidia-smi >/dev/null 2>&1; then
        missing_deps+=("NVIDIA driver (required for CUDA profile)")
    fi

    if ! dpkg-query -W -f='${Status}' nvidia-container-toolkit 2>/dev/null | grep -q "install ok installed"; then
        missing_deps+=("NVIDIA Container Toolkit (required for CUDA profile)")
    fi

    if [[ ! -f /etc/sysctl.d/10-cyclone-max.conf ]]; then
        missing_deps+=("CycloneDDS configuration")
    fi

    if [[ ! -f /etc/systemd/system/multicasting.service ]]; then
        missing_deps+=("Multicasting service")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        printf '%s\n' "${missing_deps[@]}"
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
    --help | -h)
        show_help
        exit 0
        ;;
    --yes | -y)
        AUTO_YES=true
        shift
        ;;
    -*)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
    *)
        if [[ -n $workspace_path ]]; then
            print_error "Workspace path already provided: $workspace_path"
            exit 1
        fi
        workspace_path="$1"
        shift
        ;;
    esac
done

print_info "=== Autoware Workspace Setup ==="
print_info "This script copies the workspace templates and prepares host directories."

if [[ -z $workspace_path ]]; then
    echo ""
    echo -e "${YELLOW}Enter the path to your Autoware workspace:${NC}"
    echo -en "${BLUE}:${NC} "
    read -r workspace_path
fi

if [[ -z $workspace_path ]]; then
    print_error "No workspace path provided."
    exit 1
fi

workspace_path="${workspace_path/#\~/$HOME}"

if [[ ! -d $workspace_path ]]; then
    print_error "Workspace directory does not exist: $workspace_path"
    exit 1
fi

print_success "Using workspace: $workspace_path"

vscode_exists=false
devcontainer_exists=false

if [[ -d "$workspace_path/.vscode" ]]; then
    vscode_exists=true
    print_warning "Found existing .vscode directory in workspace"
fi

if [[ -d "$workspace_path/.devcontainer" ]]; then
    devcontainer_exists=true
    print_warning "Found existing .devcontainer directory in workspace"
fi

if [[ $vscode_exists == true || $devcontainer_exists == true ]]; then
    if ! ask_question "Continue and back up the existing VS Code / devcontainer configuration?"; then
        print_info "Setup cancelled by user"
        exit 0
    fi
fi

if ask_question "Copy VS Code and Dev Container configuration into the workspace?"; then
    local_template_dir="$SCRIPT_DIR/workspace"

    if [[ ! -d $local_template_dir ]]; then
        print_error "Template directory not found: $local_template_dir"
        exit 1
    fi

    if [[ -d "$local_template_dir/.vscode" ]]; then
        backup_workspace_config "$workspace_path/.vscode" ".vscode"
        cp -a "$local_template_dir/.vscode" "$workspace_path/"
        print_success "VS Code configuration copied to workspace"
    fi

    if [[ -d "$local_template_dir/.devcontainer" ]]; then
        backup_workspace_config "$workspace_path/.devcontainer" ".devcontainer"
        cp -a "$local_template_dir/.devcontainer" "$workspace_path/"
        print_success "Devcontainer configuration copied to workspace"
    fi
else
    print_info "Skipping workspace configuration copy"
fi

if ask_question "Create the default host directories used by the devcontainers?"; then
    autoware_data_dir="$HOME/autoware_data"
    autoware_map_dir="$HOME/autoware_map"
    webauto_dir="$HOME/.webauto"
    lichtblick_dir="$HOME/.config/Lichtblick"
    ccache_dir="$HOME/.ccache"

    directories=(
        "$autoware_data_dir"
        "$autoware_map_dir"
        "$HOME/.ssh"
        "$webauto_dir"
        "$lichtblick_dir"
        "$ccache_dir"
    )

    for dir in "${directories[@]}"; do
        if [[ -d $dir ]]; then
            print_info "Directory already exists: $dir"
            continue
        fi

        print_info "Creating directory: $dir"
        mkdir -p "$dir"
        print_success "Created: $dir"
    done
else
    print_info "Skipping directory creation"
fi

print_info "Checking system dependencies..."
readarray -t missing_deps < <(check_dependencies)

if [[ ${#missing_deps[@]} -eq 0 ]]; then
    print_success "All dependencies are installed"
else
    print_warning "Some dependencies are missing or only needed for specific profiles:"
    for dep in "${missing_deps[@]}"; do
        if [[ -n $dep ]]; then
            print_warning "  - $dep"
        fi
    done
    print_info "Use README.md and ansible/playbooks/setup_host.yaml to install the missing pieces."
fi

echo ""
print_success "=== Setup Complete ==="
print_info "Workspace location: $workspace_path"
print_info "Backup directory: $BACKUP_ROOT"
