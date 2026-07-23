# deduplicate

Ruby command-line tool that finds and deletes duplicate files across a set of
directories listed in a YAML config (see `directories.yaml.example`). File
identity is by content hash, with hashes cached in `hash_cache.json` so
re-runs over large media trees are fast. Supports `--dry-run` and `--verbose`.

## Install

Requires Ruby (standard library only: digest, find, fileutils, json, yaml —
no Gemfile). For the test suite, install RSpec: `gem install rspec`.

## Run

```sh
./deduplicate [--dry-run] [--verbose] directories.yaml
```

Copy `directories.yaml.example` to your own YAML file listing the directories
to scan. Run the tests with `rspec spec/`.
