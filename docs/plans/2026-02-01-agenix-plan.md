# Agenix Integration Plan

> **Execution choice (set during handoff by the human partner):** `superpowers:executing-plans` (sequential)

**Goal:** Introduce agenix as the canonical secrets mechanism for this flake (nix-darwin), without adding any secrets yet.

**Architecture:** Add agenix as a flake input, import its darwin module, and include the CLI in system packages. Provide minimal docs/scaffolding that explain how to add encrypted secrets in the future.

**Tech Stack:** Nix flakes, nix-darwin, agenix.

**Commit Intent:** single commit for initial integration.

---

### Task 1: Wire agenix into the flake

**Depends on:** None
**Parallelizable:** no
**Shared State:** `darwin/flake.nix`, `darwin/configuration.nix`, `darwin/modules/system-packages.nix`

**Files:**
- Modify: `darwin/flake.nix`
- Modify: `darwin/configuration.nix`
- Modify: `darwin/modules/system-packages.nix`

**Step 1: Add agenix input**

Add `agenix` to flake inputs and follow nixpkgs if needed.

**Step 2: Import agenix darwin module**

Add `inputs.agenix.darwinModules.default` to `imports` in `darwin/configuration.nix`.

**Step 3: Add agenix CLI to system packages**

Include `inputs.agenix.packages.${pkgs.system}.default` in `environment.systemPackages` and pass `inputs` into `system-packages.nix`.

---

### Task 2: Add minimal docs + scaffolding

**Depends on:** Task 1
**Parallelizable:** no
**Shared State:** docs

**Files:**
- Create: `docs/guides/agenix.md`
- Create: `secrets/README.md`
- Modify: `docs/guides/darwin-setup.md`

**Step 1: Document agenix usage**

Add a short guide describing how to create `secrets/secrets.nix`, generate `.age` files, and wire `age.secrets` when needed.

**Step 2: Add a secrets directory placeholder**

Create `secrets/README.md` explaining that encrypted files live here, but no secrets are stored by default.

**Step 3: Link from darwin setup guide**

Update the setup guide to reference the new agenix guide.

---

### Task 3: Verify

**Depends on:** Task 2
**Parallelizable:** no

**Step 1: Build**

Run:
```bash
cd darwin
nix build .#darwinConfigurations.$(scutil --get LocalHostName).system --dry-run
```

---

### Task 4: Commit

```bash
git add darwin/flake.nix darwin/configuration.nix darwin/modules/system-packages.nix docs/guides/agenix.md docs/guides/darwin-setup.md secrets/README.md
git commit -m "Add agenix integration"
```
