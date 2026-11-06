## jsonl-audit

`jsonl-audit` checks a JSON Lines file for parseable JSON objects and summarizes the observed Python value types for each field. It is intended for data-pipeline and API-interoperability checks where a team needs structural feedback without printing record values. The report includes field presence counts expressed as missing counts among valid object records. It does not inspect or reveal the contents of field values.

### Prerequisites and launch

The launcher is a Bash script that invokes Python 3. The Python algorithm is self-contained and has no third-party dependencies. Use a UTF-8 encoded input file with one JSON value per nonblank line. Valid records must be JSON objects. Blank or whitespace-only lines are skipped.

Run the exact command:

```bash
bash jsonl-audit.sh --file records.jsonl
```

The `--file` argument is required. The script prints an indented JSON report to standard output. On systems where the file is executable, it can also be launched as `./jsonl-audit.sh --file records.jsonl`, but the Bash command above does not depend on executable permission.

### Reading the result

The report has an `ok` boolean, `valid_records` count, `invalid_lines` list, and `fields` object. Each invalid-line entry reports its one-based source line number and a generic reason, either `invalid JSON` or `expected an object`. It never includes the offending line or record value. `fields` is ordered by field name. For each field, `types` counts Python JSON-decoded value types among valid objects containing that field, and `missing` is the number of valid object records that do not contain it. A JSON `null` is counted as type `NoneType`; it is present, not missing.

For example, a field reported with both `str` and `int` counts has inconsistent observed types that may need investigation before downstream consumers rely on it. `ok` concerns invalid lines only. A type mixture or missing field does not make `ok` false. If any invalid line is found, the utility exits with status 1; otherwise it exits successfully. File and argument errors are reported through argparse.

### Method and limits

The utility reads the file line by line, parses each nonblank line with Python's JSON decoder, and accepts only decoded dictionaries as records. For valid objects it counts field presence and the runtime type name of each field value, then derives missing counts as `valid_records - present[field]`. Runtime is linear in input size, aside from sorting field names for output. Counts are accumulated in memory, with storage proportional to the number of distinct fields and observed field-type combinations, plus invalid-line diagnostics.

This is a structural audit, not schema validation. It does not enforce required fields, nested schemas, numeric ranges, timestamp formats, key uniqueness, or compatibility rules. It does not compare values across files, infer semantic types, or expose record values. JSON numeric values are decoded according to Python's JSON behavior. Non-standard numeric constants such as `NaN` are accepted by default and counted as floats; their values are not included in the report. Treat the summary as a triage aid, not proof that a feed is correct.

The time-series workflow motivates this utility in a practical way: before sorting timestamped observations or calculating rolling statistics, researchers need dependable ingestion. The book chapter discusses cleaning and preparing time-indexed data; this utility is an engineering aid for one narrow upstream check. The chapter does not specify this tool, and passing the audit does not establish that timestamps, sampling intervals, or scientific interpretations are valid.

## Reproducible setup and checks

```bash
bash jsonl-audit.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Python & R- The dynamic duo for Finance- A comprehensive, Chapter 4: Time Series Analysis Fundamentals. The implementation is an independently written practical utility.
