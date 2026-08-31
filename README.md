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
</p>

---

## 📋 Table of Contents
- [⚡ Quickstart (Automated Setup)](#-quickstart-automated-setup)
- [🖥️ Dashboards & Web Interfaces Reference](#️-dashboards--web-interfaces-reference)
- [🔒 Security, Observability & Resilience Architecture](#-security-observability--resilience-architecture)
  - [1. Security & Authentication](#1-security--authentication)
  - [2. Observability & Monitoring (Prometheus & Grafana Integration)](#2-observability--monitoring-prometheus--grafana-integration)
  - [3. Resilience & Fallback Mechanisms](#3-resilience--fallback-mechanisms)
  - [4. Data Persistence & Backup Scripts](#4-data-persistence--backup-scripts)
- [🤖 Automated CI/CD Workflow & Dependabot](#-automated-cicd-workflow--dependabot)
- [🔑 Obtaining Model Provider API Keys](#-obtaining-model-provider-api-keys)
- [📁 Project Structure](#-project-structure)
- [🛠️ Manual Setup Steps](#️-manual-setup-steps)
  - [1. Create Environment File (.env)](#1-create-environment-file-env)
  - [2. Database Options (Local Postgres vs. Supabase)](#2-database-options-local-postgres-vs-supabase)
  - [3. Configure Models & Fallbacks (config.yaml)](#3-configure-models--fallbacks-configyaml)
  - [4. Start Services (Docker Compose)](#4-start-services-docker-compose)
- [🚀 Usage & Code Integration Examples](#-usage--code-integration-examples)
  - [1. Health Check & Observability Dashboards](#1-health-check--observability-dashboards)
  - [2. cURL Examples](#2-curl-examples)
  - [3. Python Integration (OpenAI SDK & LangChain)](#3-python-integration-openai-sdk--langchain)
  - [4. Node.js / TypeScript Integration (OpenAI SDK)](#4-nodejs--typescript-integration-openai-sdk)
- [🔒 Security & Key Management (Admin UI)](#-security--key-management-admin-ui)
- [📜 License & Community Policy](#-license--community-policy)

---

## ⚡ Quickstart (Automated Setup)

Get up and running in seconds with the automated setup script:

```bash
chmod +x quickstart.sh && ./quickstart.sh
```

The script automatically:
1. Verifies Docker & Docker Compose dependencies.
2. Creates your `.env` configuration file from `.env.example`.
3. Automatically generates secure cryptographic keys for `MASTER_KEY` and `POSTGRES_PASSWORD`.
4. Validates `config.yaml` syntax.
5. Prompts you to add your model provider API keys and launches Docker Compose.

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

### 4. Data Persistence & Backup Scripts
- **Persistent Volume**: Database state stored in `postgres_data` volume and Grafana dashboard data in `grafana_data` volume.
- **Automated Backup & Restore Scripts**:
  - Run database backup: `./scripts/backup_db.sh`
  - Restore database: `./scripts/restore_db.sh <path_to_backup.sql>`

---

## 🤖 Automated CI/CD Workflow & Dependabot

- **GitHub Actions**: Automated CI workflow (`.github/workflows/ci.yml`) validates `config.yaml`, `quickstart.sh`, and `docker-compose.yml` on every pull request and push.
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
| **Mistral AI** | [console.mistral.ai/api-keys](https://console.mistral.ai/api-keys) | 💳 **Paid (Pay-as-you-go)** | Log in -> Go to **Workspace Settings** -> **API Keys** -> Click **Create new key** |
| **Perplexity AI** | [perplexity.ai/settings/api](https://perplexity.ai/settings/api) | 💳 **Paid (Pay-as-you-go)** | Log in -> Go to **API Settings** -> Generate key & add credits |
| **Azure OpenAI** | [portal.azure.com](https://portal.azure.com) | 💳 **Paid (Azure Billing)** | Navigate to your Azure OpenAI resource -> Find **Keys and Endpoint** |
| **AWS Bedrock** | [console.aws.amazon.com/iam](https://console.aws.amazon.com/iam) | 💳 **Paid (AWS Billing)** | Go to IAM -> Create Access Key for user -> Enable model access in Bedrock Console |

---

## 📁 Project Structure
- `quickstart.sh` -> Automated quickstart setup script.
- `docker-compose.yml` -> Production-hardened PostgreSQL, LiteLLM proxy, Prometheus, and Grafana services.
- `config.yaml` -> Contains model routing, fallbacks, vLLM/Ollama settings, and observability options.
- `.env` -> Stores sensitive API keys, credentials, and configuration flags.
- `.env.example` -> Environment variable template file.
- `SECURITY.md` -> Security policy & vulnerability reporting procedures.
- `CONTRIBUTING.md` -> Contribution guidelines and development workflow.
- `CODE_OF_CONDUCT.md` -> Community Code of Conduct.
- `LICENSE.md` -> MIT License details.
- `CHANGELOG.md` -> Version release history.
- `SUPPORT.md` -> Support and troubleshooting guide.
- `.github/workflows/ci.yml` -> Automated CI/CD validation workflow.
- `.github/dependabot.yml` -> Automated dependency update configuration.
- `scripts/backup_db.sh` -> Automated database backup script.
- `scripts/restore_db.sh` -> Automated database restore script.
- `monitoring/prometheus.yml` -> Prometheus scraping configuration.
- `monitoring/grafana/provisioning` -> Automatic Grafana datasource provisioning.
- `assets/banner.jpg` -> Enterprise project logo banner.

---

## 🛠️ Manual Setup Steps

### 1. Create Environment File (.env)
Create a `.env` file in the root directory or copy from `.env.example`:

```bash
cp .env.example .env
```

Open `.env` and fill in your variables:

```env
MASTER_KEY=sk-your-secure-and-long-master-key-here
POSTGRES_PASSWORD=your_postgres_password_here
OPENAI_API_KEY=your_openai_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
```

### 2. Database Options (Local Postgres vs. Supabase)

#### Option A: Local PostgreSQL Container (Default)
By default, Docker Compose will launch a local PostgreSQL container (`db`). Just set `POSTGRES_PASSWORD` in `.env`.

#### Option B: Supabase / External PostgreSQL
If you prefer to use **Supabase** (or any cloud-hosted Postgres) instead of running a local database container:
1. Retrieve your connection string from **Supabase Dashboard -> Project Settings -> Database** (Use Connection Pooling on port `6543` or Direct connection on port `5432`).
2. Uncomment and set `DATABASE_URL` in your `.env` file:
   ```env
   DATABASE_URL=postgresql://postgres.[YOUR-PROJECT-REF]:[YOUR-PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres?sslmode=require
   ```
3. Run only the LiteLLM proxy container:
   ```bash
   docker compose up -d litellm
   ```

### 3. Configure Models & Fallbacks (config.yaml)
Customize `config.yaml` to specify which models, fallback rules, and observability settings LiteLLM will serve.

### 4. Start Services (Docker Compose)
Run PostgreSQL, LiteLLM Proxy, Prometheus, and Grafana in the background using Docker Compose:

```bash
docker compose up -d
```

To inspect service status and logs:

```bash
# List service status
docker compose ps

# Follow logs
docker compose logs -f litellm
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
