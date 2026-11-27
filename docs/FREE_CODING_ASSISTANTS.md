[← Back to Root Repository](../README.md)

# Free AI Coding Assistants (OpenCode & DeepSeek Harness)

Setup and YAML patch configurations for running free AI coding assistants via OpenCode (`DeepSeek-V4.1-Flash` promo) and DeepSeek Harness (`dsh`) with local Ollama (`qwen3.8`) or OpenRouter `:free` models.

> **Freshness (as of 2026-11-21):** OpenCode's `$0` `DeepSeek-V4.1-Flash` tier is promotional (200K context / 32K output); `ollama launch dsh` requires Ollama `v0.32.11+`.

---

## Summary Comparison

| Tool | Cost | Execution Mode | Key Feature |
| :--- | :--- | :--- | :--- |
| **OpenCode + V4.1-Flash** | `$0` (Promotional, as of 2026-11-21) | Terminal Agent | No API key required, 200K context |
| **DeepSeek Harness (`dsh`)** | Free (MIT) | Web UI / Desktop / JetBrains | Plugin architecture, Ollama & OpenRouter support |
| **DeepSeek Web / App** | Free | Browser / Mobile | Latest `V4.1-Flash`, vision support |

---

## 1. OpenCode with Free DeepSeek-V4.1-Flash

Practical terminal coding assistant without an API key or local GPU hardware.

```bash
npm install -g opencode-ai
cd /path/to/your/project
opencode
```

### Model Selection

Inside OpenCode, run `/models` and activate `DeepSeek V4.1 Flash Free`.

- **Limits (as of 2026-11-21):** 200K context, 32K output (free only inside OpenCode during the promotional period).

---

## 2. DeepSeek Harness (`dsh`) + Local Ollama

### A) Quick Setup (Ollama `v0.32.11+`)

Ollama installs the `dsh` package automatically and writes settings to `~/.ollama/launch/dsh/settings.yaml`.

```bash
# 1. Pull the model
ollama pull qwen3.8

# 2. Launch DSH UI (http://127.0.0.1:3080)
ollama launch dsh --model qwen3.8
```

### B) Full Control (YAML Patch)

Install globally:

```bash
npm install -g @deepseek-ai/dsh@latest
```

Create `ollama.patch.yml`:

```yaml
- id: llm-pi-ai
  config:
    providers:
      ollama:
        displayName: Ollama (Local)
        api: openai-completions
        baseURL: http://127.0.0.1:11434/v1
        apiKeyEnv: OLLAMA_API_KEY
        compat:
          supportsDeveloperRole: false
          maxTokensField: max_tokens
        models:
          - id: qwen3.8
            contextWindow: 32768
```

Verify and start:

```bash
export OLLAMA_API_KEY=ollama

# Test configuration
dsh web --patch ./ollama.patch.yml --dump-config | grep -A12 "ollama"

# Start Web UI
dsh web --patch ./ollama.patch.yml
```

---

## 3. DeepSeek Harness (`dsh`) + OpenRouter Free Models

### A) Via Web UI

1. Open `http://127.0.0.1:3080` with `dsh web`.
2. Navigate to **Settings → Models → Add a custom provider**:
   - **Provider ID:** `openrouter`
   - **API Protocol:** `openai-completions`
   - **Base URL:** `https://openrouter.ai/api/v1`
   - **API Key:** Your OpenRouter API key
3. Click **Fetch available models**, select models ending with `:free`, and save.

### B) Via YAML Patch

Create `openrouter.patch.yml`:

```yaml
- id: llm-pi-ai
  config:
    providers:
      openrouter:
        displayName: OpenRouter (Free)
        api: openai-completions
        baseURL: https://openrouter.ai/api/v1
        apiKeyEnv: OPENROUTER_API_KEY
        models:
          - id: openrouter/free
            contextWindow: 128000
```

Start:

```bash
export OPENROUTER_API_KEY="sk-or-v1-..."
dsh web --patch ./openrouter.patch.yml
```

### Privacy and Security Settings

Set these optional environment variables before running `dsh web` to disable telemetry and start the agent in read-only mode:

```bash
export DSH_TELEMETRY_DISABLED=1
export DSH_PERMISSION_MODE=read-only
```

---

## 4. Apple Silicon (24 GB RAM / M5 Pro) Ollama Memory & Speed Tuning

Recommended server settings from [Ollama Local FAQ](https://docs.ollama.com/faq) and [Ollama FAQ (GitHub)](https://github.com/ollama/ollama/blob/main/docs/faq.mdx) (as of 2026-11-21) to maintain 32K context without swapping on 24 GB Unified Memory:

| Variable | Value | Purpose |
| :--- | :--- | :--- |
| `OLLAMA_FLASH_ATTENTION` | `1` | Reduces memory usage as context grows; required for KV cache quantization. |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | Halves KV cache memory vs default `f16` while preserving coding quality. |
| `OLLAMA_NUM_PARALLEL` | `1` | Saves RAM for single-user workloads since memory scales with `NUM_PARALLEL × CONTEXT_LENGTH`. |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Keeps only one model in memory at a time to prevent swap. |
| `OLLAMA_CONTEXT_LENGTH` | `32768` | Ideal for 7B–14B Q4 models; reduce to `16384` if swapping occurs on larger models. |
| `OLLAMA_KEEP_ALIVE` | `10m` | Keeps the model warm during active sessions and frees RAM when idle. |

### macOS App Configuration (`launchctl`)

The Ollama menu bar app does not read `export` lines from `~/.zshrc`. Set variables with `launchctl setenv` and restart Ollama:

```bash
launchctl setenv OLLAMA_FLASH_ATTENTION "1"
launchctl setenv OLLAMA_KV_CACHE_TYPE "q8_0"
launchctl setenv OLLAMA_NUM_PARALLEL "1"
launchctl setenv OLLAMA_MAX_LOADED_MODELS "1"
launchctl setenv OLLAMA_CONTEXT_LENGTH "32768"
launchctl setenv OLLAMA_KEEP_ALIVE "10m"
```

### `dsh` Alignment & Verification

- Keep `contextWindow` in `ollama.patch.yml` equal to `OLLAMA_CONTEXT_LENGTH` (`32768`, or `16384` if needed).
- After the first request, run `ollama ps` and verify the `PROCESSOR` column shows `100% GPU`. If it shows a CPU/GPU split, lower context to `16384`.

---

## 5. DeepSeek Harness (`dsh`) Architecture & Resources (2026-11-27)

- **Official Repository & Docs:** [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) (MIT) · [Documentation](https://deepseek-harness.github.io/deepseek-harness/)
- **Core Architecture:** `everything-is-a-plugin` design built on the [Cordis](https://github.com/cordiverse/cordis) plugin kernel (*A Programming Paradigm for Spatiotemporal Composability*, arXiv:2608.25512).
- **Developer Preview Warning:** Rapid iteration means breaking changes are expected. Review `SAFETY.md` before running.
- **Run Options:**
  - `npx @deepseek-ai/dsh web` (`http://127.0.0.1:3080`, use `--no-open` for SSH/headless).
  - From source: `pnpm install && pnpm run build && pnpm dsh web` (`pnpm run dev:web` for development, `make help` for targets).
- **Key `docs/` Modules:** `architecture.md`, `cordis-primer.md`, `agent-lifecycle.md`, `tool-execution-pipeline.md`, `capability-seams.md`, `persistence-catalog.md`, `session-format-status.md`, `defensive-patterns/`, `cookbook/`, `subsystems/`, and `AGENTS.md` (search `dsh-plugin` on GitHub for plugins).
