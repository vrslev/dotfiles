.PHONY:
init:
	brew bundle
	rustup-init --no-modify-path -y

	for tool in `cat tools/cargo.txt`; do \
		cargo binstall $$tool || cargo install $$tool; \
		done

	for tool in `cat tools/pipx.txt`; do \
		pipx install $$tool; \
		done

macos:
	sudo apply-user-defaults macos.yaml

link:
	git -C dotbot submodule sync --quiet --recursive
	git submodule update --init --recursive dotbot
	dotbot/bin/dotbot -c install.conf.yaml

update:
	python3.12 tools/dump.py
	brew bundle dump -f

	git -C dotbot submodule sync --quiet --recursive
	git submodule update --init --recursive dotbot

	brew upgrade --greedy

	rustup update
	hatch python install all --update --private

	cargo install-update --all --git
	pipx upgrade-all

all: macos link update