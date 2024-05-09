MAIN_BREWFILE=config/packages/Brewfile
PERSONAL_BREWFILE=config/packages/Brewfile-personal
HOMEBREW_BUNDLE_NO_LOCK=whatever

.PHONY:
init: install link macos
install: link update-packages

update-packages:
	brew bundle --file $(MAIN_BREWFILE)
	mise upgrade

install-personal:
	brew bundle --file $(PERSONAL_BREWFILE)

macos:
	sudo apply-user-defaults config/macos.yaml

link:
	python3.12 src/create-symlinks.py

dump:
	brew bundle dump --file $(MAIN_BREWFILE) --force
	python3.12 src/clean-brewfile.py

cleanup-work:
	brew bundle cleanup --file $(MAIN_BREWFILE) --force
	mise prune

cleanup-personal:
	cat $(MAIN_BREWFILE) $(PERSONAL_BREWFILE) | brew bundle cleanup --file - --force
	mise prune
