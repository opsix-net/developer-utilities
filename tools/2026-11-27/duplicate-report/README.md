## Purpose

`duplicate-report` inventories byte-for-byte identical files beneath a directory and estimates the storage that could be redundant if one copy from each identical group were not needed. It only reports. It never deletes or changes files. This is useful in research and asset pipelines where repeated datasets, exported images, model artifacts, or build products can consume storage and make it harder to identify the intended input.

The credit-risk discussion in the accompanying article emphasizes that data provenance and instrument identity matter before analysis. This utility supports one small operational part of that workflow: finding identical stored content for a human to review. It does not validate market observations, establish which copy is authoritative, or assess financial meaning. The book does not specify this utility.

## Requirements and input

The launcher is Bash and invokes Python 3. The algorithm uses only the Python standard library, with no third-party dependencies. Put `duplicate-report.sh` on your system and make it executable if you want to launch it directly. Pass one required option, `--root`, naming the directory to inspect:

```bash
chmod +x duplicate-report.sh
./duplicate-report.sh --root ./assets
```

The equivalent Bash invocation is:

```bash
bash duplicate-report.sh --root ./assets
```

The root must be a directory. The scan skips symlinks, non-files, and any path whose relative path has a component beginning with a period. This means hidden files and files inside hidden directories are excluded. Regular files are read as bytes, regardless of their filename extension or format. The script does not follow a symlink as a candidate file.

## Output

The program prints JSON with `duplicate_groups` and `potential_redundant_bytes`. Each group contains a SHA-256 digest, `bytes_each`, the relative `paths`, and `redundant_bytes`. A group reports files with matching size and matching SHA-256 digest. Its redundant-byte estimate is file size multiplied by the number of copies beyond one. The top-level value is the sum of those group estimates. It is a potential saving, not a promise that deleting files is safe or possible.

An empty group list means no duplicate groups were found among the included files. Errors such as an invalid root or file-opening errors are reported through argparse’s error handling. Review the JSON and file provenance before making any separate storage decision. This utility makes no changes.

## Algorithm and complexity

The script walks paths under the root in sorted order, groups regular files by byte size, and hashes only size groups containing at least two files. SHA-256 is computed by reading each candidate in 1 MiB chunks. Files are grouped by digest, and only groups with multiple paths are reported. Grouping by size avoids hashing files that cannot be identical because their lengths differ.

The traversal and bookkeeping depend on the number of paths. Hashing work is proportional to the total bytes read from files in repeated-size groups, with additional filesystem and sorting overhead. Memory use includes path and grouping metadata, rather than the full contents of each file.

## Limitations

SHA-256 equality is used as the content-identity test; the tool does not perform a byte-by-byte comparison after matching digests. It does not compare semantic or normalized content, inspect file formats, detect near-duplicates, or identify duplicates outside the selected root. Concurrent changes during scanning can affect results. Permissions, filesystem errors, and unusual filesystems can also limit a scan. Hidden paths and symlinks are deliberately excluded. The report is an inventory aid, not a deletion tool, backup policy, provenance system, or validation of scientific or financial data.

## Reproducible setup and checks

```bash
bash duplicate-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Advanced Financial Risk Management_ Tools and Techniques for Integrated Credit Risk and Interest Rate Risk Management, 30.000 Years to Maturity. The implementation is an independently written practical utility.
