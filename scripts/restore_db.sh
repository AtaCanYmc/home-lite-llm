#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo "❌ Error: Please specify the backup file to restore."
    echo "👉 Usage: ./scripts/restore_db.sh <path_to_backup_file.sql>"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "${BACKUP_FILE}" ]; then
    echo "❌ Error: Backup file not found: ${BACKUP_FILE}"
    exit 1
fi

echo "⚠️ Restoring database from ${BACKUP_FILE}..."
cat "${BACKUP_FILE}" | docker exec -i litellm-db psql -U postgres -d litellm

echo "✅ Database restored successfully!"
