* Start system and acceptance tests with an empty Postgres DB instead of the "real" one
* Save backups to object storage instead of the local filesystem
* Double-check web security
* Can we build an audit trail, or at least add a note of what happened?
* View: Grouped by class, _how many_ parents are unreachable by eMail?
* Some roles are being delegated from the Elternbeirat, and not from the class (e.g. Schulkonferenz). For those, do not record the class where the parent is having this role for, or at least do not show it (in `to_s` etc)
