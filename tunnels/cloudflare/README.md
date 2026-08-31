# Cloudflare Tunnel Integration

Exposes the LiteLLM proxy to the internet **without a static IP or port forwarding**. Traffic flows through an encrypted tunnel over Cloudflare's global network.

## Methods

| Method | Domain | Persistence | Requirement |
|:---|:---|:---|:---|
| **TryCloudflare** (Temporary) | `*.trycloudflare.com` | Changes on every restart | No account needed |
| **Named Tunnel** (Permanent) | Your own domain | Permanent | Cloudflare account + domain |

---

## ⚡ Quick Start — Temporary Tunnel (No Account Needed)

```bash
chmod +x tunnels/cloudflare/start-cloudflare.sh
./tunnels/cloudflare/start-cloudflare.sh
```

Within seconds you will see a URL in the terminal like:

```
🌐 URL: https://abc-def-123.trycloudflare.com
```

Use this URL to reach LiteLLM from outside your network:

```bash
curl https://abc-def-123.trycloudflare.com/health
```

> **Note:** The temporary URL changes on every restart. For a stable URL, set up a permanent named tunnel.

---

## 🔒 Permanent Tunnel Setup (Your Own Domain)

### 1. Prerequisites
- A [Cloudflare account](https://dash.cloudflare.com/sign-up) (free)
- A domain added to Cloudflare

### 2. Create a Tunnel Token

1. Go to [Cloudflare Zero Trust Dashboard](https://one.cloudflare.com)
2. Navigate to **Networks → Tunnels → Create a tunnel**
3. Connector type: select **Cloudflared**
4. Enter a tunnel name (e.g. `litellm-home`)
5. Click **Save tunnel**
6. Copy the displayed **Token**

### 3. Add the Token to `.env`

```env
TUNNEL_TOKEN=eyJhIjoiMT...long_token...
```

### 4. Configure DNS

After creating the tunnel in the dashboard:
- **Public Hostname → Add a public hostname**
- Domain: `litellm.yourdomain.com`
- Service: `http://litellm:4000`

### 5. Start the Permanent Tunnel

```bash
TUNNEL_TOKEN=$(grep TUNNEL_TOKEN .env | cut -d= -f2) \
  ./tunnels/cloudflare/start-cloudflare.sh
```

---

## Manual Docker Compose Usage

```bash
# Start (temporary tunnel)
docker compose \
  -f docker-compose.yml \
  -f tunnels/cloudflare/docker-compose.cloudflare.yml \
  up -d

# Follow logs to see the URL
docker compose \
  -f docker-compose.yml \
  -f tunnels/cloudflare/docker-compose.cloudflare.yml \
  logs -f cloudflared

# Stop the tunnel (LiteLLM keeps running)
docker compose \
  -f docker-compose.yml \
  -f tunnels/cloudflare/docker-compose.cloudflare.yml \
  stop cloudflared
```

---

## Security Notes

- Cloudflare automatically encrypts all HTTPS traffic (TLS/SSL included at no extra cost).
- LiteLLM requires a `MASTER_KEY`, so anyone who knows the URL still cannot make API calls without the key.
- For permanent tunnels, you can add Cloudflare Zero Trust Access policies to restrict access by IP range or email.

## Troubleshooting

```bash
# View container logs
docker logs litellm-cloudflared

# Check container status
docker inspect litellm-cloudflared --format='{{.State.Status}}'

# Manual tunnel info
docker exec litellm-cloudflared cloudflared tunnel info
```
