# 🐳 Docker Installation

Docker provides the cleanest and most portable way to run CPTF-ARM. The containerized approach ensures consistency across different ARM64 systems and eliminates dependency conflicts.

## Prerequisites

- **Docker Engine** 20.10+ with ARM64 support
- **Docker Compose** v2.0+ (optional but recommended)
- **ARM64 Architecture** (Apple Silicon M1/M2/M3, AWS Graviton, Raspberry Pi 4/5)
- **Minimum Resources**:
  - RAM: 8GB recommended (4GB minimum)
  - Storage: 15GB for full installation
  - CPU: 2+ cores recommended

### Verify Docker ARM64 Support

```bash
# Check Docker is installed and running
docker --version
docker info | grep -i "architecture"

# Verify ARM64 platform support
docker run --rm --platform linux/arm64 alpine uname -m
# Should output: aarch64
```

## 🚀 Quick Start

### Option 1: Pre-built Image (Fastest)

```bash
# Pull the pre-built image from Docker Hub
docker pull ghcr.io/yourusername/cptf-arm:latest

# Run the container
docker run -it --name cptf ghcr.io/yourusername/cptf-arm:latest
```

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/cptf-arm.git
cd cptf-arm

# Build the Docker image
docker build -t cptf-arm:latest .

# Run the container
docker run -it --name cptf cptf-arm:latest
```

### Option 3: Docker Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/cptf-arm.git
cd cptf-arm

# Start all services
docker-compose up -d

# Access the container
docker exec -it cptf-arm bash
```

## 📦 Installation Methods

### Basic Installation

Minimal setup for quick testing:

```bash
docker run -it --rm cptf-arm:latest
```

### Production Installation

Full setup with persistent storage and credentials:

```bash
docker run -d \
  --name cptf-arm \
  --hostname cptf \
  --restart unless-stopped \
  -v ~/.aws:/root/.aws:ro \
  -v ~/.azure:/root/.azure:ro \
  -v ~/gcp-credentials:/root/gcp:ro \
  -v cptf-data:/data \
  -v cptf-logs:/var/log \
  cptf-arm:latest
```

### Advanced Installation with Docker Compose

Create a `.env` file with your credentials:

```bash
# .env file
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=us-east-1

AZURE_CLIENT_ID=your_client_id
AZURE_TENANT_ID=your_tenant_id
AZURE_CLIENT_SECRET=your_client_secret

GOOGLE_CLOUD_PROJECT=your_project_id
```

Start the framework with all services:

```bash
# Start core framework
docker-compose up -d

# Include database service
docker-compose --profile with-db up -d

# Include web UI
docker-compose --profile with-ui up -d

# Start everything
docker-compose --profile with-db --profile with-ui up -d
```

## 🔧 Configuration

### Volume Mounts

CPTF-ARM uses several volume mounts for persistence and configuration:

| Volume | Purpose | Example |
|--------|---------|---------|
| `~/.aws` | AWS credentials | `-v ~/.aws:/root/.aws:ro` |
| `~/.azure` | Azure credentials | `-v ~/.azure:/root/.azure:ro` |
| `~/gcp-credentials` | GCP service accounts | `-v ~/gcp-creds:/root/gcp:ro` |
| `cptf-data` | Persistent tool data | `-v cptf-data:/data` |
| `cptf-logs` | Log files | `-v cptf-logs:/var/log` |
| `./custom-scripts` | Custom scripts | `-v ./scripts:/opt/custom-scripts:ro` |
| `./wordlists` | Custom wordlists | `-v ./wordlists:/opt/wordlists:ro` |

### Environment Variables

Configure cloud credentials via environment variables:

```bash
docker run -it \
  -e AWS_ACCESS_KEY_ID=AKIAXXXXXXXXX \
  -e AWS_SECRET_ACCESS_KEY=XXXXXXXXXX \
  -e AZURE_CLIENT_ID=xxxxxxxx-xxxx-xxxx \
  -e AZURE_TENANT_ID=xxxxxxxx-xxxx-xxxx \
  -e AZURE_CLIENT_SECRET=xxxxxxxxxx \
  -e GOOGLE_APPLICATION_CREDENTIALS=/root/gcp/service-account.json \
  cptf-arm:latest
```

### Network Modes

#### Bridge Mode (Default - Isolated)
```bash
docker run -it cptf-arm:latest
```

#### Host Mode (Full Network Access)
```bash
docker run -it --network host cptf-arm:latest
```

#### Custom Network
```bash
# Create custom network
docker network create --subnet=10.10.0.0/24 cptf-network

# Run with custom network
docker run -it --network cptf-network --ip 10.10.0.10 cptf-arm:latest
```

## 🎯 Usage Examples

### Running Specific Tools

```bash
# Run Pacu directly
docker run -it --rm cptf-arm:latest \
  bash -c "cd /opt/aws/exploitation/pacu && python3 pacu.py"

# Run ScoutSuite with AWS profile
docker run -it --rm \
  -v ~/.aws:/root/.aws:ro \
  cptf-arm:latest \
  bash -c "cd /opt/multi-cloud/enumeration/ScoutSuite && python3 scout.py aws"

# Run Azure tools with PowerShell
docker exec -it cptf-arm pwsh
```

### Interactive Shell Sessions

```bash
# Start interactive session
docker exec -it cptf-arm bash

# With specific working directory
docker exec -it -w /opt/aws/exploitation/pacu cptf-arm bash

# As specific user (if configured)
docker exec -it --user pentester cptf-arm bash
```

### Batch Operations

```bash
# Run multiple commands
docker exec cptf-arm bash -c "
  source /root/setup-env.sh
  cd /opt/multi-cloud/enumeration/ScoutSuite
  python3 scout.py aws --profile production
"

# Script execution
docker exec cptf-arm /opt/custom-scripts/enumerate-all.sh
```

## 🛠️ Build Options

### Multi-Architecture Build

Build for multiple architectures:

```bash
# Enable Docker Buildx
docker buildx create --use

# Build for multiple platforms
docker buildx build \
  --platform linux/arm64,linux/amd64 \
  -t cptf-arm:multi \
  --push .
```

### Custom Build Arguments

```bash
# Build with specific versions
docker build \
  --build-arg UBUNTU_VERSION=22.04 \
  --build-arg PYTHON_VERSION=3.11 \
  --build-arg GO_VERSION=1.21 \
  -t cptf-arm:custom .
```

### Minimal Build

Create a lightweight version with only essential tools:

```bash
# Use minimal Dockerfile
docker build -f Dockerfile.minimal -t cptf-arm:minimal .
```

## 📊 Resource Management

### Memory and CPU Limits

```bash
# Run with resource constraints
docker run -it \
  --memory="4g" \
  --memory-swap="4g" \
  --cpus="2" \
  cptf-arm:latest
```

### Docker Compose Resource Limits

```yaml
# docker-compose.override.yml
services:
  cptf:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
```

## 🔍 Monitoring and Logs

### View Container Logs

```bash
# View real-time logs
docker logs -f cptf-arm

# View last 100 lines
docker logs --tail 100 cptf-arm

# View logs with timestamps
docker logs -t cptf-arm
```

### Monitor Resource Usage

```bash
# Real-time stats
docker stats cptf-arm

# Detailed inspection
docker inspect cptf-arm

# Process listing
docker top cptf-arm
```

### Health Checks

```bash
# Check container health
docker inspect cptf-arm --format='{{.State.Health.Status}}'

# Manual health check
docker exec cptf-arm /usr/local/bin/healthcheck.sh
```

## 🔄 Updates and Maintenance

### Updating the Container

```bash
# Pull latest image
docker pull ghcr.io/yourusername/cptf-arm:latest

# Stop and remove old container
docker stop cptf-arm
docker rm cptf-arm

# Run new version
docker run -it --name cptf-arm ghcr.io/yourusername/cptf-arm:latest
```

### Backup and Restore

```bash
# Backup data volume
docker run --rm \
  -v cptf-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/cptf-backup.tar.gz /data

# Restore data volume
docker run --rm \
  -v cptf-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/cptf-backup.tar.gz -C /
```

### Cleanup

```bash
# Remove container
docker rm -f cptf-arm

# Remove image
docker rmi cptf-arm:latest

# Remove volumes (WARNING: deletes data)
docker volume rm cptf-data cptf-logs

# Full cleanup
docker-compose down -v --rmi all
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Platform Mismatch Error
```bash
# Error: image platform does not match host platform
# Solution: Force ARM64 platform
docker run --platform linux/arm64 cptf-arm:latest
```

#### 2. Permission Denied
```bash
# Error: permission denied while trying to connect to Docker daemon
# Solution: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### 3. Out of Memory
```bash
# Error: Container killed due to OOM
# Solution: Increase memory limits
docker run -it --memory="8g" cptf-arm:latest
```

#### 4. Build Failures
```bash
# Clear Docker cache and rebuild
docker builder prune -a
docker build --no-cache -t cptf-arm:latest .
```

### Debug Mode

Run container with debug capabilities:

```bash
docker run -it \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --security-opt apparmor=unconfined \
  -e DEBUG=1 \
  cptf-arm:latest
```

### Shell Access for Debugging

```bash
# If container won't start normally
docker run -it --entrypoint /bin/bash cptf-arm:latest

# Debug network issues
docker run -it --network host --entrypoint /bin/bash cptf-arm:latest
```

## 🔒 Security Considerations

### Read-Only Containers

Run with read-only filesystem:

```bash
docker run -it \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /var/run \
  -v cptf-data:/data \
  cptf-arm:latest
```

### Non-Root User

Run as non-root user (if configured in image):

```bash
docker run -it --user 1000:1000 cptf-arm:latest
```

### Secrets Management

Use Docker secrets for sensitive data:

```bash
# Create secrets
echo "my-aws-key" | docker secret create aws_key -
echo "my-azure-secret" | docker secret create azure_secret -

# Use in compose
docker-compose --file docker-compose.secrets.yml up
```

## 📝 Docker Compose Reference

### Full docker-compose.yml Example

```yaml
version: '3.8'

services:
  cptf:
    image: cptf-arm:latest
    container_name: cptf-arm
    hostname: cptf
    stdin_open: true
    tty: true
    restart: unless-stopped
    
    environment:
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - AZURE_CLIENT_ID=${AZURE_CLIENT_ID}
      - AZURE_TENANT_ID=${AZURE_TENANT_ID}
    
    volumes:
      - ~/.aws:/root/.aws:ro
      - ~/.azure:/root/.azure:ro
      - ./gcp-credentials:/root/gcp:ro
      - cptf-data:/data
      
    networks:
      - cptf-net
    
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G

networks:
  cptf-net:
    driver: bridge

volumes:
  cptf-data:
    driver: local
```

## 🚢 Container Registry

### Push to Registry

```bash
# Tag for registry
docker tag cptf-arm:latest ghcr.io/yourusername/cptf-arm:latest

# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Push image
docker push ghcr.io/yourusername/cptf-arm:latest
```

### Pull from Private Registry

```bash
# Login to private registry
docker login registry.company.com

# Pull image
docker pull registry.company.com/security/cptf-arm:latest
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Best Practices for Dockerfiles](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)

---

**Note**: The Docker installation method is recommended for most users as it provides isolation, consistency, and easy cleanup. For native installation, refer to the [script installation section](#-installation).
