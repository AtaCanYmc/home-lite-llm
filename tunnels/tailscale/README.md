[← Back to Remote Access Overview](../README.md) | [← Back to Root Repository](../../README.md)

# Tailscale Mesh VPN Integration

Connects the LiteLLM proxy container to a private WireGuard-based Tailscale mesh network. Only authenticated devices within your Tailscale tailnet can communicate with the gateway. The server remains unexposed to public search crawlers and scans.

---

## Use Cases

- Accessing LiteLLM securely from mobile devices, laptops, or secondary workstations.
- Sharing private API access with trusted team members.
- Enforcing Zero-Trust access without opening firewall ports.

---

## Quick Start

### 1. Account Setup
Register a free account at [tailscale.com](https://tailscale.com) (free for personal use up to 100 devices).

### 2. Interactive Startup
Execute the startup script:

```bash
chmod +x tunnels/tailscale/start-tailscale.sh
./tunnels/tailscale/start-tailscale.sh
```

Follow the printed authentication URL to authorize the container node in your browser.

### 3. Connect Client Devices
Install Tailscale on client devices from [tailscale.com/download](https://tailscale.com/download). Once connected to the same tailnet, reach LiteLLM directly via its Tailscale IP address or MagicDNS hostname (e.g. `http://litellm-proxy:4000/health/readiness`).

---

## Headless Setup with Pre-Authentication Key

Automate node registration without interactive browser prompts:

### 1. Generate Auth Key
1. Open the [Tailscale Keys Console](https://login.tailscale.com/admin/settings/keys).
2. Select **Generate auth key**.
3. Enable **Reusable** or ephemeral properties as required.

### 2. Configure Environment
Set `TS_AUTHKEY` in `.env`:

```env
TS_AUTHKEY=tskey-auth-kXXXXXXXXXX-XXXXXXXXXXXXXXXXXX
```

### 3. Start Tailscale Node
```bash
./tunnels/tailscale/start-tailscale.sh
```

---

## Tailscale Funnel (Public HTTPS Ingress)

To expose the proxy publicly via Tailscale Funnel:

```bash
TS_FUNNEL=1 ./tunnels/tailscale/start-tailscale.sh
```

*Note: Funnel requires enabling HTTPS certificates and Funnel feature flags in your Tailscale access control policy.*

---

## Docker Compose Execution

```bash
# Start base services with Tailscale network overlay
docker compose \
  -f docker-compose.yml \
  -f tunnels/tailscale/docker-compose.tailscale.yml \
  up -d

# Inspect Tailscale IPv4 address
docker exec litellm-tailscale tailscale ip -4

# Check node connection status
docker exec litellm-tailscale tailscale status

# Trigger interactive login if key is unset
docker exec -it litellm-tailscale tailscale login

# Stop Tailscale container
docker compose \
  -f docker-compose.yml \
  -f tunnels/tailscale/docker-compose.tailscale.yml \
  stop tailscale
```
