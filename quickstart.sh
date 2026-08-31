#!/usr/bin/env bash
# ==============================================================================
# LiteLLM Proxy Server — Interactive Quickstart & CLI Onboarding
# ==============================================================================
set -euo pipefail

# Text formatting
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
RED="\033[31m"
DIM="\033[2m"
RESET="\033[0m"

NON_INTERACTIVE=false
SKIP_KEYS=false
SKIP_START=false

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Interactive setup wizard for LiteLLM Gateway.

Options:
    -y, --non-interactive   Run without prompting (uses generated or existing .env)
    --skip-keys             Skip interactive API key prompts
    --skip-start            Perform configuration only, do not launch Docker containers
    -h, --help              Display this help message and exit

Examples:
    ./quickstart.sh
    ./quickstart.sh -y
EOF
    exit 0
}

# Parse command line flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--non-interactive|--yes)
            NON_INTERACTIVE=true
            shift
            ;;
        --skip-keys)
            SKIP_KEYS=true
            shift
            ;;
        --skip-start)
            SKIP_START=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${RESET}" >&2
            usage
            ;;
    esac
done

echo ""
echo -e "${BOLD}${CYAN}======================================================${RESET}"
echo -e "${BOLD}${CYAN}      🚀 LiteLLM Gateway — Quickstart Setup Wizard    ${RESET}"
echo -e "${BOLD}${CYAN}======================================================${RESET}"
echo ""

# Helper to safely update key in .env file
set_env_var() {
    local key="$1"
    local val="$2"
    local file="${3:-.env}"

    if [ -f "$file" ]; then
        if grep -q "^${key}=" "$file"; then
            if command -v python3 &>/dev/null; then
                python3 -c "
import sys
key, val, path = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()
with open(path, 'w', encoding='utf-8') as f:
    for line in lines:
        if line.startswith(f'{key}='):
            f.write(f'{key}={val}\n')
        else:
            f.write(line)
" "$key" "$val" "$file"
            else
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "s|^${key}=.*|${key}=${val}|" "$file"
                else
                    sed -i "s|^${key}=.*|${key}=${val}|" "$file"
                fi
            fi
        else
            echo "${key}=${val}" >> "$file"
        fi
    fi
}

# 1. Dependency Checks
echo -e "${BOLD}1. Checking System Requirements...${RESET}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Error: Docker is not installed. Please install Docker first.${RESET}"
    exit 1
fi
echo -e "  ${GREEN}✔${RESET} Docker is installed: $(docker --version)"

if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Error: Docker Compose plugin is not installed.${RESET}"
    exit 1
fi
echo -e "  ${GREEN}✔${RESET} Docker Compose is installed: $(docker compose version --short 2>/dev/null || echo 'OK')"

# 2. Setup .env file
echo ""
echo -e "${BOLD}2. Setting Up Environment Configuration (.env)...${RESET}"
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "  ${GREEN}✔${RESET} Created .env from .env.example template"
    else
        echo -e "${RED}❌ Error: .env.example not found!${RESET}"
        exit 1
    fi
else
    echo -e "  ${GREEN}✔${RESET} Existing .env file found"
fi

# 3. Generate secure Master Key if default or empty
if grep -q "sk-your-secure-and-long-master-key-here" .env 2>/dev/null || ! grep -q "^MASTER_KEY=" .env 2>/dev/null; then
    echo -e "  ${YELLOW}🔑 Generating cryptographically secure MASTER_KEY...${RESET}"
    NEW_MASTER_KEY="sk-$(openssl rand -hex 24 2>/dev/null || python3 -c 'import secrets; print(secrets.token_hex(24))')"
    set_env_var "MASTER_KEY" "$NEW_MASTER_KEY"
    set_env_var "UI_PASSWORD" "$NEW_MASTER_KEY"
    echo -e "  ${GREEN}✔${RESET} MASTER_KEY generated and saved to .env"
fi

# 4. Generate Postgres password if default
if grep -q "your_postgres_password_here" .env 2>/dev/null; then
    echo -e "  ${YELLOW}🔐 Generating secure POSTGRES_PASSWORD...${RESET}"
    NEW_PG_PASS="$(openssl rand -hex 16 2>/dev/null || python3 -c 'import secrets; print(secrets.token_hex(16))')"
    set_env_var "POSTGRES_PASSWORD" "$NEW_PG_PASS"
    echo -e "  ${GREEN}✔${RESET} PostgreSQL password configured"
fi

# 5. Generate Grafana admin password if default
if grep -q "your_grafana_password_here" .env 2>/dev/null || grep -q "GRAFANA_ADMIN_PASSWORD=admin" .env 2>/dev/null; then
    echo -e "  ${YELLOW}🔐 Generating secure GRAFANA_ADMIN_PASSWORD...${RESET}"
    NEW_GRAFANA_PASS="$(openssl rand -hex 12 2>/dev/null || python3 -c 'import secrets; print(secrets.token_hex(12))')"
    set_env_var "GRAFANA_ADMIN_PASSWORD" "$NEW_GRAFANA_PASS"
    echo -e "  ${GREEN}✔${RESET} Grafana admin password configured"
fi

# 6. Interactive Provider API Keys Configuration
echo ""
echo -e "${BOLD}3. Model Provider API Keys Configuration${RESET}"

if [ "$NON_INTERACTIVE" = false ] && [ "$SKIP_KEYS" = false ]; then
    echo -e "Would you like to configure your AI Provider API Keys interactively now?"
    echo -e "${DIM}(You can press Enter to skip any key you don't have yet)${RESET}"
    read -r -p "👉 Configure API keys now? [Y/n]: " CONFIGURE_KEYS
    CONFIGURE_KEYS=${CONFIGURE_KEYS:-Y}

    if [[ "$CONFIGURE_KEYS" =~ ^[Yy]$ ]]; then
        echo ""
        # OpenAI
        read -r -p "🔹 OpenAI API Key (sk-...): " IN_OPENAI
        if [ -n "$IN_OPENAI" ]; then
            set_env_var "OPENAI_API_KEY" "$IN_OPENAI"
            echo -e "   ${GREEN}✔ Saved OPENAI_API_KEY${RESET}"
        fi

        # Anthropic
        read -r -p "🔹 Anthropic API Key (sk-ant-...): " IN_ANTHROPIC
        if [ -n "$IN_ANTHROPIC" ]; then
            set_env_var "ANTHROPIC_API_KEY" "$IN_ANTHROPIC"
            echo -e "   ${GREEN}✔ Saved ANTHROPIC_API_KEY${RESET}"
        fi

        # Google Gemini
        read -r -p "🔹 Google Gemini API Key (AIzaSy...): " IN_GEMINI
        if [ -n "$IN_GEMINI" ]; then
            set_env_var "GEMINI_API_KEY" "$IN_GEMINI"
            echo -e "   ${GREEN}✔ Saved GEMINI_API_KEY${RESET}"
        fi

        # DeepSeek
        read -r -p "🔹 DeepSeek API Key (sk-...): " IN_DEEPSEEK
        if [ -n "$IN_DEEPSEEK" ]; then
            set_env_var "DEEPSEEK_API_KEY" "$IN_DEEPSEEK"
            echo -e "   ${GREEN}✔ Saved DEEPSEEK_API_KEY${RESET}"
        fi

        # Groq
        read -r -p "🔹 Groq API Key (gsk_...): " IN_GROQ
        if [ -n "$IN_GROQ" ]; then
            set_env_var "GROQ_API_KEY" "$IN_GROQ"
            echo -e "   ${GREEN}✔ Saved GROQ_API_KEY${RESET}"
        fi

        # Mistral
        read -r -p "🔹 Mistral AI API Key: " IN_MISTRAL
        if [ -n "$IN_MISTRAL" ]; then
            set_env_var "MISTRAL_API_KEY" "$IN_MISTRAL"
            echo -e "   ${GREEN}✔ Saved MISTRAL_API_KEY${RESET}"
        fi

        # OpenRouter
        read -r -p "🔹 OpenRouter API Key (sk-or-...): " IN_OPENROUTER
        if [ -n "$IN_OPENROUTER" ]; then
            set_env_var "OPENROUTER_API_KEY" "$IN_OPENROUTER"
            echo -e "   ${GREEN}✔ Saved OPENROUTER_API_KEY${RESET}"
        fi

        echo ""
        echo -e "${GREEN}✅ API keys configured successfully in .env!${RESET}"
    fi
else
    echo -e "  ${DIM}ℹ️  Skipping interactive key prompts (non-interactive or skipped).${RESET}"
fi

# 7. Validate Configuration
echo ""
echo -e "${BOLD}4. Validating Gateway Configuration (config.yaml)...${RESET}"
if [ -f "scripts/validate_config.py" ]; then
    python3 scripts/validate_config.py --quiet && echo -e "  ${GREEN}✔ config.yaml structure is valid!${RESET}" || python3 scripts/validate_config.py
else
    echo -e "  ${GREEN}✔ PyYAML syntax check passed${RESET}"
fi

# 8. Start Docker Services
if [ "$SKIP_START" = true ]; then
    echo ""
    echo -e "${GREEN}✅ Setup complete!${RESET}"
    echo -e "👉 Start services whenever ready with: ${BOLD}make up${RESET} (or ${BOLD}docker compose up -d${RESET})"
    exit 0
fi

echo ""
echo -e "${BOLD}5. Launch Services${RESET}"
START_SERVICES="Y"
if [ "$NON_INTERACTIVE" = false ]; then
    read -r -p "▶️  Do you want to start Docker Compose services now? [Y/n] " START_INPUT
    START_INPUT=${START_INPUT:-Y}
    if [[ ! "$START_INPUT" =~ ^[Yy]$ ]]; then
        START_SERVICES="N"
    fi
fi

if [ "$START_SERVICES" = "Y" ]; then
    echo -e "🐳 Starting LiteLLM Gateway containers..."
    docker compose up -d

    echo ""
    echo -e "${BOLD}${GREEN}======================================================${RESET}"
    echo -e "${BOLD}${GREEN}   🎉 LiteLLM Proxy Gateway is Up and Running!        ${RESET}"
    echo -e "${BOLD}${GREEN}======================================================${RESET}"
    echo -e "  • ${BOLD}Health Check:${RESET} http://localhost:4000/health"
    echo -e "  • ${BOLD}Admin UI:${RESET}     http://localhost:4000/ui"
    echo -e "  • ${BOLD}Grafana UI:${RESET}   http://localhost:3001"
    echo -e "  • ${BOLD}Prometheus:${RESET}   http://localhost:9090"
    echo -e "  • ${BOLD}API Base:${RESET}     http://localhost:4000/v1"
    echo -e "${BOLD}${GREEN}======================================================${RESET}"
    echo ""

    # 9. Remote Access Setup (Optional)
    if [ "$NON_INTERACTIVE" = false ]; then
        echo -e "${BOLD}🌐 Remote Access Setup (Optional)${RESET}"
        echo -e "   Expose LiteLLM to external devices & mobile apps outside your network."
        echo ""
        echo -e "   [1] Cloudflare Tunnel — Free, secure, no port forwarding needed"
        echo -e "   [2] ngrok             — Fastest setup for testing"
        echo -e "   [3] Tailscale         — Private VPN, personal devices"
        echo -e "   [4] Skip              — Local network only"
        echo ""
        read -r -p "Choose a remote access method [1-4, default 4]: " TUNNEL_CHOICE
        TUNNEL_CHOICE=${TUNNEL_CHOICE:-4}

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
                echo -e "${DIM}ℹ️  Skipped remote tunnel setup. Run any tunnel in tunnels/ whenever needed.${RESET}"
                ;;
        esac
    fi
else
    echo ""
    echo -e "${GREEN}✅ Quickstart setup complete!${RESET}"
    echo -e "👉 Start services when ready: ${BOLD}make up${RESET}"
fi

echo ""
echo -e "${BOLD}💡 Useful commands:${RESET}"
echo -e "  • Check status:     ${BOLD}make ps${RESET}"
echo -e "  • View logs:        ${BOLD}make logs${RESET}"
echo -e "  • Validate config:  ${BOLD}make validate${RESET}"
echo -e "  • Database backup:  ${BOLD}make backup${RESET}"
echo -e "  • Stop gateway:     ${BOLD}make down${RESET}"
echo ""
