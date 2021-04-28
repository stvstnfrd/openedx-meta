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
- [standup](https://github.com/stvstnfrd/openedx-meta/projects/3)

### Issue Flow

#### Create

When issues are created:
- automatically apply label: [triage](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atriage)
- automatically add ticket to project list: [backlog/TODO](https://github.com/stvstnfrd/openedx-meta/projects/1#column-14061503)

##### Conventional Commits

If an issue is created with a title starting with a Conventional Commit prefix [1],
we automatically apply the corresponding Github Label.

#### Update

When work is started:
- manually apply label: [progress](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Aprogress)
- automatically remove label: [done](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aclosed+is%3Aissue+label%3Adone)
- automatically remove label: [todo](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atodo)
- automatically remove label: [triage](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atriage)
- automatically move ticket to project list: [backlog/Doing](https://github.com/stvstnfrd/openedx-meta/projects/1#column-14061509)
- automatically move ticket to project list: [sprint/Doing](https://github.com/stvstnfrd/openedx-meta/projects/2#column-14068701)
- automatically move ticket to project list: [standup/Doing](https://github.com/stvstnfrd/openedx-meta/projects/3#column-14068727)

#### Complete

When work is finished:
- manually apply label: [done](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aclosed+is%3Aissue+label%3Adone)
- automatically remove label: [progress](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Aprogress)
- automatically remove label: [todo](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atodo)
- automatically remove label: [triage](https://github.com/stvstnfrd/openedx-meta/issues?q=is%3Aopen+is%3Aissue+label%3Atriage)
- automatically move ticket to project list: [backlog/Done](https://github.com/stvstnfrd/openedx-meta/projects/1#column-14061510)
- automatically move ticket to project list: [sprint/Done](https://github.com/stvstnfrd/openedx-meta/projects/2#column-14068709)
- automatically move ticket to project list: [standup/Done](https://github.com/stvstnfrd/openedx-meta/projects/3#column-14068734)
- automatically close ticket

#### Ceremony

##### Weekly

When a sprint is started:
- manually assign tickets to owner
- manually add tickets to project list: [sprint/TODO](https://github.com/stvstnfrd/openedx-meta/projects/2#column-14068697)

When a sprint is ended:
- manually archive project list: [sprint/Done](https://github.com/stvstnfrd/openedx-meta/projects/2#column-14068709)

##### Daily

When a day is started:
- manually add tickets to project list: [standup/TODO](https://github.com/stvstnfrd/openedx-meta/projects/3#column-14068716)

When an interrupt occurs:
- manually add ticket to project list: [backlog/TODO](https://github.com/stvstnfrd/openedx-meta/projects/1#column-14061503)
- manually add ticket to project list: [sprint/TODO](https://github.com/stvstnfrd/openedx-meta/projects/2#column-14068697)
- manually add ticket to project list: [standup/TODO](https://github.com/stvstnfrd/openedx-meta/projects/3#column-14068716)
- manually assign ticket to owner

When a day is ended:
- manually archive project list: [standup/Done](https://github.com/stvstnfrd/openedx-meta/projects/3#column-14068734)

## TODO

- update labels if cards are moved within the projects

## References
- [1] https://github.com/edx/open-edx-proposals/pull/182
