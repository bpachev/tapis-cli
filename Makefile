PYTEST_OPTS ?= -v --durations=10
PYTEST_SRC ?= tests/
PYTEST_MAX_FAIL ?= 1
PYTEST_FAIL_OPTS ?= --maxfail=$(PYTEST_MAX_FAIL)
PYTEST_RUN_OPTS ?= $(PYTEST_FAIL_OPTS)

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
GIT_BRANCH_CLEAN := $(shell echo $(GIT_BRANCH) | sed -e "s/[^[:alnum:]]/-/g")

CLI_BRANCH ?= $(GIT_BRANCH)
CLI_VERSION ?= "alpha"
IMAGE_BASENAME := tapis-cli-ng
DOCKER_ORG ?= tacc
PUBLIC_DOCKER_IMAGE ?= $(DOCKER_ORG)/$(IMAGE_BASENAME):latest

DOCKERFILE ?= Dockerfile
DOCKER_BUILD_ARGS ?= --force-rm --build-arg CLI_BRANCH=$(CLI_BRANCH)
DOCKER_MOUNT_AUTHCACHE ?= -v $(HOME)/.agave:/home/.agave

.PHONY: tests
tests:
	python -m pytest $(PYTEST_RUN_OPTS) $(PYTEST_OPTS) $(PYTEST_SRC)

.PHONY: format format-code format-tests
format: format-code format-tests

format-code:
	yapf --recursive --style pep8 -i tapis_cli

format-tests:
	yapf --recursive --style pep8 -i tests

.PHONY: docs docs/requirements.txt

docs: docs-clean docs-autodoc docs-text docs/requirements.txt

docs/requirements.txt:
	cat requirements.txt > docs/requirements.txt
	cat requirements-dev.txt >> docs/requirements.txt

docs-text:
	cd docs && make html && make man

docs-autodoc:
	cd docs && sphinx-apidoc --maxdepth 1 -M -H "API Reference" -f -o source ../tapis_cli

docs-clean:
	cd docs && make clean

issues:
	python scripts/github-create-issues.py

image: public-image-py3

public-image-py3:
	docker build --no-cache $(DOCKER_BUILD_ARGS) --build-arg CLI_VERSION=$(CLI_VERSION) -f $(DOCKERFILE) -t $(PUBLIC_DOCKER_IMAGE) .
