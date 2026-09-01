# 🌐 LiteLLM Proxy — Comprehensive Integration & Developer Experience (DX) Guide

This guide provides step-by-step instructions, production-ready configuration templates, and copy-paste code snippets to integrate your local/server Docker-based **LiteLLM Gateway** (`home-lite-llm`) with all your IDEs (Cursor, Continue, Cline), Terminal/CLI tools (Aider, Claude CLI), Web UIs (Open WebUI, LibreChat), and software development stacks (Python, Node.js, cURL).

---

## 📋 Table of Contents
1. [Global Connection Parameters & Endpoints](#1-global-connection-parameters--endpoints)
2. [IDE & AI Coding Assistants Integration](#2-ide--ai-coding-assistants-integration)
   - [A. Cursor IDE](#a-cursor-ide)
   - [B. Continue (VS Code & JetBrains)](#b-continue-vs-code--jetbrains)
   - [C. Cline / Roo Code (Autonomous Coding Agent)](#c-cline--roo-code-vs-code-extension)
3. [Terminal & CLI Tools Integration](#3-terminal--cli-tools-integration)
   - [A. Aider (AI Pair Programming in Terminal)](#a-aider-integration)
   - [B. Claude CLI & Official SDK Redirections](#b-claude-cli--official-sdk-redirections)
   - [C. Shell Functions & Helpers (Zsh / Bash)](#c-shell-functions--helpers-zsh--bash)
4. [Web UIs & Ecosystem Platforms](#4-web-uis--ecosystem-platforms)
   - [A. Open WebUI Integration](#a-open-webui-integration)
   - [B. LibreChat Integration](#b-librechat-integration)
5. [Code Integration Examples (SDK & cURL)](#5-code-integration-examples-sdk--curl)
   - [A. Python (OpenAI SDK — Standard & Streaming)](#a-python-integration)
   - [B. Node.js / TypeScript (OpenAI SDK)](#b-nodejs--typescript-integration)
   - [C. cURL (Terminal Verification)](#c-curl-terminal-verification)

---

## 1. Global Connection Parameters & Endpoints

LiteLLM Proxy serves as a centralized gateway that normalizes requests across 15+ upstream providers into standard **OpenAI-compatible REST API** endpoints.

### 🔌 Connection Parameters

| Parameter | Host Machine (Localhost) | Docker Container Network | Description |
| :--- | :--- | :--- | :--- |
| **OpenAI Base URL** | `http://localhost:4000/v1` | `http://litellm:4000/v1` | Primary endpoint for OpenAI SDKs & clients |
| **Root Gateway URL** | `http://localhost:4000` | `http://litellm:4000` | Base URL for management and metrics |
| **Authentication / API Key** | `MASTER_KEY` from `.env` *(or generated Virtual Key)* | `Bearer sk-...` | Passed via `Authorization: Bearer <KEY>` header |
| **Admin Dashboard UI** | `http://localhost:4000/ui` | - | Central key, budget, and spend management UI |
| **Readiness Healthcheck** | `http://localhost:4000/health/readiness` | `http://litellm:4000/health/readiness` | Probes proxy & database connectivity |

### 🤖 Supported Model Aliases (`model_name`)
Use any of the following configured model aliases directly in your client applications:

* **Frontier Cloud LLMs**: `gpt-4o`, `gpt-4o-mini`, `o3-mini`, `claude-3-5-sonnet`, `claude-3-5-haiku`, `gemini-2.0-flash`, `gemini-1.5-pro`, `deepseek-chat`, `deepseek-reasoner`, `grok-2`, `grok-2-vision`
* **Ultra-Fast LPU Inference (Groq)**: `groq-llama-3.3-70b`, `groq-llama-3.1-8b`, `groq-deepseek-r1-70b`, `groq-gemma2-9b`
* **Local / Offline Models**: `ollama-llama3.3`, `ollama-deepseek-r1`, `ollama-qwen2.5`, `lmstudio-local`, `vllm-llama3`

---

## 2. IDE & AI Coding Assistants Integration

### A. Cursor IDE

[Cursor](https://www.cursor.com/) allows overriding the default OpenAI endpoint to route all chat, code edits, and inline generation through your local proxy.

1. Open **Cursor** and navigate to **Settings** (`Cmd + ,` on macOS or `Ctrl + ,` on Windows/Linux) -> **Cursor Settings** -> **Models**.
2. Locate the **OpenAI API Key** section:
   * **OpenAI API Key**: Enter your `MASTER_KEY` from `.env` (starts with `sk-...`).
   * **Override OpenAI Base URL**: Enter `http://localhost:4000/v1` *(Ensure `/v1` is included at the end)*.
3. Click **Add Model** to register your desired models:
   * `gpt-4o`
   * `claude-3-5-sonnet`
   * `gemini-2.0-flash`
   * `groq-llama-3.3-70b`
   * `ollama-llama3.3`
4. Toggle on the models and select your default model in Cursor AI Chat / Composer.

---

### B. Continue (VS Code & JetBrains)

[Continue.dev](https://continue.dev/) is an open-source AI code assistant supporting tab autocomplete, inline edits, and sidebar chat.

Open your Continue configuration file located at `~/.continue/config.json` and paste the following configuration:

```json
{
  "models": [
    {
      "title": "LiteLLM - Claude 3.5 Sonnet",
      "provider": "openai",
      "model": "claude-3-5-sonnet",
      "apiBase": "http://localhost:4000/v1",
      "apiKey": "sk-your-secure-and-long-master-key-here"
    },
    {
      "title": "LiteLLM - GPT-4o",
      "provider": "openai",
      "model": "gpt-4o",
      "apiBase": "http://localhost:4000/v1",
      "apiKey": "sk-your-secure-and-long-master-key-here"
    },
    {
      "title": "LiteLLM - Groq Llama 3.3 (Fast)",
      "provider": "openai",
      "model": "groq-llama-3.3-70b",
      "apiBase": "http://localhost:4000/v1",
      "apiKey": "sk-your-secure-and-long-master-key-here"
    },
    {
      "title": "LiteLLM - Ollama DeepSeek R1 (Local)",
      "provider": "openai",
      "model": "ollama-deepseek-r1",
      "apiBase": "http://localhost:4000/v1",
      "apiKey": "sk-your-secure-and-long-master-key-here"
    }
  ],
  "tabAutocompleteModel": {
    "title": "LiteLLM - Fast Autocomplete",
    "provider": "openai",
    "model": "groq-llama-3.1-8b",
    "apiBase": "http://localhost:4000/v1",
    "apiKey": "sk-your-secure-and-long-master-key-here"
  },
  "embeddingsProvider": {
    "provider": "openai",
    "model": "ollama-nomic-embed",
    "apiBase": "http://localhost:4000/v1",
    "apiKey": "sk-your-secure-and-long-master-key-here"
  }
}
```

---

### C. Cline / Roo Code (VS Code Extension)

To configure the autonomous coding agent **Cline** (or **Roo Code**):

1. Click the **Cline** icon in the VS Code sidebar and open ⚙️ **Settings**.
2. **API Provider**: Select `OpenAI Compatible`.
3. **Base URL**: `http://localhost:4000/v1`
4. **API Key**: Enter your `MASTER_KEY` value from `.env`.
5. **Model ID**: Enter `claude-3-5-sonnet`, `gpt-4o`, or `groq-llama-3.3-70b`.
6. Click **Done** to save. Cline will now execute tasks through your LiteLLM gateway.

---

## 3. Terminal & CLI Tools Integration

### A. Aider Integration

[Aider](https://aider.chat/) is an AI pair-programming terminal tool that edits code across your local git repository.

#### Option 1: Direct Command-Line Invocation
```bash
export OPENAI_API_BASE="http://localhost:4000/v1"
export OPENAI_API_KEY="sk-your-secure-and-long-master-key-here"

# Start Aider with Claude 3.5 Sonnet:
aider --model openai/claude-3-5-sonnet

# Or start with ultra-fast Groq Llama 3.3:
aider --model openai/groq-llama-3.3-70b

# Or start with offline Ollama DeepSeek R1:
aider --model openai/ollama-deepseek-r1
```

#### Option 2: Project `.aider.conf.yml` File
Create an `.aider.conf.yml` file in your repository root:

```yaml
openai-api-base: http://localhost:4000/v1
openai-api-key: sk-your-secure-and-long-master-key-here
model: openai/claude-3-5-sonnet
weak-model: openai/groq-llama-3.1-8b
edit-format: diff
stream: true
```

---

### B. Claude CLI & Official SDK Redirections

To route CLI tools and third-party applications that rely on official SDK environment variables through LiteLLM:

```bash
# OpenAI SDK & CLI tools
export OPENAI_API_BASE="http://localhost:4000/v1"
export OPENAI_BASE_URL="http://localhost:4000/v1"
export OPENAI_API_KEY="sk-your-secure-and-long-master-key-here"

# LiteLLM Proxy Target
export LITELLM_BASE_URL="http://localhost:4000"
```

---

### C. Shell Functions & Helpers (Zsh / Bash)

Add this lightweight prompt helper function to your `~/.zshrc` or `~/.bashrc`:

```bash
# Instant Terminal AI Assistant
ask-llm() {
    local prompt="$*"
    local master_key="${LITELLM_KEY:-sk-your-secure-and-long-master-key-here}"
    local model="${LLM_MODEL:-gpt-4o-mini}"

    curl -s http://localhost:4000/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $master_key" \
      -d "{
        \"model\": \"$model\",
        \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}]
      }" | python3 -c "import sys, json; print(json.load(sys.stdin)['choices'][0]['message']['content'])"
}

# Example Usage:
# ask-llm "How do I filter docker container logs by timestamp in zsh?"
```

---

## 4. Web UIs & Ecosystem Platforms

### A. Open WebUI Integration

[Open WebUI](https://github.com/open-webui/open-webui) provides a ChatGPT-like web interface for your models.

#### Method 1: Add to Docker Compose
Add Open WebUI directly to your `docker-compose.yml` to run inside the same network:

```yaml
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "3000:8080"
    environment:
      - OPENAI_API_BASE_URL=http://litellm:4000/v1
      - OPENAI_API_KEY=${MASTER_KEY}
    networks:
      - litellm-network
    depends_on:
      - litellm
```

#### Method 2: Connect from an Existing Open WebUI Instance
1. Open WebUI (`http://localhost:3000`).
2. Go to **Admin Panel** -> **Settings** -> **Connections**.
3. Under **OpenAI API**:
   * **URL**: `http://localhost:4000/v1` *(or `http://litellm:4000/v1` if containerized)*
   * **Key**: Your `MASTER_KEY` from `.env`.
4. Click **Save**. All models defined in `config.yaml` will automatically appear in your model picker.

---

### B. LibreChat Integration

If using [LibreChat](https://www.librechat.ai/), add this custom endpoint entry to your `librechat.yaml`:

```yaml
endpoints:
  custom:
    - name: "LiteLLM Gateway"
      apiKey: "${MASTER_KEY}"
      baseURL: "http://host.docker.internal:4000/v1"
      models:
        default: ["gpt-4o", "claude-3-5-sonnet", "gemini-2.0-flash", "grok-2", "groq-llama-3.3-70b", "ollama-llama3.3"]
        fetch: true
      titleModel: "gpt-4o-mini"
      dropParams: ["stop"]
```

---

## 5. Code Integration Examples (SDK & cURL)

### A. Python Integration

Use the official `openai` Python SDK by pointing `base_url` to your LiteLLM instance:

```python
import os
from openai import OpenAI

# 1. Initialize LiteLLM Client
client = OpenAI(
    base_url="http://localhost:4000/v1",
    api_key="sk-your-secure-and-long-master-key-here"  # Or os.environ.get("MASTER_KEY")
)

# 2. Standard Chat Completion (GPT-4o)
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are a senior software architect."},
        {"role": "user", "content": "Explain the role of an API Gateway in microservices in 2 concise bullets."}
    ],
    temperature=0.7
)
print("🔹 Model Output:\n", response.choices[0].message.content)
print(f"💰 Token Usage: {response.usage.total_tokens}\n")

# 3. Streaming Chat Completion (Claude 3.5 Sonnet)
print("🔹 Streaming Output (Claude 3.5 Sonnet): ", end="", flush=True)
stream = client.chat.completions.create(
    model="claude-3-5-sonnet",
    messages=[
        {"role": "user", "content": "Count from 1 to 5 slowly."}
    ],
    stream=True
)

for chunk in stream:
    content = chunk.choices[0].delta.content or ""
    print(content, end="", flush=True)
print("\n")
```

---

### B. Node.js / TypeScript Integration

```typescript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'http://localhost:4000/v1',
  apiKey: process.env.MASTER_KEY || 'sk-your-secure-and-long-master-key-here',
});

async function main() {
  // Ultra-fast Groq Llama 3.3 70B Call
  const completion = await client.chat.completions.create({
    model: 'groq-llama-3.3-70b',
    messages: [{ role: 'user', content: 'State the difference between TypeScript and JavaScript in one sentence.' }],
  });

  console.log('Response:', completion.choices[0].message.content);
}

main().catch(console.error);
```

---

### C. cURL (Terminal Verification)

#### 1. Retrieve Active Models List
```bash
curl -s http://localhost:4000/v1/models \
  -H "Authorization: Bearer sk-your-secure-and-long-master-key-here" | python3 -m json.tool
```

#### 2. Chat Completion with xAI Grok 2
```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-your-secure-and-long-master-key-here" \
  -d '{
    "model": "grok-2",
    "messages": [
      {"role": "user", "content": "Provide a fascinating fact about astrophysics."}
    ]
  }'
```

#### 3. Local Offline Ollama Inference
```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-your-secure-and-long-master-key-here" \
  -d '{
    "model": "ollama-llama3.3",
    "messages": [
      {"role": "user", "content": "Hello! Are you running as a local model?"}
    ]
  }'
```
