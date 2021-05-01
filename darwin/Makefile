NIX_CONF = $(HOME)/Desktop/dotfiles/nixpkgs/darwin
NIXPATH = $(NIX_PATH):localconfig=$(NIX_CONF)/$(HOSTNAME).nix
PRENIX = NIX_PATH=$(NIXPATH)
DARWIN_REBUILD = $(PRENIX) darwin-rebuild

define announce
	@echo
	@echo '┌────────────────────────────────────────────────────────────────────────────┐'
	@echo -n '│ >>> $(1)'
	@printf "%$$((72 - $(shell echo '$(1)' | wc -c)))s│\n"
	@echo '└────────────────────────────────────────────────────────────────────────────┘'
endef

build:
		$(call announce,darwin-rebuild switch)
		@$(DARWIN_REBUILD) switch -Q
		@echo "Darwin generation: $$($(DARWIN_REBUILD) --list-generations | tail -1)"
