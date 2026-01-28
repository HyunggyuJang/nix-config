# Darwin Refactor (Phase 2) Implementation Plan

> **Execution choice (set during handoff by the human partner):** `superpowers:executing-plans` (sequential)

**Goal:** Reduce `darwin/configuration.nix` to a thin import hub by extracting remaining system and home-manager blocks into dedicated modules.

**Architecture:** Keep `darwin/configuration.nix` as a thin wrapper that defines shared module args and imports. Move system settings (defaults, users, environment, services, nix settings) into `darwin/modules/*` and move the entire home-manager block into `darwin/modules/home-manager.nix` as a first pass.

**Tech Stack:** Nix flakes, nix-darwin, home-manager.

**Commit Intent:** per-task

---

### Task 1: Add shared module args and extract system base + defaults

**Depends on:** None
**Parallelizable:** no
**Shared State:** `darwin/configuration.nix`

**Files:**
- Create: `darwin/modules/system-base.nix`
- Create: `darwin/modules/system-defaults.nix`
- Modify: `darwin/configuration.nix`

**Step 1: Add `_module.args`**

Define `_module.args` in `darwin/configuration.nix` for:
`host`, `hostName`, `owner`, `machineType`, `hgj_home`, `hgj_sync`, `hgj_darwin_home`, `hgj_projects`, `hgj_local`, `hgj_localbin`, `brewpath`.

**Step 2: Extract system base**

Move the following blocks into `darwin/modules/system-base.nix`:
- `system.primaryUser`
- `system.stateVersion`
- `users`
- `fonts`
- `nixpkgs.hostPlatform`
- `nixpkgs.config.allowUnfree`
- `ids.gids.nixbld`

**Step 3: Extract system defaults**

Move `system.defaults` into `darwin/modules/system-defaults.nix`.

**Step 4: Wire imports**

Add `./modules/system-base.nix` and `./modules/system-defaults.nix` to `imports` in `darwin/configuration.nix`.

**Step 5: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 6: Commit**

```bash
git add darwin/modules/system-base.nix darwin/modules/system-defaults.nix darwin/configuration.nix
git commit -m "refactor(darwin): extract system base and defaults"
```

### Task 2: Extract environment module

**Depends on:** Task 1
**Parallelizable:** no
**Shared State:** `darwin/configuration.nix`

**Files:**
- Create: `darwin/modules/environment.nix`
- Modify: `darwin/configuration.nix`

**Step 1: Move environment block**

Move `environment` (variables + systemPath) into `darwin/modules/environment.nix`.

**Step 2: Wire import**

Add `./modules/environment.nix` to `imports`.

**Step 3: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 4: Commit**

```bash
git add darwin/modules/environment.nix darwin/configuration.nix
git commit -m "refactor(darwin): extract environment module"
```

### Task 3: Extract services module

**Depends on:** Task 2
**Parallelizable:** no
**Shared State:** `darwin/configuration.nix`

**Files:**
- Create: `darwin/modules/services.nix`
- Modify: `darwin/configuration.nix`

**Step 1: Move services block**

Move `services` (yabai + skhd) into `darwin/modules/services.nix`.

**Step 2: Wire import**

Add `./modules/services.nix` to `imports`.

**Step 3: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 4: Commit**

```bash
git add darwin/modules/services.nix darwin/configuration.nix
git commit -m "refactor(darwin): extract services module"
```

### Task 4: Extract system programs + nix settings

**Depends on:** Task 3
**Parallelizable:** no
**Shared State:** `darwin/configuration.nix`

**Files:**
- Create: `darwin/modules/system-programs.nix`
- Create: `darwin/modules/nix-settings.nix`
- Modify: `darwin/configuration.nix`

**Step 1: Move system programs**

Move `programs.zsh` (system-level) into `darwin/modules/system-programs.nix`.

**Step 2: Move nix settings**

Move `nix` settings into `darwin/modules/nix-settings.nix`.

**Step 3: Wire imports**

Add both modules to `imports`.

**Step 4: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 5: Commit**

```bash
git add darwin/modules/system-programs.nix darwin/modules/nix-settings.nix darwin/configuration.nix
git commit -m "refactor(darwin): extract system programs and nix settings"
```

### Task 5: Extract home-manager block

**Depends on:** Task 4
**Parallelizable:** no
**Shared State:** `darwin/configuration.nix`

**Files:**
- Create: `darwin/modules/home-manager.nix`
- Modify: `darwin/configuration.nix`

**Step 1: Move home-manager configuration**

Move the entire home-manager section into `darwin/modules/home-manager.nix`, including:
- `home-manager.useGlobalPkgs`
- `home-manager.useUserPackages`
- `home-manager.users` (including `home.file`, `xdg`, `programs`, `targets`)
- `kittyDracula` derivation if still referenced within home-manager configs

**Step 2: Wire import**

Add `./modules/home-manager.nix` to `imports` and remove the block from `darwin/configuration.nix`.

**Step 3: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 4: Commit**

```bash
git add darwin/modules/home-manager.nix darwin/configuration.nix
git commit -m "refactor(darwin): extract home-manager module"
```

---

## Optional Follow-up (Not in this plan)

- Split `darwin/modules/home-manager.nix` into `darwin/home-manager/*` modules.
- Move large inline config strings to `darwin/files/**` and reference with `home.file.<path>.source`.
