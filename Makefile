.PHONY:
init:
	brew bundle
	rustup-init --no-modify-path -y

	for tool in `cat deps-cargo.txt`; do \
		cargo binstall $$tool || cargo install $$tool; \
		done

	for tool in `cat deps-pipx.txt`; do \
		pipx install $$tool; \
		done

macos:
	defaults -currentHost write -g AppleFontSmoothing -int 0
	sudo apply-user-defaults macos.yaml

link:
	python3.12 link.py

dump:
	python3.12 deps.py
	brew bundle dump -f

update:
	brew upgrade --greedy

	rustup update
	hatch python install all --update --private

	cargo install-update --all --git
	pipx upgrade-all

all: macos link dump update

