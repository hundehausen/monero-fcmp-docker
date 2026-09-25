# Monero FCMP++ & Carrot Beta Stressnet v3.0 Docker Image

[![Latest image build on push](https://github.com/hundehausen/monero-fcmp-docker/actions/workflows/update-image-on-push.yml/badge.svg)](https://github.com/hundehausen/monero-fcmp-docker/actions/workflows/update-image-on-push.yml)

A containerized build of the [Monero FCMP++ & Carrot beta stressnet](https://github.com/seraphis-migration/monero/releases/tag/v0.19.0.0-beta.3.0) (`v0.19.0.0-beta.3.0`), built from source on Alpine Linux.

> **WARNING:** This is beta software intended for the FCMP++ & Carrot beta stressnet. Do not use this with mainnet funds. The anonymity set on the stressnet is very small (dozens at best).

---

## What is this?

This image packages `monerod` from the `seraphis-migration/monero` repository, which includes:

- **FCMP++**: Full Chain Membership Proofs replacing ring signatures
- **Carrot**: Next-generation addressing protocol

Beta v3 hard forks from the beta v2 stressnet at block **3102800** (hard fork version 17), with version 18 at block **3103520**. The target date is **October 5, 2026**. The daemon rolls an existing beta stressnet database back to before the v2 fork on startup. After that rollback, rescan wallets from their restore height.

---

## Prerequisites

- [Docker](https://docs.docker.com/engine/install/) or [Podman](https://podman.io/docs/installation)
- At least 4GB RAM (8GB+ recommended)
- Sufficient disk space for the blockchain database

---

## Building

```bash
git clone <repository-url>
cd monero-fcmp
docker build -t monero-fcmp:test .
```

Or with Podman:

```bash
podman build -t monero-fcmp:test .
```

The build takes a while ( compiling C++ and Rust code).

---

## Tags

The image is published to GitHub Container Registry under `ghcr.io/hundehausen/monero-fcmp-docker`.

`latest`: The latest build from the `main` branch, built on an Alpine base image
`vx.xx.x.x`: The version corresponding to the Monero release tag used in the build

## Quick Start

### Using the published image

```bash
docker run -d --name monero-fcmp \
  -v monero-data:/home/monero/.bitmonero \
  ghcr.io/hundehausen/monero-fcmp-docker:latest
```

### Building from source

```bash
git clone https://github.com/hundehausen/monero-fcmp-docker
cd monero-fcmp-docker
docker build -t monero-fcmp:test .
```

The default arguments are:

```
--testnet
--rpc-restricted-bind-ip=0.0.0.0
--rpc-restricted-bind-port=28089
--no-igd
--no-zmq
--enable-dns-blocklist
--ban-list=/home/monero/ban_list.txt
```

---

## Ports

| Port  | Description                  |
|-------|------------------------------|
| 28080 | P2P (peer-to-peer)           |
| 28089 | Restricted RPC               |
| 28081 | Full RPC (testnet default)   |

---

## Volumes

| Path                         | Description              |
|------------------------------|--------------------------|
| `/home/monero/.bitmonero`    | Blockchain data & config |

Mount this to persist the blockchain between container restarts:

```bash
docker run -d --name monero-fcmp \
  -v /path/to/local/data:/home/monero/.bitmonero \
  monero-fcmp:test
```

---

## Common Usage Examples

### Public RPC node (testnet)

```bash
docker run -d --name monero-fcmp \
  -v monero-data:/home/monero/.bitmonero \
  -p 28080:28080 \
  -p 28089:28089 \
  monero-fcmp:test \
  --testnet \
  --rpc-restricted-bind-ip=0.0.0.0 \
  --rpc-restricted-bind-port=28089 \
  --public-node \
  --no-igd \
  --no-zmq \
  --enable-dns-blocklist \
  --ban-list=/home/monero/ban_list.txt
```

### Pruned node

```bash
docker run -d --name monero-fcmp \
  -v monero-data:/home/monero/.bitmonero \
  monero-fcmp:test \
  --testnet \
  --prune-blockchain \
  --rpc-restricted-bind-ip=0.0.0.0 \
  --rpc-restricted-bind-port=28089
```

### Run as a different user

```bash
docker run -d --name monero-fcmp \
  --user 1000:1000 \
  -v monero-data:/home/monero/.bitmonero \
  monero-fcmp:test
```

### Check version

```bash
docker run --rm monero-fcmp:test --version
```

### View logs

```bash
docker logs -f monero-fcmp
```

---

## Important Notes

- **Your FCMP++ wallet MUST point to an FCMP++ compatible daemon.**
- An existing beta stressnet database is rolled back to before the v2 fork automatically. Rescan wallets from restore height after that. A fresh sync from an older testnet database can still take **several hours**.
- Constructing many-input transactions takes some time.
- The following features are **not yet functional**:
  - Watch-only wallets
  - Hardware wallet support
  - Multisig
  - Transaction proofs

---

## Security Warning

The anonymity set of running a node on mainnet Monero is in the thousands. The anonymity set of running a node on this stressnet will be in the **dozens at best**. If you run a stressnet node, your machine's IP address (or proxy IP) will be visible to other nodes on the network.

If you have an extreme threat model, this may be an unacceptable risk.

---

## Monitoring

A basic healthcheck is included (checks `get_height` on the full RPC port). You can query it manually:

```bash
curl -s http://localhost:28081/get_height | jq .
```

Or for restricted RPC:

```bash
curl -s http://localhost:28089/get_info | jq .
```

---

## Troubleshooting

### Container exits immediately

Check the logs:

```bash
docker logs monero-fcmp
```

### Permission denied on data volume

Ensure the volume is writable by user `monero` (UID 1000 by default), or use `--user <your-uid>:<your-gid>`.

### Out of memory during build

The build compiles both C++ and Rust, which is memory-intensive. If the build fails, try limiting parallelism:

```bash
docker build --build-arg NPROC=2 -t monero-fcmp:test .
```

---

## License

The Dockerfile and scripts are provided as-is for testing purposes. The Monero source code is subject to its own licenses.

## Links

- [FCMP++ Announcement](https://www.getmonero.org/2024/04/27/fcmps.html)
- [Carrot Protocol](https://github.com/jeffro256/carrot)
- [Stressnet Issues](https://github.com/seraphis-migration/monero/issues)
- [Stressnet Matrix Room](https://matrixrooms.info/room/monero-stressnet:monero.social)
