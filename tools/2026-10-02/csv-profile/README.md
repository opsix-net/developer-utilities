## Overview

`csv-profile.sh` profiles a CSV file’s row shape, blank cells, and finite numeric values. It emits JSON so a developer or researcher can inspect a dataset quickly or pass the result to another script. The utility reports descriptive summaries only; it does not assess statistical significance, infer causes, or determine whether data are scientifically valid.

The book topic motivates a real workflow: before a trading or research application consumes external observations, inspect basic structural and numeric quality. This utility supports that preliminary inspection. It is not part of the book’s implementation and does not validate financial meaning, market freshness, or trading rules.

## Prerequisites

- Bash
- Python 3 (the launcher uses `python3` by default)
- No third-party Python packages

The implementation accepts `PYTHON_BIN` as an environment override for the Python executable. For example, `PYTHON_BIN=python3 ./csv-profile.sh --file measurements.csv` uses the specified executable.

## Input format and launch

The file must be readable as UTF-8 (an optional UTF-8 byte-order mark is accepted) and have a header row with nonempty, unique column names. Run:

```bash
bash csv-profile.sh --file measurements.csv
```

The only declared command-line option is required: `--file PATH`. CSV quoting and delimiters follow Python’s standard CSV reader defaults, including comma as the delimiter. Each data record is expected to have the same number of fields as the header.

## Reading the output

The JSON object contains `ok`, `rows`, `ragged_rows`, and `columns`. `rows` counts data records, not the header. `ragged_rows` lists one-based CSV record numbers (with the header as record 1) whose field count differs from the header; those records are skipped when column summaries are calculated. `ok` is false when any such row is found, and the process exits with status 1 in that case.

Each column reports `missing`, `numeric_count`, `numeric_min`, `numeric_max`, and `numeric_mean`. A cell is missing when it is empty or contains only whitespace. Nonblank values that cannot be parsed as numbers are excluded from numeric statistics. Parsed nonfinite values such as NaN or infinity are also excluded. A column with no finite numeric observations has `null` minimum, maximum, and mean. Blank cells are counted as missing; nonnumeric text and nonfinite numbers are not counted as missing.

## Algorithm and limitations

The script reads records sequentially, checks each row’s field count, and updates per-column counters and numeric aggregates. Runtime is $O(nm)$ for $n$ data rows and $m$ columns, with working state proportional to the number of columns, apart from the list of ragged-row record numbers. Numeric means are computed as sum divided by numeric count using floating-point arithmetic.

This is a lightweight profile, not a complete CSV validator. It does not report unique values, distributions, quantiles, dates, units, correlations, or reasons for missingness. It does not trim or rewrite the source file, infer schemas, or decide whether a number is plausible. Ragged rows are reported but not profiled. Large numeric sums can lose floating-point precision or overflow, in which case JSON output fails. Treat the output as an initial quality signal and apply domain-specific validation before relying on the data.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Getting Started with Forex Trading Using Python, 4 Trading Application: What’s Inside?. The implementation is an independently written practical utility.
