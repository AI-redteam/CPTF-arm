#!/bin/bash

#########################################
# CPTF-ARM Setup Script
# Cloud Penetration Testing Framework
# For Apple Silicon and ARM64 devices
#########################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
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

# Check if running on ARM
check_architecture() {
    ARCH=$(uname -m)
    if [[ "$ARCH" != "arm64" && "$ARCH" != "aarch64" ]]; then
        log_warning "This script is optimized for ARM64 architecture. Current architecture: $ARCH"
        read -p "Do you want to continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_success "ARM64 architecture detected: $ARCH"
    fi
}

# Check if running with sudo
check_sudo() {
    if [ "$EUID" -ne 0 ]; then 
        log_error "Please run this script with sudo"
        exit 1
    fi
}

# Update system
update_system() {
    log_info "Updating system packages..."
    apt-get update -y
    apt-get upgrade -y
    log_success "System updated"
}

# Install base dependencies
install_base_deps() {
    log_info "Installing base dependencies..."
    
    apt-get install -y \
        curl \
        wget \
        git \
        build-essential \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        pipx \
        nodejs \
        npm \
        golang \
        ruby \
        ruby-dev \
        jq \
        unzip \
        zip \
        gnupg \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        lsb-release \
        libssl-dev \
        libffi-dev \
        openjdk-11-jdk \
        vim \
        nano
    
    # Ensure pipx is in PATH
    export PATH="$PATH:/root/.local/bin"
    
    # Install PowerShell Core for ARM
    log_info "Installing PowerShell Core for ARM..."
    if ! command -v pwsh &> /dev/null; then
        wget -q https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell-7.4.0-linux-arm64.tar.gz
        mkdir -p /opt/microsoft/powershell/7
        tar zxf powershell-7.4.0-linux-arm64.tar.gz -C /opt/microsoft/powershell/7
        chmod +x /opt/microsoft/powershell/7/pwsh
        ln -sf /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
        rm powershell-7.4.0-linux-arm64.tar.gz
    fi
    
    log_success "Base dependencies installed"
}

# Create directory structure
create_directories() {
    log_info "Creating directory structure..."
    mkdir -p /opt/{aws,azure,gcp,multi-cloud}/{enumeration,exploitation,post-exploitation}
    mkdir -p /usr/local/bin
    mkdir -p /root/.cptf/bin
    log_success "Directory structure created"
}

# Install Python package in venv
install_python_package() {
    local REPO_URL="$1"
    local INSTALL_PATH="$2"
    local TOOL_NAME="$3"
    
    log_info "Installing $TOOL_NAME..."
    
    # Clone if URL provided
    if [ -n "$REPO_URL" ]; then
        if [ -d "$INSTALL_PATH" ]; then
            log_warning "$TOOL_NAME already exists, skipping clone..."
        else
            git clone "$REPO_URL" "$INSTALL_PATH" || {
                log_error "Failed to clone $TOOL_NAME"
                return 1
            }
        fi
    fi
    
    cd "$INSTALL_PATH" || return 1
    
    # Create virtual environment
    log_info "Creating virtual environment for $TOOL_NAME..."
    python3 -m venv venv
    
    # Activate and install
    source venv/bin/activate
    pip install --upgrade pip setuptools wheel
    
    # Install requirements if they exist
    if [ -f "requirements.txt" ]; then
        log_info "Installing requirements for $TOOL_NAME..."
        pip install -r requirements.txt || log_warning "Some requirements failed for $TOOL_NAME"
    fi
    
    # Install package if setup.py exists
    if [ -f "setup.py" ]; then
        pip install -e . || log_warning "Setup.py installation failed for $TOOL_NAME"
    fi
    
    deactivate
    
    log_success "$TOOL_NAME installed"
}

#########################################
# AWS Tools Installation
#########################################

install_aws_tools() {
    log_info "Installing AWS tools..."
    
    # AWS CLI v2 for ARM
    log_info "Installing AWS CLI v2..."
    if ! command -v aws &> /dev/null; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        ./aws/install
        rm -rf awscliv2.zip aws/
    fi
    
    # Install Python-based AWS tools
    install_python_package "https://github.com/NetSPI/aws_consoler.git" \
        "/opt/aws/exploitation/aws_consoler" "AWS Consoler"
    
    install_python_package "https://github.com/prevade/cloudjack.git" \
        "/opt/aws/exploitation/cloudjack" "CloudJack"
    
    install_python_package "https://github.com/duo-labs/cloudmapper.git" \
        "/opt/aws/enumeration/cloudmapper" "CloudMapper"
    
    install_python_package "https://github.com/ustayready/CredKing.git" \
        "/opt/aws/exploitation/CredKing" "CredKing"
    
    install_python_package "https://github.com/RhinoSecurityLabs/pacu.git" \
        "/opt/aws/exploitation/pacu" "Pacu"
    
    install_python_package "https://github.com/carnal0wnage/weirdAAL.git" \
        "/opt/aws/enumeration/weirdAAL" "weirdAAL"
    
    # Download standalone scripts
    log_info "Downloading AWS Escalate..."
    wget -q https://raw.githubusercontent.com/RhinoSecurityLabs/Security-Research/master/tools/aws-pentest-tools/aws_escalate.py \
        -O /opt/aws/post-exploitation/aws_escalate.py
    chmod +x /opt/aws/post-exploitation/aws_escalate.py
    
    # Clone non-Python tools
    git clone https://github.com/Static-Flow/CloudCopy.git /opt/aws/exploitation/CloudCopy 2>/dev/null || true
    git clone https://github.com/hoodoer/endgame.git /opt/aws/post-exploitation/endgame 2>/dev/null || true
    git clone https://github.com/ihamburglar/Redboto.git /opt/aws/exploitation/Redboto 2>/dev/null || true
    
    log_success "AWS tools installed"
}

#########################################
# Azure Tools Installation
#########################################

install_azure_tools() {
    log_info "Installing Azure tools..."
    
    # Azure CLI
    log_info "Installing Azure CLI..."
    if ! command -v az &> /dev/null; then
        curl -sL https://aka.ms/InstallAzureCLIDeb | bash
    fi
    
    # PowerShell modules
    if command -v pwsh &> /dev/null; then
        log_info "Installing Azure PowerShell modules..."
        pwsh -Command "Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted"
        pwsh -Command "Install-Module -Name Az -Force -AllowClobber -Scope AllUsers" || true
        pwsh -Command "Install-Module -Name AzureAD -Force -AllowClobber -Scope AllUsers" || true
        pwsh -Command "Install-Module -Name AADInternals -Force -AllowClobber -Scope AllUsers" || true
        pwsh -Command "Install-Module -Name DCToolbox -Force -AllowClobber -Scope AllUsers" || true
    fi
    
    # Clone Azure tools
    git clone https://github.com/jsa2/aadcookiespoof.git /opt/azure/exploitation/aadcookiespoof 2>/dev/null || true
    git clone https://github.com/BloodHoundAD/AzureHound.git /opt/azure/enumeration/AzureHound 2>/dev/null || true
    git clone https://github.com/dafthack/MFASweep.git /opt/azure/exploitation/MFASweep 2>/dev/null || true
    git clone https://github.com/NetSPI/MicroBurst.git /opt/azure/exploitation/MicroBurst 2>/dev/null || true
    git clone https://github.com/NetSPI/PowerUpSQL.git /opt/azure/post-exploitation/PowerUpSQL 2>/dev/null || true
    git clone https://github.com/rvrsh3ll/TokenTactics.git /opt/azure/exploitation/TokenTactics 2>/dev/null || true
    
    # Install ROADtools
    install_python_package "https://github.com/dirkjanm/ROADtools.git" \
        "/opt/azure/enumeration/ROADtools" "ROADtools"
    
    log_success "Azure tools installed"
}

#########################################
# GCP Tools Installation
#########################################

install_gcp_tools() {
    log_info "Installing GCP tools..."
    
    # Google Cloud SDK
    log_info "Installing Google Cloud SDK..."
    if ! command -v gcloud &> /dev/null; then
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
            tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
            apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        apt-get update && apt-get install -y google-cloud-cli
    fi
    
    # Install Python GCP tools
    install_python_package "https://github.com/RhinoSecurityLabs/GCPBucketBrute.git" \
        "/opt/gcp/enumeration/GCPBucketBrute" "GCPBucketBrute"
    
    # Clone other GCP tools
    git clone https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation.git \
        /opt/gcp/post-exploitation/GCP-IAM-Privilege-Escalation 2>/dev/null || true
    git clone https://github.com/RedTeamOperations/GCPTokenReuse.git \
        /opt/gcp/exploitation/GCPTokenReuse 2>/dev/null || true
    git clone https://github.com/RedTeamOperations/GoogleWorkspaceDirectoryDump.git \
        /opt/gcp/enumeration/GoogleWorkspaceDirectoryDump 2>/dev/null || true
    
    log_success "GCP tools installed"
}

#########################################
# Multi-Cloud Tools Installation
#########################################

install_multicloud_tools() {
    log_info "Installing Multi-Cloud tools..."
    
    # Install Python-based multi-cloud tools
    install_python_package "https://github.com/lyft/cartography.git" \
        "/opt/multi-cloud/enumeration/cartography" "Cartography"
    
    install_python_package "https://github.com/RhinoSecurityLabs/ccat.git" \
        "/opt/multi-cloud/exploitation/ccat" "CCAT"
    
    install_python_package "https://github.com/initstring/cloud_enum.git" \
        "/opt/multi-cloud/enumeration/cloud_enum" "CloudEnum"
    
    install_python_package "https://github.com/fortra/impacket.git" \
        "/opt/multi-cloud/exploitation/impacket" "Impacket"
    
    install_python_package "https://github.com/nccgroup/ScoutSuite.git" \
        "/opt/multi-cloud/enumeration/ScoutSuite" "ScoutSuite"
    
    install_python_package "https://github.com/carlospolop/PurplePanda.git" \
        "/opt/multi-cloud/enumeration/PurplePanda" "PurplePanda"
    
    # Clone non-Python tools
    git clone https://github.com/0xsha/CloudBrute.git /opt/multi-cloud/enumeration/CloudBrute 2>/dev/null || true
    git clone https://github.com/NotSoSecure/cloud-service-enum.git /opt/multi-cloud/enumeration/cloud-service-enum 2>/dev/null || true
    git clone https://github.com/kgretzky/evilginx2.git /opt/multi-cloud/exploitation/evilginx2 2>/dev/null || true
    git clone https://github.com/lgandx/Responder.git /opt/multi-cloud/exploitation/Responder 2>/dev/null || true
    git clone https://github.com/cyberark/SkyArk.git /opt/multi-cloud/enumeration/SkyArk 2>/dev/null || true
    git clone https://github.com/htr-tech/zphisher.git /opt/multi-cloud/exploitation/zphisher 2>/dev/null || true
    
    # Build Go tools if Go is available
    if command -v go &> /dev/null; then
        # Build CloudBrute
        if [ -d "/opt/multi-cloud/enumeration/CloudBrute" ]; then
            cd /opt/multi-cloud/enumeration/CloudBrute
            go build -o cloudbrute . 2>/dev/null || true
        fi
        
        # Build evilginx2
        if [ -d "/opt/multi-cloud/exploitation/evilginx2" ]; then
            cd /opt/multi-cloud/exploitation/evilginx2
            go build . 2>/dev/null || true
        fi
    fi
    
    log_success "Multi-Cloud tools installed"
}

#########################################
# Create launcher scripts
#########################################

create_launchers() {
    log_info "Creating launcher scripts..."
    
    # Create Pacu launcher
    cat > /usr/local/bin/pacu << 'EOF'
#!/bin/bash
cd /opt/aws/exploitation/pacu
source venv/bin/activate
python3 pacu.py "$@"
deactivate
EOF
    chmod +x /usr/local/bin/pacu
    
    # Create ScoutSuite launcher
    cat > /usr/local/bin/scoutsuite << 'EOF'
#!/bin/bash
cd /opt/multi-cloud/enumeration/ScoutSuite
source venv/bin/activate
python3 scout.py "$@"
deactivate
EOF
    chmod +x /usr/local/bin/scoutsuite
    
    # Create CloudMapper launcher
    cat > /usr/local/bin/cloudmapper << 'EOF'
#!/bin/bash
cd /opt/aws/enumeration/cloudmapper
source venv/bin/activate
python3 cloudmapper.py "$@"
deactivate
EOF
    chmod +x /usr/local/bin/cloudmapper
    
    # Create generic launcher
    cat > /usr/local/bin/cptf-tool << 'EOF'
#!/bin/bash
TOOL_DIR="$1"
shift
if [ -d "$TOOL_DIR/venv" ]; then
    cd "$TOOL_DIR"
    source venv/bin/activate
    python3 "$@"
    deactivate
else
    echo "No virtual environment found in $TOOL_DIR"
fi
EOF
    chmod +x /usr/local/bin/cptf-tool
    
    log_success "Launcher scripts created"
}

#########################################
# Setup user environment
#########################################

setup_user_env() {
    log_info "Setting up user environment..."
    
    # Get the actual user who ran sudo
    ACTUAL_USER=${SUDO_USER:-root}
    USER_HOME=$(eval echo ~$ACTUAL_USER)
    
    # Create aliases file
    cat > "$USER_HOME/.cptf_aliases" << 'EOF'
# CPTF-ARM Aliases
alias cptf-help='echo "CPTF-ARM Tools:"; echo "  pacu - AWS exploitation"; echo "  scoutsuite - Multi-cloud auditing"; echo "  cloudmapper - AWS visualization"'
alias aws-tools='ls -la /opt/aws/'
alias azure-tools='ls -la /opt/azure/'
alias gcp-tools='ls -la /opt/gcp/'
alias multi-tools='ls -la /opt/multi-cloud/'
alias cptf-update='cd /tmp && wget -O cptf-update.sh https://raw.githubusercontent.com/yourusername/cptf-arm/main/cptf-arm-setup.sh && sudo bash cptf-update.sh'
EOF
    
    # Add to bashrc if not already there
    if ! grep -q ".cptf_aliases" "$USER_HOME/.bashrc"; then
        echo "" >> "$USER_HOME/.bashrc"
        echo "# CPTF-ARM Configuration" >> "$USER_HOME/.bashrc"
        echo "[ -f ~/.cptf_aliases ] && source ~/.cptf_aliases" >> "$USER_HOME/.bashrc"
    fi
    
    # Create environment template
    cat > "$USER_HOME/cloud-env.sh" << 'EOF'
#!/bin/bash
# Cloud Environment Variables for CPTF-ARM

# AWS
#export AWS_ACCESS_KEY_ID=
#export AWS_SECRET_ACCESS_KEY=
#export AWS_DEFAULT_REGION=us-east-1

# Azure
#export AZURE_CLIENT_ID=
#export AZURE_TENANT_ID=
#export AZURE_CLIENT_SECRET=

# GCP
#export GOOGLE_APPLICATION_CREDENTIALS=

echo "Cloud environment variables loaded (edit ~/cloud-env.sh to configure)"
EOF
    chmod +x "$USER_HOME/cloud-env.sh"
    
    # Fix ownership
    chown -R $ACTUAL_USER:$ACTUAL_USER "$USER_HOME/.cptf_aliases" "$USER_HOME/cloud-env.sh"
    
    log_success "User environment configured"
}

#########################################
# Main installation
#########################################

main() {
    clear
    echo "================================================"
    echo "     CPTF-ARM Installation Script"
    echo "     Cloud Penetration Testing Framework"
    echo "     For ARM64 Devices"
    echo "================================================"
    echo ""
    
    check_sudo
    check_architecture
    
    log_info "Starting CPTF-ARM installation..."
    log_info "This will take 15-30 minutes depending on your connection"
    echo ""
    
    update_system
    install_base_deps
    create_directories
    
    # Install tools
    install_aws_tools
    install_azure_tools
    install_gcp_tools
    install_multicloud_tools
    
    # Setup environment
    create_launchers
    setup_user_env
    
    echo ""
    echo "================================================"
    log_success "CPTF-ARM Installation Complete!"
    echo "================================================"
    echo ""
    echo "Installed Tools Location: /opt/{aws,azure,gcp,multi-cloud}/"
    echo ""
    echo "Quick Start Commands:"
    echo "  pacu         - Launch Pacu (AWS exploitation)"
    echo "  scoutsuite   - Launch ScoutSuite (Multi-cloud auditing)"
    echo "  cloudmapper  - Launch CloudMapper (AWS visualization)"
    echo ""
    echo "List tools by provider:"
    echo "  aws-tools    - List AWS tools"
    echo "  azure-tools  - List Azure tools"
    echo "  gcp-tools    - List GCP tools"
    echo "  multi-tools  - List multi-cloud tools"
    echo ""
    echo "Next Steps:"
    echo "1. Restart your terminal or run: source ~/.bashrc"
    echo "2. Configure credentials: nano ~/cloud-env.sh"
    echo "3. Load credentials: source ~/cloud-env.sh"
    echo ""
    log_warning "Note: Each Python tool has its own virtual environment in its directory"
    log_info "For help, run: cptf-help"
}

# Run main function
main "$@"
