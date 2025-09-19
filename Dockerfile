# CPTF-ARM (Cloud Penetration Testing Framework for ARM)
# Multi-stage build for optimized size and security

# Use Ubuntu 22.04 as base for ARM64
FROM --platform=linux/arm64 ubuntu:22.04 AS base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="/opt/microsoft/powershell/7:${PATH}" \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /root

# Install base dependencies and clean up in single layer
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    golang-go \
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
    python3-dev \
    openjdk-11-jdk \
    vim \
    nano \
    tmux \
    net-tools \
    iputils-ping \
    dnsutils \
    nmap \
    netcat \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PowerShell Core for ARM64
RUN wget -q https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell-7.4.0-linux-arm64.tar.gz \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar zxf powershell-7.4.0-linux-arm64.tar.gz -C /opt/microsoft/powershell/7 \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && ln -sf /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh \
    && rm powershell-7.4.0-linux-arm64.tar.gz

# Create directory structure
RUN mkdir -p /opt/{aws,azure,gcp,multi-cloud}/{enumeration,exploitation,post-exploitation} \
    && mkdir -p /usr/local/bin \
    && mkdir -p /scripts

# Copy the setup script
COPY cptf-arm-setup.sh /scripts/
RUN chmod +x /scripts/cptf-arm-setup.sh

# Stage for AWS tools
FROM base AS aws-tools
WORKDIR /opt/aws

# Install AWS CLI v2 for ARM
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/

# Install Python-based AWS tools
RUN cd /opt/aws/exploitation && git clone https://github.com/NetSPI/aws_consoler.git \
    && cd aws_consoler && pip3 install -r requirements.txt --break-system-packages || true

RUN cd /opt/aws/post-exploitation \
    && wget https://raw.githubusercontent.com/RhinoSecurityLabs/Security-Research/master/tools/aws-pentest-tools/aws_escalate.py \
    && chmod +x aws_escalate.py

RUN cd /opt/aws/exploitation && git clone https://github.com/Static-Flow/CloudCopy.git

RUN cd /opt/aws/exploitation && git clone https://github.com/prevade/cloudjack.git \
    && cd cloudjack && pip3 install -r requirements.txt --break-system-packages || true

RUN cd /opt/aws/enumeration && git clone https://github.com/duo-labs/cloudmapper.git \
    && cd cloudmapper && pip3 install -r requirements.txt --break-system-packages || true

RUN cd /opt/aws/exploitation && git clone https://github.com/RhinoSecurityLabs/pacu.git \
    && cd pacu && pip3 install -r requirements.txt --break-system-packages || true

RUN cd /opt/aws/enumeration && git clone https://github.com/carnal0wnage/weirdAAL.git \
    && cd weirdAAL && pip3 install -r requirements.txt --break-system-packages || true

# Stage for Azure tools
FROM base AS azure-tools
WORKDIR /opt/azure

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install PowerShell modules for Azure
RUN pwsh -Command "Install-Module -Name Az -Repository PSGallery -Force -AllowClobber -Scope AllUsers" \
    && pwsh -Command "Install-Module -Name AzureAD -Repository PSGallery -Force -AllowClobber -Scope AllUsers" \
    && pwsh -Command "Install-Module -Name AADInternals -Repository PSGallery -Force -AllowClobber -Scope AllUsers" \
    && pwsh -Command "Install-Module -Name DCToolbox -Repository PSGallery -Force -AllowClobber -Scope AllUsers" \
    && pwsh -Command "Install-Module -Name Microsoft.Graph -Repository PSGallery -Force -AllowClobber -Scope AllUsers"

# Clone Azure tools
RUN cd /opt/azure/exploitation && git clone https://github.com/jsa2/aadcookiespoof.git
RUN cd /opt/azure/enumeration && git clone https://github.com/BloodHoundAD/AzureHound.git
RUN cd /opt/azure/exploitation && git clone https://github.com/dafthack/MFASweep.git
RUN cd /opt/azure/exploitation && git clone https://github.com/NetSPI/MicroBurst.git
RUN cd /opt/azure/post-exploitation && git clone https://github.com/NetSPI/PowerUpSQL.git
RUN cd /opt/azure/enumeration && git clone https://github.com/dirkjanm/ROADtools.git
RUN cd /opt/azure/exploitation && git clone https://github.com/rvrsh3ll/TokenTactics.git

# Stage for GCP tools
FROM base AS gcp-tools
WORKDIR /opt/gcp

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y google-cloud-cli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone GCP tools
RUN cd /opt/gcp/enumeration && git clone https://github.com/RhinoSecurityLabs/GCPBucketBrute.git \
    && cd GCPBucketBrute && pip3 install -r requirements.txt --break-system-packages || true

RUN cd /opt/gcp/post-exploitation && git clone https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation.git
RUN cd /opt/gcp/exploitation && git clone https://github.com/RedTeamOperations/GCPTokenReuse.git
RUN cd /opt/gcp/enumeration && git clone https://github.com/RedTeamOperations/GoogleWorkspaceDirectoryDump.git

# Stage for Multi-Cloud tools
FROM base AS multicloud-tools
WORKDIR /opt/multi-cloud

# Install multi-cloud tools
RUN cd /opt/multi-cloud/enumeration && git clone https://github.com/lyft/cartography.git \
    && cd cartography && pip3 install -e . --break-system-packages || true

RUN cd /opt/multi-cloud/exploitation && git clone https://github.com/RhinoSecurityLabs/ccat.git \
    && cd ccat && pip3 install -r requirements.txt --break-system-packages || true

RUN cd /opt/multi-cloud/enumeration && git clone https://github.com/initstring/cloud_enum.git \
    && cd cloud_enum && pip3 install -r requirements.txt --break-system-packages || true

RUN cd /opt/multi-cloud/exploitation && git clone https://github.com/fortra/impacket.git \
    && cd impacket && pip3 install . --break-system-packages || true

RUN cd /opt/multi-cloud/enumeration && git clone https://github.com/nccgroup/ScoutSuite.git \
    && cd ScoutSuite && pip3 install -r requirements.txt --break-system-packages || true

RUN cd /opt/multi-cloud/exploitation && git clone https://github.com/lgandx/Responder.git

# Final stage - combine all tools
FROM base AS final

# Copy tools from build stages
COPY --from=aws-tools /opt/aws /opt/aws
COPY --from=azure-tools /opt/azure /opt/azure
COPY --from=gcp-tools /opt/gcp /opt/gcp
COPY --from=multicloud-tools /opt/multi-cloud /opt/multi-cloud

# Copy cloud provider CLIs and configurations
COPY --from=aws-tools /usr/local/aws-cli /usr/local/aws-cli
COPY --from=aws-tools /usr/local/bin/aws /usr/local/bin/aws
COPY --from=azure-tools /usr/bin/az /usr/bin/az
COPY --from=azure-tools /opt/az /opt/az
COPY --from=gcp-tools /usr/lib/google-cloud-sdk /usr/lib/google-cloud-sdk
COPY --from=gcp-tools /usr/bin/gcloud /usr/bin/gcloud

# Copy PowerShell modules
COPY --from=azure-tools /opt/microsoft/powershell/7/Modules /opt/microsoft/powershell/7/Modules
COPY --from=azure-tools /root/.local/share/powershell/Modules /root/.local/share/powershell/Modules

# Create environment setup script
RUN cat > /root/setup-env.sh << 'EOF'
#!/bin/bash
# CPTF-ARM Environment Variables Setup

echo "Setting up CPTF-ARM (Cloud Penetration Testing Framework) environment..."

# AWS
#export AWS_ACCESS_KEY_ID=your_access_key
#export AWS_SECRET_ACCESS_KEY=your_secret_key
#export AWS_DEFAULT_REGION=us-east-1

# Azure
#export AZURE_CLIENT_ID=your_client_id
#export AZURE_TENANT_ID=your_tenant_id
#export AZURE_CLIENT_SECRET=your_client_secret

# GCP
#export GOOGLE_APPLICATION_CREDENTIALS=/root/gcp-service-account.json

# Tool aliases
alias aws-tools='ls -la /opt/aws/'
alias azure-tools='ls -la /opt/azure/'
alias gcp-tools='ls -la /opt/gcp/'
alias multi-tools='ls -la /opt/multi-cloud/'
alias pacu='cd /opt/aws/exploitation/pacu && python3 pacu.py'
alias scoutsuite='cd /opt/multi-cloud/enumeration/ScoutSuite && python3 scout.py'

echo "CPTF-ARM environment ready!"
echo "Edit /root/setup-env.sh to add your cloud credentials"
echo "Tools are located in /opt/{aws,azure,gcp,multi-cloud}"
EOF

RUN chmod +x /root/setup-env.sh

# Create startup script
RUN cat > /usr/local/bin/cptf-startup << 'EOF'
#!/bin/bash
cat << 'BANNER'
╔══════════════════════════════════════════════════════════╗
║          CPTF-ARM - Cloud Penetration Testing             ║
║                  Framework for ARM                        ║
║                    Docker Container                       ║
╠══════════════════════════════════════════════════════════╣
║  AWS Tools:    /opt/aws                                  ║
║  Azure Tools:  /opt/azure                                ║
║  GCP Tools:    /opt/gcp                                  ║
║  Multi-Cloud:  /opt/multi-cloud                          ║
╠══════════════════════════════════════════════════════════╣
║  Setup:        source /root/setup-env.sh                 ║
║  Help:         cat /root/README.md                       ║
╚══════════════════════════════════════════════════════════╝
BANNER

source /root/setup-env.sh
exec /bin/bash
EOF

RUN chmod +x /usr/local/bin/cptf-startup

# Create README for container users
RUN cat > /root/README.md << 'EOF'
# CPTF-ARM Docker Container
## Cloud Penetration Testing Framework for ARM Architecture

### Quick Start

1. Set up your cloud credentials:
   ```bash
   nano /root/setup-env.sh
   source /root/setup-env.sh
   ```

2. Navigate to tools:
   ```bash
   cd /opt/aws/exploitation/pacu
   cd /opt/azure/enumeration/AzureHound
   cd /opt/gcp/enumeration/GCPBucketBrute
   ```

3. Use aliases:
   ```bash
   aws-tools
   azure-tools
   gcp-tools
   multi-tools
   ```

### Mounting Volumes

To persist data and credentials:
```bash
docker run -it \
  -v ~/.aws:/root/.aws \
  -v ~/.azure:/root/.azure \
  -v ~/gcp-creds:/root/gcp-creds \
  -v ~/cptf-data:/data \
  cptf-arm
```

### Network Access

For tools requiring network access:
```bash
docker run -it --network host cptf-arm
```

### About CPTF-ARM

CPTF-ARM is a comprehensive cloud security testing framework optimized for ARM64 architecture, 
including Apple Silicon devices. It provides 40+ tools for AWS, Azure, and GCP security testing.

EOF

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/cptf-startup"]

# Metadata
LABEL maintainer="CPTF-ARM Team" \
      version="1.0" \
      description="CPTF-ARM - Cloud Penetration Testing Framework for ARM Architecture" \
      architecture="arm64"
