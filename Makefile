#!/usr/bin/env make
SHELL=bash
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
	pylint .github

.PHONY: ci.install
ci.install:  ## install CI/test dependencies
	@command -v yamllint >/dev/null \
	|| pip install yamllint
	@command -v pylint >/dev/null \
	|| pip install pylint

DETECT-VERSION = $(firstword $(subst /,,$(subst $1/,,$(shell find $1 -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort --version-sort --reverse))))
BUMP = $(shell bash -c "echo $$((1 + $1))")

DETECT_VERSION_MAJOR=$(call DETECT-VERSION,docs/versions)
ifeq ($(DETECT_VERSION_MAJOR),)
DETECT_VERSION_MAJOR=0
DETECT_VERSION_MAJOR_NEXT=0
else
DETECT_VERSION_MAJOR_NEXT=$(call BUMP,$(DETECT_VERSION_MAJOR))
endif

DETECT_VERSION_MINOR=$(call DETECT-VERSION,docs/versions/$(DETECT_VERSION_MAJOR))
ifeq ($(DETECT_VERSION_MINOR),)
DETECT_VERSION_MINOR=0
DETECT_VERSION_MINOR_NEXT=0
else
DETECT_VERSION_MINOR_NEXT=$(call BUMP,$(DETECT_VERSION_MINOR))
endif

DETECT_VERSION_PATCH=$(call DETECT-VERSION,docs/versions/$(DETECT_VERSION_MAJOR)/$(DETECT_VERSION_MINOR))
ifeq ($(DETECT_VERSION_PATCH),)
DETECT_VERSION_PATCH=0
DETECT_VERSION_PATCH_NEXT=0
else
DETECT_VERSION_PATCH_NEXT=$(call BUMP,$(DETECT_VERSION_PATCH))
endif
VERSION=$(DETECT_VERSION_MAJOR).$(DETECT_VERSION_MINOR).$(DETECT_VERSION_PATCH)

DIR_DOCS=./docs
DIR_VERSIONS=$(DIR_DOCS)/versions
DIR_VERSION_MAJOR=$(DIR_VERSIONS)/$(DETECT_VERSION_MAJOR)
DIR_VERSION_MAJOR_NEXT=$(DIR_VERSIONS)/$(DETECT_VERSION_MAJOR_NEXT)
DIR_VERSION_MINOR=$(DIR_VERSION_MAJOR)/$(DETECT_VERSION_MINOR)
DIR_VERSION_MINOR_NEXT=$(DIR_VERSION_MAJOR)/$(DETECT_VERSION_MINOR_NEXT)
DIR_VERSION_PATCH=$(DIR_VERSION_MINOR)/$(DETECT_VERSION_PATCH)
DIR_VERSION_PATCH_NEXT=$(DIR_VERSION_MINOR)/$(DETECT_VERSION_PATCH_NEXT)
FILE_NEXT_TEAM=$(DIR_VERSION_MAJOR_NEXT)/README.markdown
FILE_NEXT_SPRINT=$(DIR_VERSION_MINOR_NEXT)/README.markdown
FILE_NEXT_PLANNING=$(DIR_VERSION_MINOR_NEXT)/0/README.markdown
FILE_NEXT_STANDUP=$(DIR_VERSION_PATCH_NEXT)/README.markdown
FILE_THIS_RETRO=$(DIR_VERSION_MINOR)/README.markdown
FILE_THIS_CHANGELOG=$(DIR_VERSIONS)/README.markdown
FILE_THIS_TEAM_CHANGELOG=$(DIR_VERSION_MAJOR)/README.markdown
CHANGELOG_FILES_ALL=$(shell find docs/versions -mindepth 4 -maxdepth 4 -type f -name README.markdown | sort --version-sort --reverse)
CHANGELOG_FILES_TEAM=$(shell find docs/versions/$(DETECT_VERSION_MAJOR) -mindepth 3 -maxdepth 3 -type f -name README.markdown | sort --version-sort --reverse)

# Start Team
.PHONY: team version_major
version_major: team
team: $(FILE_NEXT_TEAM)  ## Generate a new team formation
	git add "$(DIR_VERSIONS)"
	git commit -m "team: form new team: $(TEAM_NAME), ($(TEAM_MEMBERS))"

.PHONY: sprint version_minor
version_minor: sprint
sprint: $(FILE_NEXT_SPRINT) $(FILE_NEXT_PLANNING)  ## Generate this "week's" sprint
	$(MAKE) $(FILE_THIS_TEAM_CHANGELOG)
	$(MAKE) $(FILE_THIS_CHANGELOG)
	git add "$(DIR_VERSIONS)"
	git commit -m "sprint: start new sprint: {DATESTAMP}"

.PHONY: standup version_patch
version_patch: standup
standup: $(FILE_NEXT_STANDUP)  ## Generate today's standup notes
	@$(MAKE) $(FILE_THIS_TEAM_CHANGELOG)
	@$(MAKE) $(FILE_THIS_CHANGELOG)
	@$(MAKE) $(FILE_THIS_RETRO)
	git add "$(DIR_VERSIONS)"
	git commit -m "standup: report today's standup: {DATESTAMP}"

.PHONY: $(FILE_THIS_CHANGELOG) $(FILE_THIS_TEAM_CHANGELOG)
$(FILE_THIS_CHANGELOG): $(CHANGELOG_FILES_ALL)
	@cat "$(@)" \
	| sed '/---/,$$d' \
	> tmp.md
	@echo '---' >> tmp.md
	@echo '# changelog' >> tmp.md
	@echo >> tmp.md
	@echo "## unreleased changes" >> tmp.md
	@echo >> tmp.md
	@for file in $(^); do \
		echo "## v$$(echo $$file \
		| sed 's@docs/versions/@@g; s@/README.markdown$$@@g; y@/@.@' \
		)"; \
		cat $$file \
		| sed '1,/^---$$/d' \
		| sed '/## unreleased /,/## \[done/{//!d}' \
		| sed '/^##\? /d' \
		| cat -s \
		; \
		echo; \
	done >> tmp.md
	mv tmp.md $(@)

$(FILE_THIS_TEAM_CHANGELOG): $(CHANGELOG_FILES_TEAM)
	@cat "$(@)" \
	| sed '/---/,$$d' \
	> tmp.md
	@echo '---' >> tmp.md
	@echo '# changelog' >> tmp.md
	@echo >> tmp.md
	@echo "## unreleased changes" >> tmp.md
	@echo >> tmp.md
	@for file in $(^); do \
		echo "## v$$(echo $$file \
		| sed 's@docs/versions/@@g; s@/README.markdown$$@@g; y@/@.@' \
		)"; \
		cat $$file \
		| sed '1,/^---$$/d' \
		| sed '/## unreleased /,/## \[done/{//!d}' \
		| sed '/^##\? /d' \
		| cat -s \
		; \
		echo; \
	done >> tmp.md
	mv tmp.md $(@)

ifeq ($(TEAM_MEMBERS),)
$(FILE_NEXT_TEAM):
	@echo "You must set/export 'TEAM_MEMBERS', like:"
	@echo "    make team TEAM_MEMBERS='user1 user2'"
	exit 1
else
$(FILE_NEXT_TEAM):  ## Create a new team
	@test -d "$$(dirname $(@))" || mkdir "$$(dirname $(@))"
ifneq ($(TEAM_NAME),)
	@echo "name: '$(TEAM_NAME)'" > "$(@)"
endif
	@echo "members: $(TEAM_MEMBERS)" >> "$(@)"
	@echo "" >> "$(@)"
	@echo "---" >> "$(@)"
endif

.PHONY: $(FILE_THIS_RETRO) $(FILE_NEXT_SPRINT) $(FILE_NEXT_PLANNING)
$(FILE_THIS_RETRO) $(FILE_NEXT_SPRINT) $(FILE_NEXT_PLANNING):
	@test -d "$$(dirname $(@))" || mkdir "$$(dirname $(@))"
	# TODO: archive old DONE cards
	# TODO: copy over backlog/progress -> sprint/todo
	GITHUB_TOKEN=$(GITHUB_TOKEN) python3 .github/standup.py sprint > "$(@)"

.PHONY: $(FILE_NEXT_STANDUP)
$(FILE_NEXT_STANDUP):
ifneq ($(DETECT_VERSION_PATCH_NEXT),0)
	@test -d "$$(dirname $(@))" || mkdir "$$(dirname $(@))"
	GITHUB_TOKEN=$(GITHUB_TOKEN) python3 .github/standup.py standup > "$(@)"
endif
