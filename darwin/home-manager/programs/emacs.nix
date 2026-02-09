{ config, lib, pkgs, inputs, ... }:
let
  git = "${pkgs.git}/bin/git";
  emacsRepoDir = "${config.home.homeDirectory}/.emacs.d";
  originUrl = "git@github.com:HyunggyuJang/doom-emacs.git";
  upstreamUrl = "git@github.com:doomemacs/doomemacs.git";
  branchName = "nano-doom";
in
{
  programs.doom-emacs = {
    enable = true;
    provideEmacs = true;
    emacs = pkgs.emacs;
    doomDir = inputs.doom-config.outPath;
    doomLocalDir = "${config.home.homeDirectory}/.doom";
    profileName = "";
    experimentalFetchTree = true;
    extraPackages = epkgs: [ epkgs.vterm ];
    emacsPackageOverrides = eself: esuper: {
      nov = esuper.nov.overrideAttrs (old: {
        packageRequires = (old.packageRequires or [ ]) ++ [ eself.dash ];
      });
      anki-editor = esuper.anki-editor.overrideAttrs (old: {
        packageRequires = (old.packageRequires or [ ]) ++ [
          eself.dash
          eself.request
        ];
      });
      laas = esuper.laas.overrideAttrs (old: {
        packageRequires = (old.packageRequires or [ ]) ++ [ eself.yasnippet ];
      });
    };
  };

  home.activation.ensureDoomEmacsGitRemotes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    repo=${lib.escapeShellArg emacsRepoDir}
    origin=${lib.escapeShellArg originUrl}
    upstream=${lib.escapeShellArg upstreamUrl}
    branch=${lib.escapeShellArg branchName}

    if [[ ! -d "$repo" ]]; then
      verboseEcho "Bootstrapping $repo from $origin ($branch)"
      run ${git} clone --origin origin --branch "$branch" "$origin" "$repo"
    fi

    if ! ${git} -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      echo "error: $repo exists but is not a git repository" >&2
      exit 1
    fi

    current_origin="$(${git} -C "$repo" remote get-url origin 2>/dev/null || true)"
    if [[ "$current_origin" != "$origin" ]]; then
      if [[ -n "$current_origin" ]]; then
        verboseEcho "Updating $repo origin remote"
        run ${git} -C "$repo" remote set-url origin "$origin"
      else
        verboseEcho "Adding origin remote to $repo"
        run ${git} -C "$repo" remote add origin "$origin"
      fi
    fi

    current_upstream="$(${git} -C "$repo" remote get-url upstream 2>/dev/null || true)"
    if [[ "$current_upstream" != "$upstream" ]]; then
      if [[ -n "$current_upstream" ]]; then
        verboseEcho "Updating $repo upstream remote"
        run ${git} -C "$repo" remote set-url upstream "$upstream"
      else
        verboseEcho "Adding upstream remote to $repo"
        run ${git} -C "$repo" remote add upstream "$upstream"
      fi
    fi

    run ${git} -C "$repo" config rerere.enabled true
    run ${git} -C "$repo" config rerere.autoupdate true
    run ${git} -C "$repo" config branch."$branch".remote origin
    run ${git} -C "$repo" config branch."$branch".merge refs/heads/"$branch"
    run ${git} -C "$repo" config branch."$branch".rebase false
  '';
}
