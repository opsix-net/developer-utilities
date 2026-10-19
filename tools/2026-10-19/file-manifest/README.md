# file-manifest

`file-manifest.sh` produces a deterministic SHA-256 inventory of eligible files beneath a directory. It reads file contents and prints JSON to standard output. It does not modify files. This is useful when a build, experiment, or data-processing run needs a compact record of which artifacts existed and what their bytes were at inventory time.

## Practical use

A research team might archive a simulation executable, configuration, and result files after a run. A release engineer might inventory a package staging directory before publishing it. Save the JSON output alongside the run record or transfer it separately with the artifacts. The inventory can then support later comparisons or checks of file identity. It is evidence about the files scanned, not a complete supply-chain attestation and not proof that the files are trustworthy.

The machine-transient modeling topic motivates a useful workflow distinction: physical models depend on initial conditions and precisely identified parameters. In the same spirit, reproducible engineering work benefits from recording exactly which output files were present. The book topic does not specify this utility; the connection is a practical workflow analogy.

## Prerequisites and input

The launcher is Bash and invokes Python 3. The algorithm uses only the Python standard library, with no third-party dependencies. If Python is not available as `python3`, set `PYTHON_BIN` to the desired Python executable. Run the script from a shell with access to the directory being inventoried.

The required input is a root directory. The tool accepts no file-list input and requires `--root` (argparse also provides `--help`):

```bash
bash file-manifest.sh --root ./artifacts
```

The root must be a directory. The tool recursively considers paths below it, but skips symlinks, non-files, and any path whose relative components include a name beginning with `.`. Hidden directories are therefore excluded along with hidden files. Paths in the result are relative to the root and use forward slashes.

## Reading the output

Standard output is an indented JSON object with three top-level fields:

- `files`: an array of records, each containing `path`, `bytes`, and `sha256`.
- `file_count`: the number of included files.
- `total_bytes`: the sum of their reported byte sizes.

The array is produced from sorted traversal, and JSON keys are sorted, making output ordering deterministic for an unchanged directory state. An empty eligible file set produces an empty array, count zero, and total size zero. Each SHA-256 value is calculated from the file's raw bytes, not from decoded text or metadata.

## Algorithm and limitations

For every eligible regular file, the script reads binary data in chunks of 1 MiB and updates a SHA-256 digest. If there are $N$ included bytes, hashing work is $O(N)$; traversal and ordering add filesystem-dependent work, including sorting paths. Memory use for file contents is bounded by the chunk size, apart from the collected path and result records. The script does not write a manifest file, lock files while reading, compare against a previous inventory, follow symlinks, or report skipped paths. Files changing during the scan can make the result reflect a mixed point in time. Errors raised while opening or statting files are reported through argparse's error path; traversal may skip inaccessible directories. For audit workflows, preserve the JSON output independently and control the directory and execution environment around the scan.

## Reproducible setup and checks

```bash
bash file-manifest.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Electrical Machines and Drives_ Fundamentals and Advanced Modelling, 30 Transient Phenomena in Electrical Machines. The implementation is an independently written practical utility.
