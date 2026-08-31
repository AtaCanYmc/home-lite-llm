#!/usr/bin/env bash
# =============================================================================
# setup-ddns.sh — Duck DNS Dynamic DNS Setup
# =============================================================================
# Sets up Duck DNS (free) for use with dynamic IP addresses.
# Adds a cron job that automatically updates the DNS record whenever your IP changes.
#
# Usage:
#   DUCKDNS_TOKEN=<token> DUCKDNS_DOMAIN=<subdomain> \
#     ./tunnels/port-forwarding/setup-ddns.sh
#
# Example:
#   DUCKDNS_TOKEN=abc123 DUCKDNS_DOMAIN=my-litellm \
#     ./tunnels/port-forwarding/setup-ddns.sh
#   → https://my-litellm.duckdns.org
#
# =============================================================================
set -euo pipefail

DUCKDNS_TOKEN="${DUCKDNS_TOKEN:-}"
DUCKDNS_DOMAIN="${DUCKDNS_DOMAIN:-}"
CRON_INTERVAL="${CRON_INTERVAL:-5}"   # update frequency in minutes
UPDATE_SCRIPT="$HOME/.duckdns-update.sh"
LOG_FILE="$HOME/.duckdns-update.log"

echo "=================================================="
echo "🌐 Duck DNS — Dynamic DNS Setup"
echo "=================================================="

# --- Parameter check ---
if [ -z "$DUCKDNS_TOKEN" ]; then
  echo ""
  echo "❌ DUCKDNS_TOKEN is missing!"
  echo ""
  echo "   1. Go to https://www.duckdns.org"
  echo "   2. Sign in with GitHub, Google, or Twitter"
  echo "   3. Choose a subdomain under 'Domains' (e.g. my-litellm)"
  echo "   4. Copy the 'token' value shown at the top of the page"
  echo ""
  echo "   Then run:"
  echo "   DUCKDNS_TOKEN=abc123 DUCKDNS_DOMAIN=my-litellm \\"
  echo "     ./tunnels/port-forwarding/setup-ddns.sh"
  exit 1
fi

if [ -z "$DUCKDNS_DOMAIN" ]; then
  echo ""
  echo "❌ DUCKDNS_DOMAIN is missing!"
  echo "   Enter the subdomain you registered on Duck DNS (subdomain part only)."
  echo "   Example: 'my-litellm' → https://my-litellm.duckdns.org"
  exit 1
fi

FULL_DOMAIN="${DUCKDNS_DOMAIN}.duckdns.org"
echo ""
echo "   Domain : $FULL_DOMAIN"
echo "   Token  : ${DUCKDNS_TOKEN:0:6}...${DUCKDNS_TOKEN: -4}"
echo "   Cron   : Update every $CRON_INTERVAL minutes"
echo ""

# --- Get current public IP ---
CURRENT_IP=$(curl -sf https://api.ipify.org || curl -sf https://ipecho.net/plain || echo "unknown")
echo "📡 Current public IP: $CURRENT_IP"

# --- Initial Duck DNS update ---
echo ""
echo "🔄 Updating Duck DNS..."
RESULT=$(curl -sf \
  "https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&ip=" \
  || echo "error")

if [ "$RESULT" = "OK" ]; then
  echo "✅ Duck DNS updated successfully!"
  echo "   $FULL_DOMAIN → $CURRENT_IP"
else
  echo "❌ Duck DNS update failed: $RESULT"
  echo "   Please check your token and domain name."
  exit 1
fi

# --- Create auto-update script ---
echo ""
echo "📝 Creating auto-update script: $UPDATE_SCRIPT"

cat > "$UPDATE_SCRIPT" << SCRIPT_EOF
#!/usr/bin/env bash
# Duck DNS automatic IP update script
# Created: $(date)
RESULT=\$(curl -sf "https://www.duckdns.org/update?domains=${DUCKDNS_DOMAIN}&token=${DUCKDNS_TOKEN}&ip=" 2>&1)
echo "\$(date '+%Y-%m-%d %H:%M:%S') | IP: \$(curl -sf https://api.ipify.org 2>/dev/null || echo 'unknown') | \$RESULT" >> "$LOG_FILE"
SCRIPT_EOF

chmod +x "$UPDATE_SCRIPT"
echo "✅ Script created."

# --- Add cron job ---
echo ""
echo "⏰ Adding cron job (every $CRON_INTERVAL minutes)..."

CRON_LINE="*/${CRON_INTERVAL} * * * * $UPDATE_SCRIPT"

# Read existing crontab, remove any old Duck DNS lines, append the new one
(crontab -l 2>/dev/null | grep -v "duckdns" | grep -v "duckdns-update"; echo "$CRON_LINE") | crontab -

echo "✅ Cron job added."

# --- DNS verification (allow some time for propagation) ---
echo ""
echo "🔍 Testing DNS resolution (propagation may take a few minutes)..."
sleep 2
RESOLVED=$(host "$FULL_DOMAIN" 2>/dev/null | grep "has address" | awk '{print $NF}' | head -1 || echo "")

if [ -n "$RESOLVED" ]; then
  echo "✅ DNS resolved: $FULL_DOMAIN → $RESOLVED"
else
  echo "ℹ️  DNS not yet resolved (this is normal — please wait a few minutes)."
fi

echo ""
echo "=================================================="
echo "🎉 Duck DNS Setup Complete!"
echo "=================================================="
echo ""
echo "📋 Next Steps — Modem Port Forwarding:"
echo ""
echo "   1. Open your modem admin interface (usually http://192.168.1.1)"
echo "   2. Find the 'Port Forwarding' / 'Virtual Server' section"
echo "   3. Add the following rule:"
echo "      Protocol    : TCP"
echo "      External Port: 4000  (or 443 if using an SSL reverse proxy)"
echo "      Internal IP : $(hostname -I | awk '{print $1}' 2>/dev/null || echo 'your_server_local_ip')"
echo "      Internal Port: 4000"
echo ""
echo "   4. Access your server at:"
echo "      http://$FULL_DOMAIN:4000/health"
echo ""
echo "🔒 Security Warning:"
echo "   Port forwarding exposes your server directly to the internet."
echo "   For production use, prefer Cloudflare Tunnel or Tailscale instead."
echo ""
echo "📊 Update logs: $LOG_FILE"
echo "   tail -f $LOG_FILE"
echo ""
echo "🛑 To remove the cron job:"
echo "   crontab -l | grep -v 'duckdns-update' | crontab -"
echo "=================================================="
