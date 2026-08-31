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

# 5. Validate config.yaml syntax
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
else
    echo "✅ Quickstart setup complete."
    echo "👉 When ready, run: docker compose up -d"
fi
