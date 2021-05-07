# openedx-meta

## Purpose

This repository represents an attempt to manage a Github-based
development workflow. Initially, it will attempt to work for a
single-user workflow, but should keep an eye toward team/multi-user
workflows.

## Design

### Issues

All TODO items/ideas are added as [Github Issues on this
repository](https://github.com/stvstnfrd/openedx-meta/issues).

### Labels

Automation of this project is driven by the addition of Github Labels.
To mark an issue as done, set the label to [done](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aclosed+is%3Aissue+label%3Adone),
etc. Everything else (closing the issue, updating labels, etc.)
_should_ be handled automatically.

### Projects

The following repository projects exist:
- [backlog](https://github.com/stvstnfrd/openedx-meta/projects/1)
- [sprint](https://github.com/stvstnfrd/openedx-meta/projects/2)

Optionally, the repository can be connected to a JIRA board, presently:
https://openedx.atlassian.net/secure/RapidBoard.jspa?rapidView=689

### Issue Flow

#### Create

When issues are created:
- automatically apply label: [triage](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atriage)
- automatically add issue to project list: [backlog/TODO](https://github.com/stvstnfrd/openedx-meta/projects/1#column-14061503)
- automatically create a JIRA ticket to track this issue:
  [CENG/backlog](https://openedx.atlassian.net/secure/RapidBoard.jspa?rapidView=689&projectKey=CENG&view=planning&issueLimit=100)

##### Conventional Commits

If an issue is created with a title starting with a Conventional Commit prefix [1],
we automatically apply the corresponding Github Label.

###### Supported types

- [build](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Abuild)
- [chore](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Achore)
- [docs](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Adocs)
- [feat](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Afeat)
- [fix](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Afix)
- [perf](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Aperf)
- [refactor](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Arefactor)
- [revert](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Arevert)
- [style](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Astyle)
- [style](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Astyle)
- [temp](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atemp)
- [test](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atest)

We also flag potential "parking lot" discussions with the prefix:

- [discuss](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Adiscuss)

#### Update

When work is started:
- manually apply label: [progress](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Aprogress)
- automatically remove label: [done](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aclosed+is%3Aissue+label%3Adone)
- automatically remove label: [todo](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atodo)
- automatically remove label: [triage](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atriage)
- automatically move issue to project list: [backlog/Doing](https://github.com/stvstnfrd/openedx-meta/projects/1#column-14061509)
- automatically move issue to project list: [sprint/Doing](https://github.com/stvstnfrd/openedx-meta/projects/2#column-14068701)
- automatically transition JIRA ticket "In Progress": [CENG/Kanban](https://openedx.atlassian.net/secure/RapidBoard.jspa?rapidView=689&projectKey=CENG)

#### Complete

When work is finished:
- manually apply label: [done](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aclosed+is%3Aissue+label%3Adone)
- automatically remove label: [progress](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Aprogress)
- automatically remove label: [todo](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atodo)
- automatically remove label: [triage](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atriage)
- automatically move issue to project list: [backlog/Done](https://github.com/stvstnfrd/openedx-meta/projects/1#column-14061510)
- automatically move issue to project list: [sprint/Done](https://github.com/stvstnfrd/openedx-meta/projects/2#column-14068709)
- automatically close issue:
  [closed](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aissue+is%3Aclosed)
- automatically close JIRA ticket:
  [CENG/Kanban](https://openedx.atlassian.net/secure/RapidBoard.jspa?rapidView=689&projectKey=CENG)

#### Ceremony

##### Weekly

When a sprint is started:
- manually assign issue to owner
- manually add issues to project list: [sprint/TODO](https://github.com/stvstnfrd/openedx-meta/projects/2#column-14068697)

When a sprint is ended:
- manually archive project list: [sprint/Done](https://github.com/stvstnfrd/openedx-meta/projects/2#column-14068709)

##### Daily

When an interrupt occurs:
- manually add issue to project list: [backlog/TODO](https://github.com/stvstnfrd/openedx-meta/projects/1#column-14061503)
- manually add issue to project list: [sprint/TODO](https://github.com/stvstnfrd/openedx-meta/projects/2#column-14068697)
- manually assign issue to owner

## Configuration

To enable JIRA integration, the following Repository Secrets must be added:

- `JIRA_API_TOKEN`
  - To create a personal token, visit
    https://id.atlassian.com/manage/api-tokens
- `JIRA_BASE_URL`
  - This is the base of your JIRA installation, like
    https://MY-PROJECT.atlassian.net
- `JIRA_USER_EMAIL`
  - This is the email of the account associated with the access token.

## TODO

- create automated/manual actions to snapshot daily standup, weekly sprint, etc.

## Notes

- We often refer to a "sprint" and a "week" interchangeably.

## References
- [1] https://github.com/edx/open-edx-proposals/pull/182
