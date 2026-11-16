# Contributing Guidelines

This document outlines the workflow, coding standards, and verification requirements for contributing to the LiteLLM Proxy setup repository.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
  - [Reporting Issues](#reporting-issues)
  - [Proposing Features](#proposing-features)
  - [Pull Request Workflow](#pull-request-workflow)
- [Local Development and Verification](#local-development-and-verification)
- [Standards and Conventions](#standards-and-conventions)

---

## Code of Conduct

All contributors and maintainers are expected to adhere to the [Code of Conduct](CODE_OF_CONDUCT.md).

---

## How to Contribute

### Reporting Issues

Search existing GitHub Issues before creating a new report. When submitting an issue:
- Use the structured [Bug Report Form](.github/ISSUE_TEMPLATE/bug_report.yml).
- Include exact terminal commands and steps required to reproduce the behavior.
- Attach sanitized container logs from `docker compose logs litellm`.
- For security vulnerabilities, follow the reporting procedure in [SECURITY.md](SECURITY.md).

### Proposing Features

Feature proposals must be submitted through the [Feature Request Form](.github/ISSUE_TEMPLATE/feature_request.yml).
- State the technical friction or limitation being solved.
- Detail the configuration schema additions or new provider targets.
- Confirm backwards compatibility with existing `.env` templates and Docker Compose definitions.

### Pull Request Workflow

1. Fork the repository and create a feature branch from `main`:
   ```bash
   git checkout -b feat/add-groq-provider
   ```
2. Implement your changes. Keep commits scoped and atomic.
3. Verify local configurations against the test suite:
   ```bash
   make validate
   make lint
   ```
4. Format commit messages following [Conventional Commits](https://www.conventionalcommits.org/):
   ```text
   feat: add support for groq mixtral models in config.yaml
   fix: correct database readiness health check probe
   docs: update integration guide with continue config
   ```
5. Push your branch and open a Pull Request against `main`. Ensure all CI checks pass.
6. Automated Releases: This repository uses Release Please. Merged pull requests formatted with Conventional Commits automatically update the Release PR, [CHANGELOG.md](CHANGELOG.md), and `.release-please-manifest.json`. Merging the automated Release PR publishes the GitHub Release and git tag.

---

## Local Development and Verification

### 1. Environment Setup
```bash
cp .env.example .env
```

### 2. Service Verification
Start the container stack in detached mode:
```bash
docker compose up -d
```

### 3. Automated Validation Suite
Execute the pre-flight validation suite before opening a pull request:
```bash
make validate
make test-models
```

---

## Standards and Conventions

- **YAML Configuration**: 2-space indentation. All new model definitions in `config.yaml` must define `model_name`, `litellm_params.model`, and reference `api_key` using `os.environ/KEY_NAME`.
- **Shell Scripts**: Follow the Google Shell Style Guide. Enforce strict exit flags (`set -euo pipefail`) in all executable scripts. Verify syntax with `bash -n <script>`.
- **Python Utilities**: Follow PEP 8 formatting. Lint all scripts with Ruff (`ruff check <file>`).
- **Documentation**: Write in GitHub-flavored Markdown. Strip all inline emojis, buzzwords, and fragmented em-dashes.
