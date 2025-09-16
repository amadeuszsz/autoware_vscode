#!/bin/bash

# Autoware Workspace Setup Script
# This script sets up the workspace directory for Autoware development
#
# Usage:
#   ./setup_workspace.sh                    - Interactive mode with prompts
#   ./setup_workspace.sh /path/to/workspace - Quick setup mode (auto-yes to all questions)
#   ./setup_workspace.sh --help             - Show help information

# Function to show help
show_help() {
    echo "Autoware Workspace Setup Script"
    echo ""
    echo "This script sets up your workspace directory for Autoware development."
    echo "It copies the VS Code and Dev Containers configurations to your workspace."
    echo ""
    echo "USAGE:"
    echo "  $0                    Interactive mode with prompts"
    echo "  $0 /path/to/workspace Quick setup mode (auto-yes to all questions)"
    echo "  $0 --help             Show this help information"
    echo ""
    echo "EXAMPLES:"
    echo "  $0                    # Interactive setup with prompts"
    echo "  $0 ~/autoware         # Quick setup for ~/autoware workspace"
    echo "  $0 /home/user/project # Quick setup for custom workspace"
    echo ""
    echo "FEATURES:"
    echo "  • VS Code and Dev Containers configuration deployment"
    echo "  • Automatic backup of existing configurations"
    echo "  • System dependency check"
    echo ""
    echo "BACKUP BEHAVIOR:"
    echo "  Existing .vscode and .devcontainer directories are moved to:"
    echo "  autoware_vscode/backup/TIMESTAMP/.vscode"
    echo "  autoware_vscode/backup/TIMESTAMP/.devcontainer"
    echo ""
}

set -e

# Check for help flag
if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
    show_help
    exit 0
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored output
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

# Global variables for auto-answering questions and backup timestamp
AUTO_YES=false
BACKUP_TIMESTAMP=""

# Function to get or create backup timestamp
get_backup_timestamp() {
    if [[ -z $BACKUP_TIMESTAMP ]]; then
        BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    fi
    echo "$BACKUP_TIMESTAMP"
}

# Function to ask yes/no questions with default "yes"
ask_question() {
    local question="$1"
    local response

    # Check if auto-answer is enabled
    if [[ $AUTO_YES == true ]]; then
        echo -e "\n${YELLOW}$question${NC}"
        echo -e "${GREEN}[AUTO: YES]${NC}"
        return 0
    fi

    echo -e "\n${YELLOW}$question${NC}"
    echo -e "${BLUE}[Y/n/A] (default: all yes, Y=yes once, A=all yes):${NC} \c"
    read -r response

    # Default to "all yes" if empty response
    response=${response:-a}

    case "$response" in
    [yY] | [yY][eE][sS]) return 0 ;;
    [aA] | [aA][lL][lL])
        AUTO_YES=true
        print_info "All remaining questions will be answered 'yes'"
        return 0
        ;;
    *) return 1 ;;
    esac
}

# Function to backup workspace configuration directories to repository
backup_workspace_config() {
    local source_dir="$1"
    local config_name="$2" # .vscode or .devcontainer

    if [[ -d $source_dir ]]; then
        # Create backup directory if it doesn't exist
        local backup_base_dir="$SCRIPT_DIR/backup"
        mkdir -p "$backup_base_dir"

        local timestamp
        timestamp=$(get_backup_timestamp)
        local timestamped_backup_dir="$backup_base_dir/$timestamp"
        mkdir -p "$timestamped_backup_dir"

        local backup_dir="$timestamped_backup_dir/$config_name"

        print_info "Moving existing $config_name to repository backup: $backup_dir"
        mv "$source_dir" "$backup_dir"
        print_success "Moved to: $backup_dir"
        return 0
    fi
    return 1
}

# Function to check if dependencies are installed
check_dependencies() {
    local missing_deps=()

    # Check for VS Code
    if ! command -v code &>/dev/null; then
        missing_deps+=("VS Code")
    fi

    # Check for Docker
    if ! command -v docker &>/dev/null; then
        missing_deps+=("Docker")
    fi

    # Check for NVIDIA driver
    if ! command -v nvidia-smi &>/dev/null; then
        missing_deps+=("NVIDIA driver")
    fi

    # Check for NVIDIA Container Toolkit
    if ! grep -q "nvidia-container-toolkit" /etc/apt/sources.list.d/nvidia-container-toolkit.list 2>/dev/null; then
        missing_deps+=("NVIDIA Container Toolkit")
    fi

    # Check for CycloneDDS configuration
    if [[ ! -f /etc/sysctl.d/10-cyclone-max.conf ]]; then
        missing_deps+=("CycloneDDS configuration")
    fi

    # Check for multicasting service
    if [[ ! -f /etc/systemd/system/multicasting.service ]]; then
        missing_deps+=("Multicasting service")
    fi

    # Check for vcstool
    if ! command -v vcs &>/dev/null; then
        missing_deps+=("vcstool")
    fi

    # Return results only if there are actually missing dependencies
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo "${missing_deps[@]}"
    fi
}

print_info "=== Autoware Workspace Setup ==="
print_info "This script will set up your workspace directory for Autoware development."

# Check if workspace path was provided as command line argument
if [[ $# -eq 1 ]]; then
    workspace_path="$1"
    AUTO_YES=true
    print_info "Quick setup mode: Using provided workspace path and auto-answering 'yes' to all questions"
    print_info "Question options:"
    print_info "  • All questions will be automatically answered 'yes'"
else
    print_info "Question options:"
    print_info "  • Press Enter or A/a = Yes to ALL remaining questions (default)"
    print_info "  • Type Y/y = Yes to current question only"
    print_info "  • Type N/n = No"

    # Ask for workspace path
    echo ""
    echo -e "${YELLOW}Enter the path to your Autoware workspace:${NC}"
    echo -e "${BLUE}(default: ~/autoware):${NC} \c"
    read -r workspace_path

    # Set default workspace path
    workspace_path=${workspace_path:-~/autoware}
fi

# Expand tilde if present
workspace_path="${workspace_path/#\~/$HOME}"

# Check if workspace exists
if [[ ! -d $workspace_path ]]; then
    print_error "Workspace directory does not exist: $workspace_path"
    print_error "Please create the workspace directory first or specify an existing one."
    exit 1
fi

print_success "Using workspace: $workspace_path"

# Check for existing .vscode and .devcontainer directories
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

if [[ $vscode_exists == true ]] || [[ $devcontainer_exists == true ]]; then
    echo ""
    print_warning "Existing VS Code/devcontainer configuration found!"
    if ! ask_question "Do you want to continue? (Existing files may be overridden)"; then
        print_info "Setup cancelled by user"
        exit 0
    fi
fi

# Copy workspace configuration files
if ask_question "Do you want to copy VS Code and Dev Containers configuration to the workspace?"; then
    # Check if data directory exists in script location
    data_dir="$SCRIPT_DIR/workspace"
    if [[ -d $data_dir ]]; then
        print_info "Copying workspace configuration files..."

        # Copy .vscode directory if it exists
        if [[ -d "$data_dir/.vscode" ]]; then
            backup_workspace_config "$workspace_path/.vscode" ".vscode"
            cp -r "$data_dir/.vscode" "$workspace_path/"
            print_success "VS Code configuration copied to workspace"
        fi

        # Copy .devcontainer directory if it exists
        if [[ -d "$data_dir/.devcontainer" ]]; then
            backup_workspace_config "$workspace_path/.devcontainer" ".devcontainer"
            cp -r "$data_dir/.devcontainer" "$workspace_path/"
            print_success "Devcontainer configuration copied to workspace"
        fi

        print_success "Workspace configuration files installed"
    else
        print_warning "Configuration data directory not found: $data_dir"
        print_info "Skipping workspace configuration copy"
    fi
else
    print_info "Skipping workspace configuration copy"
fi

# Create required directories for Dev Containers
if ask_question "Do you want to create required directories for Dev Containers development?"; then
    print_info "Creating required directories..."

    directories=(
        "$HOME/autoware_data"
        "$HOME/autoware_map"
        "$HOME/.ssh"
        "$HOME/.webauto"
        "$HOME/.config/Lichtblick"
        "$HOME/.ccache"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d $dir ]]; then
            print_info "Creating directory: $dir"
            mkdir -p "$dir"
            print_success "Created: $dir"
        else
            print_info "Directory already exists: $dir"
        fi
    done

    print_success "All required directories are ready"
else
    print_info "Skipping directory creation"
fi

# Check dependencies
print_info "Checking system dependencies..."
readarray -t missing_deps < <(check_dependencies)

if [[ ${#missing_deps[@]} -eq 0 ]]; then
    print_success "All dependencies are installed"
else
    print_warning "Some dependencies are missing or not properly configured:"
    for dep in "${missing_deps[@]}"; do
        # Only print non-empty dependencies
        if [[ -n $dep ]]; then
            print_warning "  • $dep"
        fi
    done

    echo ""
    print_info "To install missing dependencies, check README.md."
fi

# Final message
echo ""
print_success "=== Setup Complete ==="
print_info "Your Autoware workspace has been configured!"
print_info "Workspace location: $workspace_path"

exit 0
