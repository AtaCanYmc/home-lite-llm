[← Back to Root Repository](../README.md)

# Maintenance and Operational Scripts

This directory contains operations, configuration validation, and disaster recovery scripts for managing the LiteLLM Proxy Gateway deployment.

---

## Available Scripts

| Script | Purpose | Execution Syntax |
| :--- | :--- | :--- |
| [`backup_db.sh`](backup_db.sh) | Generates compressed PostgreSQL archives with automated retention rotation. | `./scripts/backup_db.sh [-k 10] [-d ./backups] [-q]` |
| [`restore_db.sh`](restore_db.sh) | Restores PostgreSQL state from `.sql` or `.sql.gz` backup files. | `./scripts/restore_db.sh [-f] <path_to_backup.sql.gz>` |
| [`validate_config.py`](validate_config.py) | Verifies `config.yaml` syntax, model schemas, fallbacks, and `.env` credentials. | `python3 scripts/validate_config.py [--strict] [--json]` |

---

## 1. Database Backup Utility (`backup_db.sh`)

### Features
- **Gzip Compression**: Compresses plain `.sql` dumps into `.sql.gz` to minimize storage footprint.
- **Automated Retention**: Retains the most recent $N$ backups (default: 10) and removes older archives automatically.
- **Environment Aware**: Sources database credentials directly from `.env` (`POSTGRES_USER`, `POSTGRES_DB`, `POSTGRES_PASSWORD`).
- **Cron Compatible**: Includes `-q` / `--quiet` mode for silent execution in recurring schedules.

### Execution Examples
```bash
# Generate standard compressed backup in ./backups/
./scripts/backup_db.sh

# Or via Makefile target:
make backup

# Specify custom destination and retain 5 archives:
./scripts/backup_db.sh -d /var/backups/litellm -k 5
```

### Automated Backups via Crontab
To run automated daily database backups at 02:00 AM:

```bash
# Open crontab editor
crontab -e

# Add cron entry (adjust path to repository location)
0 2 * * * cd /path/to/home-lite-llm && ./scripts/backup_db.sh -q >> /var/log/litellm_backup.log 2>&1
```

---

## 2. Disaster Recovery Restore Utility (`restore_db.sh`)

### Features
- **Universal Format Support**: Detects and decompresses both plain `.sql` and gzip `.sql.gz` archives.
- **Confirmation Safeguard**: Prompts for explicit confirmation prior to overwriting database state. Use `-f` to bypass prompts in automated environments.

### Execution Examples
```bash
# Interactive restore from a compressed archive
./scripts/restore_db.sh backups/litellm_backup_20260901_120000.sql.gz

# Or via Makefile target:
make restore FILE=backups/litellm_backup_20260901_120000.sql.gz
```

---

## 3. Configuration Validator (`validate_config.py`)

### Features
- **Model Schema Check**: Validates that all models in `model_list` declare valid parameters.
- **Fallback Integrity**: Verifies that every fallback target exists within the defined model inventory.
- **Credential Audit**: Flags unresolved `os.environ/KEY` variables or remaining placeholder tokens.

### Execution Examples
```bash
# Standard validation pass
python3 scripts/validate_config.py

# Strict mode: exits with non-zero status if any placeholder key remains
python3 scripts/validate_config.py --strict

# Output machine-readable JSON report for CI/CD pipelines
python3 scripts/validate_config.py --json
```
