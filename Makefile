RENOVATE_IMAGE := ghcr.io/renovatebot/renovate
RENOVATE_TOKEN := $(shell gh auth token)
CONTAINER_RUNTIME := $(shell command -v podman 2>/dev/null || echo docker)
SYSTEMD_USER_DIR := $(HOME)/.config/systemd/user

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

# Install systemd user units and enable the hourly timer
.PHONY: install
install:
	chmod +x systemd/renovate.sh
	cp systemd/renovate.service systemd/renovate.timer $(SYSTEMD_USER_DIR)/
	systemctl --user daemon-reload
	systemctl --user enable --now renovate.timer
	systemctl --user list-timers renovate.timer

# Uninstall systemd user units
.PHONY: uninstall
uninstall:
	systemctl --user disable --now renovate.timer || true
	rm -f $(SYSTEMD_USER_DIR)/renovate.service $(SYSTEMD_USER_DIR)/renovate.timer
	systemctl --user daemon-reload

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
