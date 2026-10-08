## Overview

`jsonl-audit` checks whether a JSON Lines file contains valid JSON objects and reports field-type counts and missing-field counts without printing record values. It is useful at a pipeline boundary where one producer sends events to another service, or when a research team wants a quick structural check on exported observations before loading them into analysis software.

A manufacturing workflow illustrates the motivation: telemetry and production events may pass between OT-connected collection systems and IT services. A book discussion of smart manufacturing motivates the need to connect systems and preserve useful context, but it does not specify this utility. This script performs a limited format and consistency audit. It does not validate manufacturing semantics or make operational decisions.

## Requirements and input

The launcher is Bash and runs Python 3. The Python algorithm is self-contained and has no third-party dependencies. Provide a UTF-8 encoded JSON Lines file, with one JSON value per nonblank line. For a record to count as valid, that value must be a JSON object. Blank or whitespace-only lines are skipped. JSON parsing follows Python's standard `json` module behavior.

Each object can contain different fields. The audit counts how often each field occurs and the Python type name of each encountered value. It reports a field as missing when it is absent from a valid object. JSON `null` is counted as the Python type `NoneType`, not as a missing field.

## Run it

```bash
bash jsonl-audit.sh --file records.jsonl
```

The only supported option is required: `--file`, followed by the input path. The launcher accepts `PYTHON_BIN` as an environment override for the Python executable; otherwise it uses `python3`. For example:

```bash
PYTHON_BIN=python3 bash jsonl-audit.sh --file records.jsonl
```

## Read the result

The script prints formatted JSON with `ok`, `valid_records`, `invalid_lines`, and `fields`. `ok` is true when no nonblank line failed JSON parsing or failed the object requirement. `valid_records` counts parsed JSON objects only. Each entry in `invalid_lines` includes a one-based line number and a generic error category, not the line contents. Under `fields`, each field has a map of observed type names to counts and a `missing` count calculated among valid records. Field names are included in the report, but record values are not.

The process exits with status 0 when `ok` is true and status 1 when invalid lines are found. File or runtime errors are reported through argparse's error handling. A nonzero status is useful for stopping a pipeline before a downstream consumer receives malformed input.

## Algorithm and limits

The script reads the file one line at a time, parses each nonblank line, and updates counters for valid objects. Its expected time is linear in the total input size, excluding the cost of parsing each JSON value, and its aggregation memory grows with the number of distinct field names and type names, plus collected error entries. Invalid-line details are retained in memory until reporting.

This is a structural audit, not a schema validator. It does not enforce required fields, nested-field rules, allowed value ranges, stable types, ordering, or domain-specific meanings. Mixed types are reported rather than automatically rejected. It does not redact values from the input file or protect the file itself; it only avoids including record values in its output. It does not provide statistical inference or missing-data imputation. Python's decoder accepts `NaN`, `Infinity`, and `-Infinity` even though they are not standard JSON. If one appears inside an object, parsing succeeds but report serialization fails, and argparse reports an error instead of producing the audit report. Review the results and define downstream validation appropriate to the application.

## Reproducible setup and checks

```bash
bash jsonl-audit.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Architectural Patterns and Techniques for Developing IoT -- Jasbir Singh Dhaliwal, 7 Pattern Implementation in the Manufacturing Domain. The implementation is an independently written practical utility.
