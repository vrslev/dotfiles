import subprocess
from pathlib import Path
from typing import Iterable


def get_cargo_packages() -> Iterable[str]:
    out = subprocess.check_output(("cargo", "install", "--list"))
    for line in out.decode().splitlines():
        if not line.startswith(" "):
            yield line.split(" ")[0]


def get_pipx_packages() -> Iterable[str]:
    out = subprocess.check_output(("pipx", "list", "--short"))
    for line in out.decode().splitlines():
        yield line.split(" ")[0]


def overwrite_file(path: Path, content: str) -> None:
    with path.open("w+") as f:
        f.seek(0)
        f.write(content + "\n")
        f.truncate()


def save_packages_list(package_manager_name: str, packages: list[str]) -> None:
    print(f"Saved {package_manager_name} packages: {packages}")
    path = (
        Path(__file__).parent.parent
        / "config"
        / "packages"
        / f"{package_manager_name}.txt"
    )
    overwrite_file(path, "\n".join(packages))


save_packages_list("cargo", list(get_cargo_packages()))
save_packages_list("pipx", list(get_pipx_packages()))
