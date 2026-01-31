---
name: update-darwin-flake-inputs
description: Refresh pinned input revisions in darwin/flake.nix (nixpkgs, nix-darwin, home-manager, nixpkgs-firefox-darwin) by updating darwin/flake.lock and syncing commit hashes.
---

# Update darwin flake input revisions

## Overview
The darwin flake pins input repos by commit in `darwin/flake.nix`. Use this skill to update those commits and keep `darwin/flake.lock` in sync.

## Steps

1. From the repo root, update the lock file to the latest default branches:

   ```bash
   cd darwin
   nix flake update \
     --override-input nixpkgs github:NixOS/nixpkgs \
     --override-input nix-darwin github:nix-darwin/nix-darwin \
     --override-input home-manager github:nix-community/home-manager \
     --override-input nixpkgs-firefox-darwin github:bandithedoge/nixpkgs-firefox-darwin \
     nixpkgs \
     nix-darwin \
     home-manager \
     nixpkgs-firefox-darwin
   ```

2. Sync `darwin/flake.nix` to the new locked revisions:

   ```bash
   cd darwin
   python - <<'PY'
   import json
   import pathlib
   import re

   lock = json.loads(pathlib.Path("flake.lock").read_text())
   inputs = [
       "nixpkgs",
       "nix-darwin",
       "home-manager",
       "nixpkgs-firefox-darwin",
   ]

   text = pathlib.Path("flake.nix").read_text()
   for name in inputs:
       rev = lock["nodes"][name]["locked"]["rev"]
       pattern = rf"({re.escape(name)}\.url\s*=\s*\"[^\"]+/)([0-9a-f]{{7,}})(\";)"
       def repl(match, rev=rev):
           return f"{match.group(1)}{rev}{match.group(3)}"
       text, count = re.subn(pattern, repl, text)
       if count != 1:
           raise SystemExit(f"Expected 1 match for {name}, got {count}")

   pathlib.Path("flake.nix").write_text(text)
   PY
   ```

3. Review the results:

   ```bash
   git diff darwin/flake.nix darwin/flake.lock
   ```

## Notes

- If you need a specific tag/branch, swap the override URL (e.g., `github:NixOS/nixpkgs/nixpkgs-unstable`) before updating.
- `firefox-addons` does not pin a revision in `flake.nix`; updating `flake.lock` is sufficient.
