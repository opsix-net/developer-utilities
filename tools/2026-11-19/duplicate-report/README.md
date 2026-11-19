## duplicate-report

`duplicate-report` reports byte-identical files beneath a directory and estimates the storage represented by redundant copies. It is read-only: it never deletes, moves, renames, or modifies files. Treat the report as evidence for a human review, not as an instruction to remove assets. This conservative separation between observation and action is useful in research and engineering workflows where a mistaken cleanup could remove a valuable input or an independently managed copy.

### Prerequisites

Run the Bash launcher in an environment with Bash and Python 3 available. The script invokes `${PYTHON_BIN:-python3}`, so it uses `python3` by default; set `PYTHON_BIN` to select a different Python 3 executable. The Python algorithm is self-contained and has no third-party dependencies. It requires access to read the files being inspected.

### Input and launch

The required `--root` argument is a directory to inspect. The tool considers regular files below that directory, recursively. It skips symbolic links and paths with any hidden component, meaning any relative path component that starts with a dot. File contents are read as bytes, so the comparison does not depend on filenames, extensions, or media type.

From the directory containing the script, run:

```bash
bash duplicate-report.sh --root ./assets
```

The root must exist and be a directory. Argument parsing reports errors for an absent root argument or an invalid root. The script does not accept or implement deletion options.

### Reading the output

On success, standard output contains formatted JSON with `duplicate_groups` and `potential_redundant_bytes`. Each group reports a SHA-256 digest, `bytes_each`, the relative paths sharing that digest, and `redundant_bytes`. For a group of $n$ identical files of size $s$, the reported redundant amount is $s(n-1)$: one copy is treated as the retained reference, and the other $n-1$ copies are potential redundancy. The total is the sum across groups. It is a storage estimate, not a promise that files can safely be removed or that a storage system will reclaim exactly that amount.

### How it works and limitations

The tool sorts paths, groups regular files by byte size, and hashes only size groups containing at least two files. SHA-256 is computed incrementally in 1 MiB chunks. Files with the same size and digest are reported together. Size grouping avoids hashing files that cannot match by length. For $N$ eligible files and $B$ bytes read among files in candidate size groups, traversal and sorting add path-processing overhead, while hashing work is proportional to $B$. Memory use includes the discovered paths and grouping data; file contents are not loaded all at once.

The report identifies exact byte identity, not semantic or visual equivalence. Re-encoded images, normalized datasets, or text files differing only in line endings will not count as identical unless their bytes match. Hidden paths and symlinks are intentionally skipped. A file may change while the scan is in progress, and permissions, I/O errors, or other filesystem conditions can prevent a complete report. Review the output and the files' ownership, provenance, and pipeline role before taking any separate cleanup action.

A book discussion of semantic modeling motivates a useful general workflow principle: state what evidence supports a relationship and do not silently turn a cautious observation into a stronger claim. This utility applies that principle to asset inspection, but the book does not specify or endorse this particular program.

## Reproducible setup and checks

```bash
bash duplicate-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Semantic modeling for data - avoiding pitfalls and breaking -- Panos Alexopoulos; Safari, an OReilly Media Company, Chapter 7. Bad Semantics. The implementation is an independently written practical utility.
