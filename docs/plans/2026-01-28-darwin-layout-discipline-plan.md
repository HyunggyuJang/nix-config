# Darwin Layout Discipline Plan

**Goal:** Document a consistent file layout for darwin/home-manager assets and align remaining root-level files with that layout.

**Architecture:** Add a short guide that defines layout conventions for `darwin/`, `darwin/modules/`, `darwin/home-manager/`, and `darwin/home-manager/files/**`. Move the remaining home-manager-managed assets from `darwin/` into `darwin/home-manager/files/**` and update the relevant module references.

**Tech Stack:** Nix flakes, nix-darwin, home-manager.

**Commit Intent:** per-task

**Execution Decision:** `superpowers:executing-plans`

---

### Task 1: Document layout conventions

**Depends on:** None
**Parallelizable:** no
**Shared State:** docs index

**Files:**
- Create: `docs/guides/darwin-home-manager-layout.md`
- Modify: `docs/agents/index.md`

**Step 1: Add guide**

Document the layout rules for:
- `darwin/` entrypoints and shared assets
- `darwin/modules/` nix-darwin modules
- `darwin/home-manager/` home-manager modules
- `darwin/home-manager/files/**` file sources (including XDG)

Avoid aspirational language; describe current conventions only.

**Step 2: Update docs index**

Add the new guide to `docs/agents/index.md`.

**Step 3: Verify**

If a doc linter exists, run it; otherwise skip.

**Step 4: Commit**

```bash
git add docs/guides/darwin-home-manager-layout.md docs/agents/index.md
git commit -m "docs(guides): add darwin layout conventions"
```

### Task 2: Move remaining root-level home-manager assets

**Depends on:** Task 1
**Parallelizable:** no
**Shared State:** `darwin/home-manager/xdg.nix`, `darwin/home-manager/programs/firefox.nix`

**Files:**
- Move: `darwin/karabiner.json` -> `darwin/home-manager/files/xdg/karabiner/karabiner.json`
- Move: `darwin/Zed/Nano.json` -> `darwin/home-manager/files/xdg/zed/Nano.json`
- Move: `darwin/Zed/keymap.json` -> `darwin/home-manager/files/xdg/zed/keymap.json`
- Move: `darwin/Zed/settings.json` -> `darwin/home-manager/files/xdg/zed/settings.json`
- Move: `darwin/userChrome.css` -> `darwin/home-manager/files/firefox/userChrome.css`
- Modify: `darwin/home-manager/xdg.nix`
- Modify: `darwin/home-manager/programs/firefox.nix`

**Step 1: Move files**

Relocate the listed files into `darwin/home-manager/files/**` keeping names unchanged.

**Step 2: Update references**

- In `darwin/home-manager/xdg.nix`, update `karabiner.json` and `zed/*` sources to the new `./files/xdg/...` paths.
- In `darwin/home-manager/programs/firefox.nix`, update `userChrome` to read from `../files/firefox/userChrome.css`.

**Step 3: Verify**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

**Step 4: Secret scan**

Run:
```bash
rg -i "password|secret|key|token|api" --type nix
rg "@.*\.(com|org|net)" --type nix
```

**Step 5: Commit**

```bash
git add darwin/home-manager/xdg.nix darwin/home-manager/programs/firefox.nix darwin/home-manager/files/xdg/karabiner/karabiner.json darwin/home-manager/files/xdg/zed/Nano.json darwin/home-manager/files/xdg/zed/keymap.json darwin/home-manager/files/xdg/zed/settings.json darwin/home-manager/files/firefox/userChrome.css
git commit -m "refactor(home-manager): align file layout"
```
