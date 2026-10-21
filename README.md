# Da'at

Da'at is a Git-based framework for recording project work and maintaining
reusable technical knowledge. It combines indexed Markdown, explicit working
rules, copyable templates, and small supporting tools so that a repository can
preserve both what happened and what can be used again.

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
- [worklogs/](worklogs/INDEX.md) records tasks that make substantive modifications
  or for which the user explicitly requests logging. Knowledge changes always
  require a worklog.
- [knowledge/](knowledge/INDEX.md) contains curated knowledge and scope-local
  `tools/` projects. Updates require an explicit request or a bounded reuse-driven
  migration.
- [ref-repo.sh](ref-repo.sh) creates shallow reference checkouts under the ignored
  `ref-repos/` cache, with refresh and expiration rules.
- `_example/` directories under dynamic worklog and project-knowledge roots
  provide complete copyable structures without representing real data.
- [LICENSE](LICENSE) contains the framework's MIT license.

## Getting Started

1. Use Da'at as the starting point for your own worklog and knowledge repository.
   Keep the framework's history if you want to merge future updates.
2. Configure your instance's `origin` to point to its own repository and configure
   `git user.name` before recording work.
3. Read [AGENTS.md](AGENTS.md) before starting a task. Follow its knowledge-reading
   workflow and create worklogs only when its logging rules require them.
4. For an explicitly requested knowledge change or the permitted reuse-driven
   migration, also follow [UPDATE_KNOWLEDGE.md](UPDATE_KNOWLEDGE.md).

Keep real worklogs, curated knowledge, and instance-specific tools in your own
repository. The upstream Da'at repository contains only the framework and its
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

Worklogs, knowledge articles, and instance-specific tools added by downstream
repositories are outside this license grant. Merging Da'at does not relicense
that content; consult the applicable owners and license notices. Existing
third-party license notices must be retained.
