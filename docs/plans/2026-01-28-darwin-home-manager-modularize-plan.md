# Darwin Home-Manager Modularization Plan

> **Execution choice (set during handoff by the human partner):** `superpowers:executing-plans` (sequential)

**Goal:** Split `darwin/modules/home-manager.nix` into smaller home-manager modules by concern while keeping behavior unchanged.

**Architecture:** Keep `darwin/modules/home-manager.nix` as a thin wrapper that imports a new `darwin/home-manager/default.nix`. That default module defines `home-manager.useGlobalPkgs`, `home-manager.useUserPackages`, `home-manager.extraSpecialArgs`, and `home-manager.users.${owner}` with `imports` pointing to per-concern home-manager modules (`files`, `xdg`, `targets`, `programs/*`). Each extracted file is a home-manager module operating under `home-manager.users.${owner}`.

**Tech Stack:** Nix flakes, nix-darwin, home-manager.

**Commit Intent:** per-task

---

### Task 1: Add home-manager wrapper + default module

**Depends on:** None
**Parallelizable:** no
**Shared State:** `darwin/modules/home-manager.nix`

**Files:**
- Create: `darwin/home-manager/default.nix`
- Modify: `darwin/modules/home-manager.nix`

**Step 1: Create default module**

In `darwin/home-manager/default.nix`, define:
- `home-manager.useGlobalPkgs = true;`
- `home-manager.useUserPackages = false;`
- `home-manager.extraSpecialArgs = { inherit hostName owner machineType hgj_home hgj_projects hgj_darwin_home hgj_localbin brewpath inputs; };`
- `home-manager.users.${owner}` with `home.stateVersion = "24.11"` and `imports = [ ./files.nix ./targets.nix ./xdg.nix ./programs/vscode.nix ./programs/zsh.nix ./programs/direnv.nix ./programs/emacs.nix ./programs/firefox.nix ./programs/fzf.nix ./programs/browserpass.nix ];`

**Step 2: Thin wrapper**

Replace the body of `darwin/modules/home-manager.nix` with a minimal import of `../home-manager/default.nix`.

**Step 3: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 4: Commit**

```bash
git add darwin/home-manager/default.nix darwin/modules/home-manager.nix
git commit -m "refactor(home-manager): add default module"
```

### Task 2: Extract `home.file`

**Depends on:** Task 1
**Parallelizable:** no
**Shared State:** `darwin/home-manager/default.nix`

**Files:**
- Create: `darwin/home-manager/files.nix`
- Modify: `darwin/modules/home-manager.nix`

**Step 1: Move `home.file` block**

Move the full `home.file` block (including the `machineType`-conditioned `.gitconfig` fragment) into `darwin/home-manager/files.nix`.

**Step 2: Ensure path references remain correct**

Keep file sources using `../karabiner.json`, `../Zed/*.json`, and other paths so they still resolve relative to `darwin/`.

**Step 3: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 4: Commit**

```bash
git add darwin/home-manager/files.nix darwin/home-manager/default.nix darwin/modules/home-manager.nix
git commit -m "refactor(home-manager): extract home.file"
```

### Task 3: Extract targets keybindings

**Depends on:** Task 2
**Parallelizable:** no
**Shared State:** `darwin/home-manager/default.nix`

**Files:**
- Create: `darwin/home-manager/targets.nix`

**Step 1: Move `targets.darwin.keybindings`**

Move the `targets.darwin.keybindings` block into `darwin/home-manager/targets.nix`.

**Step 2: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 3: Commit**

```bash
git add darwin/home-manager/targets.nix darwin/home-manager/default.nix darwin/modules/home-manager.nix
git commit -m "refactor(home-manager): extract targets"
```

### Task 4: Extract XDG configuration

**Depends on:** Task 3
**Parallelizable:** no
**Shared State:** `darwin/home-manager/default.nix`

**Files:**
- Create: `darwin/home-manager/xdg.nix`

**Step 1: Move `xdg` block**

Move the entire `xdg` block into `darwin/home-manager/xdg.nix`.

**Step 2: Relocate `kittyDracula` derivation**

Define `kittyDracula` inside `xdg.nix` so `kitty/dracula.conf` and `kitty/diff.conf` keep working.

**Step 3: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 4: Commit**

```bash
git add darwin/home-manager/xdg.nix darwin/home-manager/default.nix darwin/modules/home-manager.nix
git commit -m "refactor(home-manager): extract xdg"
```

### Task 5: Extract editor + shell programs

**Depends on:** Task 4
**Parallelizable:** no
**Shared State:** `darwin/home-manager/default.nix`

**Files:**
- Create: `darwin/home-manager/programs/vscode.nix`
- Create: `darwin/home-manager/programs/zsh.nix`
- Create: `darwin/home-manager/programs/direnv.nix`
- Create: `darwin/home-manager/programs/emacs.nix`

**Step 1: Move `programs.vscode`**

Extract the full `programs.vscode` block into `programs/vscode.nix`.

**Step 2: Move `programs.zsh` and `programs.direnv`**

Extract `programs.zsh` into `programs/zsh.nix` and `programs.direnv` into `programs/direnv.nix`.

**Step 3: Move `programs.emacs`**

Extract `programs.emacs` into `programs/emacs.nix`.

**Step 4: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 5: Commit**

```bash
git add darwin/home-manager/programs/vscode.nix darwin/home-manager/programs/zsh.nix darwin/home-manager/programs/direnv.nix darwin/home-manager/programs/emacs.nix darwin/home-manager/default.nix darwin/modules/home-manager.nix
git commit -m "refactor(home-manager): extract editor and shell programs"
```

### Task 6: Extract remaining programs

**Depends on:** Task 5
**Parallelizable:** no
**Shared State:** `darwin/home-manager/default.nix`

**Files:**
- Create: `darwin/home-manager/programs/firefox.nix`
- Create: `darwin/home-manager/programs/fzf.nix`
- Create: `darwin/home-manager/programs/browserpass.nix`

**Step 1: Move `programs.firefox`**

Extract the full `programs.firefox` block into `programs/firefox.nix`. Ensure `inputs` is available via `home-manager.extraSpecialArgs` for addons.

**Step 2: Move `programs.fzf` and `programs.browserpass`**

Extract `programs.fzf.*` into `programs/fzf.nix` and `programs.browserpass.*` into `programs/browserpass.nix`.

**Step 3: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 4: Commit**

```bash
git add darwin/home-manager/programs/firefox.nix darwin/home-manager/programs/fzf.nix darwin/home-manager/programs/browserpass.nix darwin/home-manager/default.nix darwin/modules/home-manager.nix
git commit -m "refactor(home-manager): extract remaining programs"
```
