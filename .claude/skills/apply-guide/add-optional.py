#!/usr/bin/env python3
"""Put an optional part back into a project that left it out - at stand-up, or since.

    python add-optional.py <part> <project-dir>            merge it in
    python add-optional.py <part> <project-dir> --check    report what would change, change nothing

Three-way, file by file, so the project's own changes stay: the base is the installed packs
assembled the way the project has them - without every part it lacks - and theirs the same
with this part. Only the difference between the two, the part's lines, is merged into the
project's file with `git merge-file`; a hunk that no longer fits is left as a conflict and
reported. Which parts a project lacks is read from its code: a part whose `optional: <part>`
markers are gone was stripped.

The part's own files are copied where its packs' starter tables put them. Its migrations go
after the project's head, renumbered - never back into the middle of a chain a database has
already run. A marked line inside an existing migration is reported, not merged: a schema that
has shipped changes only by a new migration, which the owner writes.

Exits 1 on a conflict, or a file the part needs that the project doesn't have.
"""
import argparse
import importlib.util
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True  # no __pycache__ beside the skill
HERE = pathlib.Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location("assemble", HERE / "assemble.py")
assembly = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(assembly)
remove_optional, LAYOUT, SKIP, owned, is_owned = (assembly.remove_optional, assembly.LAYOUT, assembly.SKIP,
                                                  assembly.owned, assembly.is_owned)

MIGRATIONS = pathlib.PurePosixPath("migrations/versions")
# The project's copies of the guides and packs carry every marker; only its own code counts
NOT_CODE = {".git", ".claude", ".cursor", "docs", ".docsys"}


def assemble(dest: pathlib.Path, without: list[str], only: set[str]) -> dict[str, str]:
    return assembly.assemble(dest, without, only)


def missing_parts(roots: list[pathlib.Path]) -> list[str]:
    """The parts whose markers the project's code no longer has anywhere."""
    found = set()
    for f in (f for root in roots for f in root.rglob("*")):
        if f.is_file() and not (SKIP | NOT_CODE) & set(f.relative_to(root_of(f, roots)).parts):
            try:
                found.update(m.group("part") for line in f.read_text().split("\n") if (m := remove_optional.ANY_MARKER.search(line)))
            except (UnicodeDecodeError, PermissionError):
                continue
    return [p for p in remove_optional.parts() if p not in found]


def head(versions: pathlib.Path) -> str | None:
    numbers = sorted(f.name[:3] for f in versions.glob("[0-9][0-9][0-9]_*.py"))
    return numbers[-1] if numbers else None


def root_of(f: pathlib.Path, roots: list[pathlib.Path]) -> pathlib.Path:
    return next(r for r in roots if f.is_relative_to(r))


def renumber(text: str, revision: str, down: str | None) -> str:
    """The migration as `revision`, after `down` - the project's head."""
    value = lambda v: f'"{v}"' if v else "None"  # noqa: E731
    text = re.sub(r'^(revision\b[^=]*=\s*)\S+', lambda m: m.group(1) + value(revision), text, count=1, flags=re.M)
    return re.sub(r'^(down_revision\b[^=]*=\s*)\S+', lambda m: m.group(1) + value(down), text, count=1, flags=re.M)


def requirements(part: str, project: pathlib.Path, check: bool) -> list[str]:
    """The part's pack requirements a project's files lack, appended."""
    notes = []
    for pack_path in owned(part):
        for req in (HERE / pack_path).glob("backend/requirements*.txt"):
            target = project / req.name
            have = set(target.read_text().split("\n")) if target.exists() else set()
            new = [line for line in req.read_text().split("\n") if line.strip() and line not in have]
            if new:
                notes.append(f"{req.name}: + {', '.join(new)}")
                if not check:
                    with target.open("a") as out:
                        out.write(("\n" if target.exists() and not target.read_text().endswith("\n") else "") + "\n".join(new) + "\n")
    return notes


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("part")
    ap.add_argument("project", type=pathlib.Path)
    ap.add_argument("--check", action="store_true", help="report what would change, change nothing")
    ap.add_argument("--only", default=",".join(LAYOUT), help="the pack folders to merge - backend,infrastructure,github,frontend")
    ap.add_argument("--frontend", type=pathlib.Path, help="where the web app is, if not <project>/frontend")
    args = ap.parse_args()
    project, part = args.project.resolve(), args.part
    only = set(args.only.split(","))
    frontend = (args.frontend or project / "frontend").resolve()
    if part not in remove_optional.parts():
        print(f"Unknown part {part} - optional-parts.txt has {', '.join(remove_optional.parts())}", file=sys.stderr)
        return 1
    lacking = missing_parts([project] + ([frontend] if "frontend" in only and not frontend.is_relative_to(project) else []))
    if part not in lacking:
        print(f"The project has {part} already - its markers are in its files")
        return 0
    paths = owned(part)
    problems, notes = [], []
    with tempfile.TemporaryDirectory() as tmp:
        base, theirs = pathlib.Path(tmp, "base"), pathlib.Path(tmp, "theirs")
        assemble(base, lacking, only)
        origin = assemble(theirs, [p for p in lacking if p != part], only)
        versions = project / MIGRATIONS
        own_migrations = []
        for rel, pack_rel in sorted(origin.items()):
            mine = frontend / rel[len("frontend/"):] if rel.startswith("frontend/") else project / rel
            new = theirs / rel
            if is_owned(pack_rel, paths):  # the part's own file
                if pathlib.PurePosixPath(rel).parent == MIGRATIONS:
                    own_migrations.append(rel)
                elif not mine.exists():
                    notes.append(f"+ {rel}")
                    if not args.check:
                        mine.parent.mkdir(parents=True, exist_ok=True)
                        shutil.copy2(new, mine)  # with its mode: scripts stay executable
                continue
            old = base / rel
            if not old.exists() or old.read_bytes() == new.read_bytes():
                continue
            if pathlib.PurePosixPath(rel).parent == MIGRATIONS:
                strip = lambda t: re.sub(r"^down_revision.*$", "", t, flags=re.M)  # noqa: E731 - a relink isn't the part's
                if strip(old.read_text()) != strip(new.read_text()):
                    problems.append(f"{rel}: the part changes a migration that may have run - write a new migration for it")
                continue
            if not mine.exists():
                problems.append(f"{rel}: the part has lines for it, and the project has no such file")
                continue
            merged = pathlib.Path(tmp, "merged")
            shutil.copyfile(mine, merged)
            result = subprocess.run(["git", "merge-file", "-L", "project", "-L", "without", "-L", part, str(merged), str(old), str(new)],
                                    capture_output=True)
            if result.returncode < 0 or result.returncode > 127:
                raise SystemExit(f"git merge-file failed on {rel}: {result.stderr.decode()}")
            if result.returncode:
                problems.append(f"{rel}: {result.returncode} conflict(s) - resolve the <<<<<<< markers")
            notes.append(f"~ {rel}")
            if not args.check:
                shutil.copyfile(merged, mine)
        # The part's migrations, in their order, after the project's head
        last = head(versions)
        for rel in own_migrations:
            number = f"{int(last or 0) + 1:03d}"
            name = MIGRATIONS / (number + pathlib.PurePosixPath(rel).name[3:])
            notes.append(f"+ {name} (was {pathlib.PurePosixPath(rel).name}, after {last})")
            if not args.check:
                versions.mkdir(parents=True, exist_ok=True)
                (project / name).write_text(renumber((theirs / rel).read_text(), number, last))
            last = number
        if "backend" in only:
            notes += requirements(part, project, args.check)
    for line in notes:
        print(line)
    for line in problems:
        print(f"❌ {line}", file=sys.stderr)
    print(f"{'Would add' if args.check else 'Added'} {part}: {len(notes)} change(s), {len(problems)} to resolve by hand."
          " Then re-export the API spec, regenerate the clients, and run every test.")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
