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
| `gomod.json`               | Go: rewrite import paths on majors, run `go mod tidy`         |
| `labels.json`              | PR labels: `dependencies`, `renovate`                         |
| `releaseAge.json`          | Hold npm updates for 1 day (pnpm's `minimumReleaseAge`)       |
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

## Go modules

`gomod.json` sets `postUpdateOptions: ["gomodTidy", "gomodUpdateImportPaths"]` for the `gomod` manager. Without them a major bump such as `go.yaml.in/yaml/v3` to `v4` only edits `go.mod`: the new module is added unused, the old one stays imported, and the PR needs the import migration done by hand. With them Renovate rewrites the imports to the new major path and tidies `go.mod` and `go.sum`. Code that relies on changed behaviour of the new major still needs fixing in the PR.

## Release age policy

pnpm (v11+) refuses lockfile entries published less than 1 day ago, so a fresh npm bump fails `pnpm install --frozen-lockfile` until the release is a day old. `releaseAge.json` makes Renovate wait the same time:

- **npm updates**: no branch or PR until the release is 1 day old (`minimumReleaseAge: "1 day"`, `internalChecksFilter: "strict"`), plus Renovate's default 30-minute `minimumReleaseAgeBuffer`. Held updates are listed under "Pending Status Checks" in the Dependency Dashboard. If a newer version is still too young, an open PR stays on the last version that passed.
- **Automerge**: minor, patch and pin PRs only exist once the age has passed, so automerge never merges a release younger than 1 day.
- **Updates without a release timestamp** (`pin`, `bump`, `lockfileUpdate`, `rollback`, `replacement`, `lockFileMaintenance`): no age check, otherwise Renovate would hold them forever.
- **Vulnerability alerts**: not delayed. Renovate applies `vulnerabilityAlerts` (`minimumReleaseAge: null`) after all package rules. pnpm still applies its own 1-day limit to the fixed version, so a fix released less than a day ago shows a lockfile error until it is old enough.
- **Other datasources** (Go modules, GitHub Actions, Docker): no age check. Docker digests from GHCR and other registries without release timestamps would be held forever, and no tool in these repos rejects fresh releases.

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
