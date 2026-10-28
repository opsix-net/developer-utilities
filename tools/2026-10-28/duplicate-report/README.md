# duplicate-report

`duplicate-report` scans a directory and reports groups of files with matching sizes and SHA-256 digests, along with their possible redundant storage. It is read-only: it never deletes, moves, or modifies files. Use it before an asset cleanup, dataset consolidation, or storage review when you need a report to inspect before taking any separate action.

## Prerequisites

The launcher is a Bash script and invokes Python 3. The Python algorithm uses only the standard library, so there are no third-party package dependencies. Run it in an environment with Bash and Python 3 available. The root supplied to the command must be an existing directory.

## Input and launch

Pass the directory to inspect with the required `--root` option. For example:

```bash
bash duplicate-report.sh --root ./assets
```

The utility recursively examines regular files under that root. It skips symlinks and paths containing hidden components, meaning any relative path component beginning with `.`. It does not follow symlink files as candidates. Argparse also provides `--help`; there are no other command-line options. The script permits selecting the Python executable through the `PYTHON_BIN` environment variable; otherwise it uses `python3`.

## Reading the JSON report

The program writes formatted JSON to standard output. `duplicate_groups` is an array. Each group contains a `sha256` digest, `bytes_each`, a list of root-relative `paths`, and `redundant_bytes`. Paths use forward slashes in the report. A group includes two or more files with the same size and SHA-256 digest.

`potential_redundant_bytes` sums the group's `redundant_bytes` values. For a group of $n$ identical files, each of size $s$ bytes, the reported amount is $s(n-1)$: it counts the bytes beyond one retained copy. This is a potential saving, not a recommendation or a promise about filesystem allocation, compression, snapshots, or deduplication features. An empty group list and a total of zero mean no matching file groups were reported under the scan rules.

## How it works and cost

The script sorts recursively discovered paths, ignores excluded entries, and groups candidate files by size. It computes SHA-256 only for files whose size is shared by at least two candidates. Hashing reads binary data in chunks of 1 MiB, avoiding loading each whole file into memory. A size match is only a filter; files are reported together only when their SHA-256 digests also match.

For $N$ discovered paths, path sorting is approximately $O(N\log N)$. Hashing work is proportional to the total bytes read from files in repeated-size groups, with additional filesystem and digest overhead. Peak file-content memory is bounded by the chunk size, apart from ordinary interpreter and metadata overhead.

## Limitations and safe use

This is a report, not a cleanup tool. Review paths and operational context before any separate removal or archival process. Files can change while a scan is running, so avoid scanning a directory being actively rewritten if you need a stable inventory. The report does not compare metadata, infer whether copies serve different purposes, or inspect symlink targets and hidden paths. It reports digest matches, not semantic equivalence between files with different bytes. SHA-256 collisions are theoretically possible, though the utility treats matching size and digest as an identical-file group. Permission and filesystem errors can prevent a successful report; error handling is provided by the command-line parser.

Ensemble learning motivates a useful engineering habit: separate measurement from the decision that follows it. A model's evaluation report should not silently become an operational action, and neither should a duplicate inventory. This utility applies that workflow principle to assets and research storage. The book passage discusses model ensembles, not this tool; the connection is a practical analogy about explicit checks and review before action.

## Reproducible setup and checks

```bash
bash duplicate-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Mastering Machine Learning with Python in Six Steps, Selected body passage. The implementation is an independently written practical utility.
