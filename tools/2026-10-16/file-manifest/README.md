## Overview

`file-manifest.sh` produces a deterministic SHA-256 inventory of files beneath a directory. It prints JSON to standard output and does not modify the files it inventories. This is useful after a research-data or software build pipeline produces artifacts: save the inventory with a run record, then use it as a basis for later comparisons. A matching hash is evidence that file content matches, not proof that the content is valid or trustworthy.

The workflow is motivated by a broader research-engineering concern: reproducibility depends on knowing which inputs and outputs a run used. Public market-data ingestion adds source, time, and licensing questions, while this utility addresses only the local file-content inventory. The book’s discussion of API fetching motivates the surrounding workflow; it does not specify this utility.

## Prerequisites

The launcher is Bash and invokes Python 3. No third-party Python packages are required. Ensure `python3` is available on `PATH`, or set `PYTHON_BIN` to the Python 3 executable to use. Run the script from a shell with permission to read the target files.

## Input and launch

The required `--root` argument names a directory to inventory. The utility recursively considers regular files below it. Symlinks and hidden paths are skipped. A path is considered hidden if any component of its relative path begins with a dot.

```bash
bash file-manifest.sh --root ./artifacts
```

To select a Python interpreter explicitly:

```bash
PYTHON_BIN=/usr/bin/python3 bash file-manifest.sh --root ./artifacts
```

The root must be a directory. The utility reads files in binary mode and does not change their contents or metadata intentionally.

## Output interpretation

The utility prints a JSON object with `files`, `file_count`, and `total_bytes`. Each item in `files` has a relative POSIX-style `path`, a `bytes` size, and a lowercase hexadecimal `sha256` digest. Paths are sorted before inventory generation, and JSON keys are emitted in sorted order, so the same visible files with the same contents produce stable output. `file_count` is the number of included files. `total_bytes` is the sum of their recorded sizes. An empty eligible tree produces an empty `files` array and zero totals.

A digest can help detect content changes when manifests are compared. The tool does not compare against an earlier manifest, sign output, verify provenance, upload results, or decide whether a change is acceptable. Redirect standard output if you want to save the JSON, for example:

```bash
bash file-manifest.sh --root ./artifacts > manifest.json
```

## Algorithm and limits

The script sorts paths returned by recursive traversal, skips symlinks, non-files, and paths with hidden components, then streams each file into SHA-256 in chunks of 1 MiB. It reports each file’s stat size and adds those sizes for the total. If there are `N` eligible files containing `B` total bytes, hashing work is O(B), with additional path sorting of O(N log N). Memory use for file content is bounded by the chunk size, apart from the collected file records and traversal/sorting data.

The inventory is deterministic for a stable tree, but files changing during the run can produce a manifest that does not represent one atomic snapshot. Symlinks are deliberately excluded, hidden paths are deliberately excluded, and special files are not inventoried. The tool does not detect hard-link identity, preserve permissions or timestamps, normalize file contents, or establish data quality. Read errors, an invalid root, and related input errors are reported through argument-parser errors and a nonzero exit. Treat the output as a content inventory, not a complete supply-chain attestation.

## Reproducible setup and checks

```bash
bash file-manifest.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Rust Programming for your First Finance Job- A Comprehensive -- Publishing, Reactive & Van Der Post, Hayden, 7.2 Fetching Market Data from Public APIs. The implementation is an independently written practical utility.
