.PHONY:
init: install link macos

update: macos link dump update-packages

install:
	brew bundle

	rustup-init --no-modify-path -y

	for tool in `cat deps-cargo.txt`; do \
		cargo binstall $$tool || cargo install $$tool; \
		done

	for tool in `cat deps-pipx.txt`; do \
		pipx install $$tool; \
		done

	hatch python install all --private

macos:
	sudo apply-user-defaults macos.yaml

link:
	python3.12 link.py

dump:
	python3.12 deps.py
	brew bundle dump --force
	python3.12 clean-brewfile.py

update-packages:
	brew upgrade --greedy
	rustup update
	hatch python install all --update --private
	cargo install-update --all --git
	pipx upgrade-all

personal:
	brew bundle --file Brewfile.personal