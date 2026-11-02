# CSV Profile

`csv-profile` reports missing-value counts, row-shape problems, and descriptive numeric statistics for each column in one UTF-8 CSV file. It is useful as a first check before loading measurements into a research pipeline, building a dashboard, or preparing data for an optimization model. For example, a scientist can quickly see whether blank sensor readings are common, whether some records have the wrong number of fields, and what range of finite numeric values appears in each column. This inspection can reveal issues; it does not validate a scientific hypothesis or establish that the data are representative.

## Requirements

The launcher is Bash and invokes Python 3. The Python algorithm uses only the standard library, with no third-party dependencies. If Python is installed under a different command, set `PYTHON_BIN` to that executable. The input must be readable as UTF-8 CSV and have a unique, nonempty header row. A UTF-8 byte-order mark is accepted.

## Run

From the directory containing the script:

```bash
bash csv-profile.sh --file measurements.csv
```

The `--file` argument is required. The program writes indented JSON to standard output. It reads records using Python's CSV reader, so quoted fields and embedded CSV delimiters are handled by that reader.

## Read the result

The top-level `rows` value counts data records after the header. `ragged_rows` lists their CSV record numbers, starting with 2 for the first data record, for records whose field count differs from the header. `ok` is true only when that list is empty. Each column reports `missing`, `numeric_count`, `numeric_mean`, `numeric_min`, and `numeric_max`.

A value is missing when its field is empty or contains only whitespace. Nonblank values that cannot be parsed as floating-point numbers do not contribute to numeric statistics. Parsed nonfinite values, including NaN and infinities, are also excluded. The sum of included finite values can nevertheless overflow for extreme data, preventing JSON output. The mean is the sum of included finite values divided by `numeric_count`; when that count is zero, the mean and minimum and maximum are JSON `null`. Ragged records are listed and skipped for all per-column counts and statistics, since their fields cannot safely be aligned to the header.

A file or header error is reported through the command-line parser. If ragged records are found, JSON is still printed, but the process exits with status 1. A clean profile exits successfully.

## Method and limits

The utility makes one pass through the CSV. For $N$ data records and $C$ columns, parsing and profiling take $O(NC)$ time in the usual field-count model. Per-column counters and numeric accumulators use $O(C)$ space, plus storage for the line numbers of ragged records. It computes descriptive summaries only. It does not infer types, impute missing values, normalize fields, detect outliers, test significance, or support causal conclusions. Numeric-looking identifiers may be summarized as numbers, so interpret column results in light of the data dictionary. The reported record number is the CSV reader's record enumeration, which may not match physical lines when quoted fields contain embedded newlines.

The book topic motivates a useful workflow principle: expose intermediate structure before relying on a downstream model. Lifted mathematical formulations make hidden variables explicit; this script makes basic CSV structure and numeric behavior visible. That is an analogy for responsible inspection, not a claim that the book specifies or implements this utility.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Geometry of Linear Matrix Inequalities_ A Course in -- Tim Netzer, Daniel Plaumann -- Compact Textbooks in Mathematics, Selected body passage. The implementation is an independently written practical utility.
