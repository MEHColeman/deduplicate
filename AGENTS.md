# deduplicate — agent instructions

Ruby CLI that deletes duplicate files (by content hash) across directories
listed in a YAML config. Entry point is the `deduplicate` executable; logic in
`lib/` (cache_manager, config_loader, duplicate_file_cleaner); hash cache
persists in `hash_cache.json` (large — do not read it whole).

Conventions: plain Ruby, stdlib only, no Gemfile; tests are RSpec in `spec/`
(`rspec spec/`). This tool deletes files — prefer `--dry-run` when testing.

Standard docs: `README.md` (what/install/run), `docs/TODO.md` (task list),
`docs/journal.md` (session journal).
