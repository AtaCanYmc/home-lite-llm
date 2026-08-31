<p align="center">
  <img src="assets/logo.jpg" alt="LiteLLM Proxy Logo" width="600" />
</p>

<h1 align="center">LiteLLM Proxy Server Setup</h1>

<p align="center">
  <b>Centralized OpenAI-compatible LLM Gateway with PostgreSQL & Supabase Integration</b>
</p>

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
4. Prompts you to add your model provider API keys and launches Docker Compose.

---

## 🔒 Production Hardening & Security Features

This configuration includes production-grade reliability and security defaults:

- **Healthchecks & Managed Dependencies**: `db` includes a `pg_isready` health check; LiteLLM waits for `service_healthy` before initializing to prevent startup connection crashes.
- **Pinned Image Versions**: Fixed version tags (`postgres:16.8-alpine`, `ghcr.io/berriai/litellm:main-v1.61.1`) to avoid breaking changes from `:latest`.
- **Log Rotation**: Configured `json-file` logging driver with `max-size: "10m"` and `max-file: "3"` to prevent host disk bloat during heavy LLM streaming.
- **Network Isolation**: Dedicated `litellm-network` bridge network. Database port `5432` is kept strictly private within the container network.
- **Restart Policy**: Configured `restart: unless-stopped` on all services for automatic recovery after crashes or system reboots.

---

## 🔑 Obtaining Model Provider API Keys

To enable model routing, obtain API keys from your preferred AI model providers and add them to your `.env` file:

| Provider | Direct Dashboard Link | Free Tier / Pricing Status | How to Get Your API Key |
| :--- | :--- | :--- | :--- |
| **Google Gemini** | [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) | 🟢 **Free Tier Available** | Log in -> Click **Create API key** -> Select or create a Google Cloud project |
| **Groq** | [console.groq.com/keys](https://console.groq.com/keys) | 🟢 **Free Tier Available** | Log in -> Go to **API Keys** -> Click **Create API Key** |
| **Ollama (Local)** | [ollama.com](https://ollama.com) | 🟢 **100% Free (Self-Hosted)** | Install Ollama locally, run models (`ollama pull llama3`), default endpoint `http://localhost:11434` |
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
- `docker-compose.yml` -> Production-hardened PostgreSQL database and LiteLLM proxy services.
- `config.yaml` -> Contains model routing and proxy configurations.
- `.env` -> Stores sensitive API keys and database credentials.
- `.env.example` -> Environment variable template file.
- `assets/logo.jpg` -> Project logo banner.

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

### 3. Configure Models (config.yaml)
Customize `config.yaml` to specify which models and settings LiteLLM will serve.

Default supported models include OpenAI, Claude, Gemini, DeepSeek, Mistral, Groq, Cohere, Bedrock, Azure, Ollama, etc.

### 4. Start Services (Docker Compose)
Run PostgreSQL and LiteLLM Proxy in the background using Docker Compose:

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

## 🚀 Usage & Testing

### Health Check
To verify that the proxy server is running:

```bash
curl http://localhost:4000/health
```

### OpenAI Compatible API Request (cURL)
LiteLLM proxy complies with the OpenAI API standard. Pass your `MASTER_KEY` in the `Authorization` header:

```bash
curl http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-your-secure-and-long-master-key-here" \
  -d '{
    "model": "gpt-4o-mini",
    "messages": [
      {"role": "user", "content": "Hello, is the LiteLLM proxy server running?"}
    ]
  }'
```

### Python Usage (OpenAI SDK)

```python
from openai import OpenAI

client = OpenAI(
    api_key="sk-your-secure-and-long-master-key-here",  # MASTER_KEY from .env
    base_url="http://localhost:4000"
)

response = client.chat.completions.create(
    model="gemini-1.5-flash",
    messages=[
        {"role": "user", "content": "Testing Gemini model via LiteLLM."}
    ]
)

print(response.choices[0].message.content)
```

---

## 🔒 Security & Key Management (Admin UI)
PostgreSQL integration enables the LiteLLM Admin UI and dynamic API key generation with budget tracking.

- **Admin UI**: Access `http://localhost:4000/ui` using your `MASTER_KEY` to log in.
- **User / Team Key Generation**: Generate sub-keys with specific budgets, model restrictions, and rate limits via the UI or API endpoints.
