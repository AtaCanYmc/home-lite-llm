# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
