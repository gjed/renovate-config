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

  // Global settings
  gitAuthor: "Renovate Bot <bot@renovateapp.com>",

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
