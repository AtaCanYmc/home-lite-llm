#!/usr/bin/env bash
# ==============================================================================
# LiteLLM PostgreSQL Database Backup Script
# Creates compressed timestamped database dumps and manages backup retention.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Configuration Defaults
BACKUP_DIR="${PROJECT_ROOT}/backups"
KEEP_BACKUPS=10
COMPRESS=true
QUIET=false
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Load environment variables if .env exists
if [ -f "${PROJECT_ROOT}/.env" ]; then
    # shellcheck disable=SC1091
    set -a
    source "${PROJECT_ROOT}/.env"
    set +a
fi

DB_CONTAINER="${DB_CONTAINER:-litellm-db}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-litellm}"

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Create a timestamped backup of the LiteLLM PostgreSQL database.

Options:
    -d, --dir DIR          Set backup destination directory (default: ./backups)
    -k, --keep NUM         Number of most recent backups to retain (default: 10, 0 to disable)
    --no-compress          Do not gzip compress the backup file
    -q, --quiet            Quiet mode (suppress informative output, errors still shown)
    -h, --help             Display this help message and exit

Environment Variables:
    POSTGRES_USER          Database superuser (default from .env: postgres)
    POSTGRES_DB            Database name (default from .env: litellm)
    DB_CONTAINER           PostgreSQL container name (default: litellm-db)
    KEEP_BACKUPS           Number of backups to keep (default: 10)

Example Crontab:
    0 2 * * * cd /path/to/home-lite-llm && ./scripts/backup_db.sh -q >> /var/log/litellm_backup.log 2>&1
EOF
    exit 0
}

# Parse Command Line Flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            BACKUP_DIR="$2"
            shift 2
            ;;
        -k|--keep)
            KEEP_BACKUPS="$2"
            shift 2
            ;;
        --no-compress)
            COMPRESS=false
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "❌ Unknown option: $1" >&2
            usage
            ;;
    esac
done

log() {
    if [ "$QUIET" = false ]; then
        echo "$@"
    fi
}

# 1. Verify Docker is running and container exists
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker command not found." >&2
    exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -Eq "^${DB_CONTAINER}$"; then
    echo "❌ Error: Database container '${DB_CONTAINER}' is not currently running." >&2
    echo "👉 Start services first with: make up (or docker compose up -d)" >&2
    exit 1
fi

# 2. Prepare Backup Directory
mkdir -p "${BACKUP_DIR}"

# 3. Perform Database Dump
log "📦 Creating PostgreSQL backup from container '${DB_CONTAINER}'..."
log "   Database: ${POSTGRES_DB} | User: ${POSTGRES_USER}"

if [ "$COMPRESS" = true ]; then
    BACKUP_FILE="${BACKUP_DIR}/litellm_backup_${TIMESTAMP}.sql.gz"
    if docker exec "${DB_CONTAINER}" pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" | gzip > "${BACKUP_FILE}"; then
        FILE_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
        log "✅ Database backup created: ${BACKUP_FILE} (${FILE_SIZE})"
    else
        echo "❌ Error: Database backup failed!" >&2
        rm -f "${BACKUP_FILE}"
        exit 1
    fi
else
    BACKUP_FILE="${BACKUP_DIR}/litellm_backup_${TIMESTAMP}.sql"
    if docker exec "${DB_CONTAINER}" pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" > "${BACKUP_FILE}"; then
        FILE_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
        log "✅ Database backup created: ${BACKUP_FILE} (${FILE_SIZE})"
    else
        echo "❌ Error: Database backup failed!" >&2
        rm -f "${BACKUP_FILE}"
        exit 1
    fi
fi

# 4. Backup Retention Management (Pruning Old Backups)
if [ "${KEEP_BACKUPS}" -gt 0 ]; then
    BACKUP_COUNT=$(find "${BACKUP_DIR}" -maxdepth 1 -name "litellm_backup_*.sql*" | wc -l | tr -d ' ')
    if [ "${BACKUP_COUNT}" -gt "${KEEP_BACKUPS}" ]; then
        log "🧹 Rotating old backups (keeping latest ${KEEP_BACKUPS} backups)..."
        # Find files sorted by modified date (oldest first) and remove excess
        find "${BACKUP_DIR}" -maxdepth 1 -name "litellm_backup_*.sql*" -type f | sort | head -n -"${KEEP_BACKUPS}" | while read -r old_backup; do
            log "   Removing old backup: $(basename "$old_backup")"
            rm -f "$old_backup"
        done
        log "✅ Backup rotation complete."
    fi
fi

log "🎉 All operations completed successfully."
exit 0
