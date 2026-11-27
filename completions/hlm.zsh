#compdef hlm

_hlm() {
  local -a commands
  commands=(
    'up:Start all services in background'
    'down:Stop all services'
    'restart:Restart all services'
    'status:Show container status'
    'logs:Follow logs'
    'health:Check LiteLLM readiness endpoint'
    'validate:Validate config.yaml and .env'
    'doctor:Check local dependencies and config files'
    'models:List active models from LiteLLM'
    'test-api:Run Bruno API endpoint tests'
    'dsh:Launch DeepSeek Harness (dsh)'
    'version:Print hlm version'
    'backup:Create PostgreSQL backup'
    'restore:Restore PostgreSQL backup from file'
    'help:Show help'
  )
  _describe 'command' commands
}

_hlm "$@"
