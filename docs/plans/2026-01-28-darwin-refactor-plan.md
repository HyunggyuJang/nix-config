# Darwin Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Choose `superpowers:subagent-driven-development` when tasks are mostly
> independent/parallelizable. Otherwise use `superpowers:executing-plans` for sequential execution.

**Goal:** Modularize the darwin config, remove `localconfig`, and document a clear new-machine setup flow with secrets kept out of the public repo.

**Architecture:** Keep `darwin/flake.nix` as the entrypoint, shift domain blocks into `darwin/modules/*`, and define per-host settings in `darwin/hosts/<host>.nix`. Keep secrets out of the public repo (prefer agenix/sops-nix or runtime secrets). Update `darwin/Makefile` to resolve the host automatically and pass an explicit flake target.

**Tech Stack:** Nix flakes, nix-darwin, home-manager, GNU Make, zsh.

---

### Task 1: New-Machine Setup Guide

**Depends on:** None
**Parallelizable:** no
**Shared State:** None

**Files:**
- Create: `docs/guides/darwin-setup.md`

**Step 1: Draft the guide**

Include:
- Prereqs (Nix, nix-darwin, Homebrew)
- Set LocalHostName (`scutil --set LocalHostName <host>`)
- Create `darwin/hosts/<host>.nix`
- Run `make switch` and verify build

**Step 2: Sanity check content**

Confirm no emails/secrets are in the guide.

**Step 3: Commit**

```bash
git add docs/guides/darwin-setup.md
git commit -m "docs(guides): add darwin new-machine setup"
```

### Task 2: Extract Overlays Module

**Depends on:** Task 1
**Parallelizable:** no
**Shared State:** `darwin/configuration.nix` edits

**Files:**
- Create: `darwin/modules/overlays.nix`
- Modify: `darwin/configuration.nix`

**Step 1: Move overlays block**

Move `nixpkgs.overlays` into `darwin/modules/overlays.nix` and export it as a module.

**Step 2: Wire module import**

Add `./modules/overlays.nix` to `imports` in `darwin/configuration.nix`.

**Step 3: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.A13884ui-MacBookPro.system --dry-run
```

**Step 4: Commit**

```bash
git add darwin/modules/overlays.nix darwin/configuration.nix
git commit -m "refactor(darwin): extract overlays module"
```

### Task 3: Extract Homebrew + System Packages Modules

**Depends on:** Task 2
**Parallelizable:** no
**Shared State:** `darwin/configuration.nix` edits

**Files:**
- Create: `darwin/modules/homebrew.nix`
- Create: `darwin/modules/system-packages.nix`
- Modify: `darwin/configuration.nix`

**Step 1: Move Homebrew config**

Extract `homebrew` block into `darwin/modules/homebrew.nix`.

**Step 2: Move system packages**

Extract `environment.systemPackages`, `pathsToLink`, and `shells` into `darwin/modules/system-packages.nix`.

**Step 3: Wire module imports**

Add both modules to `imports` in `darwin/configuration.nix`.

**Step 4: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.A13884ui-MacBookPro.system --dry-run
```

**Step 5: Commit**

```bash
git add darwin/modules/homebrew.nix darwin/modules/system-packages.nix darwin/configuration.nix
git commit -m "refactor(darwin): extract homebrew and packages modules"
```

### Task 4: Host Modules + Explicit Flake Target

**Depends on:** Task 3
**Parallelizable:** no
**Shared State:** `darwin/flake.nix`, `darwin/configuration.nix`, `darwin/Makefile`

**Files:**
- Create: `darwin/hosts/Hyunggyus-MacBook-Air.nix`
- Create: `darwin/hosts/Hyunggyus-MacBook-Pro.nix`
- Create: `darwin/hosts/A13884ui-MacBookPro.nix`
- Modify: `darwin/flake.nix`
- Modify: `darwin/configuration.nix`
- Modify: `darwin/Makefile`

**Step 1: Add host modules**

Each host module should set:
```nix
{ ... }: {
  host = {
    name = "<host>";
    owner = "<user>";
    machineType = "<type>";
  };
}
```

**Step 2: Pass host via `specialArgs`**

Update `darwin/flake.nix` to pass `host` in `specialArgs` (replace `machineType`).

**Step 3: Replace `localconfig` and `machineType` usage**

Update `darwin/configuration.nix` to use `host.*` values. Remove `localconfig` import and any `HOSTNAME` assumptions.

**Step 4: Make Makefile resolve host**

Add a `HOST` variable resolved via `scutil --get LocalHostName` (fallback to `hostname -s`) and pass `--flake .#${HOST}` to `nix-darwin` and `darwin-rebuild`.

**Step 5: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.A13884ui-MacBookPro.system --dry-run
```

**Step 6: Commit**

```bash
git add darwin/hosts/*.nix darwin/flake.nix darwin/configuration.nix darwin/Makefile
git commit -m "refactor(darwin): add host modules and explicit flake target"
```

### Task 5: Secrets handling (agenix/sops-nix)

**Note:** The host-local `*.local.nix` approach was removed under flakes (gitignored files aren’t visible). Use agenix/sops-nix or runtime secrets instead.
