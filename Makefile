MAIN_BREWFILE=config/packages/Brewfile
PERSONAL_BREWFILE=config/packages/Brewfile-personal
HOMEBREW_BUNDLE_NO_LOCK=1

.PHONY:
macos:
	sudo apply-user-defaults config/macos.yaml

link:
	python3.12 src/create-symlinks.py

install-personal:
	cat $(MAIN_BREWFILE) $(PERSONAL_BREWFILE) | brew bundle --file -
	cat $(MAIN_BREWFILE) $(PERSONAL_BREWFILE) | brew bundle cleanup --file - --force
	mise upgrade

install-work:
	brew bundle --file $(MAIN_BREWFILE)
	brew bundle cleanup --file $(MAIN_BREWFILE) --force
	mise upgrade

dump:
	brew bundle dump --file $(MAIN_BREWFILE) --force
	python3.12 src/clean-brewfile.py
