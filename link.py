import json
from pathlib import Path

repo = Path(__file__).parent

with open(repo / "link.json") as f:
    link_map: dict[str, str | None] = json.load(f)  # pyright: ignore

for conf_dest, conf_src in link_map.items():
    if conf_src is None:
        parts = Path(conf_dest).parts
        root = parts[0][1:] if parts[0].startswith(".") else parts[0]
        conf_src = Path(root).joinpath(*parts[1:])

    src = repo / conf_src
    dest = Path.home() / conf_dest

    if dest.exists(follow_symlinks=False) and dest.is_symlink():
        target = dest.readlink()

        if target == src:
            pass
        else:
            print(f"was linked to different target: {conf_dest} -> {target}")
    else:
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.symlink_to(src)
        print(f"created link: {conf_dest} -> {conf_src}")

print("Done!")
