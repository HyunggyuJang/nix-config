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

---

## Follow-up finding (2026-02-22, evening)

A direct metadata check shows an important difference:

- `github:nix-community/home-manager/master` resolves to current HEAD (`603626a8`, 2026-02-22)
- `github:nix-community/home-manager` can resolve to `abfad3d2` (2025-04-24) in the failing flow

So the extension should use an explicit branch ref in override input:

```diff
- "--override-input", "home-manager", "github:nix-community/home-manager",
+ "--override-input", "home-manager", "github:nix-community/home-manager/master",
```

This avoids ambiguous/default ref behavior and prevents accidental downgrade to
an old commit during update.

### Suggested research handoff questions

1. Why does unqualified `github:nix-community/home-manager` resolve differently in
   some flows even with `--refresh`?
2. Is there daemon-level or fetcher-level caching that `--refresh` on `flake update`
   does not fully invalidate for subsequent commands?
3. Should all extension override-input URLs use explicit refs (`/master` or release
   branch) for determinism?

---

## Research answers (2026-02-22)

### Q1: Why does unqualified URL resolve differently?

Per the [flake reference docs](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake#types):
> `github:NixOS/nixpkgs`: **The master branch** of the NixOS/nixpkgs repository.

Both `github:owner/repo` and `github:owner/repo/master` resolve to master. The
difference is in **what gets stored in the lock file's `original` field**:

| URL form | Lock `original` |
|----------|-----------------|
| `github:nix-community/home-manager` | `{owner, repo, type}` — **no ref** |
| `github:nix-community/home-manager/master` | `{owner, repo, type, ref: "master"}` |

When SYNC_SCRIPT writes a commit hash into flake.nix, Nix compares:
- flake.nix: `{..., rev: "603626a8"}` (has rev)
- lock original: `{owner, repo, type}` (no rev, no ref)

**Mismatch → re-resolution triggered.**

With explicit `/master`:
- flake.nix: `{..., rev: "603626a8"}`
- lock original: `{..., ref: "master"}`

Still a mismatch (rev vs ref), but Nix may handle this differently since the
original explicitly specifies a branch.

### Q2: Is there caching that `--refresh` doesn't invalidate?

Yes. From [nix.conf docs](https://nix.dev/manual/nix/latest/command-ref/conf-file#conf-tarball-ttl):

> `tarball-ttl`: The number of seconds a downloaded tarball is considered fresh.
> **Default: 3600** (1 hour)

GitHub flakes are fetched as tarballs. The cache works like this:

1. `nix flake update --refresh` forces fresh fetch → gets commit `603626a8`
2. Tarball for `github:nix-community/home-manager` cached at `$XDG_CACHE_HOME/nix/tarballs`
3. `darwin-rebuild build` (no `--refresh`) checks cache → tarball still "fresh" per TTL
4. **BUT** the cached tarball may serve a **different commit** than what was just fetched
   if the tarball URL is for the branch (not a specific commit)

The key insight: tarball URL for `github:owner/repo` points to **branch HEAD**, which
GitHub may serve from CDN cache. The CDN cache is separate from Nix's tarball cache.

### Q3: Should override-input URLs use explicit refs?

**Yes, for two reasons:**

1. **Lock file consistency**: `github:owner/repo/master` stores `ref: "master"` in
   the lock's `original`, making the lock more self-documenting.

2. **Determinism**: An explicit ref reduces ambiguity. While Nix docs say
   `github:owner/repo` defaults to master, having the ref explicit prevents any
   edge cases with default branch resolution.

**Recommended change:**

```diff
- "--override-input", "home-manager", "github:nix-community/home-manager",
+ "--override-input", "home-manager", "github:nix-community/home-manager/master",
```

However, this alone doesn't fix the mismatch problem (SYNC_SCRIPT still writes a
commit hash into flake.nix, creating `rev` vs `ref` mismatch). The primary fix
remains **Solution A** (`--no-update-lock-file` on validation).

---

## Final recommendation

Apply both fixes:

1. **Primary**: Add `--no-update-lock-file` to `validateFlake()` to prevent lock
   modifications during validation.

2. **Secondary**: Use explicit `/master` refs in override-input URLs for better
   determinism and lock file clarity.
