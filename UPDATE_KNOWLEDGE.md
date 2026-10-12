# Knowledge Update Instructions

## Trigger

Use this file when the user explicitly requests knowledge organization,
creation, consolidation, correction, or deletion, or when
[Reuse-driven migration](#reuse-driven-migration) applies while using existing
knowledge. A normal task or its worklog alone does not authorize another
knowledge change. Every knowledge modification, including tool migration, is a
substantive modification and requires a worklog.

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

Each scope also supports `tools/` for reusable executable projects. Tools are
not a document topic: each tool links to an owning document in one of the five
topics above. Keep shared tools in `knowledge/common/tools/` and project-bound
tools in `knowledge/projects/<project>/tools/`.

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
  tools/
    INDEX.md
    <tool-name>/
      README.md
      .gitignore
      <files required by the selected engineering form>
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
| Tools | [Open](tools/INDEX.md) | Reusable executable projects and their knowledge. |
```

New scopes copied from the template include the Tools row and `tools/INDEX.md`.
Existing scopes may retain their current structure until their first tool is
added; then add both the row and index. Do not restructure unrelated scopes.

### Tool Index

Every `tools/INDEX.md` must use:

```markdown
# <Scope Name> Tools

| Tool | Form | Knowledge | Summary |
| --- | --- | --- | --- |
| [<tool name>](<tool-name>/README.md) | `<python, nodejs, shell, or docker>` | [<knowledge title>](../<topic>/<document>.md) | <one-line purpose> |
```

Sort tools lexicographically by directory name. Keep the table header when no
tools exist. Use lowercase kebab-case tool directory names. Standard engineering
filenames such as `README.md`, `Dockerfile`, and npm manifests are allowed.

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
   Extract repeatable logic into reusable tools according to the contract below
   when reasonable, instead of leaving substantial executable logic only in
   Markdown code blocks.
6. Update the topic, scope, and root indexes affected by the change.
7. Link the required worklog for the knowledge-update task.
8. Verify relative links, full commit hashes, immutable flags, UTC+8 timestamps,
   and English content.

When replacing obsolete knowledge, preserve useful history through Git and link
the replacement page from any document that must remain for context.

## Reusable Tool Engineering

Prefer an executable project for logic that can be reused with different
runtime inputs. Keep it small, self-contained, and directly under the owning
scope's `tools/<tool-name>/`. Keep the knowledge document as the durable
explanation and operation entry point, linking to the tool and giving concrete
run commands. The tool README must link back to that document. Reuse an existing
project rather than creating a duplicate.

Choose exactly one primary form for each new tool:

### Python

Include the source, `requirements.txt`, `README.md`, and `.gitignore`. List all
third-party dependencies; keep `requirements.txt` even for a standard-library
tool and state that no dependencies are required. Prefer a project-local venv
for every invocation and document creation, dependency installation, and
execution through that environment. Ignore `.venv/`, other documented virtual
environment directories, `__pycache__/`, `*.py[cod]`, and applicable test caches.

### Node.js

Provide a complete npm project: `package.json`, committed `package-lock.json`,
source files, documented npm run scripts, `README.md`, and `.gitignore`. Declare
the supported Node.js version and all dependencies. Document `npm ci` and the
run command, even when the tool has no third-party dependencies. Ignore
`node_modules/`, npm debug logs, and applicable cache, coverage, and build output.

### Shell

Include the executable script with a shebang, `README.md`, and `.gitignore`.
State the required shell. Comments in the script must list every special
external command it uses and any required versions or nonportable features;
state explicitly when none are needed. Document invocation and ignore the
temporary files or output directories that the script can create.

### Docker

Include `Dockerfile`, `README.md`, `.dockerignore`, and `.gitignore`. The internal
language and project layout are unrestricted for this form. The knowledge
document must give concrete `docker build` and `docker run` commands, including
required input, mounts, and networking. Exclude dependency directories, caches,
temporary output, and secret files from both Git and the build context where
applicable.

### Common Project Contract

Each tool README must cover purpose, requirements, setup and startup commands,
inputs, outputs, operation effects, limitations, and the owning knowledge link.
Tool READMEs follow this engineering contract rather than the knowledge-document
heading contract. Keep all filenames, comments, and documentation in English.

Every tool must have its own `.gitignore` matching its actual dependencies and
temporary artifacts; root rules alone do not replace it. Ignore applicable
local configuration and `.env` files, without excluding required manifests or
lockfiles. Never persist credentials in source, documentation, logs, or runtime
artifacts merely because those artifacts are ignored. Use runtime input and
clean up temporary resources on success and failure. Provide validation suited
to the operation, and record only checks actually performed.

If a required runtime or command is absent on the local machine, use Docker
instead of installing it on the host. This fallback does not change the tool's
primary engineering form.

## Reuse-Driven Migration

When existing knowledge is used to perform a task, migrate its repeatable logic
if it can reasonably become a reusable tool and has no existing engineered
project. This narrow migration is authorized by the repository workflow without
an additional knowledge-organization request. Explicit user scope, including a
read-only restriction, takes precedence.

1. Read the owning knowledge, indexes, source evidence, and relevant worklogs.
2. Confirm that the procedure is not already implemented as an engineered
   project. If a corresponding tool project exists, do not silently migrate or
   rewrite the knowledge: that migration requires an explicit user request.
   Leave existing projects in place; do not improve or migrate them merely to
   satisfy this newer contract. Unrelated tools and empty `tools/` directories
   do not block migration of a procedure with no corresponding tool project.
3. Extract only the reusable logic, preserving its inputs, effects, checks, and
   operational limits. Choose one engineering form above and add its project.
4. Replace duplicated implementation blocks with tool links and usable commands.
   Retain explanations, provenance, caveats, and useful historical evidence.
5. Update the tool and owning knowledge indexes, validate the migrated behavior,
   and write the required worklog. Tests and external actions must stay within
   the user's authorized task; migration itself grants no additional operation.
