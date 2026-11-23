## Duplicate Report

`duplicate-report` scans a directory tree and reports groups of files with identical contents, along with the storage that could potentially be redundant. It is a read-only report: it never deletes, moves, or modifies files. This is useful when a research project, media pipeline, or build system accumulates repeated assets across exports and working directories. The practical connection to nearest-neighbor thinking is limited but useful: both workflows compare items to find meaningful relationships. Here the relation is exact byte-for-byte identity, not approximate similarity or a prediction.

### Requirements and input

The launcher is Bash and runs Python 3. The Python algorithm is self-contained and has no third-party dependencies. Run it in an environment with Bash and Python 3 available. Supply one directory using the required `--root` option. For example:

```bash
bash duplicate-report.sh --root ./assets
```

The root must be a directory, though the supplied root may itself be a symlink to one. The scan skips symlinks encountered beneath it and hidden paths. A path is skipped if any component relative to the root starts with a dot, so files beneath a hidden directory are excluded as well as hidden files. Regular files are considered. The tool does not accept a file list, compare separate roots, or identify visually similar images or semantically equivalent documents.

### Output

The command prints indented JSON. `duplicate_groups` is an array; each group contains a SHA-256 digest, `bytes_each`, the relative `paths` sharing that digest, and `redundant_bytes`. The latter is the size of one copy multiplied by the number of extra copies in that group. `potential_redundant_bytes` sums this value across reported groups. It is potential savings, not a promise of reclaimable capacity: links, snapshots, filesystem compression, or retention requirements may affect actual storage recovery. An empty array and a total of zero mean no exact duplicates were found among the files the scan considered.

Treat the report as an investigation aid. Check ownership, references, backup policy, and pipeline behavior before taking any separate cleanup action. This utility itself performs no cleanup.

### Algorithm and limitations

The script walks paths in sorted order, skips symlinks and hidden paths, and groups eligible files by byte size. It hashes files only in size groups containing at least two candidates. SHA-256 is computed from binary data in chunks of 1 MiB. Files are reported together only when both their sizes and digests match. Size bucketing avoids hashing files that cannot be byte-identical; hashing then distinguishes same-size files with different contents.

For $N$ eligible files totaling $B$ bytes, traversal and file metadata work scale with the number of paths, while hashing reads the bytes in candidate size groups. In the worst case, many files share a size and the tool reads all of those candidates, so hashing work can approach $O(B)$. Memory use includes path and grouping metadata and is proportional to the number of files, rather than holding file contents in memory. SHA-256 collision risk is not mathematically zero, though it is negligible for ordinary operational use.

The scan is not a filesystem snapshot. Files changing during the scan can produce inconsistent results or I/O errors. Permissions and storage failures can prevent inspection. The report does not follow symlinks, inspect hidden paths, compare metadata beyond size, or determine whether duplicate files are safe to remove. Use it to inform a reviewed storage workflow, not as an automated deletion policy.

## Reproducible setup and checks

```bash
bash duplicate-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Data Science for Dummies, 2nd Edition, 102 PART 2 Using Data Science to Extract Meaning from Your Data. The implementation is an independently written practical utility.
