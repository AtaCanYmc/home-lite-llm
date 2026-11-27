[← Back to Root Repository](../README.md)

# Ready API Test Collections (Postman and Bruno)

This directory contains pre-configured API collections for testing and validating endpoints exposed by the LiteLLM Proxy Gateway.

---

## Directory Structure

```text
collections/
├── postman/
│   ├── LiteLLM_Gateway.postman_collection.json         # Postman collection (v2.1)
│   └── LiteLLM_Local_Environment.postman_environment.json # Postman local environment config
├── bruno/
│   ├── bruno.json                                      # Bruno collection manifest
│   ├── collection.bru                                  # Global Bearer token auth and default variables
│   ├── environments/
│   │   └── Local.bru                                   # Local environment variables
│   ├── 01-health-check.bru                             # Health status probe
│   ├── 02-list-models.bru                              # OpenAI models list
│   ├── 03-chat-gpt4o.bru                               # GPT-4o chat completion
│   ├── 04-chat-claude.bru                              # Claude 3.5 Sonnet completion
│   ├── 05-chat-gemini.bru                              # Gemini 2.0 Flash completion
│   ├── 06-chat-deepseek.bru                            # DeepSeek Chat completion
│   ├── 07-chat-grok.bru                                # xAI Grok 2 completion
│   ├── 08-chat-groq.bru                                # Groq Llama 3.3 70B completion
│   ├── 09-chat-local-ollama.bru                        # Ollama local inference
│   ├── 10-chat-local-lmstudio.bru                      # LM Studio local inference
│   ├── 11-chat-local-vllm.bru                          # vLLM GPU inference server
│   ├── 12-streaming-chat.bru                           # Server-Sent Events stream
│   ├── 13-generate-virtual-key.bru                     # Admin key generation
│   ├── 14-health-readiness.bru                         # Container readiness probe
│   ├── 15-metrics.bru                                  # Prometheus metrics
│   ├── 16-key-info.bru                                 # Virtual key metadata
│   └── 17-spend-calculate.bru                          # Token cost calculation
└── README.md
```

---

## Postman Usage

1. Open Postman.
2. Select **Import**.
3. Drag and drop both collection files:
   - `collections/postman/LiteLLM_Gateway.postman_collection.json`
   - `collections/postman/LiteLLM_Local_Environment.postman_environment.json`
4. In the environment selector, choose **LiteLLM Local Gateway**.
5. Set the `master_key` variable to match the `MASTER_KEY` defined in `.env`.
6. Execute requests directly against `http://localhost:4000`.

---

## Bruno Usage

1. Launch [Bruno](https://www.usebruno.com/).
2. Select **Open Collection**.
3. Choose the directory: `collections/bruno`.
4. Select the **Local** environment from the top right environment picker.
5. Update `master_key` if a custom virtual key is used.
6. Execute requests.

---

## Endpoint Reference

| Endpoint | HTTP Method | Authentication | Purpose |
| :--- | :--- | :--- | :--- |
| `/health` | `GET` | Optional | Container and database health status |
| `/health/readiness` | `GET` | None | Kubernetes and Docker readiness check |
| `/v1/models` | `GET` | Bearer Token | Array of configured and available models |
| `/v1/chat/completions` | `POST` | Bearer Token | OpenAI-compatible chat completions |
| `/metrics` | `GET` | None | Prometheus telemetry metrics |
| `/key/generate` | `POST` | Master Key | Generate virtual API keys with spend budgets |
| `/key/info` | `GET` | Master Key | Inspect virtual key metadata and spend |
| `/spend/calculate` | `POST` | Master Key | Compute per-request token costs |
