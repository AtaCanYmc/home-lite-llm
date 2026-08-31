# Support & Troubleshooting Guide

Welcome! If you need help with your LiteLLM Proxy setup or run into issues, please use the resources below.

---

## 🔍 Common Issues & Quick Fixes

### 1. LiteLLM Proxy Fails to Connect to Database
- **Symptom**: `connection refused` or `pg_isready failed`.
- **Fix**: Check that `POSTGRES_PASSWORD` matches in `.env`. Ensure the `db` container is healthy (`docker compose ps`).

### 2. Provider API Returns 401 Unauthorized
- **Symptom**: `AuthenticationError` when calling a model.
- **Fix**: Verify that the corresponding provider API key (e.g. `OPENAI_API_KEY`, `GEMINI_API_KEY`) is uncommented and correctly filled in `.env`.

### 3. Master Key Invalid / 403 Forbidden
- **Symptom**: Requests to LiteLLM Proxy are rejected with `401/403`.
- **Fix**: Make sure your request header uses `Authorization: Bearer <MASTER_KEY>` matching the `MASTER_KEY` set in `.env`.

---

## 💬 How to Get Help

- **GitHub Issues**: Search existing [GitHub Issues](../../issues) or open a new bug report.
- **LiteLLM Official Docs**: Consult official documentation at [docs.litellm.ai](https://docs.litellm.ai).
- **Security Vulnerabilities**: For security concerns, please refer to [SECURITY.md](SECURITY.md).
