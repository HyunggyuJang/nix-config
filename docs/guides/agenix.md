# Agenix guide

This repo uses [agenix](https://github.com/ryantm/agenix) for encrypted, file-based secrets. Encrypted `.age` files are committed to the repo so the setup is reproducible.

## Quick start

1. Add a recipients file (public keys only):

   `secrets/secrets.nix`
   ```nix
   let
     users = [
       "ssh-ed25519 AAAA... your-user"
     ];
     systems = [
       "ssh-ed25519 AAAA... your-host"
     ];
   in
   {
     "ssh/<host>/id_ed25519.age".publicKeys = users ++ systems;
     "ssh/<host>/id_ed25519.pub.age".publicKeys = users ++ systems;
   }
   ```

2. Create or edit a secret:

   ```sh
   cd secrets
   agenix -e ssh/<host>/id_ed25519.age
   agenix -e ssh/<host>/id_ed25519.pub.age
   ```

## SSH keys

Place per-host SSH key secrets under:

```
secrets/ssh/<host>/
```

Any `.age` file in that folder will be installed into `~/.ssh/<filename>` on that host. Files ending in `.pub.age` are installed with mode `0644`; everything else uses `0600`.

## Notes

- Keep only **encrypted** files (`.age`) in the private secrets directory.
- You still need a private key on the target machine to decrypt. This repo defaults `age.identityPaths` to `~/.ssh/id_ed25519`, so bootstrap that key on new machines before running `darwin-rebuild`.
- For macOS, decrypted secrets land under `$TMPDIR/agenix/` by default unless you override `age.secrets.<name>.path`.
