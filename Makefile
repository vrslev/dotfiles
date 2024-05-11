.PHONY: macos
macos:
	sudo ./set-macos-defaults

link:
	./link-config-files

install:
	brew update
	brew bundle --file Brewfile
	mise upgrade
	brew bundle cleanup --file Brewfile --zap --force &
	mise prune --yes &
