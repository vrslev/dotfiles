.PHONY: macos
macos:
	sudo ./set-macos-defaults

link:
	./create-symlinks

install-personal:
	brew update
	cat Brewfile Brewfile-personal | brew bundle --file -
	cat Brewfile Brewfile-personal | brew bundle cleanup --file - --zap --force
	mise upgrade

install-work:
	brew update
	brew bundle --file Brewfile
	brew bundle cleanup --file Brewfile --zap --force
	mise upgrade
