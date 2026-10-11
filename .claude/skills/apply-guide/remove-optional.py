#!/usr/bin/env python3
"""Leave optional parts out of an assembled project: strip their marked lines, and relink the
migration chain past their migrations. The parts and the marker grammar are in
optional-parts.txt, beside this file.

    python remove-optional.py --without tenant-sites,ai <project-dir>       strip
    python remove-optional.py --without tenant-sites <project-dir> --check  report, change nothing

The part's own files are the caller's to leave out - the stand-up doesn't copy them; a project
dropping a part later deletes what that pack's IMPLEMENT.md starter table copied, then runs this.
Exits 1 when a marker is malformed - an unclosed block, a `without:` with nothing after it -
so a half-stripped project is never left behind silently.
"""
import argparse
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).resolve().parent
COMMENT = r"(?:#|//|/?\*+|<!--)"  # Python, YAML, shell / TypeScript / CSS, JSDoc / HTML
SKIP_DIRS = {".git", "node_modules", ".venv", "__pycache__", "dist", ".angular"}
# At a project's root, never the Documentation System's own files: the packs under
# .claude/skills/apply-guide carry every part's markers on purpose - add-optional.py merges a part
# back from them - and the stand-up runs the assembler, and so this, on the project's root
SYSTEM_DIRS = {".claude", ".docsys"}

TEXT_SUFFIXES = {".py", ".ts", ".html", ".css", ".scss", ".yml", ".yaml", ".sh", ".json", ".toml", ".ini", ".cfg",
                 ".txt", ".js", ".mjs", ".swift", ".rb", ".env", ".example", ""}


def skipped(path: pathlib.Path, root: pathlib.Path) -> bool:
    parts = path.relative_to(root).parts
    return bool(SKIP_DIRS & set(parts)) or (bool(parts) and parts[0] in SYSTEM_DIRS)


def parts() -> dict[str, list[str]]:
    out = {}
    for line in (HERE / "optional-parts.txt").read_text().splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            name, *paths = line.split()
            out[name] = paths
    return out


def marker(part: str) -> re.Pattern:
    return re.compile(rf"{COMMENT}\s*optional:\s*{re.escape(part)}\b(?P<rest>.*)$")


ANY_MARKER = re.compile(rf"{COMMENT}\s*optional:\s*(?P<part>[a-z][a-z0-9-]*)\b(?P<rest>.*)$")


def strip_text(text: str, removed: list[str], path: str) -> tuple[str, int]:
    """The text without the removed parts' marked lines; and how many lines it changed."""
    lines = text.split("\n")
    out, changed, open_block = [], 0, None
    patterns = {part: marker(part) for part in removed}
    for number, line in enumerate(lines, 1):
        if open_block:
            changed += 1
            m = patterns[open_block[0]].search(line)
            if m and re.match(r"\s*end\b", m.group("rest")):
                open_block = None
            continue
        replaced = False
        # A replacement may carry another part's marker - the one plan's AI limit, say - so it's
        # read again, until no removed part's marker is left on it
        # A line's first marker decides: another one after it belongs to its replacement
        while (m := ANY_MARKER.search(line)) and m.group("part") in patterns:
            part, rest = m.group("part"), m.group("rest")
            if re.match(r"\s*begin\b", rest) and not replaced:
                open_block = (part, number)
            elif re.match(r"\s*(begin|end)\b", rest):
                raise SystemExit(f"{path}:{number}: 'optional: {part} {rest.split()[0]}' where it can't open or close a block")
            # One space after "without:"; any more is the replacement's own indent, kept
            elif (w := re.match(r"\s*without: ?(.*?)\s*(?:\*/|-->)?\s*$", rest)):
                if not w.group(1).strip():
                    raise SystemExit(f"{path}:{number}: 'without:' needs the code that replaces the line")
                line = re.match(r"\s*", line).group(0) + w.group(1)
                replaced = True
                continue
            line = None  # the line goes
            break
        if line is None or open_block:
            changed += 1
            continue
        out.append(line)
        changed += replaced
    if open_block:
        raise SystemExit(f"{path}:{open_block[1]}: 'optional: {open_block[0]} begin' is never closed")
    return "\n".join(out), changed


def relink_migrations(root: pathlib.Path, check: bool) -> list[str]:
    """Point each numbered migration at the nearest earlier one that's still there - a part's
    migrations weren't copied, so the chain has gaps where they were."""
    notes = []
    for versions in root.rglob("migrations/versions"):
        if skipped(versions, root):
            continue
        files = sorted(versions.glob("[0-9][0-9][0-9]_*.py"))
        present = [f.name[:3] for f in files]
        for f in files:
            text = f.read_text()
            m = re.search(r'^down_revision[^=]*=\s*["\'](\d{3})["\']', text, re.M)
            if not m or m.group(1) in present:
                continue
            earlier = [r for r in present if r < f.name[:3]]
            target = earlier[-1] if earlier else None
            notes.append(f"{f.relative_to(root)}: down_revision {m.group(1)} -> {target}")
            if not check:
                new = f'"{target}"' if target else "None"
                f.write_text(text[:m.start()] + re.sub(r'["\']\d{3}["\']', new, text[m.start():m.end()], count=1) + text[m.end():])
    return notes


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("project", type=pathlib.Path)
    ap.add_argument("--without", required=True, help="comma-separated parts")
    ap.add_argument("--check", action="store_true", help="report what would change, change nothing")
    args = ap.parse_args()
    known = parts()
    removed = [p for p in args.without.split(",") if p]
    unknown = [p for p in removed if p not in known]
    if unknown:
        print(f"Unknown part(s): {', '.join(unknown)} - optional-parts.txt has {', '.join(known)}", file=sys.stderr)
        return 1
    total = 0
    for path in sorted(args.project.rglob("*")):
        if not path.is_file() or skipped(path, args.project):
            continue
        if path.suffix not in TEXT_SUFFIXES and not path.name.startswith("."):
            continue
        try:
            text = path.read_text()
        except (UnicodeDecodeError, PermissionError):
            continue
        new, changed = strip_text(text, removed, str(path.relative_to(args.project)))
        if changed:
            total += changed
            print(f"{path.relative_to(args.project)}: {changed} line(s)")
            if not args.check:
                path.write_text(new)
    for note in relink_migrations(args.project, args.check):
        print(note)
    print(f"{'Would change' if args.check else 'Changed'} {total} marked line(s) for: {', '.join(removed)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
