# Tailscale Integration

Joins the LiteLLM proxy into a secure mesh VPN so that only **trusted devices** can access it. The server is never exposed to the public internet — no external access is possible without being on the Tailscale network.

## When to Use Tailscale

- You want to access LiteLLM from your own devices (home, office, mobile)
- You want to share access with trusted people
- You do not want to expose LiteLLM to the internet at all (most secure option)

---

## ⚡ Quick Start

### 1. Create a Tailscale Account
[tailscale.com](https://tailscale.com) → **Get started** (free for personal use, up to 100 devices)

### 2. Start with the Script

```bash
chmod +x tunnels/tailscale/start-tailscale.sh
./tunnels/tailscale/start-tailscale.sh
```

The script displays a **login URL**. Open it in your browser and sign in with your Tailscale account.

### 3. Install Tailscale on Your Other Devices

- **iPhone/Android**: Search "Tailscale" in the App Store / Google Play
- **Mac/Windows/Linux**: [tailscale.com/download](https://tailscale.com/download)

After signing in with the same account on all devices, you can reach LiteLLM via its Tailscale IP.

---

## 🔑 Headless Setup with Auth Key (Automated)

Instead of interactive browser login, you can use an **Auth Key** to automatically join the network.

### 1. Create an Auth Key

1. Go to [Tailscale Admin → Settings → Keys](https://login.tailscale.com/admin/settings/keys)
2. Click **Generate auth key**
3. Enable **Reusable** if you want to reuse the same key
4. Click **Generate key** and copy it

### 2. Add to `.env`

```env
TS_AUTHKEY=tskey-auth-kXXXXXXXXXX-XXXXXXXXXXXXXXXXXX
```

### 3. Start with Auth Key

```bash
./tunnels/tailscale/start-tailscale.sh
# TS_AUTHKEY is read from .env automatically — no browser login required
```

---

## 📡 Tailscale Funnel (Public HTTPS Endpoint — Optional)

Tailscale's **Funnel** feature allows people who are not on your Tailscale network to access LiteLLM via a URL like `https://litellm-proxy.tail12345.ts.net`.

> ⚠️ **Warning:** Enabling Funnel exposes the server to the internet. Use this feature with care.

```bash
TS_FUNNEL=1 ./tunnels/tailscale/start-tailscale.sh
```

Funnel must be enabled in your Tailscale account settings before using this flag.

---

## Manual Docker Compose Usage

```bash
# Start
docker compose \
  -f docker-compose.yml \
  -f tunnels/tailscale/docker-compose.tailscale.yml \
  up -d

# Get Tailscale IP
docker exec litellm-tailscale tailscale ip -4

# Check Tailscale status
docker exec litellm-tailscale tailscale status

# Interactive login (if TS_AUTHKEY is not set)
docker exec -it litellm-tailscale tailscale login

# Stop Tailscale
docker compose \
  -f docker-compose.yml \
  -f tunnels/tailscale/docker-compose.tailscale.yml \
  stop tailscale
```

---

## Access Example

From any device on your Tailscale network (example IP):

```bash
# Health check
curl http://100.64.1.5:4000/health

# API request
curl http://100.64.1.5:4000/v1/chat/completions \
  -H "Authorization: Bearer $MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "gemini-2.0-flash", "messages": [{"role": "user", "content": "Hello!"}]}'

# Base URL for mobile apps
# http://100.64.1.5:4000  (or http://litellm-proxy:4000 if MagicDNS is enabled)
```

---

## MagicDNS (Hostname Resolution)

If **MagicDNS** is enabled in your Tailscale Admin panel, you can use the machine name instead of the IP:

```
http://litellm-proxy:4000/health
```

---

## Security

- **Most secure option:** The server is never exposed to the internet — only visible within the Tailscale network
- Tailscale uses end-to-end WireGuard encryption
- Devices can be removed from the Tailscale Admin panel at any time

## Troubleshooting

```bash
# View container logs
docker logs litellm-tailscale

# Detailed Tailscale status
docker exec litellm-tailscale tailscale status --json

# Connectivity test (via Tailscale IP)
docker exec litellm-tailscale tailscale ping <other-device-ts-ip>
```
