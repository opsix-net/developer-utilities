## log-summary

`log-summary` counts recognized severity labels and matching lines in a UTF-8 application log. It prints aggregate JSON counts without copying log messages into the output. This makes it useful for an incident triage or research pipeline that needs a compact view of error volume while limiting exposure of potentially sensitive log content.

### Requirements

The launcher is a Bash script that invokes Python 3. It uses only the Python standard library, so there are no third-party dependencies. Set `PYTHON_BIN` if Python 3 is available under a non-default executable name.

### Input and launch

Provide a text log file with `--file`:

```bash
bash log-summary.sh --file application.log
```

The file is read as UTF-8. Invalid UTF-8 bytes are replaced during decoding rather than causing a decoding failure. The default search regular expression is `ERROR|CRITICAL|FATAL`, matched case-insensitively. To count lines matching a different regular expression, supply `--pattern`:

```bash
bash log-summary.sh --file application.log --pattern 'timeout|connection reset'
```

The pattern is a Python regular expression. It is case-insensitive. Invalid regular expressions are reported as command-line errors.

### Output

The tool prints JSON with three fields:

- `lines`: number of lines read.
- `severity_counts`: counts for recognized labels, sorted by label. Recognized labels are `DEBUG`, `INFO`, `WARN`, `WARNING`, `ERROR`, `CRITICAL`, and `FATAL`. `WARNING` is normalized to `WARN`.
- `matching_lines`: number of lines matching the selected pattern. Each line contributes at most one match, even if the pattern matches it multiple times.

For severity, the tool uses the first recognized severity token found on each line, so a line contributes at most one severity count. A line can contribute both a severity count and a matching-line count. The JSON contains counts only, not the original log text.

### Algorithm and limitations

The script reads the file one line at a time, searches each line for a severity token and the selected pattern, then prints aggregate counts. Memory use is proportional to the current line plus the counters, rather than the entire file. Runtime is linear in the input text for ordinary patterns, although regular-expression execution can depend on the supplied pattern. This is a counting utility, not a log parser: it does not infer event structure, deduplicate incidents, associate stack traces, or redact and export log records. A matching line count is not necessarily a count of unique events. Keep regular expressions appropriate for your logs, and treat aggregate output as descriptive monitoring evidence, not as a causal explanation or statistical significance test. The tool does not validate a logging schema or determine whether the input is complete.

## Reproducible setup and checks

```bash
bash log-summary.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Statistics for Big Data For Dummies, 2.764 3.169. The implementation is an independently written practical utility.
