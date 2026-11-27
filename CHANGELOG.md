# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0](https://github.com/AtaCanYmc/home-lite-llm/compare/v1.2.1...v1.3.0) (2026-11-27)


### Features

* **cli:** upgrade hlm with doctor, version, grouped help, and tests ([9d66dc9](https://github.com/AtaCanYmc/home-lite-llm/commit/9d66dc9622dc90f85d78e8149e2853546fafd3f8))
* **observability,ci:** add Grafana panels, tap bump job, and pre-commit hooks ([aeb2505](https://github.com/AtaCanYmc/home-lite-llm/commit/aeb25054fd1fc25b2492acae99100abac352566f))


### Bug Fixes

* **ci:** mount config.yaml and fail fast in bruno-smoke ([91a0d32](https://github.com/AtaCanYmc/home-lite-llm/commit/91a0d32f4310677de2cec122ee450f904ab7987e))
* **ci:** provide ephemeral LiteLLM master key ([e78906f](https://github.com/AtaCanYmc/home-lite-llm/commit/e78906fac2b031bed2e4ffb758f483cae829e3e5))
* **ci:** use minimal smoke config for ephemeral LiteLLM container ([074e30c](https://github.com/AtaCanYmc/home-lite-llm/commit/074e30c96da6935ffe46293c05941fa79a2e6a47))
* **security:** remove tainted var_name from CLI print in validate_config.py ([c343317](https://github.com/AtaCanYmc/home-lite-llm/commit/c343317618710f58d4f51fef92f613c730303a8d))


### Documentation

* add ROADMAP.md ([081190d](https://github.com/AtaCanYmc/home-lite-llm/commit/081190d090e511d751f3dac1b0dcbd7b538289dc))
* link ROADMAP.md from README.md ([fc84ac1](https://github.com/AtaCanYmc/home-lite-llm/commit/fc84ac11ccd360f17c98651ebbdbe07b561bb3ed))
* **roadmap:** structure release milestones through v1.5.0 ([1ce4a3b](https://github.com/AtaCanYmc/home-lite-llm/commit/1ce4a3b6d9361ba861c604e5dadcc440f40a4d99))

## [1.2.1](https://github.com/AtaCanYmc/home-lite-llm/compare/v1.2.0...v1.2.1) (2026-11-27)


### Bug Fixes

* **cli:** resolve symlinks in hlm and locate patch file ([7ce55c4](https://github.com/AtaCanYmc/home-lite-llm/commit/7ce55c4511afb78bcf6ebddfd3703bc25e4d572b))


### Documentation

* add release/homebrew badges, hlm CLI docs, and brew install on site ([ad38cd6](https://github.com/AtaCanYmc/home-lite-llm/commit/ad38cd6fd0b0f1eb4e8f0f60151c5f7acf68c169))

## [1.2.0](https://github.com/AtaCanYmc/home-lite-llm/compare/v1.1.1...v1.2.0) (2026-11-27)


### Features

* **cli:** add hlm CLI wrapper and make install-cli target ([193f8c4](https://github.com/AtaCanYmc/home-lite-llm/commit/193f8c493a0a18810d33ad970cbbd7c5d23a51b4))
* **collections:** add missing bruno endpoints and api tests ([431e189](https://github.com/AtaCanYmc/home-lite-llm/commit/431e1893ae9dbf57c1dcf6842b740b28c43df4d6))
* **docs:** add zero-dependency showcase and documentation site for github pages ([e5d5dab](https://github.com/AtaCanYmc/home-lite-llm/commit/e5d5dab7b7b7327d76a0a066fe1c834adfd0634e))
* **site:** upgrade website and move to site/ folder ([9dbefe0](https://github.com/AtaCanYmc/home-lite-llm/commit/9dbefe00db3cbd56e777051a4be4ee834d27f3a5))


### Bug Fixes

* **ci:** revert pages upload/deploy actions to v3/v4 ([77002a2](https://github.com/AtaCanYmc/home-lite-llm/commit/77002a2a765b622c7778724b95b6150f4e309989))
* **security:** resolve CodeQL clear-text logging and workflow permissions alerts ([69d1279](https://github.com/AtaCanYmc/home-lite-llm/commit/69d12792d224ab29a3d9bb28d1bdc901aa904c86))


### Code Refactoring

* **site:** split index.html into HTML, CSS, and JS ([ecaf03a](https://github.com/AtaCanYmc/home-lite-llm/commit/ecaf03ad08a36a7258a9e0ebd08f3672fd859fd5))


### Documentation

* add dsh to home-lite-llm integration section ([604bc61](https://github.com/AtaCanYmc/home-lite-llm/commit/604bc6170d52751731ad4fe7ce592e974ea3011b))
* add free AI coding assistants guide (OpenCode & DeepSeek Harness) ([355ddbb](https://github.com/AtaCanYmc/home-lite-llm/commit/355ddbb6627a8ee39c76b47364ba52f22ded623a))
* **diagrams:** add HTML/SVG architecture and request flow diagrams ([2fefac9](https://github.com/AtaCanYmc/home-lite-llm/commit/2fefac9cfb717f8be67f6a03e5e032f3f7aa0a71))
* **diagrams:** replace Mermaid blocks with SVG diagrams ([75e8976](https://github.com/AtaCanYmc/home-lite-llm/commit/75e8976e5292577c2fd512201b7b3716f9a61c36))
* **integrations:** add DeepSeek Harness (dsh) patch template and setup guide ([2c86967](https://github.com/AtaCanYmc/home-lite-llm/commit/2c8696785eae0ddb7d8b21174a6d1fbfec46613d))

## [1.1.1](https://github.com/AtaCanYmc/home-lite-llm/compare/v1.1.0...v1.1.1) (2026-11-16)


### Bug Fixes

* **security:** harden network bindings, disable debug logging, and enforce strict file permissions ([15f1955](https://github.com/AtaCanYmc/home-lite-llm/commit/15f1955531314ed113918c9af5e04ffb3eff3442))


### Documentation

* align repository documentation and governance with well-document standards ([f083c33](https://github.com/AtaCanYmc/home-lite-llm/commit/f083c33d55a9959752aa2bbdaaa4fe9973601e03))

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
