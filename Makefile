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
	git commit -m "team: form new team: $(TEAM_MEMBERS)"

.PHONY: sprint version_minor
version_minor: sprint
sprint: $(FILE_NEXT_SPRINT)  ## Generate this "week's" sprint
	git add "$(DIR_VERSION_MINOR_NEXT)"
	git commit -m "sprint: start new sprint: {DATESTAMP}"

.PHONY: standup version_patch
version_patch: standup
standup: $(FILE_NEXT_STANDUP)  ## Generate today's standup notes
	git add "$(DIR_VERSION_PATCH_NEXT)"
	git commit -m "standup: report today's standup: {DATESTAMP}"

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
	echo "# team" >> "$(@)"
	@echo "" >> "$(@)"
	@echo "## how we work" >> "$(@)"
	@echo "" >> "$(@)"
	@echo "- [ ] TODO: this!" >> "$(@)"
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
	@echo "version: '$(subst /,.,$(subst /README.markdown,,$(subst docs/versions/,,$(@))))'" > "$(@)"
	@echo "" >> "$(@)"
	@echo "---" >> "$(@)"
ifeq ($(DETECT_VERSION_PATCH_NEXT),0)
	echo "# planning" >> "$(@)"
else
	echo "# standup" >> "$(@)"
endif

.PRECIOUS: $(DIR_VERSIONS)/%/
$(DIR_VERSIONS)/%/: $(DIR_VERSIONS)
	test -d "$(@)" || mkdir "$(@)"

dirs=$(sort $(DIR_DOCS) $(DIR_VERSIONS) $(DIR_VERSION_MAJOR) $(DIR_VERSION_MAJOR_NEXT) $(DIR_VERSION_MINOR) $(DIR_VERSION_MINOR_NEXT) $(DIR_VERSION_PATCH) $(DIR_VERSION_PATCH_NEXT))
.PRECIOUS: $(dirs)
$(dirs):
	$(MAKE) '$(shell dirname "$(@)")'
	test -d "$(@)" || mkdir "$(@)"
