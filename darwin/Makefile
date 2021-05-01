NIX_CONF = $(HOME)/Desktop/dotfiles/nixpkgs/darwin
NIXPATH = $(NIX_PATH):localconfig=$(NIX_CONF)/$(HOSTNAME).nix:darwin-config=$(NIX_CONF)/configuration.nix
PRENIX = PATH="$(BUILD_PATH)/sw/bin:$(PATH)" NIX_PATH="$(NIXPATH)"

NIX = $(PRENIX) nix
BUILD_PATH = /run/current-system
DARWIN_REBUILD = $(PRENIX) $(BUILD_PATH)/sw/bin/darwin-rebuild

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
		@$(NIX) build -f .
		@rm -f result*
switch:
		$(call announce,darwin-rebuild switch)
		@$(DARWIN_REBUILD) switch -Q
		@echo "Darwin generation: $$($(DARWIN_REBUILD) --list-generations | tail -1)"
