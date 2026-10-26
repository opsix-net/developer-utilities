## Purpose

`file-manifest.sh` produces a deterministic SHA-256 inventory of eligible files beneath a directory. It does not modify files. The JSON output records each relative path, byte count, and SHA-256 digest, along with a file count and total byte count. This can help a research group compare exported datasets or help a build pipeline inspect artifacts before archiving or release. It is an inventory, not a signature, malware scanner, or proof that an artifact is trustworthy.

The accompanying Python foundations topic motivates a useful engineering habit: make inputs and transformations inspectable. A manifest applies that idea to files. The book chapter does not specify this utility; it is a practical workflow tool built around reproducible inventory and integrity checks.

## Prerequisites

The launcher is Bash and invokes Python 3. There are no third-party Python dependencies. Ensure `bash` and `python3` are available. To select a different Python 3 executable, set `PYTHON_BIN`, for example `PYTHON_BIN=/usr/bin/python3`. The target root must already be a directory and must be readable for the files being inventoried.

## Input and launch

The required input is a directory supplied with `--root`. Run the script from a shell:

```bash
bash file-manifest.sh --root ./artifacts
```

The tool reads files under that root. It skips symlinks, non-file paths, and any path whose relative path contains a component beginning with a dot. That means hidden directories and hidden files are excluded. It does not follow symlinks as inventory entries. No output file is created; JSON is printed to standard output.

## Output interpretation

The JSON object contains `files`, `file_count`, and `total_bytes`. Each item in `files` has a root-relative POSIX-style `path`, the file's `bytes`, and a lowercase hexadecimal `sha256` digest. Paths are sorted before processing and JSON object keys are sorted for output, so the inventory order and serialization are deterministic for the same eligible paths and contents. `file_count` is the number of listed files. `total_bytes` is the sum of their reported sizes.

To compare two inventories, compare the relevant paths, sizes, and digests. A matching digest is evidence that the bytes read for those files match, subject to SHA-256's cryptographic assumptions. It does not establish who created the files, when they were created, or whether the contents are correct for a scientific or software purpose.

## Algorithm and cost

The script recursively enumerates paths beneath the root, sorts them, filters excluded entries, and hashes each eligible file with SHA-256. File contents are read in chunks of 1 MiB, so hashing does not require loading an entire large file into memory. If the total eligible content is $B$ bytes and there are $N$ discovered paths, work is approximately $O(N \log N + B)$, with sorting accounting for the path term. Memory use includes the collected path list and output records, plus a bounded content chunk; it is not constant overall because the inventory itself must be assembled.

## Limitations and safe use

The manifest is a snapshot assembled while files are read. Files changing during execution can make the inventory inconsistent with any single instant. The tool does not lock files or verify permissions or provenance. `Path.rglob` may suppress directory-scanning errors, so inaccessible subtrees can be omitted without a diagnostic. It does not inspect file formats or write a manifest for later comparison. It skips hidden paths and symlinks by design, so its inventory is not a complete view of every directory entry. It reports filesystem size and hashes bytes read; filesystem changes during processing can affect results. Store or redirect output separately if a saved record is needed, and protect that record using your normal provenance controls.

## Reproducible setup and checks

```bash
bash file-manifest.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Coding Black Scholes_ Mastering Algorithmic Options Trading -- Van Der Post, Hayden -- 2024 -- Reactive Publishing, Chapter 2: Basics of Python Programming for Finance. The implementation is an independently written practical utility.
