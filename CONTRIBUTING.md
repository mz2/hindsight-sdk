# Contributing to the Hindsight SDK

Thanks for your interest in improving this Workshop SDK.

## Layout

- `sdkcraft.yaml` — SDK metadata, platforms, parts, plugs, and slots.
- `hooks/` — lifecycle scripts (`setup-base`, `setup-project`, `check-health`).
- `services/` — systemd user units for the API and web UI.
- `VERSION` — the upstream Hindsight release this branch tracks (version
  branches only; `main` carries no `VERSION`).
- `renovate.json` + `.github/workflows/` — automated version bumps and CI.

## Branching

- `main` is the template branch: it holds `renovate.json` and the Renovate
  workflow and has **no** `VERSION` file. Renovate runs from here and opens PRs
  against the version branches.
- `latest` is the version branch: it holds the `VERSION` file and the build /
  upload workflows, and **no** Renovate workflow.

## Local development

```bash
sdkcraft try --verbose            # build and stage the SDK locally
workshop launch                   # using examples/workshop.yaml (try-hindsight)
workshop shell                    # verify behaviour
sdkcraft test                     # run the spread test suites
```

Keep hook scripts idempotent — they run on every `launch` and `refresh`.
