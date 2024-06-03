define announce
	@echo
	@echo '┌────────────────────────────────────────────────────────────────────────────┐'
	@echo -n '│ >>> $(1)'
	@printf "%$$((72 - $(shell echo '$(1)' | wc -c)))s│\n"
	@echo '└────────────────────────────────────────────────────────────────────────────┘'
endef

all: build switch

build:
		$(call announce,nix run nix-darwin -- switch --flake)
		@nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake
switch:
		$(call announce,darwin-rebuild switch --flake)
		@darwin-rebuild switch --flake ./ --show-trace
		@echo "Darwin generation: $$($(DARWIN_REBUILD) --list-generations | tail -1)"
rollback:
		$(call announce,darwin-rebuild switch --rollback)
		@darwin-rebuild switch --rollback
		@echo "Darwin generation: $$($(DARWIN_REBUILD) --list-generations | tail -1)"
