## Dependency Order

`dependency-order.sh` finds a deterministic topological order for tasks and flags cyclic dependency graphs. It is useful when a build, data-processing pipeline, or research workflow must run prerequisites before dependent steps. The visualization principles in the accompanying article motivate the same engineering habit: make relationships explicit and inspectable. This utility turns a dependency description into an order and reports nodes that cannot be scheduled. It is a standalone tool, not a feature specified by the book.

### Prerequisites

Run the script with Bash and Python 3 available. The Bash launcher executes the Python algorithm. The algorithm is self-contained and has no third-party dependencies. Set `PYTHON_BIN` if Python 3 is installed under a different executable name or path.

### Input format

Provide a UTF-8 JSON object mapping each task name to a list of its dependencies. For example:

```json
{
  "report": ["analyze"],
  "analyze": ["ingest"],
  "ingest": []
}
```

A task mentioned only as a dependency is also included as a node, even if it has no explicit key in the object. Names and dependency entries must be strings, and each dependency value must be a JSON list. The input describes prerequisites: `report` depends on `analyze`, so `analyze` must come first.

### Launch

Save the JSON in `dependencies.json`, then run:

```bash
bash dependency-order.sh --file dependencies.json
```

### Output

The script prints JSON with four fields. `ok` is true when all nodes can be ordered and false when a cycle leaves nodes blocked. `topological_order` contains the deterministic order found. `blocked_nodes` is the sorted set of nodes not emitted, and `nodes` is the total number of distinct nodes, including dependency-only names. On a cyclic graph, the tool exits with status 1 after printing the result. Invalid JSON, unreadable files, or an input with the wrong shape is reported as a command-line error.

The ordering uses Kahn's topological-sort method. It repeatedly removes a task whose remaining prerequisites are empty, then updates its dependents. A min-heap selects the lexicographically smallest currently available task, making the result deterministic for the same graph. With heap operations, the running time is O((V + E) log V), and storage is O(V + E), where V is the number of distinct tasks and E is the number of dependency entries. Duplicate dependencies are collapsed by sets.

### Limitations

A topological order is not a schedule: the tool does not run tasks, model durations, allocate workers, or resolve resource constraints. If a cycle exists, `blocked_nodes` contains every node left after the ordering process. Some of those nodes may depend on a cycle indirectly; the output does not identify the exact cycle path or distinguish its members from downstream blocked tasks. The tool does not validate whether task names correspond to real commands or files. Review the dependency data before using the order in a production build or scientific pipeline.

## Reproducible setup and checks

```bash
bash dependency-order.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Data Visualization in Finance with Python_ A Comprehensive -- Schwartz, Alice & Van Der Post, Hayden -- 2024 -- Reactive Publishing, CHAPTER 4: CRAFTING. The implementation is an independently written practical utility.
