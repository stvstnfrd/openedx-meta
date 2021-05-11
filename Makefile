#!make -f
.PHONY: ci
ci: ci.install
	yamllint .

.PHONY: ci.install
ci.install:
	@command -v yamllint >/dev/null \
	|| pip install yamllint
