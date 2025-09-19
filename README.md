# RedCloud OS ARM Edition

<div align="center">

![ARM Support](https://img.shields.io/badge/ARM64-Supported-green?style=for-the-badge&logo=arm)
![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-Compatible-black?style=for-the-badge&logo=apple)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Linux%20ARM-orange?style=for-the-badge&logo=linux)

**Cloud Adversary Simulation Tools for ARM Architecture**

[Installation](#-installation) • [Features](#-features) • [Tools](#-tools) • [Usage](#-usage) • [Contributing](#-contributing)

</div>

---

## 📋 Overview

RedCloud OS ARM Edition is a comprehensive setup script that brings the powerful cloud pentesting toolkit from [RedCloud OS](https://github.com/RedTeamOperations/RedCloud-OS) to ARM64 devices, including Apple Silicon Macs. This script automates the installation of 40+ cloud security testing tools optimized for AWS, Azure, GCP, and multi-cloud environments.

### 🎯 Perfect For

- Security professionals using Apple Silicon MacBooks (M1/M2/M3)
- Cloud penetration testers on ARM-based systems
- Red teams requiring portable cloud testing environments
- DevSecOps teams on ARM infrastructure
- Researchers using Raspberry Pi or ARM servers

## ✨ Features

- **🏗️ ARM-Native Installation**: Optimized for ARM64 architecture with automatic detection
- **☁️ Complete Cloud Coverage**: Tools for AWS, Azure, GCP, and multi-cloud environments
- **📦 40+ Security Tools**: Comprehensive suite of enumeration, exploitation, and post-exploitation tools
- **🔧 Automated Setup**: Single script installation with dependency management
- **🎨 Organized Structure**: Tools categorized by cloud provider and attack phase
- **⚡ Performance Optimized**: Native ARM binaries where available, source compilation fallback
- **🔐 Environment Templates**: Pre-configured templates for cloud credentials

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
git clone https://github.com/ai-redteam/redcloud-os-arm.git
cd redcloud-os-arm

# Make the script executable
chmod +x redcloud-arm-setup.sh

# Run the installation
sudo ./redcloud-arm-setup.sh
```

### Docker Installation (Alternative)

```bash
# Build the Docker image
docker build -t redcloud-arm .

# Run the container
docker run -it --name redcloud redcloud-arm /bin/bash
```

## 🛠️ Tools

### AWS Tools
| Tool | Description | Category |
|------|-------------|----------|
| [AWS CLI v2](https://aws.amazon.com/cli/) | Official AWS command-line interface | Management |
| [Pacu](https://github.com/RhinoSecurityLabs/pacu) | AWS exploitation framework | Exploitation |
| [CloudMapper](https://github.com/duo-labs/cloudmapper) | Analyze AWS environments | Enumeration |
| [weirdAAL](https://github.com/carnal0wnage/weirdAAL) | AWS Attack Library | Enumeration |
| [AWS Consoler](https://github.com/NetSPI/aws_consoler) | Convert AWS credentials to console access | Exploitation |
| [Endgame](https://github.com/hoodoer/endgame) | AWS Pentesting Library | Post-Exploitation |
| [CloudCopy](https://github.com/Static-Flow/CloudCopy) | Cloud bucket exploitation | Exploitation |
| [CloudJack](https://github.com/prevade/cloudjack) | Route53/CloudFront hijacking | Exploitation |
| [CredKing](https://github.com/ustayready/CredKing) | Password spraying | Exploitation |
| [Redboto](https://github.com/ihamburglar/Redboto) | Red team scripts for AWS | Exploitation |

### Azure Tools
| Tool | Description | Category |
|------|-------------|----------|
| [Azure CLI](https://docs.microsoft.com/cli/azure/) | Official Azure command-line interface | Management |
| [AzureHound](https://github.com/BloodHoundAD/AzureHound) | Azure AD reconnaissance | Enumeration |
| [MicroBurst](https://github.com/NetSPI/MicroBurst) | Azure security assessment scripts | Exploitation |
| [ROADtools](https://github.com/dirkjanm/ROADtools) | Azure AD exploration framework | Enumeration |
| [PowerUpSQL](https://github.com/NetSPI/PowerUpSQL) | SQL Server assessment toolkit | Post-Exploitation |
| [AADInternals](https://github.com/Gerenios/AADInternals) | Azure AD administration | Exploitation |
| [TeamFiltration](https://github.com/Flangvik/TeamFiltration) | Teams enumeration and exfiltration | Exploitation |
| [TokenTactics](https://github.com/rvrsh3ll/TokenTactics) | Azure token manipulation | Exploitation |
| [MFASweep](https://github.com/dafthack/MFASweep) | MFA bypass testing | Exploitation |

### GCP Tools
| Tool | Description | Category |
|------|-------------|----------|
| [gcloud CLI](https://cloud.google.com/sdk/) | Official Google Cloud CLI | Management |
| [GCPBucketBrute](https://github.com/RhinoSecurityLabs/GCPBucketBrute) | Enumerate GCP buckets | Enumeration |
| [GCP IAM Privilege Escalation](https://github.com/RhinoSecurityLabs/GCP-IAM-Privilege-Escalation) | Escalate GCP IAM privileges | Post-Exploitation |
| [Hayat](https://github.com/DenizParlak/hayat) | Google Cloud Platform Auditor | Enumeration |
| [GCPTokenReuse](https://github.com/RedTeamOperations/GCPTokenReuse) | GCP token reuse attacks | Exploitation |

### Multi-Cloud Tools
| Tool | Description | Category |
|------|-------------|----------|
| [ScoutSuite](https://github.com/nccgroup/ScoutSuite) | Multi-cloud security auditing | Enumeration |
| [Impacket](https://github.com/fortra/impacket) | Network protocol manipulation | Exploitation |
| [CloudEnum](https://github.com/initstring/cloud_enum) | Multi-cloud OSINT | Enumeration |
| [Cartography](https://github.com/lyft/cartography) | Infrastructure asset inventory | Enumeration |
| [PurplePanda](https://github.com/carlospolop/PurplePanda) | Multi-cloud privilege escalation | Post-Exploitation |
| [Responder](https://github.com/lgandx/Responder) | LLMNR/NBT-NS/MDNS poisoner | Exploitation |
| [Gitleaks](https://github.com/gitleaks/gitleaks) | Secret scanning | Enumeration |

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

### Setting Up Cloud Credentials

After installation, configure your cloud credentials:

```bash
# Edit the environment template
nano ~/cloud-env-vars.sh

# Add your credentials
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AZURE_CLIENT_ID=your_client_id
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json

# Source the file
source ~/cloud-env-vars.sh
```

### Quick Tool Access

Use the built-in aliases:

```bash
# List tools by provider
aws-tools      # List all AWS tools
azure-tools    # List all Azure tools
gcp-tools      # List all GCP tools
multi-tools    # List all multi-cloud tools

# Launch specific tools
pacu           # Start Pacu framework
scoutsuite     # Run ScoutSuite
```

### Running Tools

Navigate to tool directories:

```bash
# AWS Pacu
cd /opt/aws/exploitation/pacu
python3 pacu.py

# Azure MicroBurst
cd /opt/azure/exploitation/MicroBurst
pwsh
Import-Module ./MicroBurst.psm1

# GCP Scanner
cd /opt/gcp/enumeration/gcp_enum
./gcp_enum.sh
```

## 🧩 Compatibility

### Tested Platforms

- ✅ **macOS on Apple Silicon** (M1/M2/M3)
- ✅ **Ubuntu 22.04 ARM64**
- ✅ **Debian 11/12 ARM64**
- ✅ **Kali Linux ARM64**
- ✅ **Raspberry Pi OS (64-bit)**

### Known Limitations

- Some tools may have reduced functionality on ARM compared to x86_64
- Binary-only tools without ARM support require manual workarounds
- PowerShell modules may have compatibility issues

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Reporting Issues

Found a bug or have a suggestion? Please open an [issue](https://github.com/yourusername/redcloud-os-arm/issues) with:
- Your ARM device/platform details
- Error messages or logs
- Steps to reproduce the issue

## 📚 Documentation

- [Installation Guide](docs/INSTALL.md)
- [Tool Documentation](docs/TOOLS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Security Best Practices](docs/SECURITY.md)

## 🔐 Security

**⚠️ IMPORTANT**: This toolkit is designed for authorized security testing only. Users must:

- Only use these tools on systems you own or have explicit permission to test
- Comply with all applicable laws and regulations
- Understand that misuse may result in criminal charges
- Use VPNs and isolated environments when appropriate

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [RedCloud OS Team](https://github.com/RedTeamOperations/RedCloud-OS) for the original tool collection
- [Parrot Security](https://www.parrotsec.org/) for the base OS inspiration
- All tool authors and maintainers listed above
- The ARM and Apple Silicon community for testing and feedback

## 📮 Contact

- **Issues**: [GitHub Issues](https://github.com/yourusername/redcloud-os-arm/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/redcloud-os-arm/discussions)
- **Security**: Please report security vulnerabilities privately to security@example.com

## 🎓 Learning Resources

Enhance your cloud security skills:

- [AWS Cloud Red Team Specialist (CARTS)](https://cyberwarfare.live/product/aws-cloud-red-team-specialist-carts/)
- [Google Cloud Red Team Specialist (CGRTS)](https://cyberwarfare.live/product/google-cloud-red-team-specialist-cgrts/)
- [Multi-Cloud Red Team Analyst (MCRTA)](https://cyberwarfare.live/product/multi-cloud-red-team-analyst-mcrta/)
- [Hybrid Multi-Cloud Red Team Specialist (CHMRTS)](https://cyberwarfare.live/product/hybrid-multi-cloud-red-team-specialist-chmrts/)

---

<div align="center">

**⭐ Star this repository if you find it useful!**

Made with ❤️ for the ARM Security Community

[Report Bug](https://github.com/yourusername/redcloud-os-arm/issues) • [Request Feature](https://github.com/yourusername/redcloud-os-arm/issues)

</div>
