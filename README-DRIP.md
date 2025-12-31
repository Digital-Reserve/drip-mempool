# DRIP Mempool Explorer

A full-featured mempool explorer for the DRIP blockchain, forked from [mempool.space](https://github.com/mempool/mempool).

## Features

- Real-time mempool visualization
- Block explorer with transaction details
- Fee estimation and recommended fees
- Mining statistics and difficulty tracking
- WebSocket API for live updates
- Address lookup and balance tracking

## DRIP Chain Specifications

| Parameter | Value |
|-----------|-------|
| Block Time | 5 minutes |
| Total Supply | 21,000,000 DRIP |
| Halving Interval | 210,000 blocks |
| Difficulty Adjustment | Every 1008 blocks (3.5 days) |
| Address Prefix | `D` (legacy) / `drip1` (bech32) |
| RPC Port | 58332 |
| P2P Port | 58333 |

## Quick Start with Docker

### Prerequisites

- Docker and Docker Compose installed
- DRIP full node running (or use the included dripd container)
- At least 4GB RAM, 50GB disk space

### 1. Start the Stack

```bash
cd docker
docker-compose -f docker-compose.drip.yml up -d
```

### 2. Access the Explorer

Open http://localhost in your browser.

### 3. Monitor Logs

```bash
docker-compose -f docker-compose.drip.yml logs -f
```

## Manual Installation

### Backend Setup

```bash
cd backend
cp mempool-config.json.sample mempool-config.json
# Edit mempool-config.json with your DRIP node settings
npm install
npm run build
npm run start
```

### Frontend Setup

```bash
cd frontend
cp mempool-frontend-config.sample.json mempool-frontend-config.json
npm install
npm run build
npm run serve
```

## Configuration

### Backend Configuration (`backend/mempool-config.json`)

```json
{
  "MEMPOOL": {
    "NETWORK": "mainnet",
    "BACKEND": "electrum"
  },
  "CORE_RPC": {
    "HOST": "127.0.0.1",
    "PORT": 58332,
    "USERNAME": "drip",
    "PASSWORD": "drip"
  },
  "ELECTRUM": {
    "HOST": "127.0.0.1",
    "PORT": 50001,
    "TLS_ENABLED": false
  }
}
```

### DRIP Node Configuration

Ensure your DRIP node is running with:

```bash
dripd -drip -txindex=1 -server=1 -rpcuser=drip -rpcpassword=drip
```

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/mempool` | Current mempool state |
| `GET /api/blocks` | Recent blocks |
| `GET /api/block/:hash` | Block details |
| `GET /api/tx/:txid` | Transaction details |
| `GET /api/address/:address` | Address info and transactions |
| `GET /api/v1/fees/recommended` | Recommended fee rates |
| `WS /api/v1/ws` | WebSocket for live updates |

## Low-Cost Hosting Recommendations

| Provider | Monthly Cost | Specs | Notes |
|----------|--------------|-------|-------|
| **Hetzner Cloud** | $5-10 | 2 vCPU, 4GB RAM | Best value |
| **Oracle Cloud Free** | $0 | 4 vCPU, 24GB RAM | Free forever tier |
| **DigitalOcean** | $12 | 2 vCPU, 2GB RAM | Easy setup |
| **Vultr** | $6 | 1 vCPU, 1GB RAM | Global locations |

### Minimum Requirements

- 2+ CPU cores
- 4GB RAM (8GB recommended)
- 50GB SSD
- Ubuntu 22.04 LTS

## Deployment Script

```bash
# One-line deployment on a fresh Ubuntu server
curl -fsSL https://raw.githubusercontent.com/your-repo/drip-mempool/main/scripts/deploy.sh | bash
```

## Development

```bash
# Run backend in development mode
cd backend && npm run dev

# Run frontend in development mode
cd frontend && npm run serve:local
```

## License

MIT License - Based on [The Mempool Open Source Project](https://github.com/mempool/mempool)

