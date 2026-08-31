# 🌐 Remote Access — Tunnel & VPN Integrations

Four methods to expose your LiteLLM proxy outside your home network. Choose the one that best fits your use case.

---

## 📊 Method Comparison

| Feature | [Cloudflare Tunnel](cloudflare/) | [ngrok](ngrok/) | [Tailscale](tailscale/) | [Port Forwarding](port-forwarding/) |
|:---|:---:|:---:|:---:|:---:|
| **Setup Difficulty** | ⭐ Easy | ⭐ Easiest | ⭐⭐ Medium | ⭐⭐⭐ Hard |
| **Stable URL** | ✅ (own domain) | ❌ (✅ on paid plan) | ✅ (Tailscale hostname) | ✅ (with DDNS) |
| **Free Plan** | ✅ | ✅ (limited) | ✅ (up to 100 devices) | ✅ (DDNS is free) |
| **Security** | 🟢 High | 🟡 Medium | 🟢 Highest | 🔴 Low |
| **Server Exposed to Internet** | ❌ No | ❌ No | ❌ No | ✅ Yes |
| **Port Forwarding Required** | ❌ No | ❌ No | ❌ No | ✅ Yes |
| **Static IP Required** | ❌ No | ❌ No | ❌ No | ❌ No (with DDNS) |
| **Publicly Accessible URL** | ✅ | ✅ | ❌ (network members only) | ✅ |
| **Docker Compose Profile** | ✅ | ✅ | ✅ | ❌ |

---

## 🎯 Which Method Should I Choose?

```
❓ Will you only access from your own devices (phone, laptop)?
   → ✅ Tailscale — Most secure, no port forwarding needed

❓ Do you want to share with friends or a team?
   → ✅ Cloudflare Tunnel — Custom domain, free, secure

❓ Do you need a quick test or development setup?
   → ✅ ngrok — Fastest setup, single command

❓ Do you have a static IP and want full control?
   → ⚠️  Port Forwarding — But make sure to take security precautions
```

---

## ⚡ Quick Start

### Cloudflare Tunnel (Temporary URL — No Account Needed)
```bash
chmod +x tunnels/cloudflare/start-cloudflare.sh
./tunnels/cloudflare/start-cloudflare.sh
```

### ngrok
```bash
chmod +x tunnels/ngrok/start-ngrok.sh
./tunnels/ngrok/start-ngrok.sh
```

### Tailscale
```bash
chmod +x tunnels/tailscale/start-tailscale.sh
./tunnels/tailscale/start-tailscale.sh
```

### Duck DNS + Port Forwarding
```bash
chmod +x tunnels/port-forwarding/setup-ddns.sh
DUCKDNS_TOKEN=<token> DUCKDNS_DOMAIN=<subdomain> \
  ./tunnels/port-forwarding/setup-ddns.sh
```

---

## 📁 Directory Structure

```
tunnels/
├── README.md                        ← This file
├── cloudflare/
│   ├── README.md                    ← Cloudflare setup guide
│   ├── docker-compose.cloudflare.yml
│   └── start-cloudflare.sh
├── ngrok/
│   ├── README.md                    ← ngrok setup guide
│   ├── docker-compose.ngrok.yml
│   └── start-ngrok.sh
├── tailscale/
│   ├── README.md                    ← Tailscale setup guide
│   ├── docker-compose.tailscale.yml
│   └── start-tailscale.sh
└── port-forwarding/
    ├── README.md                    ← Port Forwarding guide
    └── setup-ddns.sh
```

---

## 🔑 Environment Variables (`.env`)

Add the relevant variable to your `.env` file for each method:

```env
# Cloudflare Tunnel (permanent tunnel only — not needed for temporary TryCloudflare)
TUNNEL_TOKEN=eyJhIjoiMT...

# ngrok (registered account features — not needed for anonymous use)
NGROK_AUTHTOKEN=2abc123...

# Tailscale (headless/automated join — not needed for interactive browser login)
TS_AUTHKEY=tskey-auth-...

# Duck DNS (DDNS for the Port Forwarding method)
DUCKDNS_TOKEN=abc123...
DUCKDNS_DOMAIN=my-litellm
```

---

## Detailed Guides

- 📖 [Cloudflare Tunnel Guide](cloudflare/README.md)
- 📖 [ngrok Guide](ngrok/README.md)
- 📖 [Tailscale Guide](tailscale/README.md)
- 📖 [Port Forwarding Guide](port-forwarding/README.md)
