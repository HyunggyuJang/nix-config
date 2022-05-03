self: pkgs:

{
  fzf = pkgs.fzf.overrideAttrs (oldAttrs: {
    postPatch = oldAttrs.postPatch + ''
    substituteInPlace shell/key-bindings.zsh \
      --replace "bindkey '^R'" "bindkey '\er'"
    '';
  });
}
