#!/usr/bin/env bash
# =============================================================================
# start-cloudflare.sh — Cloudflare Tunnel Launcher
# =============================================================================
# Exposes the LiteLLM proxy to the internet via Cloudflare.
#
# Usage:
#   Temporary tunnel (TryCloudflare — no account needed):
#     ./tunnels/cloudflare/start-cloudflare.sh
#
#   Permanent tunnel (your own domain):
#     TUNNEL_TOKEN=<token> ./tunnels/cloudflare/start-cloudflare.sh
#
# =============================================================================
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
COMPOSE_BASE="$PROJECT_ROOT/docker-compose.yml"
COMPOSE_CF="$PROJECT_ROOT/tunnels/cloudflare/docker-compose.cloudflare.yml"
LITELLM_PORT="${LITELLM_PORT:-4000}"

echo "=================================================="
echo "☁️  LiteLLM × Cloudflare Tunnel"
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

# --- Mode selection ---
if [ -n "${TUNNEL_TOKEN:-}" ]; then
  echo "🔒 Mode: Permanent tunnel (your own domain)"
  echo "   Token: ${TUNNEL_TOKEN:0:8}...${TUNNEL_TOKEN: -4}"
  MODE="permanent"
else
  echo "⚡ Mode: Temporary tunnel (*.trycloudflare.com)"
  MODE="temporary"
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
    echo "⚠️  LiteLLM was not ready after 30 seconds — starting tunnel anyway..."
  fi
  sleep 1
done

echo ""

# --- Start Cloudflare tunnel ---
echo "🚀 Starting Cloudflare tunnel..."
docker compose \
  -f "$COMPOSE_BASE" \
  -f "$COMPOSE_CF" \
  up -d cloudflared

echo ""
echo "📋 Watching logs for tunnel URL..."
echo "   (Press Ctrl+C to stop watching — the tunnel keeps running in the background)"
echo ""

if [ "$MODE" = "temporary" ]; then
  echo "   The temporary URL will appear below as 'trycloudflare.com':"
  echo "--------------------------------------------------"
  timeout 30 docker compose \
    -f "$COMPOSE_BASE" \
    -f "$COMPOSE_CF" \
    logs -f cloudflared 2>&1 | grep -m1 "trycloudflare.com" | sed 's/.*\(https:\/\/[^ ]*trycloudflare\.com\).*/\n🌐 URL: \1\n/' || true
  echo "--------------------------------------------------"
  echo ""
  echo "💡 To retrieve the URL later:"
  echo "   docker compose -f docker-compose.yml -f tunnels/cloudflare/docker-compose.cloudflare.yml logs cloudflared"
else
  echo "   The permanent tunnel is active on the domain configured in your Cloudflare dashboard."
  echo "   Dashboard: https://dash.cloudflare.com -> Zero Trust -> Tunnels"
fi

echo ""
echo "=================================================="
echo "🛑 To stop the tunnel:"
echo "   docker compose -f docker-compose.yml \\"
echo "     -f tunnels/cloudflare/docker-compose.cloudflare.yml \\"
echo "     stop cloudflared"
echo "=================================================="
