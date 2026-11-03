# renovate-config

Shared [Renovate](https://docs.renovatebot.com/) configuration for all [gjed](https://github.com/gjed) repositories.

## How it works

Renovate runs hourly from a GitHub Actions workflow (`.github/workflows/renovate.yml`) as the `gjed-renovate` GitHub App, using `config.js` to autodiscover all `gjed/*` repositories that contain a `renovate.json`. The app is a ruleset bypass actor (`bypass_mode: pull_request`) in [github-configs-public](https://github.com/gjed/github-configs-public), which is what lets it merge its own PRs.

## Repository structure

| File                       | Purpose                                                       |
| -------------------------- | ------------------------------------------------------------- |
| `config.js`                | Self-hosted runner config (autodiscover, platform, app auth)  |
| `.github/workflows/`       | Hourly Renovate run, authenticated as the GitHub App          |
| `default.json`             | Shareable preset — extend this in your repo's `renovate.json` |
| `automerge.json`           | Auto-merge all minor and patch updates; block majors          |
| `labels.json`              | PR labels: `dependencies`, `renovate`                         |
| `semanticCommits.json`     | Enforce semantic commit messages                              |
| `vulnerabilityAlerts.json` | Immediate alerts for CVEs, no automerge                       |
| `renovate.json`            | Self-referential config for this repo                         |

## Onboarding a new repository

Add a `renovate.json` at the root of the target repo:

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["github>gjed/renovate-config:default"]
}
```

Renovate will pick it up on the next hourly run.

## Automerge policy

- **Minor and patch**: auto-merged for all dependency types
- **Pin updates**: auto-merged
- **Major updates**: PR created, manual review required
- **Vulnerability alerts**: PR created immediately, manual review required

## Running manually

Trigger the workflow from the Actions tab or with `gh workflow run renovate.yml -R gjed/renovate-config`.

## GitHub App credentials

The workflow mints a short-lived installation token on each run from the `renovate` environment, which only accepts runs from protected branches:

| Name                       | Kind     | Value                                |
| -------------------------- | -------- | ------------------------------------ |
| `RENOVATE_APP_CLIENT_ID`   | variable | Client ID of the `gjed-renovate` app |
| `RENOVATE_APP_PRIVATE_KEY` | secret   | Private key (PEM) of the app         |

## Local runs

```bash
make run          # autodiscover all gjed repos
make dry-run      # dry-run, no PRs created
make run-repo REPO=gjed/my-repo   # single repo
```

Local runs authenticate with your personal token (`gh auth token`), not the app, so PRs are authored as you and commits are unsigned. Use `make dry-run` for debugging only.
