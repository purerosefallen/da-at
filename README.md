# Team Agent Knowledge Repository

This repository is the shared, versioned record of team work and reusable
technical knowledge.

- `worklogs/` records tasks that make substantive modifications or for which
  the user explicitly requests logging. Knowledge changes always require a
  worklog.
- `knowledge/` contains curated knowledge only when a user explicitly requests
  knowledge organization.
- `ref-repo.sh` creates short-lived, shallow reference checkouts under the
  ignored `ref-repos/` cache.
- `_example/` directories under dynamic worklog and project-knowledge roots
  provide complete copyable structures without representing real data.

Read [AGENTS.md](AGENTS.md) before starting work. It defines the required pull,
research, logging, indexing, commit, and push workflow. When the user explicitly
requests a knowledge change, also read
[UPDATE_KNOWLEDGE.md](UPDATE_KNOWLEDGE.md).
