## dependency-order

`dependency-order` finds a deterministic topological order for a task dependency graph and flags cyclic graphs. It is useful when a build, data pipeline, or research workflow has many steps and you want to validate the declared ordering before running expensive work. For example, a scientific workflow might require input validation before calibration, calibration before fitting, and fitting before report generation. This tool checks those ordering relationships; it does not run the tasks or assess the scientific validity of the analysis. The connection to solid-state physics is an analogy about local constraints shaping system behavior, not a claim that the source text specifies this utility.

### Requirements

The launcher is a Bash script and invokes Python 3. No third-party Python packages are required. Make the script executable if needed:

```bash
chmod +x dependency-order.sh
```

Run it with the required `--file` option:

```bash
dependency-order.sh --file dependencies.json
```

Or invoke it explicitly through Bash:

```bash
bash dependency-order.sh --file dependencies.json
```

The optional environment variable `PYTHON_BIN` can select the Python executable; for example, `PYTHON_BIN=python3 bash dependency-order.sh --file dependencies.json`.

### Input format

The file must contain a JSON object mapping each task name to a list of dependency names. A task listed as a dependency but not as an object key is still included as a node, with no dependencies of its own. For example:

```json
{
  "fit": ["calibrate"],
  "calibrate": ["validate"],
  "validate": []
}
```

A task’s listed dependencies must be completed before that task. Names are strings and dependency values must be lists of strings.

### Output and algorithm

The tool prints JSON with `ok`, `topological_order`, `blocked_nodes`, and `nodes`. When `ok` is true, `topological_order` is a valid deterministic ordering and `blocked_nodes` is empty. A min-heap selects the lexicographically smallest currently available task, so the chosen valid order is reproducible. With a cycle, `ok` is false, the process exits with status 1, and `blocked_nodes` lists every node that could not be processed. This can include tasks downstream of a cycle, not only nodes that lie on the cycle itself. `nodes` counts all distinct task names, including dependency names that have no object entry.

The implementation uses a Kahn-style topological sort. With $V$ distinct nodes and $E$ distinct dependency relationships, its heap operations give time complexity of approximately $O((V+E)\log V)$; adjacency construction and storage use $O(V+E)$ space. Dependencies are stored as sets, so duplicate names in one dependency list do not create duplicate edges.

### Limitations

The utility validates JSON shape and ordering constraints only. It does not detect undeclared file dependencies, execute or parallelize tasks, suggest repairs to cycles, or optimize for runtime. A valid result is only as complete as the graph supplied. Invalid JSON, unreadable files, or values outside the required object-of-string-lists format produce an argument error rather than a normal result object.

## Reproducible setup and checks

```bash
bash dependency-order.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Solid-State Physics for Electronics, 302 Solid-State Physics for Electronics. The implementation is an independently written practical utility.
