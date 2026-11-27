# Roadmap

Concrete release milestones for `home-lite-llm`. Completed items link to implemented deliverables; upcoming items represent scoped engineering targets.

## v1.2.x (Released)

- [x] `hlm` CLI wrapper (`scripts/hlm`) with `up`, `down`, `health`, `validate`, `doctor`, `models`, `test-api`, `dsh`, `backup`, and `restore`
- [x] Homebrew tap distribution (`AtaCanYmc/homebrew-tap`)
- [x] Bruno API collection (`collections/bruno/`) with 17 endpoint requests and response assertions
- [x] DeepSeek Harness (`dsh`) YAML patch template (`docs/homelitellm.patch.yml`)
- [x] Static showcase site (`site/`) deployed via GitHub Pages

## v1.3.0 (Implemented on `main`)

- [x] CI execution of `scripts/test_hlm.sh` in `.github/workflows/ci.yml`
- [x] Homebrew formula `pkgshare` installation for `docs/homelitellm.patch.yml`
- [x] Automated Bruno API smoke test job (`bruno-smoke`) against ephemeral LiteLLM container in CI

## v1.4.0 (Planned)

- [ ] Per-model latency, TTFT, and HTTP 429 failover panels in Grafana dashboard (`monitoring/grafana/`)
- [ ] Automated `release-please` workflow to open a Homebrew tap bump PR on new GitHub releases
- [ ] Pre-commit hook for `scripts/test_hlm.sh` and `scripts/validate_config.py`

## v1.5.0 (Planned)

- [ ] Multi-node Ollama / vLLM load-balancing examples in `config.yaml`
- [ ] Automated PostgreSQL backup retention pruning in `scripts/backup_db.sh`
