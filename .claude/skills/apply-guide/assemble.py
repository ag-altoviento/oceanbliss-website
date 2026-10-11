#!/usr/bin/env python3
"""Copy every implementation pack's starter files into a project, laid out as their starter tables
say, less the optional parts it leaves out - the stand-up's assembly, and the template CI's.

    python assemble.py <project-dir> [--without part,part] [--only backend,frontend,...] [--frontend DIR]

A pack's backend/ is the project's root, its infrastructure/ and github/ go to infrastructure/
and .github/, and its frontend/ to the web app - <project>/frontend unless --frontend names it.
A pack that keeps its starters at its own root - ROOT_PACKS - is laid out as its backend/ would
be, less the few files ROOT_RENAMES sends elsewhere.
Its requirements files are merged into the project's, each line once. Then remove-optional.py
strips the left-out parts' markers and relinks the migrations. Starter files overwrite what's
there: assemble into a clean tree, and read the change in git.
"""
import argparse
import importlib.util
import pathlib
import shutil
import subprocess
import sys

sys.dont_write_bytecode = True  # no __pycache__ beside the skill
HERE = pathlib.Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location("remove_optional", HERE / "remove-optional.py")
remove_optional = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(remove_optional)

# Where each pack folder lands in a project: the backend is the project's root
LAYOUT = {"backend": "", "infrastructure": "infrastructure", "github": ".github", "frontend": "frontend"}
SKIP = {"node_modules", "__pycache__", ".angular", "dist", ".venv"}
# The web stack's packs whose starters sit at the pack's root, as a project lays them out - not
# under backend/ and github/. Their IMPLEMENT.md starter tables say where each file goes, and
# the template's tests hold this table to them
ROOT_PACKS = {"local-backend", "testing", "quality-gates", "release"}
ROOT_RENAMES = {
    "pre-commit-config.yaml": ".pre-commit-config.yaml",
    "lychee.toml": ".lychee.toml",
    "releaserc.json": ".releaserc.json",
    "pr-check.yml": ".github/workflows/pr-check.yml",
    "release.yml": ".github/workflows/release.yml",
}


def packs() -> list[pathlib.Path]:
    return sorted(p for p in HERE.iterdir() if p.is_dir() and (p / "IMPLEMENT.md").exists())


def owned(part: str) -> list[str]:
    return remove_optional.parts()[part]


def is_owned(rel: str, paths: list[str]) -> bool:
    return any(rel == p or rel.startswith(p.rstrip("/") + "/") for p in paths)


def starters(pack: pathlib.Path):
    """Each of a pack's starter files as (file, the --only folder it counts as, its path in a
    project, whether it's a requirements file to merge rather than copy)."""
    for folder, target in LAYOUT.items():
        src = pack / folder
        for f in sorted(src.rglob("*")) if src.is_dir() else []:
            rel = (pathlib.PurePosixPath(target) / f.relative_to(src).as_posix()).as_posix().lstrip("/")
            yield f, folder, rel, folder == "backend" and f.parent == src and f.name.startswith("requirements")
    if pack.name in ROOT_PACKS:
        for f in sorted(pack.rglob("*")):
            own = f.relative_to(pack).as_posix()
            if own == "IMPLEMENT.md" or own.split("/")[0] in LAYOUT:
                continue
            rel = ROOT_RENAMES.get(own, own)
            folder = "github" if rel.startswith(".github/") else "backend"
            yield f, folder, rel, f.parent == pack and f.name.startswith("requirements")


def assemble(dest: pathlib.Path, without: list[str], only: set[str], frontend: pathlib.Path | None = None,
             requirements: bool = False) -> dict[str, str]:
    """Every pack copied as a project lays it out, less the parts in `without`, then stripped and
    relinked. Returns project path -> the pack path it came from; frontend files as
    `frontend/...` even when `frontend` puts them elsewhere."""
    left_out = [p for part in without for p in owned(part)]
    origin, reqs = {}, {}
    for pack in packs():
        for f, folder, rel, is_requirements in starters(pack):
            pack_rel = f.relative_to(HERE).as_posix()
            if folder not in only or not f.is_file() or SKIP & set(f.parts) or is_owned(pack_rel, left_out):
                continue
            if is_requirements:
                if requirements:
                    reqs.setdefault(f.name, []).extend(f.read_text().split("\n"))
                continue
            path = frontend / rel[len("frontend/"):] if frontend and rel.startswith("frontend/") else dest / rel
            path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(f, path)  # with its mode: scripts stay executable
            origin[rel] = pack_rel
    for name, lines in reqs.items():
        target = dest / name
        have = target.read_text().split("\n") if target.exists() else []
        merged = have + [line for line in dict.fromkeys(lines) if line.strip() and line not in have]
        target.write_text("\n".join(line for line in merged if line is not None).strip("\n") + "\n")
    if without:
        for root in {dest} | ({frontend} if frontend and "frontend" in only else set()):
            subprocess.run([sys.executable, str(HERE / "remove-optional.py"), "--without", ",".join(without), str(root)],
                           check=True, capture_output=True)
    return origin


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("project", type=pathlib.Path)
    ap.add_argument("--without", default="", help="comma-separated optional parts to leave out")
    ap.add_argument("--only", default=",".join(LAYOUT), help="the pack folders to copy - backend,infrastructure,github,frontend")
    ap.add_argument("--frontend", type=pathlib.Path, help="where the web app is, if not <project>/frontend")
    args = ap.parse_args()
    without = [p for p in args.without.split(",") if p]
    unknown = [p for p in without if p not in remove_optional.parts()]
    if unknown:
        print(f"Unknown part(s): {', '.join(unknown)} - optional-parts.txt has {', '.join(remove_optional.parts())}", file=sys.stderr)
        return 1
    origin = assemble(args.project.resolve(), without, set(args.only.split(",")),
                      args.frontend.resolve() if args.frontend else None, requirements=True)
    print(f"Assembled {len(origin)} starter files from {len(packs())} packs" + (f", without {', '.join(without)}" if without else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
