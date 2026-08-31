# Security Policy

## Supported Versions

We issue security updates and patches for the following versions of this project:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

---

## Security Features & Best Practices

This project implements enterprise-grade security defaults for LiteLLM Proxy deployments:

### 1. Master Key Protection
- `MASTER_KEY` must always be set to a cryptographically strong random secret.
- The automated setup script (`quickstart.sh`) automatically generates a 24-byte hex key.

### 2. Virtual API Key Hashing & Storage
- LiteLLM proxy hashes all virtual keys in PostgreSQL before storing them (`STORE_MODEL_IN_DB=True`).
- Raw API key values are never stored unencrypted or exposed in logs.

### 3. Network Isolation
- The PostgreSQL database service (`db`) is attached strictly to `litellm-network` and its port (`5432`) is NOT exposed to external networks.
- Only the proxy port (`4000`) is published.

### 4. Credential Management
- Sensitive credentials (`.env`) are explicitly ignored by Git (`.gitignore`).
- Never commit `.env` files containing real API keys or passwords to version control.

---

## Reporting a Vulnerability

If you discover a security vulnerability within this repository, please report it responsibly:

1. **Do NOT open a public GitHub Issue.**
2. Send a private vulnerability report detailing the issue, severity, and steps to reproduce.
3. We will acknowledge receipt of your vulnerability report within 48 hours and provide a fix timeline.
