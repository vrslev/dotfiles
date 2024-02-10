with open("Brewfile") as f:
    main_bf = f.read().splitlines()
with open("Brewfile-personal") as f:
    personal_bf = set(f.read().splitlines())

modified_bf = [line for line in main_bf if line and line not in personal_bf] + [""]

with open("Brewfile", "r+") as f:
    f.seek(0)
    f.write("\n".join(modified_bf))
    f.truncate()