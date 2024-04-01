.PHONY:
init: install link macos
update: link update-packages

install:
	brew bundle --file config/packages/Brewfile
	# rustup-init --no-modify-path -y
	hatch python install all --private

	for tool in `cat config/packages/pipx.txt`; do \
		pipx install $$tool; \
		done

update-packages:
	brew bundle --file config/packages/Brewfile
	# rustup update
	hatch python install all --update --private

	for tool in `cat config/packages/pipx.txt`; do \
		pipx install $$tool; \
		done

	pipx upgrade-all

install-personal:
	brew bundle --file config/packages/Brewfile-personal

macos:
	sudo apply-user-defaults config/macos.yaml

link:
	python3.12 src/create-symlinks.py

dump:
	python3.12 src/save-packages.py
	brew bundle dump --file config/packages/Brewfile --force
	python3.12 src/clean-brewfile.py
