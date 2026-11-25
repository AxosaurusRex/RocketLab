"""Check that every SDK name Rocket Lab plans to use is declared in the SDK headers.

Usage: python verify_sdk_symbols.py <path to the SDK 'include' folder>
This checks declarations only. It does not compile or run anything.
"""
import json
import re
import sys
from pathlib import Path

SPEC = Path(__file__).resolve().parents[2] / "Documentation" / "Architecture" / "sdk_symbols.json"


def strip_comments(text: str) -> str:
    return re.sub(r"//[^\n]*|/\*.*?\*/", "", text, flags=re.S)


def main() -> int:
    if len(sys.argv) != 2 or not Path(sys.argv[1]).is_dir():
        print(__doc__)
        return 2
    include = Path(sys.argv[1])
    files = {p.relative_to(include).as_posix().lower(): p for p in include.rglob("*.h")}
    total, missing = 0, []
    for header, names in json.loads(SPEC.read_text(encoding="utf-8")).items():
        path = files.get(header.lower())
        text = strip_comments(path.read_text(encoding="utf-8-sig", errors="replace")) if path else ""
        for name in names:
            total += 1
            if not re.search(rf"\b{re.escape(name)}\b", text):
                missing.append(f"{header}: {name}")
    for item in missing:
        print("MISSING", item)
    print(f"{total - len(missing)}/{total} SDK names found")
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
