#!/usr/bin/env bash
set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/litellm_backup_${TIMESTAMP}.sql"

mkdir -p "${BACKUP_DIR}"

echo "📦 Creating PostgreSQL database backup..."
docker exec litellm-db pg_dump -U postgres litellm > "${BACKUP_FILE}"

echo "✅ Database backup created successfully: ${BACKUP_FILE}"
