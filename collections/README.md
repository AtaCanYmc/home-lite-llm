# 📦 Ready API Test Collections (Postman & Bruno)

This directory contains ready-to-use API collections for testing and integrating with your **LiteLLM Proxy Gateway**.

---

## 📂 Structure

```text
collections/
├── postman/
│   ├── LiteLLM_Gateway.postman_collection.json         # Complete Postman Collection (v2.1)
│   └── LiteLLM_Local_Environment.postman_environment.json # Postman Environment Config
├── bruno/
│   ├── bruno.json                                      # Bruno collection manifest
│   ├── collection.bru                                  # Global Bearer token auth
│   ├── environments/
│   │   └── Local.bru                                   # Local variables (base_url, master_key)
│   ├── 01-health-check.bru                             # Health status probe
│   ├── 02-list-models.bru                              # OpenAI models list
│   ├── 03-chat-gpt4o.bru                               # GPT-4o chat completion
│   ├── 04-chat-claude.bru                              # Claude 3.5 Sonnet completion
│   ├── 05-chat-gemini.bru                              # Gemini 2.0 Flash completion
│   ├── 06-chat-deepseek.bru                            # DeepSeek Chat completion
│   ├── 07-streaming-chat.bru                           # Server-Sent Events stream
│   └── 08-generate-virtual-key.bru                     # Admin key generation
└── README.md
```

---

## 📮 Using with Postman

1. Open **Postman**.
2. Click **Import** (top left).
3. Drag and drop both:
   - `collections/postman/LiteLLM_Gateway.postman_collection.json`
   - `collections/postman/LiteLLM_Local_Environment.postman_environment.json`
4. In the top right environment dropdown, select **LiteLLM Local Gateway**.
5. Set the `master_key` variable to your generated `MASTER_KEY` from `.env`.
6. Start testing endpoints immediately!

---

## 🐶 Using with Bruno (Open-Source API Client)

1. Open **[Bruno](https://www.usebruno.com/)**.
2. Click **Open Collection**.
3. Select the folder: `collections/bruno`.
4. In Bruno, select the **Local** environment from the environment selector (top right).
5. Edit `master_key` if your proxy uses a custom key.
6. Run any request directly.

---

## 🔌 Core Endpoints Reference

| Endpoint | Method | Auth | Description |
| :--- | :---: | :---: | :--- |
| `/health` | `GET` | None | Container and database health probe |
| `/v1/models` | `GET` | Bearer | List of configured LLM models |
| `/v1/chat/completions` | `POST` | Bearer | OpenAI-compatible chat completion |
| `/metrics` | `GET` | None | Prometheus telemetry metrics |
| `/key/generate` | `POST` | Master Key | Create budgeted virtual API key |
| `/key/info` | `GET` | Master Key | Inspect virtual key metadata & spend |
| `/spend/calculate` | `POST` | Master Key | Calculate inference cost |
