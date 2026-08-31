#!/usr/bin/env bash
# =============================================================================
# start-ngrok.sh — ngrok Tunnel Launcher
# =============================================================================
# Exposes the LiteLLM proxy to the internet via ngrok.
#
# Usage:
#   Free (temporary URL):
#     ./tunnels/ngrok/start-ngrok.sh
#
#   With AuthToken (registered ngrok account):
#     NGROK_AUTHTOKEN=<token> ./tunnels/ngrok/start-ngrok.sh
#
# =============================================================================
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
COMPOSE_BASE="$PROJECT_ROOT/docker-compose.yml"
COMPOSE_NGROK="$PROJECT_ROOT/tunnels/ngrok/docker-compose.ngrok.yml"
LITELLM_PORT="${LITELLM_PORT:-4000}"
NGROK_API_PORT="4040"

echo "=================================================="
echo "🔗 LiteLLM × ngrok"
echo "=================================================="

# --- Dependency check ---
if ! command -v docker &>/dev/null; then
  echo "❌ Docker is not installed. Please install Docker first."
  exit 1
fi

if ! docker compose version &>/dev/null; then
  echo "❌ Docker Compose plugin not found."
  exit 1
fi

# --- Show mode ---
if [ -n "${NGROK_AUTHTOKEN:-}" ]; then
  echo "🔑 Mode: Authenticated (ngrok account features enabled)"
  echo "   Token: ${NGROK_AUTHTOKEN:0:8}...${NGROK_AUTHTOKEN: -4}"
else
  echo "⚡ Mode: Anonymous (free, temporary URL, connection limits apply)"
  echo "   💡 Sign up for a free account at ngrok.com and set NGROK_AUTHTOKEN to remove limits."
fi

echo ""

# --- Start LiteLLM services ---
echo "🐳 Starting LiteLLM services..."
docker compose -f "$COMPOSE_BASE" up -d --quiet-pull

echo "⏳ Waiting for LiteLLM to be ready..."
for i in $(seq 1 30); do
  if curl -sf "http://localhost:${LITELLM_PORT}/health" &>/dev/null; then
    echo "✅ LiteLLM is ready!"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "⚠️  LiteLLM was not ready after 30 seconds — starting ngrok anyway..."
  fi
  sleep 1
done

echo ""

# --- Start ngrok ---
echo "🚀 Starting ngrok..."
docker compose \
  -f "$COMPOSE_BASE" \
  -f "$COMPOSE_NGROK" \
  up -d ngrok

echo "⏳ Waiting for ngrok to establish the tunnel..."
sleep 4

# --- Fetch URL from ngrok Local API ---
NGROK_URL=""
for i in $(seq 1 15); do
  if command -v curl &>/dev/null; then
    NGROK_URL=$(curl -sf "http://localhost:${NGROK_API_PORT}/api/tunnels" 2>/dev/null \
      | grep -o '"public_url":"https://[^"]*"' \
      | head -1 \
      | sed 's/"public_url":"//;s/"//' || true)
  fi
  if [ -n "$NGROK_URL" ]; then
    break
  fi
  sleep 1
done

echo ""
echo "=================================================="
if [ -n "$NGROK_URL" ]; then
  echo "🌐 Tunnel URL: $NGROK_URL"
  echo ""
  echo "   Usage examples:"
  echo "   curl $NGROK_URL/health"
  echo "   curl $NGROK_URL/v1/chat/completions \\"
  echo "     -H 'Authorization: Bearer \$MASTER_KEY' \\"
  echo "     -H 'Content-Type: application/json' \\"
  echo "     -d '{\"model\":\"gpt-4o-mini\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello!\"}]}'"
else
  echo "⚠️  Could not retrieve URL automatically."
  echo "   Check manually:"
  echo "   • ngrok Web UI: http://localhost:${NGROK_API_PORT}"
  echo "   • Logs:         docker logs litellm-ngrok"
fi
echo ""
echo "📊 ngrok Web UI: http://localhost:${NGROK_API_PORT}"
echo "   (Inspect live requests, replay them for debugging)"
echo ""
echo "🛑 To stop the tunnel:"
echo "   docker compose -f docker-compose.yml \\"
echo "     -f tunnels/ngrok/docker-compose.ngrok.yml \\"
echo "     stop ngrok"
echo "=================================================="
