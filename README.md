# Developer Utilities

Practical developer utilities, scientific research tools, and automation tools. Tools across software engineering, scientific research, data pipelines, build systems, observability, integrity checks, and automation.

Start with a small problem worth solving: inspect a dataset, check a dependency graph, or turn measurements into a useful plot. Each tool gives you a concrete use case, clear inputs and outputs, a reproducible example, and runnable tests. Open a directory and take one for a spin.

## Explore

- [Browse the tool index](INDEX.md)
- [Read the accompanying research notes](https://github.com/opsix-net/opsix-research)

Each dated tool directory contains:

- A Bash command with a self-contained Python implementation
- A README covering the problem, algorithm, inputs, outputs, and limitations
- Example fixtures and expected output
- An offline test suite and explicit runtime requirements
- Source inspiration, artifact provenance, and validation metadata

## Run a tool

Open a directory under `tools/`, follow its README, and run the documented command. Most tools use only Bash and Python 3. Visualization tools declare a pinned Matplotlib dependency and use its headless renderer.

Read-only diagnostics do not modify inputs. Plot exporters create a new output file and refuse to replace an existing one. Tests use fixtures and never require GitHub credentials or a network connection.

New tools arrive Monday through Friday through reviewed, reproducible pull requests. Executable implementations come from a tested algorithm catalog; AI assistance supplies research explanations and documentation. Each repository retains its own subject focus.
