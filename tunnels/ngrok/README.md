[← Back to Remote Access Overview](../README.md) | [← Back to Root Repository](../../README.md)

# ngrok Tunnel Integration

Exposes the LiteLLM proxy using the ngrok ingress service. Suitable for local testing, integration validation, and external webhook delivery.

---

## Plan Comparison

| Feature | Anonymous Free | Registered Free | Paid Tier |
| :--- | :--- | :--- | :--- |
| **HTTPS Ingress** | Supported | Supported | Supported |
| **Stable URL** | No | No | Supported |
| **Concurrent Tunnels** | 1 | 1 | Multiple |
| **Traffic Limits** | Strict | Standard | Unmetered |
| **Web Inspector UI (Port 4040)** | Supported | Supported | Supported |
| **Custom Subdomain** | No | No | Supported |

---

## Quick Start

Launch ngrok tunnel using the helper script:

```bash
chmod +x tunnels/ngrok/start-ngrok.sh
./tunnels/ngrok/start-ngrok.sh
```

Upon initialization, the terminal outputs the active endpoint:

```text
Tunnel URL: https://a1b2c3d4.ngrok-free.app
```

---

## Authenticated Execution

### 1. Obtain AuthToken
1. Create an account at [ngrok.com](https://ngrok.com).
2. Retrieve your token from the [ngrok Dashboard](https://dashboard.ngrok.com/get-started/your-authtoken).

### 2. Configure Environment
Set `NGROK_AUTHTOKEN` in `.env`:

```env
NGROK_AUTHTOKEN=2abc123def456ghi789_longtoken...
```

### 3. Start Authenticated Ingress
```bash
./tunnels/ngrok/start-ngrok.sh
```

---

## Docker Compose Execution

Run ngrok using the compose overlay definition:

```bash
# Start base services with ngrok overlay
docker compose \
  -f docker-compose.yml \
  -f tunnels/ngrok/docker-compose.ngrok.yml \
  up -d

# Query public URL via ngrok local inspection API
curl -s http://localhost:4040/api/tunnels | \
  python3 -c "import sys, json; print(json.load(sys.stdin)['tunnels'][0]['public_url'])"

# Follow ngrok container logs
docker compose \
  -f docker-compose.yml \
  -f tunnels/ngrok/docker-compose.ngrok.yml \
  logs -f ngrok

# Stop ngrok container
docker compose \
  -f docker-compose.yml \
  -f tunnels/ngrok/docker-compose.ngrok.yml \
  stop ngrok
```

---

## Traffic Inspection UI

While the container is active, navigate to `http://localhost:4040` to access the local ngrok diagnostic web UI:
- Real-time HTTP request and response inspection.
- Header and body payload analysis.
- One-click request replay for testing proxy routing.
