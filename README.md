<p align="center">
  <img src="assets/banner.jpg" alt="LiteLLM Proxy Enterprise Banner" width="800" />
</p>

<h1 align="center">LiteLLM Proxy Server Setup</h1>

<p align="center">
  <b>Centralized OpenAI-compatible LLM Gateway with PostgreSQL & Supabase Integration</b>
</p>

<p align="center">
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License MIT" /></a>
  <a href="https://github.com/BerriAI/litellm"><img src="https://img.shields.io/badge/LiteLLM-v1.82.3-purple.svg" alt="LiteLLM Version" /></a>
  <a href="https://www.postgresql.org/"><img src="https://img.shields.io/badge/PostgreSQL-16.8-blue.svg" alt="PostgreSQL 16.8" /></a>
  <a href="SECURITY.md"><img src="https://img.shields.io/badge/Security-Hardened-success.svg" alt="Security Hardened" /></a>
  <a href=".github/workflows/ci.yml"><img src="https://img.shields.io/badge/CI-Passing-brightgreen.svg" alt="CI Status" /></a>
  <a href=".pre-commit-config.yaml"><img src="https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white" alt="pre-commit" /></a>
</p>

---

## 📋 Table of Contents
- [⚡ Quickstart (Interactive CLI Setup)](#-quickstart-interactive-cli-setup)
- [🛠️ Makefile Command Reference](#️-makefile-command-reference)
- [📦 Ready API Test Collections (Postman & Bruno)](#-ready-api-test-collections-postman--bruno)
- [🔍 Configuration Validation & Diagnostics](#-configuration-validation--diagnostics)
- [💾 Database Backup Routine & Disaster Recovery](#-database-backup-routine--disaster-recovery)
- [🖥️ Dashboards & Web Interfaces Reference](#️-dashboards--web-interfaces-reference)
- [🔒 Security, Observability & Resilience Architecture](#-security-observability--resilience-architecture)
- [🌐 Remote Access (Tunnels & VPN)](#-remote-access-tunnels--vpn)
- [🤖 Automated CI/CD Workflow & Quality Standards](#-automated-cicd-workflow--quality-standards)
- [🔑 Obtaining Model Provider API Keys](#-obtaining-model-provider-api-keys)
- [📁 Project Structure](#-project-structure)
- [🚀 Usage & Code Integration Examples](#-usage--code-integration-examples)
- [🔒 Security & Key Management (Admin UI)](#-security--key-management-admin-ui)
- [📜 License & Community Policy](#-license--community-policy)

---

## ⚡ Quickstart (Interactive CLI Setup)

Get up and running effortlessly with the interactive onboarding wizard:

```bash
chmod +x quickstart.sh && ./quickstart.sh
```

### 🧙‍♂️ What the Interactive Quickstart does:
1. **System Checks**: Verifies Docker, Docker Compose, and required tooling.
2. **Environment Generation**: Creates `.env` from template and automatically generates cryptographically secure secrets (`MASTER_KEY`, `POSTGRES_PASSWORD`, `GRAFANA_ADMIN_PASSWORD`).
3. **Interactive Key Configuration**: Prompts you in the terminal for your AI provider keys (OpenAI, Anthropic, Gemini, DeepSeek, Groq, Mistral, OpenRouter, etc.) and safely writes them into `.env`.
4. **Pre-flight Validation**: Automatically validates `config.yaml` syntax, model schemas, and fallback targets before launch.
5. **Container Orchestration**: Starts Docker Compose services and verifies container health.
6. **Remote Access Wizard**: Optionally sets up Cloudflare Tunnel, ngrok, or Tailscale for external device access.

> Non-interactive mode (for automation/CI): `./quickstart.sh -y`

---

## 🛠️ Makefile Command Reference

A comprehensive `Makefile` is included so you can manage your entire gateway with simple single-word commands:

| Command | Category | Description |
| :--- | :---: | :--- |
| `make up` (or `make start`) | Lifecycle | Start all containers in background (`docker compose up -d`) |
| `make down` (or `make stop`) | Lifecycle | Stop and remove running containers (`docker compose down`) |
| `make restart` | Lifecycle | Restart all gateway services |
| `make build` | Lifecycle | Rebuild images and start containers |
| `make clean` | Lifecycle | Stop services and remove persistent data volumes (`docker compose down -v`) |
| `make quickstart` | Lifecycle | Launch interactive quickstart wizard |
| `make ps` (or `make status`) | Monitoring | Show status of running containers |
| `make logs` | Logs | Stream live logs for all containers |
| `make logs-litellm` | Logs | Stream live logs for LiteLLM proxy container |
| `make logs-db` | Logs | Stream live logs for PostgreSQL database container |
| `make logs-grafana` | Logs | Stream live logs for Grafana analytics container |
| `make validate` | Diagnostics | Run deep syntax, schema, and `.env` cross-checks |
| `make health` | Diagnostics | Test local proxy health endpoint (`http://localhost:4000/health`) |
| `make test-models` | Diagnostics | Query active models from LiteLLM proxy with auth |
| `make backup` | Database | Create timestamped compressed PostgreSQL backup (`.sql.gz`) |
| `make restore FILE=...` | Database | Restore PostgreSQL database from backup archive |
| `make lint` | Quality | Run pre-commit or validation checks across repository |
| `make help` | Info | Print colorized help menu of all available targets |

---

## 📦 Ready API Test Collections (Postman & Bruno)

Pre-built API collections are available in the [`collections/`](collections/) directory:

```text
collections/
├── postman/
│   ├── LiteLLM_Gateway.postman_collection.json         # Postman Collection v2.1
│   └── LiteLLM_Local_Environment.postman_environment.json # Postman Environment Config
└── bruno/
    ├── bruno.json                                      # Bruno collection manifest
    ├── collection.bru                                  # Bearer auth configuration
    ├── environments/Local.bru                          # Bruno local environment
    ├── 01-health-check.bru                             # Health status probe
    ├── 02-list-models.bru                              # List OpenAI models
    ├── 03-chat-gpt4o.bru                               # GPT-4o completion
    ├── 04-chat-claude.bru                              # Claude 3.5 Sonnet completion
    ├── 05-chat-gemini.bru                              # Gemini 2.0 Flash completion
    ├── 06-chat-deepseek.bru                            # DeepSeek Chat completion
    ├── 07-streaming-chat.bru                           # SSE stream completion
    └── 08-generate-virtual-key.bru                     # Admin key generation
```

### Quick Import:
- **Postman**: Import both files in `collections/postman/` and select the **LiteLLM Local Gateway** environment.
- **Bruno**: Open the folder `collections/bruno/` directly in [Bruno](https://www.usebruno.com/).

> See [collections/README.md](collections/README.md) for full endpoint schemas and testing examples.

---

## 🔍 Configuration Validation & Diagnostics

Prevent misconfigurations before deploying with our built-in configuration validator (`scripts/validate_config.py`):

```bash
# Run validation check:
make validate
# or directly:
python3 scripts/validate_config.py
```

### Features:
- **Syntax & Schema Verification**: Parses `config.yaml` to ensure required sections (`model_list`, `router_settings`, `general_settings`) are valid.
- **Fallback Integrity**: Verifies that all fallback targets exist in the defined models list.
- **Environment Variable Cross-Check**: Scans all `os.environ/XYZ` references in `config.yaml` against `.env` and flags missing keys or unconfigured placeholder values.
- **CLI Options**:
  - `python3 scripts/validate_config.py --strict` (Fails if any referenced API key is missing or placeholder)
  - `python3 scripts/validate_config.py --json` (Outputs structured JSON report for CI/CD)

---

## 💾 Database Backup Routine & Disaster Recovery

Protect your virtual keys, user spend, and rate limit data stored in PostgreSQL with automated backup and restore scripts.

### 1. Manual Backup & Restore
```bash
# Create compressed timestamped backup (.sql.gz) in ./backups/
make backup

# Restore from a backup:
make restore FILE=backups/litellm_backup_20260901_120000.sql.gz
```

### 2. Automated Scheduled Backups (Crontab)
To configure automated daily database backups at 02:00 AM:

```bash
# Open your user crontab
crontab -e

# Add the following entry (replace /path/to/home-lite-llm with your actual repository path):
0 2 * * * cd /path/to/home-lite-llm && ./scripts/backup_db.sh -q >> /var/log/litellm_backup.log 2>&1
```

### Backup Script Highlights:
- **Gzip Compression**: Compresses database dumps by default to save storage.
- **Automated Retention**: Keeps the most recent 10 backups (customizable via `-k <num>`).
- **Safe Disaster Recovery**: Sourcing `.env` credentials automatically with interactive confirmation safeguards.

> See [scripts/README.md](scripts/README.md) for detailed flag references and advanced recovery workflows.

---

## 🖥️ Dashboards & Web Interfaces Reference

Here is a guide to all web interfaces, management screens, and diagnostic endpoints available in this project:

| Interface / URL | Credentials / Auth | Description & Features |
| :--- | :--- | :--- |
| **LiteLLM Admin UI**<br>`http://localhost:4000/ui` | Bearer `MASTER_KEY`<br>or `UI_USERNAME` / `UI_PASSWORD` | **Central Management Dashboard**: Generate virtual API keys, set spending budgets per user/team, track cost/token metrics, inspect request logs, and test model prompts inline. |
| **Grafana Analytics**<br>`http://localhost:3001` | Default: `admin` / `admin`<br>*(configurable in `.env`)* | **Performance & Analytics Dashboard**: Pre-configured Prometheus graphs showing request rates (RPS), token consumption by model, P50/P90/P99 latency, and error rates (`429`, `500`). |
| **Prometheus Explorer**<br>`http://localhost:9090` | None *(Internal)* | **Metrics Database UI**: Execute PromQL queries, check target scrape status (`litellm-proxy`), and inspect raw metric series. |
| **Health Check**<br>`http://localhost:4000/health` | None | **Container Health Check**: Endpoint used by Docker Compose and load balancers to verify proxy uptime (`200 OK`). |
| **Prometheus Metrics**<br>`http://localhost:4000/metrics` | None | **Raw Telemetry Stream**: Exposes Prometheus-formatted metrics scraped automatically by the Prometheus service. |
| **Active Models List**<br>`http://localhost:4000/v1/models` | Bearer `MASTER_KEY` | **OpenAI Models Endpoint**: Returns a JSON list of all active LLM models configured in `config.yaml`. |
| **Chat Completions API**<br>`http://localhost:4000/v1/chat/completions` | Bearer `MASTER_KEY` or Virtual Key | **OpenAI API Gateway**: Primary endpoint for standard and streaming LLM inference. |

---

## 🔒 Security, Observability & Resilience Architecture

This deployment includes enterprise-grade production hardening:

### 1. Security & Authentication
- **Crypto-Random Master Key**: Automatically generated strong hex keys prevent unauthorized API usage.
- **Hashed API Key Storage**: LiteLLM hashes all virtual keys in PostgreSQL before storing them.
- **Private Database Network**: Database port `5432` is bound strictly to `litellm-network` and is never exposed externally.
- **Security Policy**: Comprehensive security guidelines and vulnerability disclosure process documented in [SECURITY.md](SECURITY.md).

### 2. Observability & Monitoring (Prometheus & Grafana Integration)
- **Grafana Analytics Dashboard**: Pre-configured Grafana runs on `http://localhost:3001` (default login: `admin`/`admin`), automatically provisioned with Prometheus as its default datasource.
- **Built-in Prometheus Container**: Pre-configured Prometheus server runs on `http://localhost:9090`, scraping `litellm:4000/metrics`.
- **Prometheus Metrics**: Metrics endpoint available at `http://localhost:4000/metrics` for monitoring token counts, request latency, and HTTP status codes (`429`, `500`).
- **Structured JSON Logging**: Enabled `json_logs: true` in `config.yaml` for seamless parsing by Loki, Datadog, or AWS CloudWatch.
- **Log Rotation**: Host disk bloat prevention via Docker `json-file` driver (`max-size: "10m"`, `max-file: "3"`).

### 3. Resilience & Fallback Mechanisms
- **Advanced Healthchecks**: Both `db` (`pg_isready`) and `litellm` (`/health`) feature active Docker healthchecks. LiteLLM waits for `service_healthy` to ensure database readiness before starting.
- **Automatic Fallbacks**: Configured in `config.yaml` so if a primary provider fails or hits rate limits, requests automatically failover (e.g. `gpt-4o` -> `gemini-2.0-flash` / `claude-3-5-sonnet`).
- **Retries & Rate Limits**: Configured `num_retries: 3` and model RPM limits to prevent upstream ban/exhaustion.

---

## 🌐 Remote Access (Tunnels & VPN)

Access your LiteLLM proxy from outside your home network — without opening ports or needing a static IP.

| Method | Best For | Security | Free |
|:---|:---|:---:|:---:|
| **[Cloudflare Tunnel](tunnels/cloudflare/README.md)** | Sharing with others, custom domain | 🟢 High | ✅ |
| **[ngrok](tunnels/ngrok/README.md)** | Quick testing & development | 🟡 Medium | ✅ |
| **[Tailscale](tunnels/tailscale/README.md)** | Personal devices only (most secure) | 🟢 Highest | ✅ |
| **[Port Forwarding](tunnels/port-forwarding/README.md)** | Static IP / full control | 🔴 Lower | ✅ |

```bash
# Cloudflare Tunnel (free, no account needed)
./tunnels/cloudflare/start-cloudflare.sh

# ngrok (one command)
./tunnels/ngrok/start-ngrok.sh

# Tailscale (most secure, VPN-based)
./tunnels/tailscale/start-tailscale.sh
```

> See **[tunnels/README.md](tunnels/README.md)** for a full comparison and detailed setup guides.

---

## 🤖 Automated CI/CD Workflow & Quality Standards

- **Pre-commit Hooks**: Enforce YAML, Shell, Python, and JSON formatting with `.pre-commit-config.yaml`.
  ```bash
  pip install pre-commit && pre-commit install
  make lint
  ```
- **GitHub Actions**: Automated CI workflow (`.github/workflows/ci.yml`) validates `config.yaml`, `scripts/validate_config.py`, shell scripts, API collections, and Docker Compose configurations on every pull request and push.
- **Dependabot**: Configured (`.github/dependabot.yml`) for weekly automated updates of GitHub Actions and Docker Compose image versions.

---

## 🔑 Obtaining Model Provider API Keys

To enable model routing, obtain API keys from your preferred AI model providers and add them to your `.env` file:

| Provider | Direct Dashboard Link | Free Tier / Pricing Status | How to Get Your API Key |
| :--- | :--- | :--- | :--- |
| **Google Gemini** | [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) | 🟢 **Free Tier Available** | Log in -> Click **Create API key** -> Select or create a Google Cloud project |
| **Groq** | [console.groq.com/keys](https://console.groq.com/keys) | 🟢 **Free Tier Available** | Log in -> Go to **API Keys** -> Click **Create API Key** |
| **Ollama (Local)** | [ollama.com](https://ollama.com) | 🟢 **100% Free (Self-Hosted)** | Install Ollama locally, run models (`ollama pull llama3`), default endpoint `http://localhost:11434` |
| **vLLM (Local/Cloud)** | [vllm.ai](https://vllm.ai) | 🟢 **100% Free (Self-Hosted)** | Run vLLM OpenAI-compatible server on `http://localhost:8000/v1` |
| **OpenRouter** | [openrouter.ai/keys](https://openrouter.ai/keys) | 🟢 **Free Models & Paid** | Log in -> Go to **Keys** page -> Click **Create Key** (Offers free & paid models) |
| **Together AI** | [api.together.ai/settings/api-keys](https://api.together.ai/settings/api-keys) | 🎁 **Free Trial Credits** | Log in -> Go to **Settings** -> **API Keys** -> Copy default key |
| **Fireworks AI** | [fireworks.ai/account/api-keys](https://fireworks.ai/account/api-keys) | 🎁 **Free Trial Credits** | Log in -> Go to **Account** -> **API Keys** -> Create key |
| **Cohere** | [dashboard.cohere.com/api-keys](https://dashboard.cohere.com/api-keys) | 🎁 **Free Trial Key** | Log in -> Copy your **Trial Key** or generate a **Production Key** |
| **OpenAI** | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) | 💳 **Paid (Pay-as-you-go)** | Log in -> Navigate to **API Keys** -> Click **Create new secret key** |
| **Anthropic (Claude)** | [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys) | 💳 **Paid (Pay-as-you-go)** | Log in -> Go to **API Keys** -> Click **Create Key** |
| **DeepSeek** | [platform.deepseek.com/api_keys](https://platform.deepseek.com/api_keys) | 💳 **Paid (Low Cost)** | Log in -> Go to **API Keys** -> Click **Create API Key** |
| **xAI (Grok)** | [console.x.ai](https://console.x.ai) | 💳 **Paid / Credits** | Log in -> Go to **API Keys** -> Click **Create API Key** |
| **Mistral AI** | [console.mistral.ai/api-keys](https://console.mistral.ai/api-keys) | 💳 **Paid (Pay-as-you-go)** | Log in -> Go to **Workspace Settings** -> **API Keys** -> Click **Create new key** |

| **Perplexity AI** | [perplexity.ai/settings/api](https://perplexity.ai/settings/api) | 💳 **Paid (Pay-as-you-go)** | Log in -> Go to **API Settings** -> Generate key & add credits |
| **Azure OpenAI** | [portal.azure.com](https://portal.azure.com) | 💳 **Paid (Azure Billing)** | Navigate to your Azure OpenAI resource -> Find **Keys and Endpoint** |
| **AWS Bedrock** | [console.aws.amazon.com/iam](https://console.aws.amazon.com/iam) | 💳 **Paid (AWS Billing)** | Go to IAM -> Create Access Key for user -> Enable model access in Bedrock Console |

---

## 📁 Project Structure

```text
├── Makefile                                    # Management commands (make up, logs, backup, etc.)
├── quickstart.sh                               # Interactive setup CLI wizard
├── docker-compose.yml                          # Production PostgreSQL, LiteLLM, Prometheus & Grafana
├── config.yaml                                 # LiteLLM routing, fallbacks, and model settings
├── .env.example                                # Environment variable template
├── .pre-commit-config.yaml                     # Pre-commit code quality hooks
├── .yamllint.yml                               # YAML linter configuration
├── collections/                                # Ready API collections
│   ├── README.md                               # API collection import documentation
│   ├── postman/                                # Postman collection & local environment
│   └── bruno/                                  # Bruno collection & requests
├── scripts/                                    # Maintenance & diagnostic scripts
│   ├── README.md                               # Scripts usage & crontab guide
│   ├── validate_config.py                      # Configuration validator
│   ├── backup_db.sh                            # Timestamped compressed PostgreSQL backup
│   └── restore_db.sh                           # PostgreSQL disaster recovery restore
├── monitoring/                                 # Observability configs
│   ├── prometheus.yml                          # Metrics scraping configuration
│   └── grafana/provisioning/                   # Grafana datasource provisioning
├── tunnels/                                    # Remote access guides & scripts
│   ├── README.md                               # Tunnel comparison overview
│   ├── cloudflare/                             # Cloudflare Tunnel setup
│   ├── ngrok/                                  # ngrok tunnel setup
│   ├── tailscale/                              # Tailscale VPN setup
│   └── port-forwarding/                        # Dynamic DNS & Port Forwarding
├── SECURITY.md                                 # Security policy
├── CONTRIBUTING.md                             # Contribution guidelines
├── CODE_OF_CONDUCT.md                          # Code of conduct
├── CHANGELOG.md                                # Version release log
└── LICENSE.md                                  # MIT License
```

---

## 🚀 Usage & Code Integration Examples

### 1. Health Check & Observability Dashboards
Verify that all services are running:

```bash
# Health Check (LiteLLM Proxy)
curl http://localhost:4000/health

# Prometheus Metrics (LiteLLM)
curl http://localhost:4000/metrics

# Prometheus Server Dashboard:  http://localhost:9090
# Grafana Analytics Dashboard:  http://localhost:3001  (Default: admin / admin)
```

---

### 2. cURL Examples

#### Standard Chat Completion Request
```bash
curl http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-your-secure-and-long-master-key-here" \
  -d '{
    "model": "gpt-4o-mini",
    "messages": [
      {"role": "user", "content": "Hello! Explain LiteLLM in one sentence."}
    ]
  }'
```

#### Streaming Response Request
```bash
curl http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-your-secure-and-long-master-key-here" \
  -d '{
    "model": "claude-3-5-sonnet",
    "messages": [
      {"role": "user", "content": "Write a short poem about AI proxies."}
    ],
    "stream": true
  }'
```

---

### 3. Python Integration (OpenAI SDK & LangChain)

#### Standard & Streaming Completion (OpenAI Python SDK)
```python
from openai import OpenAI

# Initialize client pointing to local LiteLLM Proxy
client = OpenAI(
    api_key="sk-your-secure-and-long-master-key-here",  # MASTER_KEY from .env
    base_url="http://localhost:4000"
)

# Standard Response
response = client.chat.completions.create(
    model="gemini-2.0-flash",
    messages=[
        {"role": "user", "content": "Testing Gemini model via LiteLLM Proxy."}
    ]
)
print("Standard Response:", response.choices[0].message.content)

# Streaming Response
stream = client.chat.completions.create(
    model="deepseek-chat",
    messages=[
        {"role": "user", "content": "Count from 1 to 5 slowly."}
    ],
    stream=True
)

print("Streaming Response: ", end="")
for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
print()
```

#### LangChain Integration
```python
from langchain_community.chat_models import ChatOpenAI

llm = ChatOpenAI(
    openai_api_key="sk-your-secure-and-long-master-key-here",
    openai_api_base="http://localhost:4000",
    model_name="claude-3-5-sonnet"
)

response = llm.invoke("What are the advantages of a centralized LLM gateway?")
print(response.content)
```

---

### 4. Node.js / TypeScript Integration (OpenAI SDK)

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: 'sk-your-secure-and-long-master-key-here', // MASTER_KEY from .env
  baseURL: 'http://localhost:4000',
});

async function main() {
  // Standard Completion
  const completion = await openai.chat.completions.create({
    model: 'gpt-4o',
    messages: [{ role: 'user', content: 'Hello from Node.js!' }],
  });
  console.log('Response:', completion.choices[0].message.content);

  // Streaming Completion
  const stream = await openai.chat.completions.create({
    model: 'gemini-1.5-flash',
    messages: [{ role: 'user', content: 'Tell me a quick joke.' }],
    stream: true,
  });

  process.stdout.write('Stream: ');
  for await (const chunk of stream) {
    process.stdout.write(chunk.choices[0]?.delta?.content || '');
  }
  console.log();
}

main().catch(console.error);
```

---

## 🔒 Security & Key Management (Admin UI)
PostgreSQL integration enables the LiteLLM Admin UI and dynamic API key generation with budget tracking.

- **Admin UI**: Access `http://localhost:4000/ui` using your `MASTER_KEY` to log in.
- **User / Team Key Generation**: Generate sub-keys with specific budgets, model restrictions, and rate limits via the UI or API endpoints.

---

## 📜 License & Community Policy

- **License**: Distributed under the MIT License. See [LICENSE.md](LICENSE.md) for details.
- **Security Policy**: Read our vulnerability disclosure guidelines in [SECURITY.md](SECURITY.md).
- **Contributing**: Please review [CONTRIBUTING.md](CONTRIBUTING.md) before submitting Pull Requests.
- **Code of Conduct**: Community standards documented in [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
- **Support**: Troubleshooting & support resources in [SUPPORT.md](SUPPORT.md).
- **Changelog**: Release history in [CHANGELOG.md](CHANGELOG.md).
