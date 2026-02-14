# macOS upgrade and Peekaboo validation

This guide is for upgrading this machine from Sonoma to Sequoia and verifying the darwin config end-to-end.

## Recommended target

- Upgrade to **macOS Sequoia 15.7.4** first.
- Reason: it satisfies Peekaboo's `macOS 15+` requirement with lower risk than jumping directly to Tahoe.

## What is declared in Nix

- `darwin/modules/homebrew.nix`
  - Declares `steipete/tap`
  - Declares Homebrew formula `peekaboo`
- `darwin/modules/system-packages.nix`
  - Declares core CLI/runtime packages (including Node and pnpm)

## Upgrade to Sequoia 15.7.4

```sh
softwareupdate --list-full-installers
sudo softwareupdate --fetch-full-installer --full-installer-version 15.7.4
open "/Applications/Install macOS Sequoia.app"
```

## Post-upgrade steps

1. Re-apply nix-darwin configuration:

   ```sh
   cd darwin
   make switch
   ```

2. Validate core tooling:

   ```sh
   sw_vers
   nix --version
   brew --version
   node -v
   pnpm -v
   ```

3. Validate Peekaboo installation:

   ```sh
   brew info steipete/tap/peekaboo
   command -v peekaboo
   peekaboo --version
   ```

4. Validate permissions (manual, required by macOS TCC):

   ```sh
   peekaboo permissions status
   ```

   Then ensure your terminal (or bridge host app) has:
   - Privacy & Security → **Screen & System Audio Recording**
   - Privacy & Security → **Accessibility**

## Important limitation (by design)

macOS TCC permissions are not reliably managed declaratively via nix-darwin.
They must be granted manually once per app/binary identity.

If you move to Tahoe later and CLI permissions are flaky, use Peekaboo Bridge (`peekaboo bridge status`) with a permissioned GUI host app.
