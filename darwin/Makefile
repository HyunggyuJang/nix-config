NIX_CONF = $(HOME)/Desktop/dotfiles/nixpkgs/darwin
NIXPATH = "$(NIX_PATH):localconfig=$(NIX_CONF)/$(HOSTNAME).nix:darwin-config=$(NIX_CONF)/configuration.nix"
PRENIX = PATH="/nix/var/nix/profiles/system/sw/bin:$(PATH)" NIX_PATH="$(NIXPATH)"

NIX_BUILD = $(PRENIX) nix-build

DARWIN_REBUILD = $(PRENIX) darwin-rebuild
DARWIN_INSTALL = $(PRENIX) ./result/bin/darwin-installer

define announce
	@echo
	@echo '┌────────────────────────────────────────────────────────────────────────────┐'
	@echo -n '│ >>> $(1)'
	@printf "%$$((72 - $(shell echo '$(1)' | wc -c)))s│\n"
	@echo '└────────────────────────────────────────────────────────────────────────────┘'
endef

all: build switch

build:
		$(call announce,darwin-installer)
		@$(NIX_BUILD)
		@$(DARWIN_INSTALL)
		@rm -f result*
switch:
		$(call announce,darwin-rebuild switch)
		@$(DARWIN_REBUILD) switch -Q
		@echo "Darwin generation: $$($(DARWIN_REBUILD) --list-generations | tail -1)"
