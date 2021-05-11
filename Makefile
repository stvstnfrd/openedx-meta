#!make -f
.PHONY: help
help:  ## This.
	@echo "Available targets:"
	@grep '^[a-zA-Z]' $(MAKEFILE_LIST) | sort | awk -F ':.*?## ' 'NF==2 {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "version: $(VERSION)"

.PHONY: tree
tree:
	tree docs/versions

.PHONY: ci
ci: ci.install  ## run the CI/test validation suite
	yamllint .

.PHONY: ci.install
ci.install:  ## install CI/test dependencies
	@command -v yamllint >/dev/null \
	|| pip install yamllint
