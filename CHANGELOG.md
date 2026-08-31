# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-09-01

### Added
- **Makefile Command Center**: Added full-featured `Makefile` for one-word lifecycle operations (`make up`, `make down`, `make logs`, `make validate`, `make backup`, `make restore`, `make help`).
- **Interactive Quickstart CLI**: Redesigned `quickstart.sh` with interactive terminal prompts for API key configuration, safe `.env` updater, and non-interactive flag support (`-y`).
- **Ready-to-Use API Collections**: Added Postman Collection v2.1 (`collections/postman/`) and Bruno Collections (`collections/bruno/`) for Chat Completions, Streaming, Tools, Healthchecks, and Admin Key Management.
- **Deep Configuration Validator**: Implemented `scripts/validate_config.py` for comprehensive YAML syntax, schema checks, fallback analysis, and `.env` variable cross-referencing.
- **Automated Database Backups with Retention**: Upgraded `scripts/backup_db.sh` and `scripts/restore_db.sh` with Gzip compression (`.sql.gz`), automated retention rotation (`--keep`), force restore flags, and crontab automation docs.
- **Pre-commit & Code Quality**: Added `.pre-commit-config.yaml` and `.yamllint.yml` with automated formatters and linters for YAML, Shell scripts, Python, and JSON.

## [1.0.0] - 2026-09-01

### Added
- **Docker Compose Setup**: Integrated PostgreSQL 16.8 and LiteLLM Proxy with `depends_on: service_healthy` rules.
- **Production Hardening**: Pinned Docker image tags, configured `json-file` log rotation (`max-size: 10m`), restart policies (`unless-stopped`), and isolated `litellm-network` bridge.
- **Comprehensive Model Support**: Pre-configured `config.yaml` for OpenAI, Anthropic, Gemini, DeepSeek, Mistral, Groq, Cohere, Bedrock, Azure, OpenRouter, Perplexity, Together AI, Fireworks, Ollama, and vLLM.
- **Resilience & Fallbacks**: Configured automatic provider failovers (`router_settings.fallbacks`) and retry parameters (`num_retries: 3`).
- **Observability**: Added Prometheus server integration (`monitoring/prometheus.yml`) and enabled `json_logs` and `prometheus` metrics endpoints.
- **Supabase Support**: Support for external Supabase database connection string via `.env` fallback.
- **Quickstart Setup Script**: Created automated `quickstart.sh` with dependency checks, key generation, and YAML validation.
- **Backup & Restore Scripts**: Added `scripts/backup_db.sh` and `scripts/restore_db.sh` for one-click database operations.
- **CI/CD & Security**: Configured GitHub Actions CI (`.github/workflows/ci.yml`), Dependabot (`.github/dependabot.yml`), and Security Policy (`SECURITY.md`).
