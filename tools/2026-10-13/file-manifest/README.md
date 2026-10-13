# file-manifest

`file-manifest.sh` produces a deterministic SHA-256 inventory of build artifacts or research outputs without modifying any files. It prints JSON containing each included file's relative path, byte count, and digest, plus totals. The tool is useful when a team needs to review exactly which artifacts are present before publishing a model, transferring a dataset, or comparing outputs from two pipeline runs.

## Prerequisites

The launcher requires Bash and Python 3. It uses only the Python standard library, with no third-party dependencies. The script invokes `python3` by default. If Python is available under a different executable name or path, set `PYTHON_BIN` when launching it.

## Input and launch

Pass `--root` followed by the directory to inventory. For example:

```bash
bash file-manifest.sh --root ./artifacts
```

The root must be a directory. The utility recursively examines its contents. It skips symbolic links, non-files, and any path with a hidden component, meaning a path component whose name starts with `.`. This also excludes files in hidden directories. It does not accept a file as the root.

To select a Python executable explicitly:

```bash
PYTHON_BIN=python3 bash file-manifest.sh --root ./artifacts
```

## Reading the output

The command prints formatted JSON to standard output. `files` is an array sorted by the traversal's sorted path order. Each entry has a root-relative POSIX-style `path`, a `bytes` count from the file's size, and a lowercase hexadecimal `sha256` digest. `file_count` is the number of included files, and `total_bytes` is the sum of their byte counts. An empty eligible file set produces an empty `files` array and zero totals.

The digest identifies file content for comparison, while the path and byte count provide useful context. A changed digest indicates different bytes with overwhelming practical sensitivity, but the inventory does not establish who created a file, whether it is safe, or whether it is scientifically valid. Preserve the printed inventory alongside release or experiment records if it is needed for later comparison.

## Algorithm and complexity

The script sorts paths returned by recursive traversal, filters out symlinks, non-files, and hidden paths, then reads each eligible file in binary chunks of 1 MiB. It updates SHA-256 incrementally, so it does not need to load an entire large artifact into memory. Hashing takes time proportional to the total number of bytes read. Traversal and sorting also require work proportional to the number of paths, with sorting typically $O(m \log m)$ for $m$ discovered paths. Memory use includes the path list and output records, plus a bounded file-reading buffer.

## Concrete limitations

This is a snapshot, not a transactional filesystem capture. Files changed while the command runs can produce an inventory that does not correspond to one simultaneous instant. The tool skips symlinks and hidden paths by design, so its output is not a complete inventory of everything reachable from the root. It does not hash directory metadata, permissions, ownership, timestamps, or link targets, and it does not modify files. Because clustering results depend on documented preprocessing and data choices, a manifest can help identify the exact output files being reviewed; it cannot explain or validate the analysis that produced them.

## Reproducible setup and checks

```bash
bash file-manifest.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** An Introduction to Statistical Learning  with Applications in R, 401 A Tempered Approach to Interpreting the Results of Clustering. The implementation is an independently written practical utility.
