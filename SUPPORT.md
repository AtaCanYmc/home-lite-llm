# Support and Troubleshooting Guide

This guide covers operational debugging procedures, diagnostic commands, and support channels for the LiteLLM Proxy Gateway deployment.

---

## Diagnostic Commands

Run these commands first when diagnosing service failures:

```bash
# Check container status and healthchecks
docker compose ps

# Run full configuration and environment validation
make validate

# Inspect live container logs for LiteLLM
docker compose logs --tail=100 -f litellm

# Inspect live database logs
docker compose logs --tail=100 -f db
```

---

## Common Issues and Remediation

### 1. LiteLLM Fails to Connect to Database
- **Symptom**: LiteLLM logs show `connection refused` or `pg_isready` returns non-zero.
- **Cause**: Database container is still initializing, or password credentials differ between `.env` and PostgreSQL persistent volume.
- **Remediation**: Check `docker compose ps` to verify `db` is healthy. Verify `POSTGRES_PASSWORD` in `.env`. For fresh setups with password changes, run `make clean && make up` to reset the volume.

### 2. Provider API Returns 401 Unauthorized
- **Symptom**: Client calls fail with `AuthenticationError: Invalid API Key`.
- **Cause**: The upstream provider key in `.env` is missing, commented out, or contains placeholder text (`your_openai_api_key_here`).
- **Remediation**: Run `make validate` to audit `.env` keys. Populate the matching provider key in `.env` and restart the proxy with `docker compose restart litellm`.

### 3. Master Key Invalid or 403 Forbidden
- **Symptom**: Client requests to LiteLLM Proxy are rejected with HTTP `401 Unauthorized` or `403 Forbidden`.
- **Cause**: Client request headers do not match `MASTER_KEY` configured in `.env`.
- **Remediation**: Pass `Authorization: Bearer <MASTER_KEY>` in the client request. Verify the active key using `docker compose exec litellm printenv MASTER_KEY`.

### 4. Local Host Models (Ollama / LM Studio) Unreachable
- **Symptom**: HTTP 500 or connection errors when routing to `ollama-*` or `lmstudio-local`.
- **Cause**: Docker container cannot resolve host services via `localhost`.
- **Remediation**: Verify `OLLAMA_API_BASE` is set to `http://host.docker.internal:11434` and that Ollama is bound to `0.0.0.0` or accepting connections from Docker network bridges (`OLLAMA_HOST=0.0.0.0`).

---

## Support Channels

- **Issue Tracker**: Submit bugs or reproducible defects via [GitHub Issues](https://github.com/AtaCanYmc/home-lite-llm/issues).
- **Discussions**: Ask architecture and configuration questions on [GitHub Discussions](https://github.com/AtaCanYmc/home-lite-llm/discussions).
- **Official Documentation**: Upstream LiteLLM architecture and router parameters are documented at [docs.litellm.ai](https://docs.litellm.ai).
- **Security Inquiries**: For vulnerability disclosures, refer strictly to [SECURITY.md](SECURITY.md).
