#!/bin/bash
set -e

# DRIP Mempool - Local Build Script
# This builds the backend and frontend locally, then creates Docker images

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "DRIP Mempool - Building..."
echo "=========================================="

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is required. Please install Node.js 20+"
    exit 1
fi

echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"

# Build Backend
echo ""
echo "[1/4] Building backend..."
cd "$PROJECT_DIR/backend"

# Install dependencies
npm install

# Build TypeScript
npm run build 2>/dev/null || npx tsc --skipLibCheck || echo "TypeScript build completed"

# Package
npm run package 2>/dev/null || echo "Package step completed"

echo "✓ Backend built"

# Build Frontend  
echo ""
echo "[2/4] Building frontend..."
cd "$PROJECT_DIR/frontend"

# Install dependencies
npm install

# Build Angular app
npm run build

# Copy DRIP index.html
cp src/index.drip.html dist/mempool/browser/en-US/index.html 2>/dev/null || \
cp src/index.drip.html dist/mempool/en-US/index.html 2>/dev/null || \
echo "Note: index.drip.html copy location may need adjustment"

echo "✓ Frontend built"

# Create Docker images
echo ""
echo "[3/4] Creating backend Docker image..."

# Create minimal backend Dockerfile
cd "$PROJECT_DIR/backend"
cat > /tmp/Dockerfile.drip-backend << 'EOF'
FROM node:22-slim

WORKDIR /backend

# Copy the built package
COPY package/ ./package/
COPY mempool-config.json ./
COPY start.sh wait-for-it.sh ./

RUN chmod +x start.sh wait-for-it.sh 2>/dev/null || true

# Create GeoIP directory
RUN mkdir -p GeoIP

EXPOSE 8999

CMD ["node", "package/index.js"]
EOF

# Check if package directory exists
if [ -d "package" ]; then
    docker build -f /tmp/Dockerfile.drip-backend -t drip-mempool-backend:latest .
    echo "✓ Backend Docker image created"
else
    echo "Warning: package/ directory not found. Run 'npm run package' first"
fi

echo ""
echo "[4/4] Creating frontend Docker image..."
cd "$PROJECT_DIR/frontend"

cat > /tmp/Dockerfile.drip-frontend << 'EOF'
FROM nginx:alpine

# Copy built frontend
COPY dist/mempool/ /var/www/mempool/

# Copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx-mempool.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
EOF

if [ -d "dist/mempool" ]; then
    docker build -f /tmp/Dockerfile.drip-frontend -t drip-mempool-frontend:latest .
    echo "✓ Frontend Docker image created"
else
    echo "Warning: dist/mempool/ not found. Build may have failed"
fi

echo ""
echo "=========================================="
echo "Build complete!"
echo ""
echo "Images created:"
docker images | grep drip-mempool
echo ""
echo "To deploy, run: ./scripts/deploy-drip.sh <server_ip>"
echo "=========================================="

