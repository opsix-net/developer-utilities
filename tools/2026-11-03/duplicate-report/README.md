# duplicate-report

`duplicate-report` reports identical files and estimates potential redundant storage. It never deletes, moves, or modifies anything. The utility is intended for asset pipelines, research archives, and storage reviews where a human should inspect findings before deciding what to do.

## Requirements

The launcher is Bash and invokes Python 3. The Python algorithm is self-contained and uses only the standard library. No third-party packages are required. Place `duplicate-report.sh` in your project and make it executable if you want to invoke it directly:

```bash
chmod +x duplicate-report.sh
```

## Input and launch

The required `--root` argument names a directory to inspect. The tool considers regular files beneath that directory, skips symbolic links, and skips any path whose relative path contains a component beginning with a dot. Run it with the exact CLI form:

```bash
bash duplicate-report.sh --root ./assets
```

The command writes a JSON report to standard output. Invalid roots and filesystem or input errors are reported through argparse as command-line errors. The tool does not accept file patterns, a deletion mode, or other operational options beyond the required root argument; `--help` displays usage.

## Reading the report

The JSON object has `duplicate_groups` and `potential_redundant_bytes`. Each group contains a SHA-256 digest, `bytes_each`, the relative `paths` with matching contents, and `redundant_bytes`. For a group of three identical 200-byte files, for example, the estimate is $200 \times (3-1)=400$ bytes: one copy is treated as the retained copy for accounting purposes. The report does not choose a file to retain. The total is the sum of the group estimates, not a promise that a particular storage system will reclaim exactly that amount.

## How it works

The utility walks paths in sorted order, groups eligible files by byte size, and hashes only size groups containing at least two files. It reads file contents in chunks of 1 MiB and uses SHA-256. Files are reported together only when both their sizes and their SHA-256 digests match. Size filtering avoids hashing files that cannot be identical by byte length. For $N$ eligible files and $B$ bytes read across candidate size groups, traversal and bookkeeping depend on the number of paths, while hashing takes $O(B)$ time; memory use includes path and digest groupings, but file contents are streamed rather than loaded whole into memory.

A useful research workflow is to run the report on generated outputs, instrument collections, or image and model asset directories before archiving them. The chapter's emphasis on turning ordered observations into explicit, inspectable inputs motivates the same engineering habit here: make the data being examined and the resulting evidence clear. That connection is a practical analogy, not a claim that the book specifies this utility.

## Limitations and safety

The report identifies byte-identical files, not visually similar images, equivalent scientific datasets, or files that differ only in metadata. It skips hidden paths and symlinks by design, so its report is not a complete inventory when those matter. Files that change during a scan may yield inconsistent observations or an I/O error. SHA-256 is used as the equality check; the tool does not perform a byte-by-byte confirmation after matching hashes. Review paths and application requirements before any separate cleanup. This utility itself never deletes anything.

## Reproducible setup and checks

```bash
bash duplicate-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Python for algorithmic trading - from idea to cloud -- Yves J Hilpisch, Chapter 5. Predicting Market Movements with Machine Learning. The implementation is an independently written practical utility.
