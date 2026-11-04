## duplicate-report

`duplicate-report` reports identical files and potential redundant storage under a directory. It is a read-only inspection tool: it never deletes, moves, or modifies files. This is useful when an asset pipeline accumulates exports, intermediate artifacts, or repeated research datasets and a developer needs evidence before deciding what to retain.

### Prerequisites

The launcher is a Bash script and invokes Python 3. The Python algorithm uses only the standard library, so there are no third-party Python dependencies. Ensure Bash and a Python 3 executable are available. By default the script uses `python3`; if Python 3 is available under another executable name, set `PYTHON_BIN` to that executable.

### Input and launch

The tool accepts a directory to inspect through its required `--root` option. It recursively considers regular files below that root. Symlinks and paths with any hidden component, meaning a path component beginning with `.`, are skipped. For example, `.cache/export.bin` is excluded because one component is hidden.

Run it from the directory containing the script:

```bash
bash duplicate-report.sh --root ./assets
```

To choose a Python 3 executable explicitly:

```bash
PYTHON_BIN=python3 bash duplicate-report.sh --root ./assets
```

A root that is not a directory produces an argument error. The report is written as formatted JSON to standard output. Errors encountered while inspecting files are reported through the argument parser's error handling.

### Reading the report

The top-level `duplicate_groups` array contains one entry per group of identical file contents. Each entry has a SHA-256 digest, `bytes_each`, the paths relative to the root, and `redundant_bytes`. The latter is calculated as `bytes_each * (number of paths - 1)`, representing the size beyond one retained copy within that group. `potential_redundant_bytes` is the sum of those group values.

For example, three identical files of 100 bytes have `redundant_bytes` of `100 * (3 - 1) = 200`. This is a storage estimate, not a deletion recommendation. Review ownership, provenance, references, and backup policy before taking any action.

### Algorithm and limitations

The utility walks paths in sorted order, groups eligible files by size, and hashes files only in size groups containing at least two files. It calculates SHA-256 incrementally in 1 MiB chunks. Files are reported as duplicates only when both size and digest match. As with any hash-based comparison, this is strong practical evidence, not a mathematical proof of byte identity. With $N$ eligible files and $B$ bytes read for hashing, traversal and sorting have filesystem and sorting costs, while hashing costs approximately $O(B)$ for files in candidate size groups. The implementation retains path lists and hash-group metadata in memory.

The report describes the files observed during that run. Concurrent changes can affect results, and the script does not provide a filesystem snapshot. It skips hidden paths and symlinks, does not inspect files outside the root, and does not delete anything. Identical bytes do not mean files are interchangeable in an application or research workflow. The book topic of systematic testing motivates a broader engineering habit, repeatable checks in controlled workflows, but the book does not specify this utility.

## Reproducible setup and checks

```bash
bash duplicate-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Serious Python - black-belt advice on deployment, Selected body passage. The implementation is an independently written practical utility.
