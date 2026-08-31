# ngrok Integration

Exposes the LiteLLM proxy with **a single command**. Ideal for quick testing and development environments.

## Free vs. Paid Plan

| Feature | Free (Anonymous) | Free (Registered) | Paid |
|:---|:---:|:---:|:---:|
| HTTPS tunnel | ✅ | ✅ | ✅ |
| Stable URL | ❌ | ❌ | ✅ |
| Concurrent tunnels | 1 | 1 | Multiple |
| Connection limits | Yes | Fewer | None |
| Web UI (port 4040) | ✅ | ✅ | ✅ |
| Custom domain | ❌ | ❌ | ✅ |

> 💡 **Recommendation:** Sign up for a **free account** at [ngrok.com](https://ngrok.com) and set `NGROK_AUTHTOKEN` to remove connection limits.

---

## ⚡ Quick Start

```bash
chmod +x tunnels/ngrok/start-ngrok.sh
./tunnels/ngrok/start-ngrok.sh
```

Once the script completes, you will see output like:

```
🌐 Tunnel URL: https://a1b2c3d4.ngrok-free.app
```

---

## 🔑 Setup with AuthToken

### 1. Create an ngrok Account and AuthToken

1. Go to [ngrok.com](https://ngrok.com) → **Sign up** (free)
2. Copy your token from [Dashboard → Your Authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)

### 2. Add the Token to `.env`

```env
NGROK_AUTHTOKEN=2abc123def456ghi789_longtoken...
```

### 3. Start with Token

```bash
./tunnels/ngrok/start-ngrok.sh
# Token is automatically read from .env
```

---

## Manual Docker Compose Usage

```bash
# Start
docker compose \
  -f docker-compose.yml \
  -f tunnels/ngrok/docker-compose.ngrok.yml \
  up -d

# Get the URL (ngrok Local API)
curl http://localhost:4040/api/tunnels | \
  python3 -c "import sys,json; t=json.load(sys.stdin)['tunnels']; print(t[0]['public_url'])"

# Follow logs
docker compose \
  -f docker-compose.yml \
  -f tunnels/ngrok/docker-compose.ngrok.yml \
  logs -f ngrok

# Stop the tunnel
docker compose \
  -f docker-compose.yml \
  -f tunnels/ngrok/docker-compose.ngrok.yml \
  stop ngrok
```

---

## 📊 ngrok Web UI

While ngrok is running, open `http://localhost:4040` to access the built-in web interface:

- Inspect incoming requests in real time
- View request/response headers and bodies
- **Replay** requests (very useful for debugging)

---

## API Usage Example

```bash
# Store the URL in a variable
NGROK_URL=$(curl -sf http://localhost:4040/api/tunnels | \
  grep -o '"public_url":"https://[^"]*"' | \
  head -1 | sed 's/"public_url":"//;s/"//')

# Send a request to LiteLLM
curl "$NGROK_URL/v1/chat/completions" \
  -H "Authorization: Bearer $MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "gemini-2.0-flash", "messages": [{"role": "user", "content": "Hello!"}]}'
```

---

## Security Notes

- Even though the ngrok URL is random, it is publicly accessible. The LiteLLM `MASTER_KEY` requirement provides the baseline security.
- For production use, prefer Cloudflare Tunnel or Tailscale over ngrok.
- Remember to stop the tunnel after testing: `docker compose ... stop ngrok`

## Troubleshooting

```bash
# View container logs
docker logs litellm-ngrok

# Check ngrok API response
curl http://localhost:4040/api/tunnels

# Manual connectivity test
curl -I $(curl -sf http://localhost:4040/api/tunnels | grep -o 'https://[^"]*ngrok[^"]*' | head -1)/health
```
