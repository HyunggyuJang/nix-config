# Darwin home-manager layout

## darwin/ entrypoints and shared assets

- `darwin/flake.nix`, `darwin/flake.lock`, `darwin/configuration.nix`, and `darwin/Makefile` are the nix-darwin entrypoints.
- `darwin/hosts/` stores per-host modules referenced by the flake.
- `darwin/*.nix` at the root holds shared nix sources used by modules (for example `darwin/azik_us.nix` and `darwin/silicon.nix`).

## darwin/modules/

- Nix-darwin modules that configure system defaults, services, packages, and home-manager integration.
- Files are scoped by responsibility (for example `darwin/modules/system-base.nix`, `darwin/modules/homebrew.nix`).

## darwin/home-manager/

- Home Manager modules for darwin.
- `darwin/home-manager/default.nix` and `darwin/home-manager/targets.nix` wire modules together.
- `darwin/home-manager/programs/` contains program-specific modules.
- `darwin/home-manager/files.nix` defines `home.file` entries; `darwin/home-manager/xdg.nix` defines XDG config entries.

## darwin/home-manager/files/**

- Source files managed by Home Manager and referenced with `./files/...` paths from modules.
- XDG config sources live under `darwin/home-manager/files/xdg/<app>/...` and are referenced from `darwin/home-manager/xdg.nix`.
- Non-XDG assets live under `darwin/home-manager/files/<area>/...` (for example `darwin/home-manager/files/gnupg/gpg-agent.conf`, `darwin/home-manager/files/firefox/userChrome.css`) or as top-level files like `darwin/home-manager/files/tridactylrc`.
