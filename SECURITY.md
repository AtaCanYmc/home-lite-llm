# Security Policy

## Supported Versions

Security updates and patches are issued for the following versions:

| Version | Supported |
| :--- | :--- |
| 1.x.x | Supported |
| < 1.0 | Unsupported |

---

## Security Features and Defaults

This deployment implements production hardening defaults for LiteLLM Proxy deployments:

### 1. Master Key Protection
- The `MASTER_KEY` environment variable must always be set to a cryptographically strong random secret.
- The automated setup script (`quickstart.sh`) generates a 24-byte hex key by default.

### 2. Virtual API Key Hashing and Storage
- LiteLLM proxy hashes all virtual keys in PostgreSQL before storing them (`STORE_MODEL_IN_DB=True`).
- Raw API key values are never stored unencrypted or exposed in logs.

### 3. Network Isolation
- The PostgreSQL database service (`db`) attaches strictly to `litellm-network`.
- Database port `5432` is not published to host or external networks. Only the proxy port `4000` is published.

### 4. Credential Management
- Sensitive credential files (`.env`) are explicitly ignored by Git (`.gitignore`).
- Never commit `.env` files containing real API keys or database passwords to version control.

---

## Reporting a Vulnerability

If you discover a security vulnerability within this repository, report it responsibly.

1. **Do not open a public GitHub issue.** Public issues disclose vulnerabilities before patches are available.
2. Submit a private vulnerability report via [GitHub Security Advisories](https://github.com/AtaCanYmc/home-lite-llm/security/advisories/new).
3. If GitHub Advisories is inaccessible, send a private email to `security@atacanyilmaz.com` including:
   - Impact summary and affected configuration files.
   - Exact steps or minimal proof-of-concept commands to reproduce the issue.
   - Any proposed remediation or mitigation.
4. Maintainers acknowledge receipt of vulnerability reports within 48 hours and provide a status update with expected fix timelines.
