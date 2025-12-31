#!/bin/bash
# DRIP Mempool Explorer Deployment Script
# For Ubuntu 22.04 LTS

set -e

echo "=========================================="
echo "DRIP Mempool Explorer - Deployment Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

echo -e "${GREEN}[1/6] Updating system packages...${NC}"
apt-get update && apt-get upgrade -y

echo -e "${GREEN}[2/6] Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
else
    echo "Docker already installed"
fi

echo -e "${GREEN}[3/6] Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    apt-get install -y docker-compose-plugin
fi

echo -e "${GREEN}[4/6] Cloning DRIP Mempool repository...${NC}"
if [ ! -d "/opt/drip-mempool" ]; then
    git clone https://github.com/digital-reserve/drip-mempool.git /opt/drip-mempool
else
    cd /opt/drip-mempool && git pull
fi

echo -e "${GREEN}[5/6] Starting services...${NC}"
cd /opt/drip-mempool/docker
docker compose -f docker-compose.drip.yml up -d

echo -e "${GREEN}[6/6] Setting up firewall...${NC}"
if command -v ufw &> /dev/null; then
    ufw allow 80/tcp   # HTTP
    ufw allow 443/tcp  # HTTPS
    ufw allow 58333/tcp # DRIP P2P
fi

echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Access the explorer at: http://$(curl -s ifconfig.me)"
echo ""
echo "Useful commands:"
echo "  - View logs: docker compose -f docker-compose.drip.yml logs -f"
echo "  - Stop: docker compose -f docker-compose.drip.yml down"
echo "  - Restart: docker compose -f docker-compose.drip.yml restart"
echo ""
echo -e "${YELLOW}Note: Initial blockchain sync may take several hours.${NC}"
echo -e "${NC}"

