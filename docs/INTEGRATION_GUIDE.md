[← Back to Root Repository](../README.md)

# LiteLLM Proxy Integration and Developer Experience Guide

This guide provides technical specifications, configuration manifests, and code examples for integrating the local or server-hosted LiteLLM Proxy Gateway (`home-lite-llm`) across development environments, IDEs, terminal assistants, web interfaces, and custom software stacks.

---

## Table of Contents

- [Global Connection Parameters](#1-global-connection-parameters)
- [Architecture and Request Flow](#2-architecture-and-request-flow)
- [IDE and Coding Assistant Integration](#3-ide-and-coding-assistant-integration)
  - [Cursor IDE](#a-cursor-ide)
  - [Continue (VS Code and JetBrains)](#b-continue-vs-code-and-jetbrains)
  - [Cline / Roo Code (VS Code Extension)](#c-cline--roo-code-vs-code-extension)
  - [DeepSeek Harness (dsh)](#d-deepseek-harness-dsh)
- [Terminal and CLI Tooling Integration](#4-terminal-and-cli-tooling-integration)
  - [Aider Pair Programming CLI](#a-aider-pair-programming-cli)
  - [Environment Redirection for Official SDKs](#b-environment-redirection-for-official-sdks)
  - [Terminal Shell Helper](#c-terminal-shell-helper)
- [Web Interfaces and Orchestration Platforms](#5-web-interfaces-and-orchestration-platforms)
  - [Open WebUI](#a-open-webui)
  - [LibreChat](#b-librechat)
- [SDK and cURL Execution Examples](#6-sdk-and-curl-execution-examples)
  - [Python (OpenAI SDK)](#a-python-openai-sdk)
  - [Node.js / TypeScript](#b-nodejs--typescript)
  - [cURL Verification](#c-curl-verification)

---

## 1. Global Connection Parameters

LiteLLM Proxy normalizes multiple upstream AI provider interfaces into standard OpenAI-compatible REST API endpoints.

| Parameter | Host Machine (Localhost) | Docker Container Network | Description |
| :--- | :--- | :--- | :--- |
| **OpenAI Base URL** | `http://localhost:4000/v1` | `http://litellm:4000/v1` | Target endpoint for OpenAI SDKs and third-party tools |
| **Root Gateway URL** | `http://localhost:4000` | `http://litellm:4000` | Root path for metrics, UI, and diagnostics |
| **Authentication Token** | `MASTER_KEY` or Virtual Key | `Bearer sk-...` | Passed via `Authorization: Bearer <KEY>` header |
| **Admin Dashboard UI** | `http://localhost:4000/ui` | Not published | Web UI for key generation, spend tracking, and logs |
| **Readiness Healthcheck** | `http://localhost:4000/health/readiness` | `http://litellm:4000/health/readiness` | Unauthenticated status probe for proxy and database |

### Supported Model Aliases
Use any configured model alias in client requests:
- **Commercial Cloud Models**: `gpt-4o`, `gpt-4o-mini`, `o3-mini`, `claude-3-5-sonnet`, `claude-3-5-haiku`, `gemini-2.0-flash`, `gemini-1.5-pro`, `deepseek-chat`, `deepseek-reasoner`, `grok-2`, `grok-2-vision`
- **Ultra-Fast LPU Models (Groq)**: `groq-llama-3.3-70b`, `groq-llama-3.1-8b`, `groq-deepseek-r1-70b`, `groq-gemma2-9b`
- **Local / Host Models**: `ollama-llama3.3`, `ollama-deepseek-r1`, `ollama-qwen2.5`, `lmstudio-local`, `vllm-llama3`

---

## 2. Architecture and Request Flow

```mermaid
sequenceDiagram
    autonumber
    actor Client as Client / IDE / CLI
    participant Proxy as LiteLLM Gateway (:4000)
    participant DB as PostgreSQL (:5432)
    participant Provider as Upstream Provider (Cloud / Local)

    Client->>Proxy: POST /v1/chat/completions (Bearer Key, Model)
    Proxy->>DB: Validate Key and Deduct Budget
    DB-->>Proxy: Key Valid (Remaining: $9.50)
    Proxy->>Provider: Forward Request to Selected Backend
    Provider-->>Proxy: Response Stream or Token Payload
    Proxy->>DB: Record Token Consumption and Spend
    Proxy-->>Client: 200 OK (OpenAI-compatible JSON payload)
```

---

## 3. IDE and Coding Assistant Integration

### A. Cursor IDE

1. Open Cursor and navigate to **Settings** -> **Cursor Settings** -> **Models**.
2. Configure OpenAI API parameters:
   - **OpenAI API Key**: Enter `MASTER_KEY` from `.env`.
   - **Override OpenAI Base URL**: Enter `http://localhost:4000/v1`.
3. Select **Add Model** to register active models:
   - `gpt-4o`
   - `claude-3-5-sonnet`
   - `gemini-2.0-flash`
   - `groq-llama-3.3-70b`
   - `ollama-llama3.3`
4. Enable the models in Cursor settings.

---

### B. Continue (VS Code and JetBrains)

Configure `~/.continue/config.json`:

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
      "title": "LiteLLM - Groq Llama 3.3",
      "provider": "openai",
      "model": "groq-llama-3.3-70b",
      "apiBase": "http://localhost:4000/v1",
      "apiKey": "sk-your-secure-and-long-master-key-here"
    },
    {
      "title": "LiteLLM - Ollama DeepSeek R1",
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

1. Open the **Cline** panel in VS Code and click **Settings**.
2. Set **API Provider** to `OpenAI Compatible`.
3. Set **Base URL** to `http://localhost:4000/v1`.
4. Enter `MASTER_KEY` in the **API Key** input.
5. Set **Model ID** to `claude-3-5-sonnet` or `groq-llama-3.3-70b`.
6. Save and initiate tasks.

---

### D. DeepSeek Harness (`dsh`)

Use `docs/homelitellm.patch.yml` to route DeepSeek Harness (`dsh`) through `home-lite-llm` at `http://127.0.0.1:4000/v1`.

#### Quick Start (YAML Patch)

```bash
export LITELLM_API_KEY="sk-your-litellm-virtual-key"
npx @deepseek-ai/dsh web --patch docs/homelitellm.patch.yml
```

#### Verify Configuration

```bash
npx @deepseek-ai/dsh web --patch docs/homelitellm.patch.yml --dump-config
```

#### Web UI Alternative

1. Open `dsh` Web UI and go to **Settings** -> **Models** -> **Add a custom provider**.
2. Set **API Protocol** to `openai-completions`, **Base URL** to `http://127.0.0.1:4000/v1`, and enter your virtual key.

#### Security Notes

- `dsh` reads local project files and executes commands on the host where it runs. Run `dsh` on your client workstation rather than inside the `home-lite-llm` Docker Compose stack.
- For remote access, start with `npx @deepseek-ai/dsh web --no-open` and expose port `3080` only behind **Tailscale** or **Cloudflare Access**.
- Optional hardening variables: `DSH_TELEMETRY_DISABLED=1` and `DSH_PERMISSION_MODE=read-only`.

---

## 4. Terminal and CLI Tooling Integration

### A. Aider Pair Programming CLI

#### Command-Line Invocation
```bash
export OPENAI_API_BASE="http://localhost:4000/v1"
export OPENAI_API_KEY="sk-your-secure-and-long-master-key-here"

# Start with Claude 3.5 Sonnet
aider --model openai/claude-3-5-sonnet

# Start with Groq Llama 3.3
aider --model openai/groq-llama-3.3-70b

# Start with local Ollama DeepSeek R1
aider --model openai/ollama-deepseek-r1
```

#### Persistent Configuration (`.aider.conf.yml`)
```yaml
openai-api-base: http://localhost:4000/v1
openai-api-key: sk-your-secure-and-long-master-key-here
model: openai/claude-3-5-sonnet
weak-model: openai/groq-llama-3.1-8b
edit-format: diff
stream: true
```

---

### B. Environment Redirection for Official SDKs

Redirect tools using standard OpenAI environment variables to LiteLLM:

```bash
export OPENAI_API_BASE="http://localhost:4000/v1"
export OPENAI_BASE_URL="http://localhost:4000/v1"
export OPENAI_API_KEY="sk-your-secure-and-long-master-key-here"
export LITELLM_BASE_URL="http://localhost:4000"
```

---

### C. Terminal Shell Helper

Add this function to `~/.zshrc` or `~/.bashrc` for terminal LLM queries:

```bash
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
```

---

## 5. Web Interfaces and Orchestration Platforms

### A. Open WebUI

#### Docker Compose Integration
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

#### External Connection Configuration
1. Navigate to Open WebUI at `http://localhost:3000`.
2. Open **Admin Panel** -> **Settings** -> **Connections**.
3. Under **OpenAI API**:
   - Set **URL** to `http://localhost:4000/v1`.
   - Set **Key** to `MASTER_KEY`.
4. Save settings. Models will appear in the model picker.

---

### B. LibreChat

Configure custom endpoints in `librechat.yaml`:

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

## 6. SDK and cURL Execution Examples

### A. Python (OpenAI SDK)

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:4000/v1",
    api_key=os.environ.get("MASTER_KEY", "sk-your-secure-and-long-master-key-here")
)

# Standard Completion
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are a systems engineer."},
        {"role": "user", "content": "Explain reverse proxy architecture in two sentences."}
    ],
    temperature=0.7
)
print("Response:\n", response.choices[0].message.content)
print("Tokens used:", response.usage.total_tokens)

# Streaming Completion
stream = client.chat.completions.create(
    model="claude-3-5-sonnet",
    messages=[
        {"role": "user", "content": "Count from 1 to 5."}
    ],
    stream=True
)

for chunk in stream:
    token = chunk.choices[0].delta.content or ""
    print(token, end="", flush=True)
print()
```

---

### B. Node.js / TypeScript

```typescript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'http://localhost:4000/v1',
  apiKey: process.env.MASTER_KEY || 'sk-your-secure-and-long-master-key-here',
});

async function main() {
  const completion = await client.chat.completions.create({
    model: 'groq-llama-3.3-70b',
    messages: [
      { role: 'user', content: 'Explain high-throughput LPU inference in one sentence.' }
    ],
  });

  console.log('Response:', completion.choices[0].message.content);
}

main().catch(console.error);
```

---

### C. cURL Verification

#### List Models
```bash
curl -s http://localhost:4000/v1/models \
  -H "Authorization: Bearer sk-your-secure-and-long-master-key-here" | python3 -m json.tool
```

#### Chat Completion via xAI Grok 2
```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-your-secure-and-long-master-key-here" \
  -d '{
    "model": "grok-2",
    "messages": [
      {"role": "user", "content": "Provide a summary of orbital mechanics in two bullets."}
    ]
  }'
```

#### Local Offline Ollama Inference
```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-your-secure-and-long-master-key-here" \
  -d '{
    "model": "ollama-llama3.3",
    "messages": [
      {"role": "user", "content": "Confirm local inference connectivity."}
    ]
  }'
```
