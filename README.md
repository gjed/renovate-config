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
make run          # autodiscover all gjed repos
make dry-run      # dry-run, no PRs created
make run-repo REPO=gjed/my-repo   # single repo
```

Requires `gh` CLI authenticated (`gh auth login`). Token is resolved at runtime.

## Automation (systemd)

Install the hourly systemd user timer:

```bash
make install
```

This copies `systemd/renovate.service` and `systemd/renovate.timer` into
`~/.config/systemd/user/` and enables the timer immediately.

Check status:

```bash
systemctl --user status renovate.timer
systemctl --user status renovate.service
journalctl --user -u renovate.service -f
```

Uninstall:

```bash
make uninstall
```
