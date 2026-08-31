#!/usr/bin/env bash
# ==============================================================================
# LiteLLM PostgreSQL Database Restore Script
# Restores database from a plain .sql or compressed .sql.gz backup file.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

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
FORCE=false
BACKUP_FILE=""

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <path_to_backup_file>

Restore the LiteLLM PostgreSQL database from a backup file (.sql or .sql.gz).

Options:
    -f, --force            Bypass interactive confirmation prompt
    -h, --help             Display this help message and exit

Arguments:
    <path_to_backup_file>  Path to the .sql or .sql.gz backup file to restore

Examples:
    $(basename "$0") backups/litellm_backup_20260901_120000.sql.gz
    $(basename "$0") --force backups/litellm_backup_20260901_120000.sql
EOF
    exit 0
}

# Parse Command Line Arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [ -z "${BACKUP_FILE}" ]; then
                BACKUP_FILE="$1"
                shift
            else
                echo "❌ Unexpected argument: $1" >&2
                usage
            fi
            ;;
    esac
done

if [ -z "${BACKUP_FILE}" ]; then
    echo "❌ Error: Please specify a backup file to restore." >&2
    usage
fi

if [ ! -f "${BACKUP_FILE}" ]; then
    echo "❌ Error: Backup file not found: ${BACKUP_FILE}" >&2
    exit 1
fi

# Verify Docker and Database Container
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker command not found." >&2
    exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -Eq "^${DB_CONTAINER}$"; then
    echo "❌ Error: Database container '${DB_CONTAINER}' is not currently running." >&2
    echo "👉 Start services first with: make up (or docker compose up -d)" >&2
    exit 1
fi

echo "=================================================="
echo "⚠️  LITELLM DATABASE RESTORE"
echo "=================================================="
echo "  • Backup File: ${BACKUP_FILE}"
echo "  • Target Container: ${DB_CONTAINER}"
echo "  • Target Database:  ${POSTGRES_DB}"
echo "  • Target User:      ${POSTGRES_USER}"
echo "=================================================="
echo "⚠️  WARNING: Restoring will overwrite existing data in '${POSTGRES_DB}'!"

if [ "$FORCE" = false ]; then
    read -r -p "Are you sure you want to proceed with restore? (yes/N): " CONFIRM
    if [[ "$CONFIRM" != "yes" && "$CONFIRM" != "YES" ]]; then
        echo "❌ Restore cancelled by user."
        exit 0
    fi
fi

echo "🔄 Restoring database..."

if [[ "${BACKUP_FILE}" == *.gz ]]; then
    gzip -dc "${BACKUP_FILE}" | docker exec -i "${DB_CONTAINER}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"
else
    docker exec -i "${DB_CONTAINER}" psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" < "${BACKUP_FILE}"
fi

echo "✅ Database restored successfully from ${BACKUP_FILE}!"
