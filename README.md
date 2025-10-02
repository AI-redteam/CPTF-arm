**There is a current issue with docker version, will fix asap**

# CPTF ARM Edition

<div align="center">

![GitHub stars](https://img.shields.io/github/stars/ai-redteam/cptf-arm?style=social)
![GitHub forks](https://img.shields.io/github/forks/ai-redteam/cptf-arm?style=social)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-ARM64-orange.svg)

**Cloud Adversary Simulation Tools for ARM Architecture**

[Installation](#-installation) • [Features](#-features) • [Tools](#-tools) • [Usage](#-usage) • [Contributing](#-contributing)

</div>

---

## 📋 Overview

CPTF ARM Edition is a comprehensive setup script that brings a powerful cloud pentesting toolkit to ARM64 devices, including Apple Silicon Macs. This script automates the installation of 40+ cloud security testing tools optimized for AWS, Azure, GCP, and multi-cloud environments.

## 🎯 Perfect For

- 💻 Security professionals using Apple Silicon MacBooks (M1/M2/M3)
- ☁️ Cloud penetration testers on ARM-based systems
- 🔴 Red teams requiring portable cloud testing environments
- 🔧 DevSecOps teams on ARM infrastructure
- 🔬 Researchers using Raspberry Pi or ARM servers

## ✨ Features

- **🏗️ ARM-Native Installation** - Optimized for ARM64 architecture with automatic detection
- **☁️ Complete Cloud Coverage** - Tools for AWS, Azure, GCP, and multi-cloud environments
- **📦 40+ Security Tools** - Comprehensive suite of enumeration, exploitation, and post-exploitation tools
- **🔧 Automated Setup** - Single script installation with dependency management
- **🎨 Organized Structure** - Tools categorized by cloud provider and attack phase
- **⚡ Performance Optimized** - Native ARM binaries where available, source compilation fallback
- **🔐 Environment Templates** - Pre-configured templates for cloud credentials

## 🚀 Installation

### Prerequisites

- ARM64/aarch64 Linux system (Ubuntu, Debian, Kali, or compatible)
- Minimum 16GB RAM recommended (8GB minimum)
- 20GB+ free disk space
- Internet connection
- sudo privileges

### Quick Start

```bash
# Clone the repository
git clone https://github.com/ai-redteam/CPTF-arm.git
cd CPTF-arm

# Make the script executable
chmod +x cptf-arm.sh

# Run the installation
sudo ./cptf-arm.sh
```

### ⚠️ Important: Post-Installation Steps

After the script finishes, you must perform the following steps to use the tools:

#### 1. Reload Your Shell Environment

To enable the new commands and aliases, either close and re-open your terminal or run:

```bash
source ~/.bashrc
```

#### 2. Configure Your Cloud Credentials

A template file has been created in your home directory to manage API keys.

```bash
# Edit the credentials file
nano ~/cloud-env.sh
```

Uncomment the lines for the cloud provider you are testing and add your keys.

#### 3. Load Credentials into Your Session

Before running any tools, source the file to load your keys as environment variables.

```bash
source ~/cloud-env.sh
```

> **Note:** You will need to do this for every new terminal session.

## 🐳 Docker Installation (Recommended)

The Docker installation provides a clean, isolated environment without modifying your host system.

### Prerequisites

- Docker Engine 20.10+ with ARM64 support
- 8GB RAM recommended (4GB minimum)
- 15GB free disk space

### Quick Start

```bash
# Clone the repository
git clone https://github.com/ai-redteam/cptf-arm.git
cd cptf-arm

# Build the image
docker build -t cptf-arm .

# Run the container
docker run -it --name cptf cptf-arm
```

### Using Docker Compose

```bash
# Start with docker-compose
docker-compose up -d

# Access the container
docker exec -it cptf-arm bash

# Stop and remove
docker-compose down
```

### Mounting Cloud Credentials

```bash
# Run with persistent credentials
docker run -it \
  -v ~/.aws:/root/.aws:ro \
  -v ~/.azure:/root/.azure:ro \
  -v ~/gcp-creds:/root/gcp:ro \
  -v ~/cptf-data:/data \
  cptf-arm
```

### Environment Variables

Create a `.env` file for docker-compose:

```env
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AZURE_CLIENT_ID=your_client_id
AZURE_TENANT_ID=your_tenant_id
```

### Useful Commands

```bash
# Run specific tool
docker exec -it cptf-arm pacu

# Update container
docker pull cptf-arm:latest
docker-compose restart

# View logs
docker logs cptf-arm

# Clean up
docker-compose down -v
```

> **💡 Tip:** The Docker method provides isolation, easy cleanup, and consistent environments across different systems. All tools are pre-installed and configured in `/opt/{aws,azure,gcp,multi-cloud}/`.

## 🛠️ Tools

### AWS Tools

| Tool | Description | Category |
|------|-------------|----------|
| **AWS CLI v2** | Official AWS command-line interface | Management |
| **Pacu** | AWS exploitation framework | Exploitation |
| **CloudMapper** | Analyze AWS environments | Enumeration |
| **weirdAAL** | AWS Attack Library | Enumeration |
| **AWS Consoler** | Convert AWS credentials to console access | Exploitation |
| **Endgame** | AWS Pentesting Library | Post-Exploitation |
| **CloudCopy** | Cloud bucket exploitation | Exploitation |
| **CloudJack** | Route53/CloudFront hijacking | Exploitation |
| **CredKing** | Password spraying | Exploitation |
| **Redboto** | Red team scripts for AWS | Exploitation |

### Azure Tools

| Tool | Description | Category |
|------|-------------|----------|
| **Azure CLI** | Official Azure command-line interface | Management |
| **AzureHound** | Azure AD reconnaissance | Enumeration |
| **MicroBurst** | Azure security assessment scripts | Exploitation |
| **ROADtools** | Azure AD exploration framework | Enumeration |
| **PowerUpSQL** | SQL Server assessment toolkit | Post-Exploitation |
| **AADInternals** | Azure AD administration | Exploitation |
| **TeamFiltration** | Teams enumeration and exfiltration | Exploitation |
| **TokenTactics** | Azure token manipulation | Exploitation |
| **MFASweep** | MFA bypass testing | Exploitation |

### GCP Tools

| Tool | Description | Category |
|------|-------------|----------|
| **gcloud CLI** | Official Google Cloud CLI | Management |
| **GCPBucketBrute** | Enumerate GCP buckets | Enumeration |
| **GCP IAM Privilege Escalation** | Escalate GCP IAM privileges | Post-Exploitation |
| **Hayat** | Google Cloud Platform Auditor | Enumeration |
| **GCPTokenReuse** | GCP token reuse attacks | Exploitation |

### Multi-Cloud Tools

| Tool | Description | Category |
|------|-------------|----------|
| **ScoutSuite** | Multi-cloud security auditing | Enumeration |
| **Impacket** | Network protocol manipulation | Exploitation |
| **CloudEnum** | Multi-cloud OSINT | Enumeration |
| **Cartography** | Infrastructure asset inventory | Enumeration |
| **PurplePanda** | Multi-cloud privilege escalation | Post-Exploitation |
| **Responder** | LLMNR/NBT-NS/MDNS poisoner | Exploitation |
| **Gitleaks** | Secret scanning | Enumeration |

## 📁 Directory Structure

```
/opt/
├── aws/
│   ├── enumeration/
│   ├── exploitation/
│   └── post-exploitation/
├── azure/
│   ├── enumeration/
│   ├── exploitation/
│   └── post-exploitation/
├── gcp/
│   ├── enumeration/
│   ├── exploitation/
│   └── post-exploitation/
└── multi-cloud/
    ├── enumeration/
    ├── exploitation/
    └── post-exploitation/
```

## 🔧 Usage

### Quick Tool Access

Use the built-in launchers and aliases for fast access to common tools.

```bash
# Get a list of primary tool commands
cptf-help

# Launch specific tools directly
pacu         # Starts the Pacu AWS exploitation framework
scoutsuite   # Runs the ScoutSuite multi-cloud scanner
```

You can also list all installed tools for a specific cloud provider:

```bash
# List tools by provider
aws-tools
azure-tools
gcp-tools
multi-tools
```

### Running Tools Without Launchers

For tools that don't have a dedicated launcher, you can run them by activating their isolated Python environment.

**Example: Running CloudMapper**

```bash
# 1. Navigate to the tool's directory
cd /opt/aws/enumeration/cloudmapper

# 2. Activate its virtual environment
source venv/bin/activate

# 3. Run the tool according to its documentation
python3 cloudmapper.py --help

# 4. Deactivate the environment when finished
deactivate
```

## 🧩 Compatibility

### ✅ Tested Platforms

- macOS on Apple Silicon (M1/M2/M3) via Linux VM
- Ubuntu 22.04 ARM64
- Debian 11/12 ARM64
- Kali Linux ARM64
- Raspberry Pi OS (64-bit)

### ⚠️ Known Limitations

- Some tools may have reduced functionality on ARM compared to x86_64
- Binary-only tools without ARM support require manual workarounds
- PowerShell modules may have compatibility issues

## 🤝 Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Reporting Issues

Found a bug or have a suggestion? Please [open an issue](https://github.com/ai-redteam/cptf-arm/issues) with:

- Your ARM device/platform details
- Error messages or logs
- Steps to reproduce the issue

## 📚 Documentation

- [Installation Guide](docs/installation.md)
- [Tool Documentation](docs/tools.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Security Best Practices](docs/security.md)

## 🔐 Security

> **⚠️ IMPORTANT:** This toolkit is designed for authorized security testing only.

Users must:
- Only use these tools on systems you own or have explicit permission to test
- Comply with all applicable laws and regulations
- Understand that misuse may result in criminal charges
- Use VPNs and isolated environments when appropriate

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **RedCloud OS Team** for the original tool collection
- **Parrot Security** for the base OS inspiration
- All tool authors and maintainers listed above
- The ARM and Apple Silicon community for testing and feedback

---

<div align="center">

### ⭐ Star this repository if you find it useful!

**Made with ❤️ for the ARM Security Community**

[Report Bug](https://github.com/ai-redteam/cptf-arm/issues) • [Request Feature](https://github.com/ai-redteam/cptf-arm/issues)

</div>
