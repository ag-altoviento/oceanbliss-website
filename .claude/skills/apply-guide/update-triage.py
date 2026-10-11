#!/usr/bin/env python3
"""Sort what a Documentation System update changed in the starters against the project's own files.

/apply-guide review-update runs it. The packs before the update come from git, the packs after it
from the working tree; each is laid out as a project has it - by its own assemble.py, the optional
parts the project left out left out - and every starter file the update changed is compared three
ways: the old starter, the new one, and the project's file.

    python .claude/skills/apply-guide/update-triage.py              the update not committed yet
    python .claude/skills/apply-guide/update-triage.py --old REF    the commit before the update
    python .claude/skills/apply-guide/update-triage.py --apply      bring over what's clean

It changes nothing unless --apply is given, and then only what can't lose the project's work: a
file the project never changed, a three-way merge with no conflict, and a file the project doesn't
have yet. Conflicts, and files with no common base, are listed for the owner.
"""
import argparse
import importlib.util
import pathlib
import subprocess
import sys
import tarfile
import tempfile

HERE = pathlib.Path(__file__).resolve().parent
SKILL = ".claude/skills/apply-guide"

# Each state, in the order the report shows them, with what it means for the owner
STATES = {
    "already new": "the project's file is the new starter already",
    "has the change": "the project's file already carries the change, beside its own",
    "takes cleanly": "the project never changed the old starter: the new one replaces it",
    "merges cleanly": "both changed it, in different places: the three-way merge has no conflict",
    "conflicts": "both changed the same lines: the owner merges it",
    "no common base": "new in the starters, but the project has its own file there: compare by hand",
    "new": "a starter file the project doesn't have yet",
    "not in project": "the update changed a starter the project doesn't have - left out or removed",
    "removed upstream": "the update dropped this starter; the project's copy stays until the owner decides",
}
CLEAN = {"takes cleanly", "merges cleanly", "new"}


def git(root: pathlib.Path, *args: str, **kw) -> subprocess.CompletedProcess:
    return subprocess.run(["git", "-C", str(root), *args], capture_output=True, **kw)


def load(name: str, path: pathlib.Path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def left_out(root: pathlib.Path, frontend: pathlib.Path) -> list[str]:
    """The optional parts the project left out: those none of whose starter files it has."""
    assemble = load("assemble", HERE / "assemble.py")
    parts = []
    for part, paths in assemble.remove_optional.parts().items():
        lands = [rel for pack in assemble.packs() for f, _, rel, req in assemble.starters(pack)
                 if f.is_file() and not req and assemble.is_owned(f.relative_to(HERE).as_posix(), paths)]
        if lands and not any(project_path(root, frontend, rel).exists() for rel in lands):
            parts.append(part)
    return parts


def project_path(root: pathlib.Path, frontend: pathlib.Path, rel: str) -> pathlib.Path:
    return frontend / rel[len("frontend/"):] if rel.startswith("frontend/") else root / rel


def lay_out(skill: pathlib.Path, dest: pathlib.Path, without: list[str]) -> None:
    """The starters as a project has them, by that version's own assembler and its own parts."""
    known = {line.split()[0] for line in (skill / "optional-parts.txt").read_text().splitlines()
             if line.split("#", 1)[0].strip()} if (skill / "optional-parts.txt").exists() else set()
    keep = [p for p in without if p in known]
    subprocess.run([sys.executable, str(skill / "assemble.py"), str(dest), "--without", ",".join(keep)],
                   check=True, capture_output=True)


def files(top: pathlib.Path) -> set[str]:
    return {p.relative_to(top).as_posix() for p in top.rglob("*") if p.is_file()}


def merge(project: bytes, old: bytes, new: bytes) -> tuple[bool, bytes]:
    """git merge-file, three ways: whether it merged without conflict, and the result."""
    with tempfile.TemporaryDirectory() as tmp:
        paths = []
        for name, data in (("project", project), ("old", old), ("new", new)):
            path = pathlib.Path(tmp) / name
            path.write_bytes(data)
            paths.append(str(path))
        result = subprocess.run(["git", "merge-file", "-p", "-L", "project", "-L", "old starter", "-L", "new starter",
                                 *paths], capture_output=True)
        return result.returncode == 0, result.stdout


def triage(root: pathlib.Path, frontend: pathlib.Path, old_ref: str, without: list[str],
           modes: dict[str, int]) -> list[tuple[str, str, bytes | None]]:
    """(state, project path, what --apply would write) for every starter file the update touched;
    `modes` gets each new file's mode."""
    with tempfile.TemporaryDirectory() as tmp:
        tmp = pathlib.Path(tmp)
        archive = git(root, "archive", "--format=tar", old_ref, SKILL)
        if archive.returncode:
            sys.exit(f"Can't read {SKILL} at {old_ref}: {archive.stderr.decode().strip()}")
        (tmp / "old.tar").write_bytes(archive.stdout)
        with tarfile.open(tmp / "old.tar") as tar:
            tar.extractall(tmp / "old-tree", filter="data")  # our own repository's files, read as data
        lay_out(tmp / "old-tree" / SKILL, tmp / "old", without)
        lay_out(HERE, tmp / "new", without)
        old, new = files(tmp / "old"), files(tmp / "new")
        rows = []
        for rel in sorted(old | new):
            before = (tmp / "old" / rel).read_bytes() if rel in old else None
            after = (tmp / "new" / rel).read_bytes() if rel in new else None
            if before == after:
                continue  # the update didn't change it
            target = project_path(root, frontend, rel)
            mine = target.read_bytes() if target.is_file() else None
            if after is None:
                rows.append(("removed upstream", rel, None))
            elif mine == after:
                rows.append(("already new", rel, None))
            elif before is None:
                # A new file keeps its starter's mode: a script stays executable
                if mine is None:
                    rows.append(("new", rel, after))
                    modes[rel] = (tmp / "new" / rel).stat().st_mode & 0o777
                else:
                    rows.append(("no common base", rel, None))
            elif mine is None:
                rows.append(("not in project", rel, None))
            elif mine == before:
                rows.append(("takes cleanly", rel, after))
            else:
                clean, merged = merge(mine, before, after)
                if not clean:
                    rows.append(("conflicts", rel, None))
                elif merged == mine:
                    rows.append(("has the change", rel, None))
                else:
                    rows.append(("merges cleanly", rel, merged))
        return rows


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--old", default="HEAD", help="the commit whose packs the update replaced (default: HEAD, an update not committed yet)")
    ap.add_argument("--without", help="the optional parts the project left out (default: worked out from its files)")
    ap.add_argument("--frontend", type=pathlib.Path, help="where the web app is, if not <project>/frontend")
    ap.add_argument("--apply", action="store_true", help="write the clean ones: takes cleanly, merges cleanly, new")
    args = ap.parse_args()

    top = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True)
    if top.returncode:
        sys.exit("Run it inside the project's git repository: the packs before the update come from git")
    root = pathlib.Path(top.stdout.strip())
    frontend = (args.frontend or root / "frontend").resolve()
    without = [p for p in args.without.split(",") if p] if args.without is not None else left_out(root, frontend)

    modes: dict[str, int] = {}
    rows = triage(root, frontend, args.old, without, modes)
    if not rows:
        print(f"The starters are the same at {args.old} and now. If the update is already committed, pass --old <the commit before it>.")
        return 0
    print("Starter files the update changed, against this project's" + (f" (left out: {', '.join(without)})" if without else "") + ":\n")
    width = max(len(s) for s in STATES)
    for state in STATES:
        for s, rel, _ in rows:
            if s == state:
                print(f"  {state:<{width}}  {rel}")
    print()
    for state, meaning in STATES.items():
        n = sum(1 for s, _, _ in rows if s == state)
        if n:
            print(f"  {n:>3}  {state} - {meaning}")
    clean = [(s, rel, data) for s, rel, data in rows if s in CLEAN]
    if not args.apply:
        if clean:
            print(f"\n{len(clean)} can come over cleanly: run again with --apply, once the owner agrees. Nothing was changed.")
        return 0
    for _, rel, data in clean:
        target = project_path(root, frontend, rel)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)  # an existing file keeps its own mode
        if rel in modes:
            target.chmod(modes[rel])
    print(f"\nWrote {len(clean)} file(s): read them in git before committing. The rest are the owner's.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
