#!/bin/bash

#########################################
# CPTF OS ARM Setup Script
# For Apple Silicon and ARM64 devices
# Based on RedCloud OS tool collection
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
        nodejs \
        npm \
        golang \
        ruby \
        ruby-dev \
        docker.io \
        docker-compose \
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
        python3-dev \
        openjdk-11-jdk \
        terminator \
        vim \
        nano
    
    # Install PowerShell Core for ARM
    log_info "Installing PowerShell Core for ARM..."
    # Download and install PowerShell for ARM64
    wget -q https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell-7.4.0-linux-arm64.tar.gz
    mkdir -p /opt/microsoft/powershell/7
    tar zxf powershell-7.4.0-linux-arm64.tar.gz -C /opt/microsoft/powershell/7
    chmod +x /opt/microsoft/powershell/7/pwsh
    ln -sf /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
    rm powershell-7.4.0-linux-arm64.tar.gz
    
    log_success "Base dependencies installed"
}

# Create directory structure
create_directories() {
    log_info "Creating directory structure..."
    mkdir -p /opt/{aws,azure,gcp,multi-cloud}/{enumeration,exploitation,post-exploitation}
    mkdir -p /usr/local/bin
    log_success "Directory structure created"
}

#########################################
# AWS Tools Installation
#########################################

install_aws_tools() {
    log_info "Installing AWS tools..."
    
    # AWS CLI v2 for ARM
    log_info "Installing AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    ./aws/install
    rm -rf awscliv2.zip aws/
    
    # AWS Consoler
    log_info "Installing AWS Consoler..."
    cd /opt/aws/exploitation
    git clone https://github.com/NetSPI/aws_consoler.git
    cd aws_consoler
    pip3 install -r requirements.txt
    
    # AWS Escalate
    log_info "Installing AWS Escalate..."
    cd /opt/aws/post-exploitation
    wget https://raw.githubusercontent.com/RhinoSecurityLabs/Security-Research/master/tools/aws-pentest-tools/aws_escalate.py
    chmod +x aws_escalate.py
    
    # CloudCopy
    log_info "Installing CloudCopy..."
    cd /opt/aws/exploitation
    git clone https://github.com/Static-Flow/CloudCopy.git
    
    # CloudJack
    log_info "Installing CloudJack..."
    cd /opt/aws/exploitation
    git clone https://github.com/prevade/cloudjack.git
    cd cloudjack
    pip3 install -r requirements.txt
    
    # CloudMapper
    log_info "Installing CloudMapper..."
    cd /opt/aws/enumeration
    git clone https://github.com/duo-labs/cloudmapper.git
    cd cloudmapper
    pip3 install -r requirements.txt
    
    # CredKing
    log_info "Installing CredKing..."
    cd /opt/aws/exploitation
    git clone https://github.com/ustayready/CredKing.git
    cd CredKing
    pip3 install -r requirements.txt
    
    # Endgame
    log_info "Installing Endgame..."
    cd /opt/aws/post-exploitation
    git clone https://github.com/hoodoer/endgame.git
    cd endgame
    pip3 install -r requirements.txt || true
    
    # Pacu
    log_info "Installing Pacu..."
    cd /opt/aws/exploitation
    git clone https://github.com/RhinoSecurityLabs/pacu.git
    cd pacu
    pip3 install -r requirements.txt
    
    # Redboto
    log_info "Installing Redboto..."
    cd /opt/aws/exploitation
    git clone https://github.com/ihamburglar/Redboto.git
    
    # weirdAAL
    log_info "Installing weirdAAL..."
    cd /opt/aws/enumeration
    git clone https://github.com/carnal0wnage/weirdAAL.git
    cd weirdAAL
    pip3 install -r requirements.txt
    
    log_success "AWS tools installed"
}

#########################################
# Azure Tools Installation
#########################################

install_azure_tools() {
    log_info "Installing Azure tools..."
    
    # Azure CLI
    log_info "Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash
    
    # AADCookieSpoof
    log_info "Installing AADCookieSpoof..."
    cd /opt/azure/exploitation
    git clone https://github.com/jsa2/aadcookiespoof.git
    
    # AADInternals (PowerShell module)
    log_info "Installing AADInternals..."
    pwsh -Command "Install-Module -Name AADInternals -Force -AllowClobber"
    
    # AzureAD PowerShell module
    log_info "Installing AzureAD PowerShell module..."
    pwsh -Command "Install-Module -Name AzureAD -Force -AllowClobber"
    
    # AzureHound
    log_info "Installing AzureHound..."
    cd /opt/azure/enumeration
    git clone https://github.com/BloodHoundAD/AzureHound.git
    cd AzureHound
    go build .
    
    # BloodHound
    log_info "Installing BloodHound..."
    cd /opt/azure/enumeration
    wget https://github.com/BloodHoundAD/BloodHound/releases/latest/download/BloodHound-linux-arm64.zip -O BloodHound.zip || {
        log_warning "ARM64 BloodHound not available, will need manual installation"
    }
    if [ -f BloodHound.zip ]; then
        unzip -q BloodHound.zip
        rm BloodHound.zip
    fi
    
    # DCToolbox
    log_info "Installing DCToolbox..."
    pwsh -Command "Install-Module -Name DCToolbox -Force -AllowClobber"
    
    # MFASweep
    log_info "Installing MFASweep..."
    cd /opt/azure/exploitation
    git clone https://github.com/dafthack/MFASweep.git
    
    # MicroBurst
    log_info "Installing MicroBurst..."
    cd /opt/azure/exploitation
    git clone https://github.com/NetSPI/MicroBurst.git
    
    # Microsoft365 devicePhish
    log_info "Installing Microsoft365 devicePhish..."
    cd /opt/azure/exploitation
    git clone https://github.com/optiv/Microsoft365_devicePhish.git
    cd Microsoft365_devicePhish/Python
    pip3 install -r requirements.txt || true
    
    # MS Graph PowerShell
    log_info "Installing MS Graph PowerShell..."
    pwsh -Command "Install-Module -Name Microsoft.Graph -Force -AllowClobber"
    
    # PowerUpSQL
    log_info "Installing PowerUpSQL..."
    cd /opt/azure/post-exploitation
    git clone https://github.com/NetSPI/PowerUpSQL.git
    
    # ROADtools
    log_info "Installing ROADtools..."
    cd /opt/azure/enumeration
    git clone https://github.com/dirkjanm/ROADtools.git
    cd ROADtools
    pip3 install . || true
    
    # TeamFiltration
    log_info "Installing TeamFiltration..."
    cd /opt/azure/exploitation
    # TeamFiltration requires .NET, downloading pre-built if available
    wget https://github.com/Flangvik/TeamFiltration/releases/latest/download/TeamFiltration_Linux_ARM64.zip -O TeamFiltration.zip || {
        log_warning "ARM64 TeamFiltration not available, building from source..."
        git clone https://github.com/Flangvik/TeamFiltration.git
    }
    if [ -f TeamFiltration.zip ]; then
        unzip -q TeamFiltration.zip
        rm TeamFiltration.zip
    fi
    
    # TokenTactics
    log_info "Installing TokenTactics..."
    cd /opt/azure/exploitation
    git clone https://github.com/rvrsh3ll/TokenTactics.git
    
    log_success "Azure tools installed"
}

#########################################
# GCP Tools Installation
#########################################

install_gcp_tools() {
    log_info "Installing GCP tools..."
    
    # Google Cloud SDK
    log_info "Installing Google Cloud SDK..."
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    apt-get update && apt-get install -y google-cloud-cli
    
    # GCPBucketBrute
    log_info "Installing GCPBucketBrute..."
    cd /opt/gcp/enumeration
    git clone https://github.com/RhinoSecurityLabs/GCPBucketBrute.git
    cd GCPBucketBrute
    pip3 install -r requirements.txt
    
    # GCP Delegation
    log_info "Installing GCP Delegation..."
    cd /opt/gcp/exploitation
    git clone https://gitlab.com/gitlab-com/gl-security/threatmanagement/redteam/redteam-public/gcp_misc.git
    
    # GCP Enum
    log_info "Installing GCP Enum..."
    cd /opt/gcp/enumeration
    git clone https://gitlab.com/gitlab-com/gl-security/threatmanagement/redteam/redteam-public/gcp_enum.git
    
    # GCP Firewall Enum
    log_info "Installing GCP Firewall Enum..."
    cd /opt/gcp/enumeration
    git clone https://gitlab.com/gitlab-com/gl-security/threatmanagement/redteam/redteam-public/gcp_firewall_enum.git
    
    # GCP IAM Collector
    log_info "Installing GCP IAM Collector..."
    cd /opt/gcp/enumeration
    git clone https://github.com/marcin-kolda/gcp-iam-collector.git
    cd gcp-iam-collector
    go build .
    
    # GCP IAM Privilege Escalation
    log_info "Installing GCP IAM Privilege Escalation..."
    cd /opt/gcp/post-exploitation
    git clone https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation.git
    
    # GCPTokenReuse
    log_info "Installing GCPTokenReuse..."
    cd /opt/gcp/exploitation
    git clone https://github.com/RedTeamOperations/GCPTokenReuse.git
    
    # GoogleWorkspaceDirectoryDump
    log_info "Installing GoogleWorkspaceDirectoryDump..."
    cd /opt/gcp/enumeration
    git clone https://github.com/RedTeamOperations/GoogleWorkspaceDirectoryDump.git
    
    # Hayat
    log_info "Installing Hayat..."
    cd /opt/gcp/enumeration
    git clone https://github.com/DenizParlak/hayat.git
    cd hayat
    go build .
    
    log_success "GCP tools installed"
}

#########################################
# Multi-Cloud Tools Installation
#########################################

install_multicloud_tools() {
    log_info "Installing Multi-Cloud tools..."
    
    # Cartography
    log_info "Installing Cartography..."
    cd /opt/multi-cloud/enumeration
    git clone https://github.com/lyft/cartography.git
    cd cartography
    pip3 install -e .
    
    # CCAT
    log_info "Installing CCAT..."
    cd /opt/multi-cloud/exploitation
    git clone https://github.com/RhinoSecurityLabs/ccat.git
    cd ccat
    pip3 install -r requirements.txt
    
    # CloudBrute
    log_info "Installing CloudBrute..."
    cd /opt/multi-cloud/enumeration
    git clone https://github.com/0xsha/CloudBrute.git
    cd CloudBrute
    go build -o cloudbrute .
    
    # CloudEnum
    log_info "Installing CloudEnum..."
    cd /opt/multi-cloud/enumeration
    git clone https://github.com/initstring/cloud_enum.git
    cd cloud_enum
    pip3 install -r requirements.txt
    
    # Cloud Service Enum
    log_info "Installing Cloud Service Enum..."
    cd /opt/multi-cloud/enumeration
    git clone https://github.com/NotSoSecure/cloud-service-enum.git
    
    # Evilginx2
    log_info "Installing Evilginx2..."
    cd /opt/multi-cloud/exploitation
    git clone https://github.com/kgretzky/evilginx2.git
    cd evilginx2
    go build .
    
    # Gitleaks
    log_info "Installing Gitleaks..."
    cd /opt/multi-cloud/enumeration
    wget https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_*_linux_arm64.tar.gz -O gitleaks.tar.gz || {
        log_warning "ARM64 Gitleaks not found, building from source..."
        git clone https://github.com/gitleaks/gitleaks.git
        cd gitleaks
        go build .
    }
    if [ -f gitleaks.tar.gz ]; then
        tar -xzf gitleaks.tar.gz
        rm gitleaks.tar.gz
    fi
    
    # Impacket
    log_info "Installing Impacket..."
    cd /opt/multi-cloud/exploitation
    git clone https://github.com/fortra/impacket.git
    cd impacket
    pip3 install .
    
    # Leonidas
    log_info "Installing Leonidas..."
    cd /opt/multi-cloud/exploitation
    git clone https://github.com/WithSecureLabs/leonidas.git
    cd leonidas
    pip3 install -r requirements.txt || true
    
    # Modlishka
    log_info "Installing Modlishka..."
    cd /opt/multi-cloud/exploitation
    git clone https://github.com/drk1wi/Modlishka.git
    cd Modlishka
    go build .
    
    # Mose
    log_info "Installing Mose..."
    cd /opt/multi-cloud/post-exploitation
    git clone https://github.com/master-of-servers/mose.git
    cd mose
    go build .
    
    # PurplePanda
    log_info "Installing PurplePanda..."
    cd /opt/multi-cloud/enumeration
    git clone https://github.com/carlospolop/PurplePanda.git
    cd PurplePanda
    pip3 install -r requirements.txt
    
    # Responder
    log_info "Installing Responder..."
    cd /opt/multi-cloud/exploitation
    git clone https://github.com/lgandx/Responder.git
    
    # ScoutSuite
    log_info "Installing ScoutSuite..."
    cd /opt/multi-cloud/enumeration
    git clone https://github.com/nccgroup/ScoutSuite.git
    cd ScoutSuite
    pip3 install -r requirements.txt
    
    # SkyArk
    log_info "Installing SkyArk..."
    cd /opt/multi-cloud/enumeration
    git clone https://github.com/cyberark/SkyArk.git
    
    # Zphisher
    log_info "Installing Zphisher..."
    cd /opt/multi-cloud/exploitation
    git clone https://github.com/htr-tech/zphisher.git
    
    log_success "Multi-Cloud tools installed"
}

#########################################
# Create startup scripts
#########################################

create_startup_scripts() {
    log_info "Creating startup scripts..."
    
    # Create a template startup script
    cat > /usr/local/bin/redcloud-template << 'EOF'
#!/bin/bash
# RedCloud Tool Launcher Template
TOOL_PATH="$1"
TOOL_NAME="$2"

if [ -z "$TOOL_PATH" ]; then
    echo "Usage: $0 <tool_path> <tool_name>"
    exit 1
fi

cd "$TOOL_PATH" || exit 1

echo "Starting $TOOL_NAME..."
echo "Tool location: $TOOL_PATH"
echo ""

# Check for Python virtual environment
if [ -f "requirements.txt" ]; then
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
    pip3 install -r requirements.txt 2>/dev/null
fi

# Start interactive shell in tool directory
exec bash
EOF
    
    chmod +x /usr/local/bin/redcloud-template
    
    # Create individual tool launchers
    echo '#!/bin/bash' > /usr/local/bin/pacu
    echo 'cd /opt/aws/exploitation/pacu && python3 pacu.py' >> /usr/local/bin/pacu
    chmod +x /usr/local/bin/pacu
    
    echo '#!/bin/bash' > /usr/local/bin/scoutsuite
    echo 'cd /opt/multi-cloud/enumeration/ScoutSuite && python3 scout.py "$@"' >> /usr/local/bin/scoutsuite
    chmod +x /usr/local/bin/scoutsuite
    
    log_success "Startup scripts created"
}

#########################################
# Setup aliases
#########################################

setup_aliases() {
    log_info "Setting up aliases..."
    
    cat >> /etc/bash.bashrc << 'EOF'

# RedCloud OS Aliases
alias c='clear'
alias a='nano ~/.bash_aliases'
alias s='source ~/.bash_aliases'
alias v='python3 -m venv venv && source venv/bin/activate'
alias d='deactivate'
alias p='pip3 install -r requirements.txt'
alias ll='ls -la'

# Tool quick access
alias aws-tools='ls -la /opt/aws/'
alias azure-tools='ls -la /opt/azure/'
alias gcp-tools='ls -la /opt/gcp/'
alias multi-tools='ls -la /opt/multi-cloud/'
EOF
    
    log_success "Aliases configured"
}

#########################################
# Create environment variable templates
#########################################

create_env_templates() {
    log_info "Creating environment variable templates..."
    
    cat > /root/cloud-env-vars.sh << 'EOF'
#!/bin/bash
# Cloud Environment Variables Template
# Source this file: source ~/cloud-env-vars.sh

# AWS
#export AWS_ACCESS_KEY_ID=<access_key_id>
#export AWS_SECRET_ACCESS_KEY=<access_key>
#export AWS_DEFAULT_REGION=<region>

# Azure
#export AZURE_CLIENT_ID=<app-id>
#export AZURE_TENANT_ID=<tenant-id>
#export AZURE_CLIENT_SECRET=<app-secret>

# GCP
#export GOOGLE_APPLICATION_CREDENTIALS=<Service Account Json File Path>

echo "Cloud environment variables template loaded"
echo "Edit this file to add your credentials: nano ~/cloud-env-vars.sh"
EOF
    
    chmod +x /root/cloud-env-vars.sh
    log_success "Environment templates created"
}

#########################################
# Fix permissions
#########################################

fix_permissions() {
    log_info "Fixing permissions..."
    chmod -R 755 /opt/aws /opt/azure /opt/gcp /opt/multi-cloud
    log_success "Permissions fixed"
}

#########################################
# Main installation flow
#########################################

main() {
    clear
    echo "================================================"
    echo "     RedCloud OS ARM Setup Script"
    echo "     For Apple Silicon & ARM64 Devices"
    echo "================================================"
    echo ""
    
    check_sudo
    check_architecture
    
    log_info "Starting RedCloud OS ARM installation..."
    
    update_system
    install_base_deps
    create_directories
    
    # Install tool categories
    install_aws_tools
    install_azure_tools
    install_gcp_tools
    install_multicloud_tools
    
    # Setup environment
    create_startup_scripts
    setup_aliases
    create_env_templates
    fix_permissions
    
    echo ""
    echo "================================================"
    log_success "RedCloud OS ARM installation completed!"
    echo "================================================"
    echo ""
    echo "Next steps:"
    echo "1. Configure cloud credentials in ~/cloud-env-vars.sh"
    echo "2. Source the file: source ~/cloud-env-vars.sh"
    echo "3. Tools are installed in /opt/{aws,azure,gcp,multi-cloud}"
    echo "4. Restart your shell to use the new aliases"
    echo ""
    echo "Default credentials for reference:"
    echo "Username: $USER (current user)"
    echo "Tools location: /opt/"
    echo ""
    log_warning "Some tools may require additional configuration for ARM architecture"
    log_warning "Check individual tool documentation for ARM-specific setup"
}

# Run main function
main "$@"
