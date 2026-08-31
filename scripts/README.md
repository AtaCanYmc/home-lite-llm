# 🛠️ LiteLLM Helper & Maintenance Scripts

This directory provides maintenance, validation, and disaster recovery utilities for the LiteLLM Proxy Gateway deployment.

---

## 📋 Available Scripts

| Script | Purpose | Key Flags / Usage |
| :--- | :--- | :--- |
| [`backup_db.sh`](file:///Users/atacan/PycharmProjects/home-lite-llm/scripts/backup_db.sh) | Creates compressed PostgreSQL dumps with automatic retention rotation. | `./scripts/backup_db.sh [-k 10] [-d ./backups] [-q]` |
| [`restore_db.sh`](file:///Users/atacan/PycharmProjects/home-lite-llm/scripts/restore_db.sh) | Restores database state from `.sql` or `.sql.gz` backup files. | `./scripts/restore_db.sh [-f] <path_to_backup.sql.gz>` |
| [`validate_config.py`](file:///Users/atacan/PycharmProjects/home-lite-llm/scripts/validate_config.py) | Verifies `config.yaml` syntax, model schemas, fallbacks, and checks `.env` keys. | `python3 scripts/validate_config.py [--strict] [--json]` |

---

## 💾 1. Database Backup Routine (`backup_db.sh`)

### Features:
- **Gzip Compression**: Compresses `.sql` to `.sql.gz` by default to minimize disk usage.
- **Automatic Retention Management**: Keeps the latest $N$ backups (default: 10) and automatically purges older archives.
- **Environment Aware**: Automatically sources database credentials (`POSTGRES_USER`, `POSTGRES_DB`, `POSTGRES_PASSWORD`) from `.env`.
- **Cron Compatible**: Includes `-q` / `--quiet` mode for silent execution in cron jobs.

### Manual Usage:
```bash
# Create standard compressed backup in ./backups/
./scripts/backup_db.sh

# Or via Makefile:
make backup

# Custom destination and retain only 5 backups:
./scripts/backup_db.sh -d /var/backups/litellm -k 5
```

### Automated Periodic Backups via Cron:
To run backups automatically every day at 02:00 AM:

1. Open your crontab editor:
   ```bash
   crontab -e
   ```
2. Add the scheduled backup entry (adjust the path to your repository location):
   ```cron
   0 2 * * * cd /path/to/home-lite-llm && ./scripts/backup_db.sh -q >> /var/log/litellm_backup.log 2>&1
   ```

---

## 🔄 2. Database Disaster Recovery (`restore_db.sh`)

### Features:
- **Universal Format Support**: Transparently handles both plain `.sql` and compressed `.sql.gz` archives.
- **Safety Confirmation**: Requires explicit confirmation before overwriting active database data (can be bypassed with `-f` for automation).

### Usage:
```bash
# Interactive restore from a compressed backup
./scripts/restore_db.sh backups/litellm_backup_20260901_120000.sql.gz

# Or via Makefile:
make restore FILE=backups/litellm_backup_20260901_120000.sql.gz

# Non-interactive / Force restore in CI/CD or automation
./scripts/restore_db.sh --force backups/litellm_backup_20260901_120000.sql.gz
```

---

## 🔍 3. Configuration Validation (`validate_config.py`)

### Features:
- Validates YAML syntax and root schema.
- Checks each model definition and target provider strings.
- Analyzes fallback chains to ensure fallback models exist in `model_list`.
- Cross-references all `os.environ/XYZ` variables in `config.yaml` against `.env` and flags missing keys or default placeholders.

### Usage:
```bash
# Run validation check
python3 scripts/validate_config.py

# Or via Makefile:
make validate

# Strict mode (fails with exit code 1 if any referenced API key is unset or placeholder)
python3 scripts/validate_config.py --strict

# Output validation report as JSON (for CI or automated pipelines)
python3 scripts/validate_config.py --json
```
