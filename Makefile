# ==============================================================================
# LiteLLM Gateway Management Makefile
# Convenience commands for container lifecycle, configuration, tests, and backups
# ==============================================================================

.PHONY: help up start down stop restart status ps logs logs-litellm logs-db logs-grafana logs-prometheus build clean validate quickstart backup restore health test-models lint

# Default target when invoking `make` without arguments
.DEFAULT_GOAL := help

# Colors for terminal styling
CYAN   := \033[36m
GREEN  := \033[32m
YELLOW := \033[33m
RED    := \033[31m
RESET  := \033[0m
BOLD   := \033[1m

## 📋 Help & Information
help: ## Display this help menu of available commands
	@echo ""
	@echo "$(BOLD)$(CYAN)======================================================$(RESET)"
	@echo "$(BOLD)$(CYAN)       LiteLLM Gateway — Command Center               $(RESET)"
	@echo "$(BOLD)$(CYAN)======================================================$(RESET)"
	@echo ""
	@echo "Usage: $(BOLD)make [target]$(RESET)"
	@echo ""
	@echo "$(BOLD)$(YELLOW)🚀 Lifecycle Management:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## Lifecycle: .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## Lifecycle: "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BOLD)$(YELLOW)📊 Monitoring & Logs:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## Logs: .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## Logs: "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BOLD)$(YELLOW)🔍 Diagnostics & Validation:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## Diagnostics: .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## Diagnostics: "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BOLD)$(YELLOW)💾 Database & Maintenance:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## Maintenance: .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## Maintenance: "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""

## 🚀 Lifecycle Management
up: ## Lifecycle: Start all containers in background
	@echo "🚀 Starting LiteLLM Gateway services..."
	docker compose up -d

start: up ## Lifecycle: Alias for 'up'

down: ## Lifecycle: Stop and remove all running containers
	@echo "🛑 Stopping LiteLLM Gateway services..."
	docker compose down

stop: down ## Lifecycle: Alias for 'down'

restart: ## Lifecycle: Restart all containers
	@echo "🔄 Restarting LiteLLM Gateway services..."
	docker compose restart

build: ## Lifecycle: Rebuild images and start containers
	@echo "🔨 Rebuilding and starting services..."
	docker compose up -d --build

clean: ## Lifecycle: Stop services and remove persistent data volumes (CAUTION)
	@echo "$(RED)⚠️  Stopping services and removing all persistent volumes...$(RESET)"
	docker compose down -v

quickstart: ## Lifecycle: Run the interactive quickstart wizard
	@chmod +x quickstart.sh
	@./quickstart.sh

## 📊 Monitoring & Logs
ps: ## Logs: Show status of running containers
	docker compose ps

status: ps ## Logs: Alias for 'ps'

logs: ## Logs: Follow live logs for all containers
	docker compose logs -f

logs-litellm: ## Logs: Follow live logs for LiteLLM proxy container
	docker compose logs -f litellm

logs-db: ## Logs: Follow live logs for PostgreSQL database container
	docker compose logs -f db

logs-grafana: ## Logs: Follow live logs for Grafana analytics container
	docker compose logs -f grafana

logs-prometheus: ## Logs: Follow live logs for Prometheus collector container
	docker compose logs -f prometheus

## 🔍 Diagnostics & Validation
validate: ## Diagnostics: Validate config.yaml syntax and check API keys against .env
	@python3 scripts/validate_config.py

health: ## Diagnostics: Check LiteLLM proxy health endpoint (http://localhost:4000/health)
	@echo "🩺 Checking LiteLLM Proxy health..."
	@curl -s -f http://localhost:4000/health && echo "\n$(GREEN)✅ LiteLLM Proxy is healthy!$(RESET)" || (echo "\n$(RED)❌ LiteLLM Proxy is unreachable!$(RESET)" && exit 1)

test-models: ## Diagnostics: Query available models from LiteLLM proxy
	@echo "🤖 Querying active models list..."
	@if [ -f .env ]; then \
		KEY=$$(grep -E '^MASTER_KEY=' .env | cut -d '=' -f2- | tr -d '"'\'''); \
		curl -s -H "Authorization: Bearer $$KEY" http://localhost:4000/v1/models | python3 -m json.tool || echo "$(RED)❌ Failed to fetch models$(RESET)"; \
	else \
		curl -s http://localhost:4000/v1/models | python3 -m json.tool || echo "$(RED)❌ Failed to fetch models$(RESET)"; \
	fi

lint: ## Diagnostics: Run pre-commit checks on repository
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit run --all-files; \
	else \
		echo "$(YELLOW)pre-commit not installed. Running Python config validation instead...$(RESET)"; \
		python3 scripts/validate_config.py; \
	fi

## 💾 Database & Maintenance
backup: ## Maintenance: Create timestamped compressed PostgreSQL backup
	@chmod +x scripts/backup_db.sh
	@./scripts/backup_db.sh

restore: ## Maintenance: Restore database from a backup file (Usage: make restore FILE=backups/xxx.sql.gz)
	@chmod +x scripts/restore_db.sh
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)❌ Error: Please specify backup file with FILE=<path>$(RESET)"; \
		echo "👉 Example: make restore FILE=backups/litellm_backup_20260901_120000.sql.gz"; \
		exit 1; \
	fi
	@./scripts/restore_db.sh $(FILE)
