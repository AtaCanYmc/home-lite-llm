<p align="center">
  <img src="assets/logo.jpg" alt="LiteLLM Proxy Logo" width="600" />
</p>

<h1 align="center">LiteLLM Proxy Server Setup</h1>

<p align="center">
  <b>Centralized OpenAI-compatible LLM Gateway with PostgreSQL & Supabase Integration</b>
</p>

---

This repository is configured to run a centralized LiteLLM proxy server using Docker Compose for local network and external access.

## 📁 Project Structure
- `docker-compose.yml` -> Contains PostgreSQL database and LiteLLM proxy services.
- `config.yaml` -> Contains model routing and proxy configurations.
- `.env` -> Stores sensitive API keys and database credentials.
- `.env.example` -> Environment variable template file.
- `assets/logo.jpg` -> Project logo banner.

---

## 🛠️ Setup Steps

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
