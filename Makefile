.PHONY: macos
macos:
	sudo sh set-macos-defaults.sh

link:
	fish create-symlinks.fish

install-personal:
	cat Brewfile Brewfile-personal | brew bundle --file -
	cat Brewfile Brewfile-personal | brew bundle cleanup --file - --zap --force
	mise upgrade

install-work:
	brew bundle --file Brewfile
	brew bundle cleanup --file Brewfile --zap --force
	mise upgrade

dump:
	brew bundle dump --file Brewfile --force
	grep --invert-match --line-regexp -f Brewfile-personal Brewfile >Brewfile.tmp
	mv Brewfile.tmp Brewfile
