# Da'at

Da'at is a Git-based framework for tracking active todos, recording project
work, and maintaining reusable technical knowledge. It combines indexed
Markdown, explicit working rules, copyable templates, and small supporting
tools so that a repository can preserve both what happened and what can be used
again.

## Why Da'at?

Da'at takes its name from the Hebrew word for "knowledge" in the Kabbalistic
tradition. In that tradition, Da'at connects understanding with lived experience
and practice. The name reflects this project's purpose: turning recorded work
into knowledge that can guide future work. See
[The Sefirot by Nissan Dovid Dubov](https://www.chabad.org/library/article_cdo/aid/361885/jewish/The-Sefirot.htm)
for the background behind this connection.

## Repository Structure

- [AGENTS.md](AGENTS.md) defines the required pull, research, logging, indexing,
  commit, and push workflow.
- [UPDATE_KNOWLEDGE.md](UPDATE_KNOWLEDGE.md) defines how knowledge is created,
  organized, updated, and migrated into reusable tools.
- [UPDATE_TODOS.md](UPDATE_TODOS.md) defines how todos are added, updated,
  resolved, and abandoned, including removal commits and worklog evidence.
- [todos/](todos/INDEX.md) lists every active todo in this repository, with
  common and project-specific details. New todos require an explicit user
  request; completed authorized work can resolve an existing todo automatically.
  Todo details can reference knowledge, supporting worklogs, and other active
  todos, including prerequisites that block progress.
- [worklogs/](worklogs/INDEX.md) records tasks that make substantive modifications
  or for which the user explicitly requests logging. Knowledge changes and
  actual todo creations, status changes, resolutions, and abandonments always
  require a worklog.
- [knowledge/](knowledge/INDEX.md) contains curated knowledge and scope-local
  `tools/` projects. Updates require an explicit request or a bounded reuse-driven
  migration.
- [ref-repo.sh](ref-repo.sh) creates shallow reference checkouts under the ignored
  `ref-repos/` cache, with refresh and expiration rules.
- `_example/` directories under dynamic worklog, project-todo, and knowledge roots
  provide complete copyable structures without representing real data.
- [LICENSE](LICENSE) contains the framework's MIT license.

## Getting Started

1. **Fork or copy this repository to your own Git hosting platform.** On GitHub,
   fork Da'at into your personal or organization account. On another host, such
   as your organization's internal Git server, import the repository or push a
   copy to a new repository you control. Keep the Git history if you want to
   merge future framework updates.
2. Clone your fork or hosted copy and verify that `origin` points to that
   repository. Configure `git user.name` before recording work.
3. Read [AGENTS.md](AGENTS.md) and [the active todo list](todos/INDEX.md) before
   starting a task. Follow the knowledge-reading workflow and create worklogs
   only when the logging rules require them.
4. For an explicitly requested knowledge change or the permitted reuse-driven
   migration, also follow [UPDATE_KNOWLEDGE.md](UPDATE_KNOWLEDGE.md).
5. Before adding or changing todos, follow [UPDATE_TODOS.md](UPDATE_TODOS.md).
   Resolve an existing todo after verified authorized work or on an explicit
   manual-resolve request. Abandon only on an explicit user decision to give
   up execution. Commit the removal before recording its full hash in a worklog.
   Todo project scopes remain available after their last item is removed.

Keep real todos, worklogs, curated knowledge, and instance-specific tools in your
own repository. The upstream Da'at repository contains only the framework and its
reserved examples.

For a reference checkout, run:

```sh
./ref-repo.sh <repo-url> <ref>
```

Use `--immutable` for tags. Full commit hashes are automatically immutable;
branches are refreshed. Reference checkouts are disposable and must not be
committed.

Run the existing helper regression test with:

```sh
bash tests/ref-repo.test.sh
```

## Repositories

- [Moenext](https://code.moenext.com/nanahira/da-at)
- [GitHub](https://github.com/purerosefallen/da-at)

Both repositories publish the Da'at framework on the `master` branch.

## License

The Da'at framework is available under the [MIT License](LICENSE), copyright
2026 purerosefallen. This covers the framework documentation, instruction files,
reserved examples, shared scripts, and tests supplied by this upstream project.

Todos, worklogs, knowledge articles, and instance-specific tools added by
downstream repositories are outside this license grant. Merging Da'at does not
relicense that content; consult the applicable owners and license notices.
Existing third-party license notices must be retained.
