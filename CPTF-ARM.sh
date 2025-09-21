#!/bin/bash

################################################################################
#                                                                              #
#                   Cloud Penetration Testing Framework (CPTF)                 #
#                             Setup Script for ARM64                           #
#                                                                              #
#  This script installs a comprehensive suite of penetration testing tools     #
#  for AWS, Azure, GCP, and multi-cloud environments on Debian-based ARM64     #
#  systems (e.g., Debian, Ubuntu, Kali Linux).                                 #
#                                                                              #
################################################################################

# --- Script Configuration ---
set -o pipefail

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Logging Functions ---
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# --- Pre-flight Checks ---

# Function to check if the script is run with root privileges
check_privileges() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run with sudo or as root."
        exit 1
    fi
}

# Function to check for ARM64 architecture
check_architecture() {
    ARCH=$(uname -m)
    if [[ "$ARCH" != "arm64" && "$ARCH" != "aarch64" ]]; then
        log_warning "This script is optimized for ARM64, but you are on $ARCH."
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation aborted by user."
            exit 0
        fi
    else
        log_success "ARM64 architecture confirmed: $ARCH"
    fi
}

# --- Core Installation Functions ---

# Function to update system packages
update_system() {
    log_info "Updating system package lists..."
    if ! apt-get update -y; then
        log_error "Failed to update package lists. Please check your network connection and APT sources."
        exit 1
    fi
    log_info "Upgrading installed packages..."
    if ! apt-get upgrade -y; then
        log_error "Failed to upgrade packages."
        exit 1
    fi
    log_success "System packages are up to date."
}

# Function to install base dependencies
install_base_deps() {
    log_info "Installing base dependencies..."
    DEPS=(
        curl wget git build-essential python3 python3-pip python3-venv
        python3-dev pipx nodejs npm golang ruby ruby-dev jq unzip zip
        gnupg software-properties-common apt-transport-https ca-certificates
        lsb-release libssl-dev libffi-dev default-jdk vim nano
    )
    if ! apt-get install -y "${DEPS[@]}"; then
        log_error "Failed to install one or more base dependencies. Aborting."
        exit 1
    fi

    # Configure pipx path system-wide
    log_info "Configuring system-wide PATH for pipx..."
    PIPX_PATH_FILE="/etc/profile.d/cptf-pipx.sh"
    echo 'export PATH="$PATH:/root/.local/bin"' > "$PIPX_PATH_FILE"
    chmod +x "$PIPX_PATH_FILE"
    export PATH="$PATH:/root/.local/bin" # Also apply to current session

    log_success "Base dependencies installed."
}

# Function to install PowerShell Core
install_powershell() {
    if command -v pwsh &>/dev/null; then
        log_success "PowerShell is already installed."
        return
    fi
    log_info "Installing PowerShell Core for ARM..."
    PWSH_URL="https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/powershell-7.4.2-linux-arm64.tar.gz"
    PWSH_ARCHIVE=$(basename "$PWSH_URL")
    PWSH_DIR="/opt/microsoft/powershell/7"

    wget -q "$PWSH_URL" -O "$PWSH_ARCHIVE"
    mkdir -p "$PWSH_DIR"
    tar zxf "$PWSH_ARCHIVE" -C "$PWSH_DIR"
    chmod +x "$PWSH_DIR/pwsh"
    ln -sfn "$PWSH_DIR/pwsh" /usr/bin/pwsh
    rm "$PWSH_ARCHIVE"
    log_success "PowerShell Core installed."
}

# Function to create the directory structure for tools
create_directories() {
    log_info "Creating tool directory structure in /opt/..."
    mkdir -p /opt/{aws,azure,gcp,multi-cloud}/{enumeration,exploitation,post-exploitation}
    log_success "Directory structure created."
}

# --- Tool Installation Helpers ---

# A robust git clone function that checks if the directory exists
clone_repo() {
    local repo_url="$1"
    local install_path="$2"
    local tool_name="$3"
    
    if [ -d "$install_path" ]; then
        log_warning "$tool_name already exists at $install_path, skipping clone."
    else
        log_info "Cloning $tool_name..."
        if ! git clone "$repo_url" "$install_path"; then
            log_error "Failed to clone $tool_name. Please check the URL and your connection."
        fi
    fi
}

# Function to install a Python tool into its own virtual environment
install_python_tool() {
    local repo_url="$1"
    local install_path="$2"
    local tool_name="$3"
    
    clone_repo "$repo_url" "$install_path" "$tool_name"
    
    if [ ! -d "$install_path" ]; then
        log_warning "Skipping Python setup for $tool_name because clone failed or was skipped."
        return
    fi

    log_info "Setting up Python virtual environment for $tool_name..."
    cd "$install_path"
    
    if [ -d "venv" ]; then
        log_warning "Virtual environment for $tool_name already exists."
        cd - >/dev/null
        return
    fi

    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip setuptools wheel

    if [ -f "requirements.txt" ]; then
        log_info "Installing dependencies from requirements.txt for $tool_name..."
        pip install -r requirements.txt || log_warning "Some requirements failed to install for $tool_name."
    fi

    if [ -f "setup.py" ]; then
        pip install -e . || log_warning "Failed to install $tool_name from setup.py."
    fi

    deactivate
    cd - >/dev/null
    log_success "Python setup for $tool_name is complete."
}

# --- Cloud Provider Tool Installers ---

install_aws_tools() {
    log_info "--- Installing AWS Tools ---"
    
    # AWS CLI v2
    if ! command -v aws &>/dev/null; then
        log_info "Installing AWS CLI v2..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
        unzip -qo awscliv2.zip
        ./aws/install
        rm -rf awscliv2.zip aws/
    else
        log_success "AWS CLI is already installed."
    fi

    # Python Tools
    install_python_tool "https://github.com/RhinoSecurityLabs/pacu.git" "/opt/aws/exploitation/pacu" "Pacu"
    install_python_tool "https://github.com/duo-labs/cloudmapper.git" "/opt/aws/enumeration/cloudmapper" "CloudMapper"
    install_python_tool "https://github.com/NetSPI/aws_consoler.git" "/opt/aws/exploitation/aws_consoler" "AWS Consoler"
    install_python_tool "https://github.com/carnal0wnage/weirdAAL.git" "/opt/aws/enumeration/weirdAAL" "weirdAAL"
    
    # Other Tools
    clone_repo "https://github.com/Static-Flow/CloudCopy.git" "/opt/aws/exploitation/CloudCopy" "CloudCopy"
    clone_repo "https://github.com/hoodoer/endgame.git" "/opt/aws/post-exploitation/endgame" "endgame"
}

install_azure_tools() {
    log_info "--- Installing Azure Tools ---"
    
    # Azure CLI
    if ! command -v az &>/dev/null; then
        log_info "Installing Azure CLI..."
        curl -sL https://aka.ms/InstallAzureCLIDeb | bash
    else
        log_success "Azure CLI is already installed."
    fi
    
    # PowerShell Modules
    if command -v pwsh &>/dev/null; then
        log_info "Installing Azure PowerShell modules (Az, AzureAD, AADInternals)..."
        pwsh -Command "Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted; Install-Module -Name Az, AzureAD, AADInternals -Force -AllowClobber -Scope AllUsers"
    fi
    
    # Python Tools
    install_python_tool "https://github.com/dirkjanm/ROADtools.git" "/opt/azure/enumeration/ROADtools" "ROADtools"
    
    # Other Tools
    clone_repo "https://github.com/BloodHoundAD/AzureHound.git" "/opt/azure/enumeration/AzureHound" "AzureHound"
    clone_repo "https://github.com/dafthack/MFASweep.git" "/opt/azure/exploitation/MFASweep" "MFASweep"
    clone_repo "https://github.com/NetSPI/MicroBurst.git" "/opt/azure/exploitation/MicroBurst" "MicroBurst"
}

install_gcp_tools() {
    log_info "--- Installing GCP Tools ---"
    
    # Google Cloud SDK (with modern key management)
    if ! command -v gcloud &>/dev/null; then
        log_info "Installing Google Cloud SDK..."
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
        apt-get update && apt-get install -y google-cloud-cli
    else
        log_success "Google Cloud SDK is already installed."
    fi

    # Python Tools
    install_python_tool "https://github.com/RhinoSecurityLabs/GCPBucketBrute.git" "/opt/gcp/enumeration/GCPBucketBrute" "GCPBucketBrute"

    # Other Tools
    clone_repo "https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation.git" "/opt/gcp/post-exploitation/GCP-IAM-Privilege-Escalation" "GCP-IAM-Privilege-Escalation"
}

install_multicloud_tools() {
    log_info "--- Installing Multi-Cloud Tools ---"
    
    # Python Tools
    install_python_tool "https://github.com/nccgroup/ScoutSuite.git" "/opt/multi-cloud/enumeration/ScoutSuite" "ScoutSuite"
    install_python_tool "https://github.com/initstring/cloud_enum.git" "/opt/multi-cloud/enumeration/cloud_enum" "CloudEnum"
    install_python_tool "https://github.com/fortra/impacket.git" "/opt/multi-cloud/exploitation/impacket" "Impacket"
    
    # Go Tools
    clone_repo "https://github.com/kgretzky/evilginx2.git" "/opt/multi-cloud/exploitation/evilginx2" "evilginx2"
    if [ -d "/opt/multi-cloud/exploitation/evilginx2" ] && command -v go &>/dev/null; then
        log_info "Building evilginx2..."
        cd /opt/multi-cloud/exploitation/evilginx2
        go build || log_warning "Failed to build evilginx2. Manual build may be required."
        cd - >/dev/null
    fi
}

# --- Post-Installation Setup ---

# Function to create convenient launcher scripts in /usr/local/bin
create_launchers() {
    log_info "Creating launcher scripts in /usr/local/bin..."
    
    # Pacu Launcher
    cat > /usr/local/bin/pacu << 'EOF'
#!/bin/bash
cd /opt/aws/exploitation/pacu
source venv/bin/activate
python3 pacu.py "$@"
EOF
    chmod +x /usr/local/bin/pacu

    # ScoutSuite Launcher
    cat > /usr/local/bin/scoutsuite << 'EOF'
#!/bin/bash
cd /opt/multi-cloud/enumeration/ScoutSuite
source venv/bin/activate
python3 scout.py "$@"
EOF
    chmod +x /usr/local/bin/scoutsuite
    
    # CloudMapper Launcher
    cat > /usr/local/bin/cloudmapper << 'EOF'
#!/bin/bash
cd /opt/aws/enumeration/cloudmapper
source venv/bin/activate
python3 cloudmapper.py "$@"
EOF
    chmod +x /usr/local/bin/cloudmapper
    
    log_success "Launcher scripts created for pacu, scoutsuite, and cloudmapper."
}

# Function to set up a helpful environment for the user who ran sudo
setup_user_env() {
    log_info "Setting up user environment..."
    
    # Find the actual user, not root
    ACTUAL_USER=${SUDO_USER:-$(whoami)}
    USER_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

    if [ ! -d "$USER_HOME" ]; then
        log_warning "Could not determine home directory for user '$ACTUAL_USER'. Skipping user env setup."
        return
    fi
    
    # Create aliases file
    cat > "$USER_HOME/.cptf_aliases" << 'EOF'
# CPTF Aliases
alias cptf-help='echo "CPTF Tools:"; echo "  pacu         - AWS Exploitation Framework"; echo "  scoutsuite   - Multi-Cloud Auditing Tool"; echo "  cloudmapper  - AWS Visualizer"'
alias aws-tools='ls -lA /opt/aws/'
alias azure-tools='ls -lA /opt/azure/'
alias gcp-tools='ls -lA /opt/gcp/'
alias multi-tools='ls -lA /opt/multi-cloud/'

# To update CPTF, navigate to the repo directory and run: git pull && sudo bash ./cptf-arm-setup.sh
EOF
    
    # Add sourcing to .bashrc if not present
    if ! grep -q ".cptf_aliases" "$USER_HOME/.bashrc"; then
        echo -e "\n# CPTF Configuration\n[ -f \"\$HOME/.cptf_aliases\" ] && source \"\$HOME/.cptf_aliases\"" >> "$USER_HOME/.bashrc"
    fi
    
    # Create environment variable template
    if [ ! -f "$USER_HOME/cloud-env.sh" ]; then
        cat > "$USER_HOME/cloud-env.sh" << 'EOF'
#!/bin/bash
# Cloud Environment Variables for CPTF

# --- AWS ---
# Uncomment and fill in your details
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""
# export AWS_SESSION_TOKEN=""
# export AWS_DEFAULT_REGION="us-east-1"

# --- Azure ---
# Uncomment and fill in your details
# export AZURE_CLIENT_ID=""
# export AZURE_TENANT_ID=""
# export AZURE_CLIENT_SECRET=""

# --- GCP ---
# Use 'gcloud auth application-default login' or set the path below
# export GOOGLE_APPLICATION_CREDENTIALS="~/.config/gcloud/application_default_credentials.json"

echo "Cloud environment variables sourced. Edit this file (~/cloud-env.sh) to configure."
EOF
        chmod +x "$USER_HOME/cloud-env.sh"
    fi
    
    # Set correct ownership
    chown -R "$ACTUAL_USER":"$ACTUAL_USER" "$USER_HOME/.cptf_aliases" "$USER_HOME/cloud-env.sh"
    
    log_success "User environment configured for '$ACTUAL_USER'."
}

# --- Main Function ---
main() {
    clear
    echo -e "${BLUE}"
    echo "    ____  ___________ ____       ______ ______________  _______   _________";
    echo "   / __ \\/ __/ __/ _ \/ __ \\____ / __/ // /  _/ __/  |/  / __/ | / / __/ _ \\";
    echo "  / /_/ / _// _// , _/ /_/ /___/_\\ \\/ _  // // _// /|_/ / _//  |/ / _// , _/";
    echo "  \\____/___/_/ /_/|_|\\____/   /___/\\__/_/___/___/_/  /_/___/\\__/|__/___/_/|_|";
    echo "                                  ARM64 Setup Script                      ";
    echo -e "${NC}"
    
    check_privileges
    check_architecture
    
    log_info "Starting full installation..."
    log_warning "This process may take 15-45 minutes."
    
    update_system
    install_base_deps
    install_powershell
    create_directories
    
    # Install all tools
    install_aws_tools
    install_azure_tools
    install_gcp_tools
    install_multicloud_tools
    
    # Finalize setup
    create_launchers
    setup_user_env
    
    echo ""
    echo "======================================================================="
    log_success "CPTF Installation Complete!"
    echo "======================================================================="
    echo ""
    echo "Installed Tool Location: /opt/"
    echo ""
    echo "  ${YELLOW}Quick Start Commands:${NC}"
    echo "  pacu          - Launch Pacu (AWS)"
    echo "  scoutsuite    - Launch ScoutSuite (Multi-Cloud)"
    echo "  cloudmapper   - Launch CloudMapper (AWS)"
    echo ""
    echo "  ${YELLOW}Tool Listing Commands:${NC}"
    echo "  aws-tools     - List AWS tools"
    echo "  azure-tools   - List Azure tools"
    echo "  gcp-tools     - List GCP tools"
    echo "  multi-tools   - List Multi-Cloud tools"
    echo ""
    echo "  ${YELLOW}NEXT STEPS:${NC}"
    echo "  1. ${RED}IMPORTANT:${NC} Restart your terminal or run: ${GREEN}source ~/.bashrc${NC}"
    echo "  2. Configure your cloud credentials by editing the template:"
    echo "     ${GREEN}nano ~/cloud-env.sh${NC}"
    echo "  3. Load your credentials into your session with:"
    echo "     ${GREEN}source ~/cloud-env.sh${NC}"
    echo ""
    log_info "Run 'cptf-help' for a list of main tool commands."
}

# Execute the main function with all provided arguments
main "$@"

