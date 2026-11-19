# Todo Update Instructions

## Authorization and Operations

Use this file before adding a todo, changing its status, resolving it, or
abandoning it. Read [AGENTS.md](AGENTS.md) for the repository workflow, project
naming, worklog contracts, and delivery checks.

- Add a todo only when the user explicitly asks to mark or record it. Report
  newly discovered follow-up work without silently creating a record.
- Change an existing todo's status on user instruction or when its actual
  progress changes during clearly related authorized work.
- Resolve an existing todo automatically when the authorized work has actually
  satisfied its acceptance criteria, or on an explicit manual-resolve request.
- Abandon an existing todo only when the user explicitly gives up executing it.
  A blocker, elapsed time, inactivity, or an unsuccessful attempt is not such
  an instruction. `abandon` is an action, not a status.

Recording a todo does not authorize execution of its objective. Respect explicit
read-only and no-write restrictions. Reading records, duplicate add requests,
and repeated completed removal requests that change nothing need no worklog.
Every actual todo creation or status change must have a corresponding worklog,
including automatic status updates when the named project's files are unchanged.
Resolution and abandonment also require worklogs, after their removal commits.
An open current-task worklog may cover related operations, but do not rewrite
published historical logs or omit the record because only metadata changed.
Naming a project in a record does not by itself make that project modified.

## Scope, Templates, and Identity

Choose `todos/common/` for work independent of a particular project, or
`todos/projects/<project>/` for work owned by one project. Project names follow
[AGENTS.md](AGENTS.md#member-and-project-names). Knowledge and todo scopes are
independent; neither requires creating the other.

Use one canonical record per objective and set of acceptance criteria in its
scope. Read the root and relevant scope indexes and compare existing details
before adding anything. Return an existing matching todo instead of creating a
duplicate. Do not infer active todos from historical knowledge or worklogs.

Never assemble a new project scope manually. Copy `todos/projects/_example/`
to `todos/projects/<project>/`, replace the `_example` values, rename and
replace the sample item, and register the project in the root index. Copy
`todos/projects/_example/items/example-todo.md` for later project items and for
common items. Create `common/items/` when first needed. Do not alter the source
template while copying it, and do not add placeholder files for empty folders.

Every real item is named `YYYYMMDD-HHmmss-<slug>.md`. Use a concise lowercase
kebab-case English slug and generate the creation timestamp in UTC+8 with:

```sh
TZ=Asia/Shanghai date '+%Y%m%d-%H%M%S'
```

If the target exists, wait for the next second and generate a new timestamp.
The filename without `.md` is the stable identifier; keep it unchanged when
updating the title, progress, or status. Treat a scope and its identifier as
the item locator. A copied sample must be fully replaced before it becomes a
real record.

Project scopes are permanent once created. Keep their `INDEX.md`, directory,
and root project-table entry even when no items remain. Never delete a project
scope or its navigation as part of resolving or abandoning an item.

## Tree and Index Contracts

```text
todos/
  INDEX.md
  common/
    INDEX.md
    items/
      <timestamp>-<slug>.md
  projects/
    _example/
      INDEX.md
      items/
        example-todo.md
    <project>/
      INDEX.md
      items/
        <timestamp>-<slug>.md
```

The real item document is the source of its title, scope, status, creation time,
and next action. Maintain indexes manually during the same operation; no index
generator is required. Keep each item's values identical across its document
and both indexes. Escape Markdown table separators in values and keep index
cells on one line.

Sort active rows first by status (`in-progress`, `todo`, `blocked`), then by
scope name lexicographically, then by creation time ascending, then identifier.
Scope indexes use the same order without the scope comparison. Do not list
reserved examples as real todos or real projects.

### Root Index

`todos/INDEX.md` must use this structure. Its first table contains every active
real item in this repository, rather than just project navigation:

```markdown
# Todo Index

## Active Todos

| Scope | Status | Todo | Next Action |
| --- | --- | --- | --- |
| `<common or project>` | `<status>` | [<title>](<scope>/items/<identifier>.md) | <next action> |

## Common

- [Common todos](common/INDEX.md)

## Template

- [Example project structure](projects/_example/INDEX.md)

## Projects

| Project | Index |
| --- | --- |
| `<project>` | [Open](projects/<project>/INDEX.md) |
```

Use `common` or `projects/<project>` for the link's `<scope>`. Sort the project
table lexicographically by directory name and retain empty real projects.

### Scope Index

Every common and project scope index must use:

```markdown
# <Common or Project Name> Todos

| Status | Todo | Next Action |
| --- | --- | --- |
| `<status>` | [<title>](items/<identifier>.md) | <next action> |
```

For any empty real active table, retain its header and place
`No active todos.` below it, separated by a blank line. Remove that sentence
when rows exist. The reserved project index links its sample item, but that
sample is excluded from the root active table.

## Todo Document Contract

Every real item and the reserved item template uses all these fields and
headings. Replace every placeholder in a real item and use `None` for empty
progress or reference sections. Times use UTC+8.

```markdown
# <Todo title>

- Scope: `<common or project>`
- Status: `todo`
- Created: `YYYY-MM-DD HH:mm:ss UTC+8`
- Updated: `YYYY-MM-DD HH:mm:ss UTC+8`
- Next action: <one concrete next step>

## Objective

<Goal and requested scope.>

## Acceptance Criteria

- [ ] <An observable completion condition.>

## Progress

None.

## References

### Related Knowledge

None.

### Supporting Worklogs

None.
```

Only `todo`, `in-progress`, and `blocked` are valid statuses:

- `todo`: not started, or explicitly returned to the waiting state.
- `in-progress`: work has started but the acceptance criteria are not all met.
- `blocked`: a concrete obstacle prevents progress. Record the obstacle and
  its release condition in Progress, and the unblocking step in Next action.

Keep Created unchanged. Update Updated when the record changes, using:

```sh
TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S UTC+8'
```

Do not use `done`, `resolved`, or `abandoned` as statuses, and do not keep
completion or abandonment directories. Resolution and abandonment remove items.

## References and Knowledge Boundaries

Todos may reference specific repository-local knowledge documents and
supporting worklogs using relative links. Supporting Worklogs may include
background records, validation evidence, and the corresponding creation or
status-change worklog once it has been written. Knowledge documents and knowledge
indexes must not link back to todo documents or indexes. A todo operation does
not authorize a knowledge update; follow `UPDATE_KNOWLEDGE.md` separately when
the user authorizes one.

Keep durable worklog references to todos as plain identifiers and full removal
commit hashes, not links to files that will disappear. Do not create backward
links from knowledge, or links between live todo files that removal would break.
This contract covers repository-local relationships only.

## Add a Todo

1. Confirm the explicit user request; read the root and applicable scope index.
2. Check active items for an existing matching objective and acceptance criteria.
   If found, return its locator without writing a duplicate or another worklog.
3. Select the scope and copy the required scope or item template. Set a fresh
   identifier, `todo` status, equal Created and Updated times, the objective,
   acceptance criteria, next action, and applicable references.
4. Replace any copied sample row, register a new project if needed, and add the
   item to the scope and root active tables in the required order.
5. Validate and write a corresponding worklog under AGENTS.md, recording the
   new identifier, objective, and initial status. Commit and push the intended
   management changes together with the worklog and its indexes. No project
   execution is implied by adding this record.

## Change Status

1. Locate the exact active item and confirm the instruction or observed progress
   in the related authorized work. Clarify an ambiguous target before changing it.
2. Set one of the three valid statuses. Update Updated, Progress, and Next action
   to describe actual progress or the explicit user instruction. Include the
   reason and release condition when blocked.
3. Synchronize and reorder the scope and root active rows. Keep the identifier,
   Created time, scope structure, and project navigation unchanged.
4. Validate and write a corresponding worklog, recording the identifier, old
   and new status, reason, and observed progress. Commit and push the status
   change, index updates, worklog, and log indexes through the ordinary workflow.
   An identical request with no actual change creates no duplicate log or commit.

## Resolve and Abandon

Resolve after the authorized work actually meets its acceptance criteria, or
on an explicit manual-resolve request. Automatic resolution must have evidence;
a passing-looking label or a historical claim is not enough. For manual
resolution without independent verification, record that limitation.

Abandon only on an explicit user decision to give up execution. Record the
user's reason, or `No reason supplied.` Never claim abandonment means the
objective was completed or passed acceptance. Both actions remove the single
item and follow the same two-commit sequence:

1. Read the item and preserve its identifier, objective, criteria, evidence,
   action, and user instruction for the later worklog. Check the target is
   committed and that unrelated changes will not enter the removal commit.
   Finish the authorized add workflow before removing an uncommitted new item.
2. Delete only the selected item documents and their scope/root active rows.
   Retain every project INDEX.md, directory, and root project-table entry.
   Keep empty active headers and add `No active todos.` when applicable.
3. Validate links, complete and consistent indexes, and the precise diff.
   Stage only the selected todo deletions and corresponding index changes.
   Do not include project implementation changes or worklogs in this commit.
4. Commit the removal, then immediately capture the full hash with
   `git rev-parse HEAD`. Verify with `git show --name-status <removal-commit>`
   that this commit actually deletes each intended item. Never use a later
   worklog or merge commit as the removal hash.
5. Only after that commit exists, pull the reporting repository as required by
   AGENTS.md, create the required worklog, and update its indexes. Include the
   fields below in Results; a batch may share a removal commit but must list
   every identifier and its action. Cite the repository at the removal commit
   under References / Repositories.
6. Commit the worklog and its indexes separately, then push both commits and
   verify the remote contains them. If reporting occurs in a separately
   designated repository, the removal and reporting commits live in their
   respective repositories; the same removal-before-reporting order applies.

Required worklog Results fields:

```markdown
- Todo action: `resolve` or `abandon`
- Todo identifier: `<scope>/<identifier>`
- Todo objective: <original goal>
- Basis and evidence: <acceptance evidence, manual instruction, or abandonment reason>
- Todo removal commit: `<full removal commit hash>`
```

Keep the existing worklog status vocabulary. A `completed` management log can
mean the requested removal was completed; it must not misrepresent an abandoned
or unverified objective as completed work. Do not add a new worklog status.

If interrupted after removal was committed, find and verify that exact commit
and recover the item's content from its parent for reporting. Continue with
the missing worklog or push instead of recreating or deleting the item again.
If removal and reporting are already complete, return the existing record
without another mutation or log. If the target is absent and no verified
removal history exists, report the uncertainty rather than inventing success.

## Delivery Checks

- Every real item follows the document and filename contracts; all text is English.
- Every active item appears exactly once in each applicable active table, with
  matching scope, title, status, and next action, in the required order.
- Every real project appears exactly once in the root project table. Previously
  created projects, indexes, and navigation remain after removals.
- All prose links resolve, examples are excluded from real active lists, and
  empty lists retain their headers and the required empty-list sentence.
- Knowledge content is unchanged by todo operations and contains no todo backlinks.
- A removal commit contains the intended deletions and index updates only.
- Each removal worklog names the action and exact full deletion commit, exists
  after that commit, and distinguishes completion from manual or abandoned work.
- Required worklogs and their indexes are committed, both stages are pushed,
  and retry handling preserves unrelated changes and history without force-push.
