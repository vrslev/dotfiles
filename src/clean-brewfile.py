from pathlib import Path

dir = Path(__file__).parent.parent / "config" / "packages"

with open(dir / "Brewfile") as f:
    main_bf = f.read().splitlines()

with open(dir / "Brewfile-personal") as f:
    personal_bf = set(f.read().splitlines())

modified_bf = [line for line in main_bf if line and line not in personal_bf] + [""]

with open(dir / "Brewfile", "r+") as f:
    f.seek(0)
    f.write("\n".join(modified_bf))
    f.truncate()
