[← Back to Remote Access Overview](../README.md) | [← Back to Root Repository](../../README.md)

# Cloudflare Tunnel Integration

Exposes the LiteLLM proxy to the internet without a static IP or inbound port forwarding rules. Traffic routes through an encrypted tunnel over Cloudflare's global edge network.

---

## Operating Modes

| Mode | Domain Scope | Persistence | Prerequisites |
| :--- | :--- | :--- | :--- |
| **TryCloudflare** | `*.trycloudflare.com` | Ephemeral (resets on restart) | None |
| **Named Tunnel** | Custom domain | Persistent | Cloudflare account and registered domain |

---

## Quick Start: Ephemeral Tunnel

Start an ad-hoc tunnel without a Cloudflare account:

```bash
chmod +x tunnels/cloudflare/start-cloudflare.sh
./tunnels/cloudflare/start-cloudflare.sh
```

Inspect the output for the assigned edge hostname:

```text
URL: https://abc-def-123.trycloudflare.com
```

Verify service connectivity through the tunnel:

```bash
curl https://abc-def-123.trycloudflare.com/health/readiness
```

---

## Persistent Named Tunnel Setup

### 1. Prerequisites
- A Cloudflare account with a registered domain.
- Cloudflare nameservers delegated for the target domain.

### 2. Provision Tunnel Token
1. Open the [Cloudflare Zero Trust Dashboard](https://one.cloudflare.com).
2. Navigate to **Networks** -> **Tunnels** -> **Create a tunnel**.
3. Select **Cloudflared** as the connector type.
4. Specify a tunnel identifier (e.g. `litellm-proxy`).
5. Save the tunnel and copy the generated authentication token.

### 3. Configure Environment
Set `TUNNEL_TOKEN` in `.env`:

```env
TUNNEL_TOKEN=eyJhIjoiMT...long_token...
```

### 4. Configure Public Hostname Routing
In the Zero Trust tunnel configuration:
- Set **Public Hostname** to your domain (e.g. `litellm.example.com`).
- Set **Service Type** to `HTTP`.
- Set **URL** to `http://litellm:4000`.

### 5. Launch Named Tunnel
```bash
TUNNEL_TOKEN=$(grep TUNNEL_TOKEN .env | cut -d= -f2) \
  ./tunnels/cloudflare/start-cloudflare.sh
```

---

## Docker Compose Execution

Manage the tunnel alongside base services using Compose override files:

```bash
# Start LiteLLM with Cloudflare Tunnel overlay
docker compose \
  -f docker-compose.yml \
  -f tunnels/cloudflare/docker-compose.cloudflare.yml \
  up -d

# Inspect connector logs
docker compose \
  -f docker-compose.yml \
  -f tunnels/cloudflare/docker-compose.cloudflare.yml \
  logs -f cloudflared

# Stop the tunnel overlay while retaining base services
docker compose \
  -f docker-compose.yml \
  -f tunnels/cloudflare/docker-compose.cloudflare.yml \
  stop cloudflared
```
