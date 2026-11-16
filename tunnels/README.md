[← Back to Root Repository](../README.md)

# Remote Access Integrations

This guide details four methods to access your local LiteLLM proxy gateway outside your local network.

---

## Method Comparison Matrix

| Capability | Cloudflare Tunnel | ngrok | Tailscale | Port Forwarding |
| :--- | :--- | :--- | :--- | :--- |
| **Setup Complexity** | Low | Lowest | Medium | High |
| **Stable URL** | Yes (Custom domain) | Paid plans only | Yes (Tailscale hostname) | Yes (Requires DDNS) |
| **Free Tier** | Yes (Unlimited) | Yes (Rate-limited) | Yes (Up to 100 devices) | Yes (Self-managed) |
| **Security Profile** | High | Medium | Highest (Zero-Trust Mesh) | Low (Direct IP exposure) |
| **Public IP Required** | No | No | No | Yes |
| **Port Forwarding Required** | No | No | No | Yes |
| **Public Internet Ingress** | Yes | Yes | No (Authorized mesh only) | Yes |
| **Docker Compose Profile** | Yes | Yes | Yes | No |
| **Documentation Link** | [Cloudflare](cloudflare/README.md) | [ngrok](ngrok/README.md) | [Tailscale](tailscale/README.md) | [Port Forwarding](port-forwarding/README.md) |

---

## Selection Criteria

Select the method corresponding to your operational requirements:

1. **Private Access for Personal Devices**: Choose **Tailscale**. Traffic remains encrypted within an authenticated mesh VPN without exposing HTTP ports to the open internet.
2. **Team Access via Custom Domain**: Choose **Cloudflare Tunnel**. Exposes public HTTPS endpoints on your own domain with zero inbound router port configuration.
3. **Temporary Testing or Webhooks**: Choose **ngrok**. Instantly generates an ephemeral public HTTPS URL through a single command.
4. **Self-Hosted Static Ingress**: Choose **Port Forwarding**. Direct routing via router firewall rules. Requires strict reverse proxy TLS termination and upstream IP filtering.

---

## Quick Start

### Cloudflare Tunnel (Ephemeral URL)
```bash
chmod +x tunnels/cloudflare/start-cloudflare.sh
./tunnels/cloudflare/start-cloudflare.sh
```

### ngrok (Ephemeral URL)
```bash
chmod +x tunnels/ngrok/start-ngrok.sh
./tunnels/ngrok/start-ngrok.sh
```

### Tailscale (Private Mesh)
```bash
chmod +x tunnels/tailscale/start-tailscale.sh
./tunnels/tailscale/start-tailscale.sh
```
