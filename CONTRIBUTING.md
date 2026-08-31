# Contributing to LiteLLM Proxy Setup

First off, thank you for considering contributing to this repository! Contributions make open-source projects a fantastic place to learn, inspire, and create.

---

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Development Workflow](#development-workflow)
- [Coding Standards & Style Guide](#coding-standards--style-guide)

---

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, please include:
- A clear and descriptive title.
- Steps to reproduce the problem.
- Expected behavior vs. actual behavior.
- Relevant log output from `docker compose logs litellm`.

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub Issues. Please include:
- A clear, descriptive title.
- A detailed explanation of the proposed feature.
- Use cases or benefits to the project.

### Pull Requests

1. Fork the repository.
2. Create a new topic branch: `git checkout -b feature/amazing-feature`.
3. Make your changes and verify that:
   - `config.yaml` is valid YAML.
   - `quickstart.sh` passes `bash -n quickstart.sh`.
   - `docker compose config` exits with code 0.
4. Commit your changes with a clear commit message: `git commit -m 'feat: add support for new provider'`.
5. Push to your branch: `git push origin feature/amazing-feature`.
6. Open a Pull Request against `main`.

---

## Development Workflow

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Test local changes with Docker Compose:
   ```bash
   docker compose up -d
   ```
3. Run syntax checks locally:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"
   bash -n quickstart.sh
   docker compose config
   ```

---

## Coding Standards & Style Guide

- **YAML Formatting**: Use 2 spaces for indentation. Include descriptive comments for new models or configuration directives.
- **Bash Scripts**: Follow Google Shell Style Guide. Use `set -e` at the top of executable scripts.
- **Documentation**: Keep documentation in clean, GitHub-flavored Markdown. Ensure all file paths and symbols are accurately linked.
