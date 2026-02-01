# Darwin new-machine setup

## Prereqs

- Nix
- nix-darwin
- Homebrew

## Setup

1. Set the machine host name:

   ```sh
   sudo scutil --set LocalHostName <host>
   ```

2. Create a host module at `darwin/hosts/<host>.nix`.

   ```nix
   { ... }: {
     host = {
       name = "<host>";
       owner = "<user>";
       machineType = "<type>";
     };
   }
   ```

   Note: flake-only setup expects these host fields to be set.

3. If you need secrets, prefer a dedicated secret manager (e.g., agenix/sops-nix) or load values at runtime from `pass`/Keychain. Avoid storing plaintext secrets in Nix files.

4. Apply the configuration and verify the build:

   ```sh
   cd darwin
   make switch
   ```
