#!/usr/bin/env make
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

MY-SORT = $(shell echo '$2' | tr ' ' '\n' | sort $1 -)
DETECT-VERSION = $(firstword $(call MY-SORT,-nr,$(subst /,,$(subst $1/,,$(wildcard $1/*/)))))
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
FILE_NEXT_STANDUP=$(DIR_VERSION_PATCH_NEXT)/README.markdown
FILE_NEXT_PLANNING=$(DIR_VERSION_MINOR_NEXT)/0/README.markdown

# Start Team
.PHONY: team version_major
version_major: team
team: $(FILE_NEXT_TEAM)  ## Generate a new team formation
	git add "$(DIR_VERSION_MAJOR_NEXT)"
	git commit -m "team: form new team: $(TEAM_NAME), ($(TEAM_MEMBERS))"

.PHONY: sprint version_minor
version_minor: sprint
sprint: $(FILE_NEXT_SPRINT)  ## Generate this "week's" sprint
	git add "$(DIR_VERSION_MINOR_NEXT)"
	git commit -m "sprint: start new sprint: {DATESTAMP}"

.PHONY: standup version_patch
version_patch: standup
standup: $(FILE_NEXT_STANDUP)  ## Generate today's standup notes
	@cat "$(DIR_VERSION_MAJOR)/README.markdown" \
	| sed '/---/,$$d' \
	> tmp.md
	@echo '---' >> tmp.md
	@$(MAKE) changelog-team >> tmp.md
	mv tmp.md "$(DIR_VERSION_MAJOR)/README.markdown"
	@cat "$(DIR_VERSIONS)/README.markdown" \
	| sed '/---/,$$d' \
	> tmp.md
	@echo '---' >> tmp.md
	@$(MAKE) changelog >> tmp.md
	mv tmp.md "$(DIR_VERSIONS)/README.markdown"
	GITHUB_TOKEN=$(GITHUB_TOKEN) python3 .github/standup.py sprint > "$(DIR_VERSION_MINOR)/README.markdown"
	git add "$(DIR_VERSIONS)/README.markdown"
	git add "$(DIR_VERSION_MAJOR)/README.markdown"
	git add "$(DIR_VERSION_MINOR)/README.markdown"
	git add "$(DIR_VERSION_PATCH_NEXT)"
	git commit -m "standup: report today's standup: {DATESTAMP}"

.PHONY: changelog changelog-team
CHANGELOG_FILES_ALL=$(call MY-SORT,-nr,$(wildcard docs/versions/*/*/*/README.markdown))
CHANGELOG_FILES_TEAM=$(call MY-SORT,-nr,$(wildcard docs/versions/$(DETECT_VERSION_MAJOR)/*/*/README.markdown))
changelog-team: $(CHANGELOG_FILES_TEAM)
	@echo '# changelog'
	@echo
	@echo "## unreleased changes"
	@echo
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
	done

changelog: $(CHANGELOG_FILES_ALL)
	@echo '# changelog'
	@echo
	@echo "## unreleased changes"
	@echo
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
	done

# team
ifeq ($(TEAM_MEMBERS),)
$(FILE_NEXT_TEAM):
	@echo "You must set/export 'TEAM_MEMBERS', like:"
	@echo "    make team TEAM_MEMBERS='user1 user2'"
	exit 1
else
$(FILE_NEXT_TEAM): $(DIR_VERSION_MAJOR_NEXT)/  ## Create a new team
ifneq ($(TEAM_NAME),)
	@echo "name: '$(TEAM_NAME)'" > "$(@)"
endif
	@echo "members: $(TEAM_MEMBERS)" >> "$(@)"
	@echo "" >> "$(@)"
	@echo "---" >> "$(@)"
endif

# sprint
$(DIR_VERSION_MINOR_NEXT)/README.markdown: $(DIR_VERSION_MINOR_NEXT)/
	@echo "version: '$(subst /,.,$(subst /README.markdown,,$(subst docs/versions/,,$(@)))).X'" > "$(@)"
	@echo "" >> "$(@)"
	@echo "---" >> "$(@)"
	echo "# retrospective" >> "$(@)"
	$(MAKE) $(FILE_NEXT_PLANNING)

# standup/planning
$(FILE_NEXT_STANDUP): $(DIR_VERSION_PATCH_NEXT)/
ifeq ($(DETECT_VERSION_PATCH_NEXT),0)
	@echo "version: '$(subst /,.,$(subst /README.markdown,,$(subst docs/versions/,,$(@))))'" > "$(@)"
	@echo "" >> "$(@)"
	@echo "---" >> "$(@)"
	echo "# planning" >> "$(@)"
else
	GITHUB_TOKEN=$(GITHUB_TOKEN) python3 .github/standup.py standup > "$(@)"

endif

.PRECIOUS: $(DIR_VERSIONS)/%/
$(DIR_VERSIONS)/%/: $(DIR_VERSIONS)
	test -d "$(@)" || mkdir "$(@)"

dirs=$(sort $(DIR_DOCS) $(DIR_VERSIONS) $(DIR_VERSION_MAJOR) $(DIR_VERSION_MAJOR_NEXT) $(DIR_VERSION_MINOR) $(DIR_VERSION_MINOR_NEXT) $(DIR_VERSION_PATCH) $(DIR_VERSION_PATCH_NEXT))
.PRECIOUS: $(dirs)
$(dirs):
	$(MAKE) '$(shell dirname "$(@)")'
	test -d "$(@)" || mkdir "$(@)"
