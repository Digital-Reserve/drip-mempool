#!/bin/bash
# Zero-downtime deployment script for DRIP Explorer

set -e

cd /opt/drip-mempool/frontend

echo "[1/5] Backing up current build..."
rm -rf /tmp/drip-backup
cp -r dist/mempool /tmp/drip-backup 2>/dev/null || true

echo "[2/5] Building new version..."
npm run build 2>&1 | tail -5

echo "[3/5] Copying assets..."
cp src/resources/drippoollogo.png dist/mempool/browser/resources/

echo "[4/5] Reloading nginx..."
systemctl reload nginx

echo "[5/5] Cleanup..."
rm -rf /tmp/drip-backup

echo "✅ Deployed successfully!"
