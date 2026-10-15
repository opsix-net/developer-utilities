## Purpose

`jsonl-audit` checks whether a JSON Lines file can be parsed as a sequence of JSON objects and summarizes the observed type of each field. It reports structural information, not record values. This can help a data engineer or research team validate an export before loading it into a database, analysis notebook, or API integration, especially when records may contain sensitive information.

The scientific-programming workflow of making assumptions explicit and checking computed results motivates this kind of utility: identify the expected input shape, run a repeatable check, and inspect a concise result. The source passage's differential-equation project does not specify this utility; this is a separate practical application of careful validation.

## Prerequisites and launch

The launcher is a Bash script that runs Python 3. It has no third-party Python dependencies. Use a shell with Bash and a Python 3 interpreter available. The script accepts a UTF-8 JSON Lines file through the required `--file` option:

```bash
bash jsonl-audit.sh --file records.jsonl
```

Each nonblank line should contain one JSON object. Blank or whitespace-only lines are skipped. For example, records can have different fields, and values can be strings, numbers, booleans, arrays, objects, or null. The audit uses Python's decoded JSON value types when counting field types.

## Output and interpretation

The utility prints an indented JSON summary with four main parts:

- `ok` is `true` when no nonblank line failed parsing or decoded to a non-object, otherwise `false`.
- `valid_records` counts successfully parsed JSON objects.
- `invalid_lines` lists line numbers and a general error category, either `invalid JSON` or `expected an object`. It does not include record contents.
- `fields` is keyed by field name. Each entry contains type counts and `missing`, computed as valid object records minus the number of valid records containing that field.

Field names are included in the output, so do not use the tool if field names themselves are sensitive. On structural validation failure, the process exits with status 1 after printing the summary. File, encoding, and argument errors are reported by argparse as command-line errors. A successful audit exits normally.

## Method and limits

The script reads the file one line at a time, parses each nonblank line, and accumulates field counts and type counts for objects. Its runtime is linear in the input size, plus the cost of JSON parsing; memory use grows with the distinct field names, their observed type categories, and the collected invalid-line entries, rather than retaining all valid records. JSON parsing necessarily materializes the current line's value in memory.

This is a structural audit, not a schema validator. It does not enforce required fields, allowed values, nested-field rules, numeric ranges, or consistent types across records. Instead, it reports observed type counts so a developer can spot variation. It does not expose record values, but it does expose field names, counts, line numbers, and type categories. JSON numeric values are not checked for scientific validity or finiteness. Python's JSON parser accepts non-standard constants such as NaN and Infinity by default; this utility counts them as floats and does not include their values in the summary. The tool does not repair input, infer intended schemas, or guarantee API compatibility. Treat its summary as a descriptive diagnostic and follow it with domain-specific validation where needed.

## Reproducible setup and checks

```bash
bash jsonl-audit.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** A Primer on Scientific Programming with Python, 0 as k ! 1.. The implementation is an independently written practical utility.
