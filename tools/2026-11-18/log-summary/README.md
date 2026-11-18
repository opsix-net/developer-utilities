# Log Summary Utility

`log-summary.sh` counts recognized severity labels and lines matching a regular expression. It prints aggregate JSON rather than copying log messages, which is useful when reviewing application health without pasting potentially sensitive message text into a report. A scientist running a sentiment-processing pipeline, for example, can summarize an application log after a batch and check whether error-related activity increased. This is operational triage only. Counts do not establish model quality, explain the cause of failures, or demonstrate compliance. The book topic motivates attention to reliable, auditable analytical workflows; it does not specify this utility.

## Requirements and input

The launcher is Bash and invokes Python 3. It requires a Bash-compatible shell and Python 3 available as `python3`, unless the executable is selected with the `PYTHON_BIN` environment variable. The Python algorithm uses only the standard library, so there are no third-party package dependencies.

Input is a UTF-8 application log supplied as a file. The utility opens it with UTF-8 decoding and replaces invalid byte sequences rather than failing on them. It reads line by line. For each line, it recognizes the first severity token matching `DEBUG`, `INFO`, `WARN`, `WARNING`, `ERROR`, `CRITICAL`, or `FATAL`, without regard to case. `WARNING` is normalized to `WARN`. A line contributes at most one severity count, even if it contains several severity labels. Independently, each line contributes at most one matching-line count if the configured regular expression matches anywhere in it.

## Run it

From the directory containing the script:

```bash
bash log-summary.sh --file application.log
```

The default pattern is `ERROR|CRITICAL|FATAL`, matched case-insensitively. To count lines matching a different regular expression, provide `--pattern`:

```bash
bash log-summary.sh --file application.log --pattern 'timeout|connection reset'
```

Patterns use Python regular-expression syntax. The utility reports invalid regular expressions as command-line errors. Do not put secrets in a pattern if shell history or process inspection is a concern.

## Output and algorithm

Successful output is indented JSON with three fields: `lines` is the number of input lines, `severity_counts` is a sorted object containing counts for severity labels encountered, and `matching_lines` is the number of lines matched by the selected pattern. A severity label can be counted even when the line does not match the custom pattern. A matching line can have no recognized severity. The two summaries answer different questions.

The program scans each line once, applying a severity search and a pattern search. If the file has $n$ characters and the regular-expression engine takes time proportional to the input for the patterns used, scanning is approximately $O(n)$; memory beyond the regex and counters is $O(k + L)$, where $k$ is the number of distinct severity labels, bounded by the fixed severity set, and $L$ is the length of the longest input line. Pathological regular expressions can take much longer, so use sensible patterns on untrusted input.

## Limitations

This tool does not redact, copy, or print log messages, but it still reads the file locally. Aggregate counts can reveal operational information, and the original log remains sensitive. It does not parse structured log schemas, identify multiple severity tokens per line, deduplicate events, inspect timestamps, classify root causes, or validate a model. Its severity detection uses word boundaries and the first recognized label on a line, so formats with unusual tokens may not be counted as expected. It reports line counts, not event counts, and does not infer missing log records. Review access controls and retention practices for the source file and output.

## Reproducible setup and checks

```bash
bash log-summary.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Sentiment Analysis in Trading, Chapter 12: The Future of Sentiment Analysis in Trading. The implementation is an independently written practical utility.
