# Agenix guide

This repo uses [agenix](https://github.com/ryantm/agenix) for encrypted, file-based secrets. Secrets are committed as `.age` files and decrypted at activation time on the target machine.

## Quick start

1. Create a recipients file (public keys only):

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
     "brave-api.age".publicKeys = users ++ systems;
   }
   ```

2. Create or edit a secret:

   ```sh
   agenix -e secrets/brave-api.age
   ```

3. Reference the secret in Nix when needed:

   ```nix
   age.secrets.brave-api.file = ./secrets/brave-api.age;
   ```

## Notes

- Keep only **encrypted** files (`.age`) in the repo.
- You still need the private key on the target machine to decrypt.
- For macOS, decrypted secrets land under `$TMPDIR/agenix/` by default unless you override `age.secrets.<name>.path`.
