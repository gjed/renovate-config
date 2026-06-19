# renovate-config

Shared [Renovate](https://docs.renovatebot.com/) configuration for all [gjed](https://github.com/gjed) repositories.

## How it works

Renovate runs as a self-hosted cron job (hourly) on a local machine, using `config.js` to autodiscover all `gjed/*` repositories that contain a `renovate.json`.

## Repository structure

| File                       | Purpose                                                       |
| -------------------------- | ------------------------------------------------------------- |
| `config.js`                | Self-hosted runner config (autodiscover, platform, caching)   |
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

## Running locally

```bash
LOG_LEVEL=debug renovate --config-file=config.js
```

Requires `RENOVATE_TOKEN` env var set to a GitHub PAT with `repo` scope.
