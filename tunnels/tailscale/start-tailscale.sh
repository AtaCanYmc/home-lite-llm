#!/usr/bin/env bash
# =============================================================================
# start-tailscale.sh — Tailscale VPN Launcher
# =============================================================================
# Joins LiteLLM into a Tailscale mesh VPN.
# Only trusted devices on your Tailscale network can reach it.
#
# Usage:
#   Interactive login (first-time setup):
#     ./tunnels/tailscale/start-tailscale.sh
#
#   Auth Key (headless/automated mode):
#     TS_AUTHKEY=<authkey> ./tunnels/tailscale/start-tailscale.sh
#
#   With Funnel (public HTTPS via Tailscale):
#     TS_FUNNEL=1 ./tunnels/tailscale/start-tailscale.sh
#
# =============================================================================
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
COMPOSE_BASE="$PROJECT_ROOT/docker-compose.yml"
COMPOSE_TS="$PROJECT_ROOT/tunnels/tailscale/docker-compose.tailscale.yml"
LITELLM_PORT="${LITELLM_PORT:-4000}"

echo "=================================================="
echo "🔐 LiteLLM × Tailscale"
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

# --- Mode info ---
if [ -n "${TS_AUTHKEY:-}" ]; then
  echo "🔑 Mode: Automatic join via Auth Key (headless)"
else
  echo "🌐 Mode: Interactive login (browser will open)"
fi

if [ "${TS_FUNNEL:-0}" = "1" ]; then
  echo "📡 Tailscale Funnel: Enabled (publicly accessible HTTPS endpoint)"
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
    echo "⚠️  LiteLLM was not ready after 30 seconds — starting Tailscale anyway..."
  fi
  sleep 1
done

echo ""

# --- Start Tailscale ---
echo "🚀 Starting Tailscale..."
docker compose \
  -f "$COMPOSE_BASE" \
  -f "$COMPOSE_TS" \
  up -d tailscale

# --- Interactive login required? ---
if [ -z "${TS_AUTHKEY:-}" ]; then
  echo ""
  echo "🔗 Retrieving Tailscale login URL..."
  sleep 3

  LOGIN_URL=$(docker logs litellm-tailscale 2>&1 \
    | grep -o 'https://login.tailscale.com/a/[^ ]*' \
    | tail -1 || true)

  if [ -n "$LOGIN_URL" ]; then
    echo ""
    echo "📲 Open the following URL in your browser and sign in:"
    echo ""
    echo "   $LOGIN_URL"
    echo ""
    echo "⏳ Waiting for login to complete (up to 120 seconds)..."

    for i in $(seq 1 24); do
      sleep 5
      STATUS=$(docker exec litellm-tailscale tailscale status --json 2>/dev/null \
        | grep -o '"BackendState":"[^"]*"' | head -1 | sed 's/"BackendState":"//;s/"//' || echo "unknown")
      if [ "$STATUS" = "Running" ]; then
        echo "✅ Tailscale connected!"
        break
      fi
      if [ "$i" -eq 24 ]; then
        echo "⚠️  Timed out. Check manually: docker exec litellm-tailscale tailscale status"
      fi
    done
  else
    echo "ℹ️  Login URL not found in logs."
    echo "   Manual login: docker exec -it litellm-tailscale tailscale login"
  fi
fi

# --- Get Tailscale IP and hostname ---
echo ""
sleep 2
TS_IP=$(docker exec litellm-tailscale tailscale ip -4 2>/dev/null | head -1 || echo "")
TS_HOST=$(docker exec litellm-tailscale tailscale status --json 2>/dev/null \
  | grep -o '"Self":{[^}]*"DNSName":"[^"]*"' \
  | grep -o '"DNSName":"[^"]*"' \
  | sed 's/"DNSName":"//;s/"//' \
  | sed 's/\.$//' || echo "")

# --- Enable Tailscale Funnel (optional) ---
if [ "${TS_FUNNEL:-0}" = "1" ]; then
  echo "📡 Enabling Tailscale Funnel (port $LITELLM_PORT → HTTPS)..."
  docker exec litellm-tailscale tailscale funnel --bg "${LITELLM_PORT}" || {
    echo "⚠️  Funnel could not be started. Make sure Funnel is enabled in your Tailscale account."
  }
fi

echo ""
echo "=================================================="
if [ -n "$TS_IP" ]; then
  echo "🌐 Tailscale IP:   $TS_IP"
  echo "   LiteLLM URL:   http://${TS_IP}:${LITELLM_PORT}"
fi
if [ -n "$TS_HOST" ]; then
  echo "   Hostname URL:  http://${TS_HOST}:${LITELLM_PORT}"
fi
echo ""
echo "   Access from any device on your Tailscale network:"
echo "   curl http://\$TS_IP:${LITELLM_PORT}/health"
echo ""
echo "📱 Tailscale Admin: https://login.tailscale.com/admin/machines"
echo ""
echo "🛑 To stop Tailscale:"
echo "   docker compose -f docker-compose.yml \\"
echo "     -f tunnels/tailscale/docker-compose.tailscale.yml \\"
echo "     stop tailscale"
echo "=================================================="
