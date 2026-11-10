## Overview

`duplicate-report` scans a directory and reports groups of files with matching SHA-256 digests, along with their potential redundant storage. It is useful when a research team collects instrument exports, when a build pipeline accumulates repeated assets, or when storage engineers need an inventory before planning cleanup. It is read-only: it reports findings and never deletes anything.

The connection to integrated-circuit design is methodological, not historical. The logic-design lesson is to assess an implementation using the resources actually in use, rather than relying on one abstract count. For storage work, file count alone is similarly incomplete. This utility adds byte sizes and SHA-256 digest comparison to help prioritize review. The book section does not specify this utility.

## Prerequisites

The launcher is Bash and invokes Python 3. There are no third-party Python dependencies. Run the command from a shell with Bash and Python 3 available. `PYTHON_BIN` can select a Python executable if `python3` is not the desired command, for example `PYTHON_BIN=/path/to/python3 bash duplicate-report.sh --root ./assets`.

## Input and launch

Supply one directory using the required `--root` option:

```bash
bash duplicate-report.sh --root ./assets
```

The root must be a directory. The tool recursively inspects regular files beneath it. Symbolic links, non-file paths, and paths with any hidden component are skipped. A hidden component is a path component whose name begins with a period, such as `.cache`.

It does not interpret file formats or normalize text. Files are grouped only when their sizes and SHA-256 digests match, so the report is a practical duplicate indicator, not byte-by-byte proof of identity.

## Output

The command prints formatted JSON with `duplicate_groups` and `potential_redundant_bytes`. Each group contains a SHA-256 digest, `bytes_each`, paths relative to the root, and `redundant_bytes`. For a group of $n$ files with the same size and digest, each of size $s$ bytes, the reported potential is $s(n-1)$ bytes. This treats one copy as retained and the other copies as potentially redundant. The top-level total is the sum across reported groups.

“Potential” is important. The report does not know whether duplicate files are required copies, backups, versioned deliverables, or safely removable. Review provenance, retention rules, and references before taking any action. The utility itself never deletes or modifies files.

## Algorithm and limitations

The program sorts paths, groups eligible files by size, and hashes only size groups containing at least two files. It computes SHA-256 in chunks of 1 MiB, then reports only digest groups containing multiple paths. Size bucketing avoids hashing files whose sizes cannot match. Hashing provides a practical content comparison, but the implementation does not perform a separate byte-by-byte confirmation after a digest match.

Traversal and sorting require work proportional to the number of paths, with memory used to retain path groups. Hashing reads the contents of files in repeated-size candidate groups; its I/O cost is proportional to the bytes read. Large files or a large candidate set can therefore take time and storage bandwidth. File changes during a scan can affect what is read, so use a stable snapshot when reproducibility matters.

The output is descriptive, not a policy decision or a guarantee of recoverable storage. It does not follow symlinks, inspect hidden paths, find near-duplicates, or determine whether files are safe to remove. It also does not produce statistical significance or causal conclusions. Treat its report as an inventory for careful engineering review.

## Reproducible setup and checks

```bash
bash duplicate-report.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Digital Principles and Logic Design, 5.8 COMBINATIONAL LOGIC WITH MSI AND LSI. The implementation is an independently written practical utility.
