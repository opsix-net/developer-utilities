## Duplicate Report

`duplicate-report` reports identical files and potential redundant storage under a directory. It is a read-only report: it never deletes or changes files. This is useful before a research dataset migration, an image-processing run, or an asset-pipeline cleanup. Fourier analysis teaches us to describe data through its structure rather than its appearance; in storage work, a related habit is to compare file content rather than trust filenames. This utility applies that engineering idea to byte-for-byte file identity. The book topic motivates the workflow, but does not specify this tool.

### Prerequisites

The launcher is a Bash script that runs Python 3. It uses only the Python standard library and has no third-party dependencies. Set `PYTHON_BIN` to choose a Python executable if `python3` is not the desired command. Run it from an environment where the root directory is readable.

### Input and launch

The required input is a directory supplied with `--root`. The utility recursively inspects regular files beneath that root. Symbolic links beneath the root and paths with any hidden component, meaning a relative path part beginning with `.`, are skipped. File names are not treated as evidence of identity: content is compared using SHA-256 after candidates have been grouped by file size.

```bash
bash duplicate-report.sh --root ./assets
```

The command prints indented JSON to standard output. Argument and filesystem errors are reported by `argparse`. The tool does not offer cleanup, deletion, or other mutation commands.

### Reading the report

`duplicate_groups` contains one entry for each set of identical files. Each entry includes the shared `sha256` digest, `bytes_each`, relative `paths`, and `redundant_bytes`. For a group of $n$ identical files, `redundant_bytes` is `bytes_each * (n - 1)`: it counts the bytes beyond one retained copy. `potential_redundant_bytes` sums that value across groups. It is a potential saving, not a guarantee about filesystem allocation, compression, hard links, or storage billing.

An empty group list means no duplicate group was found among the files this run examined. The report is descriptive. It makes no statistical-significance or causal claim, and it does not infer whether duplicates are intentional.

### Algorithm and complexity

The script sorts paths from a recursive traversal, skips symlinks, non-files, and hidden paths, then groups eligible files by byte size. Groups with fewer than two files need no hashing. Files in candidate groups are read in 1 MiB chunks and hashed with SHA-256; matching digests form duplicate groups. Sorting sizes, paths, and digest groups makes report ordering stable for the same filesystem contents and traversal results.

Let $B$ be the total bytes read for files in size groups containing at least two files, and $P$ the number of paths. Hashing takes time proportional to $B$, plus per-file overhead, with additional traversal, sorting, and bookkeeping costs. Memory use includes path and group metadata; file contents are streamed rather than loaded all at once.

### Limitations and safe use

Identity here means equal size and equal SHA-256 digest. Hashing is a practical content-comparison method, not a byte-by-byte proof against every conceivable collision. The tool examines the filesystem as it is observed, so changes during a scan can affect results. Permissions, I/O failures, and unusual filesystem behavior can prevent a complete report. Hidden paths and symlinks are intentionally excluded, and only regular files beneath the specified root are considered. Review the report and your retention requirements before making any separate storage changes.

## Reproducible setup and checks

```bash
bash duplicate-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Understanding Fourier Transforms with Python, Chapter 6: Fourier Transform in Image Processing. The implementation is an independently written practical utility.
