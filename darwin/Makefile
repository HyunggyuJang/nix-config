NIX_CONF = $(HOME)/Desktop/dotfiles/nixpkgs/darwin
NIXPATH = "$(NIX_PATH):localconfig=$(NIX_CONF)/$(HOSTNAME).nix:darwin-config=$(NIX_CONF)/configuration.nix"
PRENIX = PATH="$(BUILD_PATH)/sw/bin:$(PATH)" NIX_PATH="$(NIXPATH)"

NIX_BUILD = $(PRENIX) nix-build
BUILD_PATH = /run/current-system

ifeq ($(HOSTNAME),silicon)
BUILD_ARGS = # --argstr system aarch64-darwin not work.
else
BUILD_ARGS =
endif

DARWIN_REBUILD = $(PRENIX) $(BUILD_PATH)/sw/bin/darwin-rebuild
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
		@$(NIX_BUILD) https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer $(BUILD_ARGS)
		@$(DARWIN_INSTALL)
		@rm -f result*
switch:
		$(call announce,darwin-rebuild switch)
		@$(DARWIN_REBUILD) switch -Q
		@echo "Darwin generation: $$($(DARWIN_REBUILD) --list-generations | tail -1)"
