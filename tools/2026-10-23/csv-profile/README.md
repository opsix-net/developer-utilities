# csv-profile

`csv-profile.sh` is a small command-line utility for inspecting a UTF-8 CSV before analysis. It reports blank fields, row-width mismatches, and descriptive statistics for finite numeric values. It is useful when a researcher receives a new instrument export or a developer wants a quick data-quality check before an automated import. It does not repair data or determine whether a dataset is scientifically valid.

## Requirements and input

The launcher is Bash and invokes Python 3. The Python algorithm uses only the standard library, so no third-party packages are required. Set `PYTHON_BIN` if the Python 3 executable is not available as `python3` on `PATH`.

The input must be a UTF-8 CSV file with a unique, nonempty header row. A UTF-8 byte-order mark is accepted. The CSV reader handles quoted fields according to Python's `csv` module. Header names must be unique as written, and names containing only whitespace are rejected. The utility has one required option, `--file`.

Run it from the directory containing the script:

```bash
bash csv-profile.sh --file measurements.csv
```

For a different Python 3 executable:

```bash
PYTHON_BIN=/path/to/python3 bash csv-profile.sh --file measurements.csv
```

## Reading the JSON result

The utility prints formatted JSON. `rows` is the number of data rows after the header. `ragged_rows` lists the CSV record numbers (counting the header as record 1) for data records whose number of fields differs from the header width. `ok` is true when that list is empty. Each entry under `columns` reports `missing`, `numeric_count`, `numeric_mean`, `numeric_min`, and `numeric_max`.

A field is missing when its value is empty or consists only of whitespace. A nonblank value is included in numeric statistics only if Python can parse it as a float and the result is finite. Thus text, `NaN`, and positive or negative infinity are excluded from numeric statistics, but they are not counted as missing. A column with no finite numeric values has `numeric_mean`, `numeric_min`, and `numeric_max` set to JSON `null`. The mean is the sum of included values divided by `numeric_count`.

Rows with the wrong number of fields are listed and skipped for all column-level counts and statistics. The tool still prints its JSON report, then exits with status 1 if any ragged rows were found. Invalid file access or an invalid header is reported as an argument error.

## Method and limitations

The script reads records sequentially, maintaining counts and numeric aggregates per column. If there are $R$ data rows and $C$ columns, runtime is $O(RC)$ in the usual case. Memory use is $O(C + K + W)$, where $K$ is the number of ragged-row record numbers retained and $W$ is the size of the current CSV record; it does not retain all well-formed rows. Numeric means are descriptive summaries, not tests of significance, estimates of causality, or evidence that values are valid for a particular domain. Floating-point arithmetic also has ordinary representation and rounding limits. Summing very large finite values can overflow, causing JSON output to fail.

This tool does not infer types, normalize units, impute missing values, validate scientific ranges, or identify quoted semantic errors. It treats every finite numeric value in a column as part of that column's numeric summary, even if the column is conceptually an identifier. It reports blank values separately from nonnumeric or nonfinite values. Review the source schema and domain rules before making analytical decisions.

Tuple unpacking motivates a useful engineering habit: check that input records have the expected shape before assigning meaning to their positions. `csv-profile` supports that workflow by surfacing row-width mismatches and basic column summaries. The book topic motivates the workflow, but this utility is a separate implementation, not a tool specified by the book.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Hands-On Data Science and Python Machine Learning, 6 List of tuples. The implementation is an independently written practical utility.
