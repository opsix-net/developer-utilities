## JSONL Audit

`jsonl-audit` checks whether a UTF-8 JSON Lines file contains valid JSON objects and reports field type counts and missing-field counts. It is designed for an early data-pipeline or API interoperability check, before records are transformed into tables or visualized. The output contains field names, counts, types, and line numbers for invalid entries. It does not print record values.

### Prerequisites

The launcher is a Bash script and requires Bash and Python 3. The Python algorithm uses only the standard library; there are no third-party dependencies. The launcher uses `python3` by default. If Python 3 is available under another executable name or path, set `PYTHON_BIN` for the invocation.

### Input format and launch

Provide a UTF-8 file with one JSON value per nonblank line. Valid data records must be JSON objects. Blank or whitespace-only lines are skipped. For example, an input could contain `{"id": 1, "active": true}` on one line and `{"id": 2, "active": false}` on the next. Save the launcher as `jsonl-audit.sh`, make it executable if needed, and run:

```bash
chmod +x jsonl-audit.sh
bash jsonl-audit.sh --file records.jsonl
```

The required CLI argument is `--file`. To select a Python 3 executable explicitly, use the environment variable supported by the launcher:

```bash
PYTHON_BIN=python3 bash jsonl-audit.sh --file records.jsonl
```

### Reading the result

The tool prints formatted JSON. `ok` is true when no nonblank line produced an error. `valid_records` counts parsed object records. `invalid_lines` lists line numbers and either `invalid JSON` or `expected an object`. `fields` is keyed by field name. Each field has a `types` object counting observed Python JSON-decoded value types and a `missing` count, calculated as valid object records minus records containing that field. Field names are sorted in the output. A file with invalid lines produces `ok: false` and a nonzero exit status; a file with no invalid lines exits successfully if its report can be serialized.

The audit checks observed consistency, not a schema. For example, it can reveal that one field appeared as both an integer and a string, but it does not decide which type is correct or enforce required fields. Missing counts refer only to valid object records. Invalid lines are excluded from the valid-record total and field counts.

### Algorithm and limitations

The script reads the file line by line, parses each nonblank line with Python's JSON decoder, and updates counters for each object field and decoded value type. For $n$ input bytes and $k$ distinct field names, the scan takes $O(n)$ time, plus sorting field names in $O(k \log k)$ time. Counter storage grows with the distinct field/type combinations and field names. The complete list of invalid line numbers is retained in memory, so a file with very many invalid lines can also consume substantial memory.

This is a structural audit, not data validation or privacy certification. It does not check business rules, nested schemas, cross-record relationships, duplicate records, or whether values are appropriate. It does not expose record values in its report, but it still reads them locally and should be run in an environment authorized to access the file. Python's JSON decoder accepts non-standard numeric tokens such as NaN in some circumstances; if such a value is counted, the final strict JSON output may fail because output serialization disallows non-finite numbers. Review input conventions and downstream requirements before relying on the audit.

## Reproducible setup and checks

```bash
bash jsonl-audit.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Python Data Visualization Essentials Guide- Become a Data, CHAPTER 1 Introduction to Data Visualization. The implementation is an independently written practical utility.
