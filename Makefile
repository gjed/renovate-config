RENOVATE_IMAGE := ghcr.io/renovatebot/renovate
RENOVATE_TOKEN := $(shell gh auth token)
CONTAINER_RUNTIME := $(shell command -v podman 2>/dev/null || echo docker)

.PHONY: pull
pull:
	$(CONTAINER_RUNTIME) pull $(RENOVATE_IMAGE)

# Run renovate against all autodiscovered gjed repos
.PHONY: run
run: pull
	$(CONTAINER_RUNTIME) run --rm \
		-e RENOVATE_TOKEN=$(RENOVATE_TOKEN) \
		-e LOG_LEVEL=info \
		-e RENOVATE_CONFIG_FILE=/usr/src/app/config.js \
		-v $(PWD)/config.js:/usr/src/app/config.js \
		$(RENOVATE_IMAGE)

# Run renovate against a specific repo (usage: make run-repo REPO=gjed/my-repo)
.PHONY: run-repo
run-repo: pull
	$(CONTAINER_RUNTIME) run --rm \
		-e RENOVATE_TOKEN=$(RENOVATE_TOKEN) \
		-e LOG_LEVEL=info \
		-e RENOVATE_CONFIG_FILE=/usr/src/app/config.js \
		-e RENOVATE_AUTODISCOVER=false \
		-v $(PWD)/config.js:/usr/src/app/config.js \
		$(RENOVATE_IMAGE) \
		$(REPO)

# Dry-run against all autodiscovered repos
.PHONY: dry-run
dry-run: pull
	$(CONTAINER_RUNTIME) run --rm \
		-e RENOVATE_TOKEN=$(RENOVATE_TOKEN) \
		-e LOG_LEVEL=debug \
		-e RENOVATE_CONFIG_FILE=/usr/src/app/config.js \
		-e RENOVATE_DRY_RUN=full \
		-v $(PWD)/config.js:/usr/src/app/config.js \
		$(RENOVATE_IMAGE)

# Dry-run against a specific repo (usage: make dry-run-repo REPO=gjed/my-repo)
.PHONY: dry-run-repo
dry-run-repo: pull
	$(CONTAINER_RUNTIME) run --rm \
		-e RENOVATE_TOKEN=$(RENOVATE_TOKEN) \
		-e LOG_LEVEL=debug \
		-e RENOVATE_CONFIG_FILE=/usr/src/app/config.js \
		-e RENOVATE_AUTODISCOVER=false \
		-e RENOVATE_DRY_RUN=full \
		-v $(PWD)/config.js:/usr/src/app/config.js \
		$(RENOVATE_IMAGE) \
		$(REPO)
