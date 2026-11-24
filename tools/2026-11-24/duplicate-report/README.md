## Duplicate Report

`duplicate-report` scans an asset directory and reports byte-identical files grouped by SHA-256 digest. It estimates potential redundant storage but never deletes, moves, or modifies files. Treat the report as an audit input, not as an automatic cleanup plan.

### Prerequisites

Run the Bash launcher with Bash and Python 3 available. The Python algorithm uses only the standard library; there are no third-party dependencies. The launcher honors `PYTHON_BIN` if you need to select a Python executable. From a shell, run:

```bash
bash duplicate-report.sh --root ./assets
```

The required `--root` argument names the directory to inspect. The root must be a directory. The command prints JSON to standard output. Argument and filesystem errors are reported by `argparse`, which exits with an error status.

### Inputs and scan rules

The input is a filesystem tree, not a manifest or a list of checksums. The scan sorts paths and considers regular files under the root. It skips symbolic links and any path whose relative components include a name beginning with a dot, including hidden directories and files. Empty files are eligible. The utility does not follow a symlink as a file to hash.

### Reading the output

The JSON object contains `duplicate_groups` and `potential_redundant_bytes`. Each group has a `sha256` digest, `bytes_each`, a list of root-relative POSIX `paths`, and `redundant_bytes`. A group represents files with the same size and SHA-256 digest. `redundant_bytes` is the size of one copy multiplied by the number of additional copies. The top-level value sums that estimate across groups. It is a potential saving if a project deliberately consolidates copies, not a promise that storage can safely be reclaimed. Identical content may be needed at multiple paths by applications, packaging rules, or deployment systems.

### Algorithm and practical use

The tool first groups eligible files by byte size. It hashes only files in size groups containing at least two paths, reading each in 1 MiB chunks. It then groups matching digests and reports groups with multiple paths. This avoids hashing files that cannot have a same-size duplicate. If there are $N$ eligible files and $B$ bytes across files that need hashing, the sorted traversal and bookkeeping require $O(N\log N)$ time and $O(N)$ path storage, while hashing work is proportional to $B$. Hashing uses bounded chunk memory, apart from path and group metadata. Runtime and I/O still depend on filesystem size and storage speed.

For a research asset pipeline, run the report before archiving image exports, simulation outputs, or shared datasets. A duplicate report can guide a human review of storage use and help identify repeated exports. This is an engineering workflow motivated by careful measurement and interpretation: a number is evidence for inspection, not permission to delete. The book topic discussed alongside this utility is statistical inference; it does not specify this utility.

### Limitations

The report detects byte-identical files, not visually or semantically equivalent assets. Different encodings, metadata, compression settings, or line endings produce different bytes and will not be grouped. SHA-256 is used as a content fingerprint; as with any hash-based report, do not treat it as a substitute for a separate verification step where the consequences of a mistaken consolidation are high. The scan is not a transactional snapshot: files can change during traversal or hashing. Permissions, I/O failures, and concurrent modifications can affect a run. Hidden paths and symlinks are intentionally omitted, so the result is not a complete inventory of all reachable storage. Review paths and application references before taking any separate action.

## Reproducible setup and checks

```bash
bash duplicate-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Math for Deep Learning - What You Need to Know to Understand, 0.8 Large. The implementation is an independently written practical utility.
