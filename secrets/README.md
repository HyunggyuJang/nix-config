# Secrets

This directory holds encrypted `.age` files tracked in the repo for reproducible setup.

Structure example:

```
secrets/
  secrets.nix
  ssh/
    <host>/
      id_ed25519.age
      id_ed25519.pub.age
```

Nothing in this directory should contain plaintext secrets.
