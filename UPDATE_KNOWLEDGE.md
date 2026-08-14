# Knowledge Update Instructions

## Trigger

Use this file only when the user explicitly requests knowledge organization,
creation, consolidation, correction, or deletion. A normal task or its worklog
does not authorize a knowledge change. Every knowledge modification is a
substantive modification and requires a worklog, even when the rest of the task
is limited to questions, research, inspection, or diagnosis.

## Scope and Topic Selection

Choose exactly one scope for each knowledge document:

- `knowledge/common/` when the material applies across projects;
- `knowledge/projects/<project>/` when it depends on one project.

Project names follow the naming rules in [AGENTS.md](AGENTS.md). Every scope has
these topic directories:

- `architecture/`: components, boundaries, data flow, and system design;
- `workflows/`: repeatable development and team procedures;
- `operations/`: deployment, maintenance, monitoring, and recovery;
- `troubleshooting/`: symptoms, diagnoses, evidence, and verified remedies;
- `decisions/`: durable decisions, alternatives, and consequences.

Place a document in the narrowest fitting topic. Consolidate overlapping pages
instead of creating duplicates.

`knowledge/projects/_example/` is the reserved complete project-scope template.
Never assemble a new project knowledge scope manually. When
`knowledge/projects/<project>/` does not exist, copy
`knowledge/projects/_example/` to it, replace every `_example` value, and add
the project to `knowledge/INDEX.md`. Convert the example document into the
requested knowledge page or remove it when the new scope has no architecture
knowledge. Never modify the source template and never use `_example` as a real
project name.

## Knowledge Tree and Index Contracts

Each scope uses:

```text
<scope>/
  INDEX.md
  architecture/
    INDEX.md
    <topic>.md
  workflows/
    INDEX.md
    <topic>.md
  operations/
    INDEX.md
    <topic>.md
  troubleshooting/
    INDEX.md
    <topic>.md
  decisions/
    INDEX.md
    <topic>.md
```

Use lowercase kebab-case document filenames. Use stable subject names rather
than timestamps.

### Repository Knowledge Index

`knowledge/INDEX.md` must contain:

```markdown
# Knowledge Index

## Common

- [Common knowledge](common/INDEX.md)

## Template

- [Example project structure](projects/_example/INDEX.md)

## Projects

| Project | Index |
| --- | --- |
| `<project>` | [Open](projects/<project>/INDEX.md) |
```

Sort real projects lexicographically. Keep the table header even when no
projects exist, and do not add `_example` to the project table.

### Scope Index

Every scope `INDEX.md` must use:

```markdown
# <Common or Project Name> Knowledge

| Topic | Index | Description |
| --- | --- | --- |
| Architecture | [Open](architecture/INDEX.md) | Components, boundaries, and design. |
| Workflows | [Open](workflows/INDEX.md) | Repeatable development and team procedures. |
| Operations | [Open](operations/INDEX.md) | Deployment, maintenance, and recovery. |
| Troubleshooting | [Open](troubleshooting/INDEX.md) | Symptoms, diagnoses, and verified remedies. |
| Decisions | [Open](decisions/INDEX.md) | Durable decisions and their consequences. |
```

### Topic Index

Every topic `INDEX.md` must use:

```markdown
# <Scope Name> <Topic Name>

| Document | Summary |
| --- | --- |
| [<title>](<topic>.md) | <one-line purpose> |
```

Sort documents lexicographically by filename. Keep the table header when the
topic has no documents.

### Designated Operation Entry Points

Add an operation entry point only when the user explicitly designates a
knowledge document as the entry for a named operation. Do not infer entry-point
status merely because a document is under `operations/` or describes a
repeatable procedure.

Expose each designated entry point in both of these places:

1. In the scope `INDEX.md`, place this callout immediately after the title and
   before the topic table:

   ```markdown
   > **Operation entry point — <imperative action>:** [Open the procedure](<topic>/<document>.md).
   ```

2. In the owning topic `INDEX.md`, use the same `<imperative action>` as the
   document link label and begin its summary with `Primary entry point for`.

Write `<imperative action>` as a concise English verb phrase that reflects the
user's intended operation, such as `Operate DNS records`. Keep the underlying
knowledge filename and document title stable; an entry label is navigation,
not a reason to rename the document. When a scope has multiple explicitly
designated entries, add one callout per entry and sort the callouts
lexicographically by action label. Remove or update both index representations
when the user withdraws or changes the designation.

Keep `knowledge/INDEX.md` as the structural scope directory. Do not add
operation-level entry points there.

## Knowledge Document Contract

Every knowledge document must use every heading below. Use `None` when a
reference subsection has no entries.

```markdown
# <Knowledge title>

- Scope: `<common or project name>`
- Topic: `<topic>`
- Last updated: `YYYY-MM-DD HH:mm:ss UTC+8`

## Summary

<Concise durable conclusion.>

## Details

<Source-aligned explanation, architecture, procedure, or decision.>

## Constraints and Caveats

<Boundaries, version sensitivity, failure modes, or `None`.>

## References

### Related Knowledge

- [<title>](<relative path>)

### Supporting Worklogs

- [<member, project, and timestamp>](<relative path>)

### Repositories

| URL | Ref | Commit | Immutable |
| --- | --- | --- | --- |
| `<repository URL>` | `<requested ref>` | `<full resolved commit hash>` | `yes` or `no` |
```

Full commit hashes and tags are immutable. Branches are mutable. Always record
both the requested ref and the full resolved commit hash. Prefer primary source
repositories and link supporting knowledge and worklogs whenever possible.

## Update Procedure

1. Read the root, scope, and topic indexes before editing.
2. Read related knowledge and supporting worklogs.
3. Inspect source repositories at the cited refs. Use `ref-repo.sh` and refresh
   every mutable ref.
4. Update an existing page when it already owns the subject; create a new page
   only for a distinct durable subject.
5. Keep conclusions source-aligned and separate verified facts from caveats.
6. Update the topic, scope, and root indexes affected by the change.
7. Link the required worklog for the knowledge-update task.
8. Verify relative links, full commit hashes, immutable flags, UTC+8 timestamps,
   and English content.

When replacing obsolete knowledge, preserve useful history through Git and link
the replacement page from any document that must remain for context.
