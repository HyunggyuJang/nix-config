define announce
	@echo
	@echo '┌────────────────────────────────────────────────────────────────────────────┐'
	@echo -n '│ >>> $(1)'
	@printf "%$$((72 - $(shell echo '$(1)' | wc -c)))s│\n"
	@echo '└────────────────────────────────────────────────────────────────────────────┘'
endef

HOST ?= $(shell scutil --get LocalHostName 2>/dev/null || hostname -s)

all: build switch

build:
		$(call announce,nix run nix-darwin -- switch --flake .#$(HOST))
		@nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- switch --flake .#$(HOST)
switch:
		$(call announce,darwin-rebuild switch --flake .#$(HOST))
		@sudo darwin-rebuild switch --flake .#$(HOST) --show-trace
		@echo "Darwin generation: $$(sudo darwin-rebuild --list-generations | tail -1)"
rollback:
		$(call announce,darwin-rebuild switch --rollback --flake .#$(HOST))
		@sudo darwin-rebuild switch --rollback --flake .#$(HOST)
		@echo "Darwin generation: $$(sudo darwin-rebuild --list-generations | tail -1)"
