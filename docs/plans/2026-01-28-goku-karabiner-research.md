# Goku Karabiner Migration Research

Date: 2026-01-28

## Current State

- Home Manager is wired via nix-darwin at `darwin/configuration.nix:51-56`.
- User config uses XDG paths and config files under `darwin/configuration.nix:726-795`.
- Karabiner JSON is linked from the repo via `xdg.configFile` at `darwin/configuration.nix:786`.
- Karabiner-Elements is installed via Homebrew cask at `darwin/configuration.nix:2568-2572`.
- Source Karabiner config is the full JSON file at `darwin/karabiner.json`.

## Planned Integration Points

- Add `xdg.configFile."karabiner.edn".source = ./karabiner.edn;` next to other XDG config files (`darwin/configuration.nix:726-795`).
- Remove `xdg.configFile."karabiner/karabiner.json"` so Goku owns the output (`darwin/configuration.nix:786`).
- Add `home.packages = [ pkgs.goku ];` inside the user config (no existing `home.packages` block found).
- Add a `home.activation` step (likely after `writeBoundary`) to run Goku during `darwin-rebuild switch`.

## Gaps / Caveats

- EDN translation must cover all settings currently in `darwin/karabiner.json` (global, profiles, devices, fn keys, simple modifications, complex rules). Verify Goku supports every section needed; if any section is unsupported, it may need alternative handling.
- Activation must ensure `XDG_CONFIG_HOME` is set to `${config.xdg.configHome}` so Goku writes to the intended `~/.config` tree.
- The existing JSON symlink must be removed before running Goku, otherwise writes may fail or target the repo file.

## Conclusion

Goku-only generation is blocked because the documented EDN format does not cover Karabiner global settings, device configuration output, or `fn_function_keys`. Proceeding without a merge strategy would drop these settings.

## Notes

- No existing `home.activation` hooks were found in `darwin/configuration.nix`.
