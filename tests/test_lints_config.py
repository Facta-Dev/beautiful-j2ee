#!/usr/bin/env python3
"""Contract tests: the drop-in Checkstyle config stays pinned."""

from __future__ import annotations

import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
CONFIG = REPO_ROOT / "lints" / "checkstyle.xml"


class CheckstyleConfig(unittest.TestCase):
    def setUp(self):
        self.text = CONFIG.read_text(encoding="utf-8")

    def test_core_rules_are_pinned(self):
        for rule in ("AvoidStarImport", "NeedBraces", "MagicNumber", "TodoComment", "StringLiteralEquality"):
            self.assertIn(rule, self.text)

    def test_line_length_and_severity(self):
        self.assertIn('value="120"', self.text)
        self.assertIn('value="error"', self.text)

    def test_no_suppression(self):
        self.assertNotIn("SuppressionFilter", self.text)
        self.assertNotIn("suppressions.xml", self.text)


if __name__ == "__main__":
    unittest.main()
