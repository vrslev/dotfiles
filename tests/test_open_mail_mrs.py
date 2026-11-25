import runpy
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "bin/source-control/open-mail-mrs"
OPEN_MAIL_MRS = runpy.run_path(str(SCRIPT))


class SummaryScrollTests(unittest.TestCase):
    def test_wrapped_rows_keep_color_and_wide_characters(self) -> None:
        color = "\033[36m"
        reset = "\033[0m"
        lines = [f"{color}ab界c\u0301de{reset}", "", "next"]
        rows = OPEN_MAIL_MRS["wrap_summary"](lines, 4)
        self.assertEqual(rows, [f"{color}ab界{reset}", f"{color}c\u0301de{reset}", "", "next"])

    def test_scroll_accepts_split_keys_and_respects_viewport_bounds(self) -> None:
        scroll = OPEN_MAIL_MRS["scroll_summary"]
        offset, pending = scroll(b"\033[6", 0, 5, 8)
        self.assertEqual((offset, pending), (0, b"\033[6"))
        self.assertEqual(scroll(pending + b"~\033OB", offset, 5, 8), (6, b""))
        self.assertEqual(scroll(b"\033[6~\033OA", 6, 5, 8), (7, b""))
        self.assertEqual(scroll(b"\033[H\033[A", 7, 5, 8), (0, b""))
