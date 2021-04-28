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

### Projects

The following repository projects exist:
- [openedx-backlog](https://github.com/stvstnfrd/openedx-meta/projects)

The following user projects exist:
- [openedx-backlog](https://github.com/users/stvstnfrd/projects/5)
- [openedx-sprint](https://github.com/users/stvstnfrd/projects/2)
- [openedx-standup](https://github.com/users/stvstnfrd/projects/4)

### Issue Flow

#### Create

When issues are created:
- add ticket to project list: `openedx-backlog.TODO`

#### Update

When work is started:
- move ticket to project list: `openedx-backlog.Doing`
- move ticket to project list: `openedx-sprint.Doing`
- move ticket to project list: `openedx-standup.Doing`

##### Automatically move to done when issue closed

When work is finished:
- move ticket to project list: `openedx-backlog.Done`
- move ticket to project list: `openedx-sprint.Done`
- move ticket to project list: `openedx-standup.Done`

#### Ceremony

##### Weekly

When a sprint is started:
- assign tickets to owner
- add tickets to project list: `openedx-sprint.TODO`

When a sprint is ended:
- archive project list: `openedx-sprint.Done`

##### Daily

When a day is started:
- add tickets to project list: `openedx-standup.TODO`

When an interrupt occurs:
- add ticket to project list: `openedx-backlog.TODO`
- add ticket to project list: `openedx-sprint.TODO`
- add ticket to project list: `openedx-standup.TODO`
- assign ticket to owner

When a day is ended:
- archive project list: `openedx-standup.Done`

## Proposed

### Labels

It would probably help to have some automation setup
(presumably via Github Actions?)
to update things based on labels.
Titles too (conventional commits)?

#### Workflow

When issues are created:
- automatically apply label: `triage`
- automatically add ticket to project list: `openedx-backlog.TODO`

When work is started:
- manually apply label: `progress`
- automatically remove label: `done`
- automatically remove label: `progress`
- automatically move ticket to project list: `openedx-backlog.Doing`
- automatically move ticket to project list: `openedx-sprint.Doing`
- automatically move ticket to project list: `openedx-standup.Doing`

When work is finished:
- manually apply label: `done`
- automatically remove label: `triage`
- automatically remove label: `progress`
- automatically move ticket to project list: `openedx-backlog.Done`
- automatically move ticket to project list: `openedx-sprint.Done`
- automatically move ticket to project list: `openedx-standup.Done`
- automatically close ticket

## References
