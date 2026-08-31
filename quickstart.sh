#!/usr/bin/env bash
set -e

echo "=================================================="
echo "🚀 LiteLLM Proxy Server Quickstart Setup"
echo "=================================================="

# 1. Check dependencies
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "❌ Error: Docker Compose plugin is not installed."
    exit 1
fi

# 2. Setup .env file
if [ ! -f .env ]; then
    echo "📄 Creating .env file from .env.example..."
    cp .env.example .env
else
    echo "ℹ️  Existing .env file found."
fi

# 3. Generate secure Master Key if default
if grep -q "sk-your-secure-and-long-master-key-here" .env 2>/dev/null; then
    echo "🔑 Generating secure MASTER_KEY..."
    NEW_MASTER_KEY="sk-$(openssl rand -hex 24 2>/dev/null || python3 -c 'import secrets; print(secrets.token_hex(24))')"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/sk-your-secure-and-long-master-key-here/$NEW_MASTER_KEY/g" .env
    else
        sed -i "s/sk-your-secure-and-long-master-key-here/$NEW_MASTER_KEY/g" .env
    fi
    echo "✅ Master Key generated and set in .env"
fi

# 4. Generate Postgres password if default
if grep -q "your_postgres_password_here" .env 2>/dev/null; then
    echo "🔐 Generating secure POSTGRES_PASSWORD..."
    NEW_PG_PASS="$(openssl rand -hex 16 2>/dev/null || python3 -c 'import secrets; print(secrets.token_hex(16))')"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/your_postgres_password_here/$NEW_PG_PASS/g" .env
    else
        sed -i "s/your_postgres_password_here/$NEW_PG_PASS/g" .env
    fi
    echo "✅ PostgreSQL Password generated and set in .env"
fi

# 5. Generate Grafana admin password if default
if grep -q "your_grafana_password_here" .env 2>/dev/null || grep -q "GRAFANA_ADMIN_PASSWORD=admin" .env 2>/dev/null; then
    echo "🔐 Generating secure GRAFANA_ADMIN_PASSWORD..."
    NEW_GRAFANA_PASS="$(openssl rand -hex 12 2>/dev/null || python3 -c 'import secrets; print(secrets.token_hex(12))')"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/GRAFANA_ADMIN_PASSWORD=admin/GRAFANA_ADMIN_PASSWORD=$NEW_GRAFANA_PASS/g" .env
        sed -i '' "s/your_grafana_password_here/$NEW_GRAFANA_PASS/g" .env
    else
        sed -i "s/GRAFANA_ADMIN_PASSWORD=admin/GRAFANA_ADMIN_PASSWORD=$NEW_GRAFANA_PASS/g" .env
        sed -i "s/your_grafana_password_here/$NEW_GRAFANA_PASS/g" .env
    fi
    echo "✅ Grafana Admin Password generated and set in .env"
fi

# 6. Validate config.yaml syntax
echo "🔍 Validating config.yaml syntax..."
if command -v python3 &> /dev/null; then
    python3 -c "import yaml; yaml.safe_load(open('config.yaml'))" 2>/dev/null && echo "✅ config.yaml syntax is valid" || echo "ℹ️ Skipped PyYAML validation (python3/pyyaml optional)"
fi

echo ""
echo "--------------------------------------------------"
echo "⚠️  Action Required: Add your model provider API keys in .env!"
echo "   (e.g., OPENAI_API_KEY, GEMINI_API_KEY, ANTHROPIC_API_KEY)"
echo "--------------------------------------------------"
echo ""

# 7. Start core services
read -p "▶️  Do you want to start Docker Compose services now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🐳 Starting Docker Compose services..."
    docker compose up -d

    echo ""
    echo "=================================================="
    echo "🎉 LiteLLM Proxy is up and running!"
    echo "=================================================="
    echo "  • Health Check: http://localhost:4000/health"
    echo "  • Prometheus:   http://localhost:9090"
    echo "  • Grafana UI:   http://localhost:3001"
    echo "  • Admin UI:     http://localhost:4000/ui"
    echo "=================================================="
    echo ""

    # 8. Remote access setup (optional)
    echo "--------------------------------------------------"
    echo "🌐 Remote Access Setup (optional)"
    echo "--------------------------------------------------"
    echo "   Expose LiteLLM to devices outside your local network."
    echo ""
    echo "   [1] Cloudflare Tunnel  — Free, secure, no port forwarding needed"
    echo "       Temporary URL (no account required):"
    echo "       ./tunnels/cloudflare/start-cloudflare.sh"
    echo ""
    echo "   [2] ngrok              — Fastest setup, great for quick tests"
    echo "       ./tunnels/ngrok/start-ngrok.sh"
    echo ""
    echo "   [3] Tailscale          — Most secure, VPN-based, personal devices only"
    echo "       ./tunnels/tailscale/start-tailscale.sh"
    echo ""
    echo "   [4] Port Forwarding    — Static IP / full control (advanced)"
    echo "       DUCKDNS_TOKEN=<token> DUCKDNS_DOMAIN=<subdomain> \\"
    echo "       ./tunnels/port-forwarding/setup-ddns.sh"
    echo ""
    echo "   See tunnels/README.md for a full comparison and setup guides."
    echo "--------------------------------------------------"
    echo ""

    read -p "▶️  Would you like to set up remote access now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Which method would you like to use?"
        echo "  1) Cloudflare Tunnel (recommended — free, no account needed)"
        echo "  2) ngrok"
        echo "  3) Tailscale"
        echo "  4) Skip — I'll set it up later"
        echo ""
        read -p "Enter your choice [1-4]: " -r TUNNEL_CHOICE
        echo ""

        case "$TUNNEL_CHOICE" in
            1)
                echo "☁️  Starting Cloudflare Tunnel..."
                chmod +x tunnels/cloudflare/start-cloudflare.sh
                ./tunnels/cloudflare/start-cloudflare.sh
                ;;
            2)
                echo "🔗 Starting ngrok..."
                chmod +x tunnels/ngrok/start-ngrok.sh
                ./tunnels/ngrok/start-ngrok.sh
                ;;
            3)
                echo "🔐 Starting Tailscale..."
                chmod +x tunnels/tailscale/start-tailscale.sh
                ./tunnels/tailscale/start-tailscale.sh
                ;;
            *)
                echo "ℹ️  Skipped. Run any of the tunnel scripts above whenever you're ready."
                ;;
        esac
    else
        echo "ℹ️  Skipped. Run a tunnel script from the tunnels/ directory whenever you're ready."
    fi
else
    echo "✅ Quickstart setup complete."
    echo "👉 When ready, run: docker compose up -d"
    echo ""
    echo "ℹ️  For remote access options, see: tunnels/README.md"
fi
