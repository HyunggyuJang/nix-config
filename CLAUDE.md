# CLAUDE.md

This file provides security and development guidance for the nixpkgs-config project.

## ⚠️ CRITICAL SECURITY NOTICE

**THIS IS A PUBLIC REPOSITORY** - All content is visible to the world on GitHub.

### NEVER COMMIT:
- API keys, tokens, or secrets of any kind
- Passwords or private keys
- Personal email addresses or sensitive personal information
- Private file paths that reveal system structure
- SSH keys or certificates
- Company-specific configuration that shouldn't be public

### ALLOWED PUBLIC CONTENT:
- General nix configuration patterns
- Application preferences and keybindings
- Development environment setups
- Public package configurations
- Non-sensitive system preferences

## Security Guidelines

### Password Management
- ✅ **GOOD**: `passwordeval "pass Migrate/math.nagoya-u.ac.jp"` (references password manager)
- ❌ **BAD**: `password = "actual-password-here"`
- ✅ **GOOD**: `passwordCommand = "security find-generic-password -s myservice"`
- ❌ **BAD**: Any hardcoded credentials

### File Paths
- ✅ **GOOD**: `~/Documents/notes` or `${config.home.homeDirectory}/notes`
- ⚠️ **NEUTRAL**: `/Users/username/specific-path` (acceptable but not ideal)
- ❌ **BAD**: Paths that reveal sensitive company or personal information

### Configuration References
- ✅ **GOOD**: Reference external secret management tools
- ✅ **GOOD**: Use environment variables for sensitive data
- ✅ **GOOD**: Use nix's `lib.mkIf` for conditional inclusion
- ❌ **BAD**: Inline secrets or credentials

## Pre-commit Checklist

Before committing ANY changes:

1. **Secret Scan**: Search for common secret patterns
   ```bash
   rg -i "password|secret|key|token|api" --type nix
   ```

2. **Personal Info Check**: Look for personal email addresses, private paths
   ```bash
   rg "@.*\.(com|org|net)" --type nix
   ```

3. **Review Diff**: Always review `git diff` before committing

4. **Test Configuration**: Ensure nix configurations build without secrets
   ```bash
   nix build --dry-run
   ```

## Development Workflow

### Safe Secret Handling
- Store secrets in macOS Keychain, pass, or similar tools
- Reference secrets via command execution (`passwordeval`, `passwordCommand`)
- Use environment variables for CI/CD systems
- Document secret requirements in README without exposing values

### Configuration Organization
- Keep public configurations in this repo
- Store sensitive overrides in local files (gitignored)
- Use nix's import system for optional local configurations

## Emergency Procedures

### If Secrets Are Accidentally Committed:

1. **DO NOT** just delete the file and commit - secrets remain in git history
2. **IMMEDIATELY** rotate any exposed credentials
3. **CONTACT** repository owner for history rewriting
4. **CONSIDER** using tools like `git-filter-repo` to remove from history
5. **AUDIT** all related systems for potential compromise

## File Types to Review Carefully

- `*.nix` - All nix configuration files
- `*.json` - Application configurations
- `*.conf` - Configuration files
- `*.plist` - macOS preference files
- Any dotfiles or configuration templates

## Resources

- [Git Secrets Prevention](https://github.com/awslabs/git-secrets)
- [Nix Security Best Practices](https://nixos.org/manual/nixos/stable/index.html#sec-security)
- [macOS Keychain Integration](https://developer.apple.com/documentation/security/keychain_services)

---

**Remember: When in doubt, DON'T commit. Ask for review if unsure about content safety.**