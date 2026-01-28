# Goku Migration for Karabiner (nix-darwin + home-manager)

## Status

Blocked

## Blockers

- Goku EDN does not document support for generating Karabiner global settings (menu bar, confirmation, UI flags).
- Goku EDN does not document support for device configuration output (disable built-in keyboard, ignore flags, per-device simple modifications).
- Goku EDN does not document support for `fn_function_keys` output; remapping would need to move into complex rules, changing semantics.
- Migrating to Goku as the sole generator would drop the above settings unless a merge strategy is introduced.

## Context

Karabiner is currently managed as a static JSON file in `darwin/karabiner.json` and linked into `~/.config/karabiner/karabiner.json` via home-manager. This makes editing cumbersome and prevents inline comments. We want to move to Goku (EDN) as the source of truth, generate JSON during `dswitch`, and avoid any background watcher.

`dswitch` is the canonical flow and runs `darwin-rebuild switch` through `darwin/Makefile`. Home-manager activation runs during this flow, so it is the correct place to run a one-shot `goku` command.

## Goals

- Use EDN as the source of truth for Karabiner rules.
- Run Goku only during `dswitch` rebuilds (no watcher).
- Let Goku own `~/.config/karabiner/karabiner.json`.
- Keep changes scoped to nix-darwin + home-manager.

## Non-goals

- Changing Karabiner-Elements installation (still Homebrew cask).
- Changing existing rule semantics.
- Running a launchd watcher (`gokuw`).

## Current State

- `home.file."karabiner/karabiner.json".source = ./karabiner.json` in `darwin/configuration.nix`.
- `xdg.configHome = "${hgj_home}/.config"` already set.
- `dswitch` alias runs `make switch` → `darwin-rebuild switch`.

## Proposed Design

### Source Layout

- Add `darwin/karabiner.edn` to the repo (human-edited, comment friendly).
- Link it to `~/.config/karabiner.edn` using home-manager `xdg.configFile`.

### Generation Flow

- Add `pkgs.goku` to `home.packages`.
- Add a home-manager activation step (after `writeBoundary`) that runs:
  - `mkdir -p "$XDG_CONFIG_HOME/karabiner"`
  - `GOKU_EDN_CONFIG_FILE="$XDG_CONFIG_HOME/karabiner.edn" ${pkgs.goku}/bin/goku`
- Remove `home.file."karabiner/karabiner.json"` so Goku owns JSON output.

### Data Flow

`dswitch` → `darwin-rebuild switch` → home-manager activation → EDN symlinked → `goku` runs → `~/.config/karabiner/karabiner.json` → Karabiner-Elements reads JSON.

## Error Handling

- If `goku` fails, the rebuild should fail. This avoids silently leaving stale JSON.

## Migration Plan

- Add `darwin/karabiner.edn` by translating the existing JSON rules into EDN.
- Add home-manager `xdg.configFile` entry for `karabiner.edn`.
- Add `goku` to `home.packages`.
- Add activation hook to run `goku`.
- Remove the JSON file from `home.file` linking.
- Keep `darwin/karabiner.json` in git only until the EDN version is verified, then remove it.

## Verification

- Run `dswitch`.
- Confirm `~/.config/karabiner/karabiner.json` is regenerated.
- Confirm Karabiner-Elements rules appear as expected (use EventViewer if needed).

## Rollback

- Restore `home.file."karabiner/karabiner.json"` and remove the activation hook.
- Keep the JSON file linked from the repo.

## Risks

- EDN translation errors could break rules; detection is via `goku` failure during rebuild.
- Misconfigured `XDG_CONFIG_HOME` would place output in the wrong path.
