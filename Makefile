.PHONY:
init: install link macos
update: link update-packages

install:
	brew bundle --file config/packages/Brewfile
	mise install

update-packages:
	brew bundle --file config/packages/Brewfile
	mise install

install-personal:
	brew bundle --file config/packages/Brewfile-personal

macos:
	sudo apply-user-defaults config/macos.yaml

link:
	python3.12 src/create-symlinks.py

dump:
	brew bundle dump --file config/packages/Brewfile --force
	python3.12 src/clean-brewfile.py
