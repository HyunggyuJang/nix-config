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

3. (Optional) Create a private host-local file at `darwin/hosts/<host>.local.nix` for secrets or personal mail configs. Keep it gitignored.

4. Apply the configuration and verify the build:

   ```sh
   cd darwin
   make switch
   ```
