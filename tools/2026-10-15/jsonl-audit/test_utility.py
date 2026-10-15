"""Offline fixture and CLI tests. Run: python3 -m unittest test_utility.py -v"""
from pathlib import Path
import json
import os
import subprocess
import sys
import tempfile
import unittest

def demo_fixture(kind: str, directory: Path):
    directory.mkdir(parents=True, exist_ok=True)
    if kind == "matrix-audit":
        return ["--matrix", "[[1,2],[3,4]]"], {"rank": 2, "determinant": "-2"}
    if kind == "dependency-order":
        path = directory / "dependencies.json"
        path.write_text('{"test":["build"],"build":["compile"],"compile":[]}\n')
        return ["--file", str(path)], {"ok": True, "topological_order": ["compile", "build", "test"]}
    if kind == "jsonl-audit":
        path = directory / "records.jsonl"
        path.write_text('{"id":1,"active":true}\n{"id":2}\n')
        return ["--file", str(path)], {"ok": True, "valid_records": 2}
    if kind == "csv-profile":
        path = directory / "measurements.csv"
        path.write_text('name,value\na,2\nb,4\nc,\n')
        return ["--file", str(path)], {"ok": True, "rows": 3}
    if kind in ("csv-statistics", "correlation-report", "csv-visualize"):
        path = directory / "measurements.csv"
        path.write_text('x,y,value\n1,2,2\n2,4,4\n3,6,6\n4,8,8\n')
        if kind == "csv-statistics":
            return ["--file", str(path), "--column", "value", "--resamples", "100", "--seed", "42"], {"n": 4, "mean": 5.0, "median": 5.0}
        if kind == "correlation-report":
            return ["--file", str(path), "--x", "x", "--y", "y"], {"n_pairs": 4, "pearson_r": 1.0, "least_squares_slope": 2.0}
        return ["--file", str(path), "--x", "x", "--y", "y", "--output", str(directory / "scatter.svg")], {"kind": "scatter", "observations": 4}
    if kind == "log-summary":
        path = directory / "application.log"
        path.write_text('INFO started\nWARNING retry\nERROR failed\n')
        return ["--file", str(path)], {"lines": 3, "matching_lines": 1, "severity_counts": {"INFO": 1, "WARN": 1, "ERROR": 1}}
    if kind in ("file-manifest", "duplicate-report"):
        root = directory / "assets"
        root.mkdir(exist_ok=True)
        (root / "a.txt").write_text("same\n")
        (root / "b.txt").write_text("same\n")
        (root / ".env").write_text("exclude this fixture\n")
        return ["--root", str(root)], {"file_count": 2, "total_bytes": 10} if kind == "file-manifest" else {"potential_redundant_bytes": 5}
    path = directory / "sample.bin"
    path.write_bytes(bytes(range(256)))
    return ["--file", str(path)], {"bytes": 256, "entropy_bits_per_byte": 8.0}

KIND = 'jsonl-audit'
SCRIPT = Path(__file__).resolve().parent / (KIND + '.sh')

class UtilityTests(unittest.TestCase):
    def test_documented_fixture(self):
        with tempfile.TemporaryDirectory() as directory:
            args, expected = demo_fixture(KIND, Path(directory))
            environment = {'PATH': os.defpath, 'PYTHON_BIN': sys.executable, 'MPLCONFIGDIR': directory, 'LC_ALL': 'C.UTF-8'}
            completed = subprocess.run(['bash', str(SCRIPT), *args], capture_output=True, text=True, env=environment, check=True)
            actual = json.loads(completed.stdout)
            for key, value in expected.items():
                self.assertEqual(actual[key], value)
            if KIND == 'csv-visualize':
                self.assertIn('<svg', Path(actual['output']).read_text())
                repeated = subprocess.run(['bash', str(SCRIPT), *args], capture_output=True, text=True, env=environment)
                self.assertEqual(repeated.returncode, 2)

    def test_missing_arguments(self):
        completed = subprocess.run(['bash', str(SCRIPT)], capture_output=True, text=True, env={'PATH': os.defpath, 'PYTHON_BIN': sys.executable})
        self.assertEqual(completed.returncode, 2)

if __name__ == '__main__':
    unittest.main()
