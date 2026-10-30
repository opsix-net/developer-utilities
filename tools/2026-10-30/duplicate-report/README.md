## duplicate-report

`duplicate-report` scans a directory and reports groups of files with matching SHA-256 digests, along with an estimate of potential redundant storage. It is designed for asset pipelines and storage engineering, including research teams that accumulate repeated exports, derived images, or build artifacts. It is a reporting tool only: it never deletes or modifies files. The book topic motivates a useful workflow principle, translating conditions into explicit checks before acting. This utility is an independent engineering example, not a tool specified by the book.

### Requirements and input

The launcher is Bash and invokes Python 3. The Python algorithm uses only the standard library, so there are no third-party dependencies. Provide a directory to inspect. The command-line interface accepts the required `--root` directory argument and the standard `-h`/`--help` option.

```bash
bash duplicate-report.sh --root ./assets
```

The root must be a directory. Regular files below it are considered unless their paths contain a hidden component, meaning a path component whose name begins with `.`. Symlinks are skipped. File contents can be arbitrary bytes; there is no filename extension or file-format requirement.

### Reading the report

The command prints indented JSON with two top-level fields. `duplicate_groups` is an array. Each group contains a SHA-256 digest, `bytes_each`, a list of relative POSIX-style `paths`, and `redundant_bytes`. The latter is calculated as `bytes_each * (number of paths - 1)`, treating one copy as retained. `potential_redundant_bytes` is the sum of that estimate across reported groups. It is a potential saving, not a guarantee that deleting files is safe or desirable. Review paths and application requirements before taking any separate action.

### How it works and limitations

The utility walks the root recursively, sorts paths, and groups eligible files by byte size. It hashes contents only for size groups containing at least two files, reading each candidate in 1 MiB chunks with SHA-256. Files are reported together only when their hashes match. Size is a preliminary filter, not proof of identity; the digest comparison is the content check used for grouping.

Let $N$ be the number of eligible files, $B$ the total bytes read among files in repeated-size groups, and $P$ the number of discovered paths. Sorting and traversal require roughly $O(P \log P)$ ordering work, while hashing costs $O(B)$ time. Memory use includes path records and hash-group metadata, approximately $O(P)$, rather than file contents.

The scan is a point-in-time report, not a transactional snapshot. Files can change during or after scanning. Permissions and I/O errors can prevent completion. Hard links are not separately identified, and identical content does not establish that copies are safe to remove. Hidden paths and symlinks are intentionally excluded, so this is not a complete inventory of every reachable file. No files are deleted.

## Reproducible setup and checks

```bash
bash duplicate-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Boolean Algebra and Its Applications (Dover Books on -- J_ Eldon Whitesitt [Whitesitt, J_ Eldon] -- INscribe Digital, [N_p_], 2012, 1 (a) Choose suitable words to express this connective in English.. The implementation is an independently written practical utility.
