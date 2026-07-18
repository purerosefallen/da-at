# Team Repository Instructions

## Repository Language

Use English for every committed filename, directory name, heading, index entry,
worklog, and knowledge document in this repository.

## Required Task Workflow

Every task must follow this sequence unless the user explicitly narrows the
delivery for that task:

1. Enter this repository and run `git pull --no-rebase`.
2. Determine the member and affected project names.
3. Read relevant worklogs and knowledge before starting project work.
4. Perform the actual project work.
5. Return to this repository and run `git pull --no-rebase` again.
6. Write one worklog for every affected project and update all affected worklog
   indexes.
7. Commit the repository-management changes and push them. If the push is
   rejected because the remote advanced, run `git pull --no-rebase`, resolve
   the merge, and push again.

Do not skip a worklog because a task was read-only, failed, became blocked, or
produced no project changes.

Do not create, edit, reorganize, or delete knowledge content unless the user
explicitly requests knowledge organization. For such a request, follow
[UPDATE_KNOWLEDGE.md](UPDATE_KNOWLEDGE.md).

## Fixed File Contracts

The repository root contains these fixed files:

- `README.md`: repository title, purpose, content map, and links to the two
  instruction files.
- `AGENTS.md`: mandatory task workflow, worklog contracts, knowledge-reading
  workflow, reference-repository usage, and delivery checks.
- `UPDATE_KNOWLEDGE.md`: the only instructions for creating, organizing, or
  updating knowledge.
- `.gitignore`: excludes the complete `/ref-repos/` cache.
- `ref-repo.sh`: materializes a shallow reference checkout and prints its
  absolute path.
- `_example/`: the reserved template directory name under dynamic roots. Never
  use `_example` as a real member or project, and never treat its contents as an
  operational record.

Do not add another root-level process document when one of these files can hold
the rule.

## Member and Project Names

Read the member name from `git config user.name`, trim surrounding whitespace,
and replace `/` with `-` so it remains one path component. If the result is
empty, stop and ask the user to configure it before writing a worklog.

Determine each affected project independently:

- For a Git repository with a parseable `origin` URL, use
  `<namespace>_<repository>`. Remove a trailing `.git`, join nested namespace
  components with `-`, and replace path-unsafe characters with `-`.
- For a directory outside a Git repository, use `nongit-<directory-name>`.
- For a Git repository whose namespace and repository cannot be determined,
  use `misc`.

For example, `git@git.example.com:team/platform/service.git` becomes
`team-platform_service`.

## Creating Worklog Directories

Never assemble a new member or project tree manually.

- If `worklogs/members/<member>/` does not exist, copy
  `worklogs/members/_example/` to it. Replace `_example` in the copied member
  `INDEX.md` with the real member name, keep the copied `projects/_example/`
  template, and add the member to `worklogs/INDEX.md`.
- If `worklogs/members/<member>/projects/<project>/` does not exist, copy that
  member's `projects/_example/` to it. Replace `_example` values, rename the
  example log to the current task timestamp, replace all example log content,
  and add the project to the member index.

Do not modify the source `_example` trees while instantiating them. Do not list
`_example` in a real member or project table.

## Worklog Tree and File Contracts

The worklog tree is:

```text
worklogs/
  INDEX.md
  members/
    <member>/
      INDEX.md
      projects/
        _example/
          INDEX.md
          logs/
            20000101-000000.md
        <project>/
          INDEX.md
          logs/
            <timestamp>.md
```

Generate `<timestamp>` as `YYYYMMDD-HHmmss` in UTC+8 with:

```sh
TZ=Asia/Shanghai date '+%Y%m%d-%H%M%S'
```

If the target filename exists, wait for the next second. Never overwrite a log.

### Root Worklog Index

`worklogs/INDEX.md` must contain exactly one title followed by a member table:

```markdown
# Worklog Members

## Template

- [Example structure](members/_example/INDEX.md)

## Members

| Member | Index |
| --- | --- |
| `<member>` | [Open](members/<member>/INDEX.md) |
```

Sort real members lexicographically by directory name. Do not add `_example` to
the member table.

### Member Index

`worklogs/members/<member>/INDEX.md` must use:

```markdown
# <member> Projects

## Template

- [Example project structure](projects/_example/INDEX.md)

## Projects

| Project | Index |
| --- | --- |
| `<project>` | [Open](projects/<project>/INDEX.md) |
```

Sort real projects lexicographically by directory name. Do not add `_example`
to the project table.

The reserved `members/_example/INDEX.md` follows this contract and links its
reserved `projects/_example/` project as a template, not as a real project row.

### Project Index

`worklogs/members/<member>/projects/<project>/INDEX.md` must use:

```markdown
# <project> Worklogs

| Timestamp | Status | Summary | Log |
| --- | --- | --- | --- |
| `YYYYMMDD-HHmmss` | `<status>` | <one-line summary> | [Open](logs/<timestamp>.md) |
```

Sort rows in reverse chronological order. Status is one of `completed`,
`partial`, `blocked`, `failed`, or `no-change`.

### Worklog Document

Every `logs/<timestamp>.md` must use all of these headings. Use `None` when a
section has no entries.

```markdown
# <Task title>

- Timestamp: `YYYY-MM-DD HH:mm:ss UTC+8`
- Member: `<member>`
- Project: `<project>`
- Status: `<status>`

## Objective

<Goal and requested scope.>

## Work Performed

<Actions, investigations, and changes.>

## Results

<Outcome and material decisions.>

## Validation

| Command or Check | Result |
| --- | --- |
| `<command or check>` | <observed result> |

## Limitations and Follow-up

<Remaining limitations or follow-up work, or `None`.>

## References

### Repositories

- `<repository URL>` at `<full commit hash>`

### Documents

- [<document title>](<relative path>)

### Related Worklogs

- [<project and timestamp>](<relative path>)
```

Use one log per affected project. When a task spans projects, every produced
log must link to all sibling logs under `Related Worklogs`. Use relative
Markdown links for repository-local documents. Preserve historical logs;
change one only to correct inaccurate content or a broken link.

## Reading Knowledge

Knowledge has two scopes:

- `knowledge/common/` for material shared across projects;
- `knowledge/projects/<project>/` for project-specific material.

Read knowledge in this order:

1. Open `knowledge/INDEX.md` to locate the scope.
2. Open the scope's `INDEX.md` to select a topic.
3. Open the topic's `INDEX.md` to locate documents.
4. Read the selected document and follow its related-knowledge and supporting
   worklog links when they affect the task.
5. For a repository source, use its URL, ref, resolved commit, and immutable
   status. Materialize it with `ref-repo.sh` when local source inspection is
   needed.

Do not infer current behavior from an old mutable branch reference. Refresh the
branch with `ref-repo.sh` before relying on it.

## Reference Repositories

Use:

```sh
./ref-repo.sh [--immutable] <repo-url> <ref>
```

- Use `--immutable` for tags.
- Full 40- or 64-character commit hashes are automatically immutable.
- Omit `--immutable` for branches and other refs that can move.
- Treat returned checkouts as disposable, read-only reference material.
- Never commit anything under `ref-repos/`.

The helper prints one absolute checkout path on stdout. Diagnostics go to
stderr. Cite the original URL and resolved commit, never the cache path.

## Delivery Checks

Before committing, verify that:

- all new repository content is English;
- every new file follows its contract above or in `UPDATE_KNOWLEDGE.md`;
- all affected indexes contain valid relative links;
- cross-project logs link to one another;
- no `ref-repos/` content is tracked;
- each worklog records the validation actually performed.

Commit only intended repository-management changes. Do not include unrelated
project changes.
