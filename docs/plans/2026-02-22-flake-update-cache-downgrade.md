# Problem: nix flake update downgrade via stale cache

## Summary

The `update-darwin-flake-inputs` extension reliably downgrades `home-manager`
from today's master HEAD to a 10-month-old commit, even with `--refresh`.

---

## Observed sequence

1. `flake.nix` pins home-manager to a specific commit:
   ```
   home-manager.url = "github:nix-community/home-manager/603626a8...";
   ```

2. The extension runs `nix flake update --refresh --override-input home-manager github:nix-community/home-manager`.
   - `--refresh` works: nix fetches the latest master HEAD (`603626a8`, 2026-02-22).
   - The lock is updated:
     - `original`: `{type: github, owner: nix-community, repo: home-manager}` ← **no rev**
     - `locked.rev`: `603626a8`

3. `SYNC_SCRIPT` patches `flake.nix` with the new rev from the lock:
   ```
   home-manager.url = "github:nix-community/home-manager/603626a8...";
   ```
   (effectively unchanged in this case, but the pattern always writes the rev
   from the lock back into the URL)

4. The validation step runs `darwin-rebuild build --flake .`.
   Nix reads `flake.nix` and compares it to the lock:
   - `flake.nix` says: `{type: github, owner: nix-community, repo: home-manager, ref: "603626a8..."}`
   - lock `original` says: `{type: github, owner: nix-community, repo: home-manager}` ← **no ref**
   - **Mismatch.** Nix "corrects" the lock by re-resolving the input.

5. During re-resolution, nix does **not** use `--refresh` (that was only for step 2).
   It hits the stale tarball cache and resolves `github:nix-community/home-manager`
   to `abfad3d2` (2025-04-24) — a 10-month-old commit.

6. The lock is silently overwritten with the downgraded rev, and the build fails
   because the older home-manager is missing options present in the current config.

---

## Root cause

The mismatch is structural:

- `--override-input home-manager github:nix-community/home-manager` stores an
  **unversioned** original in the lock (`no ref`).
- `SYNC_SCRIPT` then writes the resolved rev **into the flake.nix URL** (e.g.
  `github:nix-community/home-manager/603626a8...`), which has an **implicit ref**
  (the commit hash).
- Every subsequent nix invocation sees these as different inputs and re-resolves,
  bypassing the explicit pin — and without `--refresh`, it hits stale cache.

---

## What has been tried

| Attempt | Result |
|---------|--------|
| `--refresh` on `nix flake update` | Step 2 fetches the correct HEAD, but step 4 still re-resolves without refresh |
| Excluding home-manager from INPUTS | Prevents the update entirely; not the desired behaviour |

---

## Hypothesis for the fix

After SYNC_SCRIPT runs, call `nix flake lock` (no extra flags) to reconcile the
lock's `original` fields with the updated `flake.nix` URLs. Because flake.nix now
has explicit commit hashes in the URLs, `nix flake lock` would:
- Parse `github:nix-community/home-manager/603626a8...` as `ref = "603626a8..."`
- Fetch that specific commit (unique tarball URL — no stale cache collision)
- Write `original: {ref: "603626a8..."}` into the lock

After that, `darwin-rebuild build` would see no mismatch and leave the lock alone.

**Needs verification:**
- Does `nix flake lock` without flags do exactly this, or does it also try to
  update unpinned inputs?
- Is there a lighter alternative (`nix flake lock --no-update-lock-file` would
  validate only; `nix flake update <inputs>` without override might work too)?
- Can `darwin-rebuild build` be told not to touch the lock at all
  (e.g. via `--no-update-lock-file` passed through)?

---

## Relevant files

- Extension: `.pi/extensions/update-darwin-flake-inputs.ts`
  - `runUpdate()`: runs `nix flake update` + SYNC_SCRIPT
  - `validateFlake()`: runs `darwin-rebuild build --flake .`
- `darwin/flake.nix`: contains the pinned input URLs that SYNC_SCRIPT patches
- `darwin/flake.lock`: the lock file whose `original` fields cause the mismatch
