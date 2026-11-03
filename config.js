module.exports = {
  platform: "github",
  endpoint: "https://api.github.com/",

  // Auto-discover all repositories in the gjed account
  autodiscover: true,
  autodiscoverFilter: ["gjed/*"],

  // Disable onboarding - repositories must have renovate.json
  onboarding: false,

  // Require renovate.json in repositories
  requireConfig: "required",

  // Runs as the gjed-renovate GitHub App (installation token). Commits go
  // through the GitHub API so they are signed by GitHub as the app, which
  // satisfies required_signatures. gitAuthor must match the app's bot user.
  username: "gjed-renovate[bot]",
  gitAuthor: "gjed-renovate[bot] <351878540+gjed-renovate[bot]@users.noreply.github.com>",
  platformCommit: "enabled",

  // Dry run mode - set to null for actual PRs
  dryRun: null,

  // Persistence
  repositoryCache: "enabled",

  // GitHub-specific settings
  optimizeForDisabled: true,

  // Disable fork processing
  forkProcessing: "disabled",

  // Allow Go cache environment variables
  allowedEnv: ["GOCACHE", "GOMODCACHE"],

  // Go cache environment variables to fix permission issues
  env: {
    GOCACHE: "/tmp/go-build-cache",
    GOMODCACHE: "/tmp/go-mod-cache",
  },

  // Auto-rebase PRs when they fall behind
  rebaseWhen: "behind-base-branch",
};
