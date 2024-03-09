import subprocess
from pathlib import Path

lines = subprocess.check_output(("pipx", "list", "--short")).decode().splitlines()
packages = [line.split(" ")[0] for line in lines]

path = Path(__file__).parent.parent / "config" / "packages" / "pipx.txt"
content = "\n".join(packages) + "\n"

with path.open("w+") as f:
    f.seek(0)
    f.write(content)
    f.truncate()

print(f"Saved pipx packages: {packages}")
