# Roadmap

Concrete milestones grouped by release version.

## v1.2.x (Current)

- [x] `hlm` CLI wrapper (`up`, `down`, `health`, `validate`, `doctor`, `models`, `test-api`, `dsh`, `backup`, `restore`)
- [x] Homebrew tap formula (`AtaCanYmc/homebrew-tap`)
- [x] Bruno API collection with 17 endpoint requests and response assertions
- [x] DeepSeek Harness (`dsh`) YAML patch template (`docs/homelitellm.patch.yml`)
- [x] Static showcase site in `site/` deployed to GitHub Pages

## v1.3.0

- [x] CI execution of `scripts/test_hlm.sh` in `.github/workflows/ci.yml`
- [x] Homebrew formula `pkgshare` installation for `docs/homelitellm.patch.yml`
- [x] Automated Bruno API smoke test job against ephemeral LiteLLM container in CI

## v1.4.0

- [ ] Per-model latency and error-rate panels in Grafana dashboard
- [ ] Automated `release-please` trigger to open Homebrew tap bump PR on tag
