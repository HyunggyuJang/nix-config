final: prev:
with prev;
{
  lean = prev.lean.overrideAttrs (oldAttrs: rec {
    version = "3.28.0";
    src = fetchFromGitHub {
      owner  = "leanprover-community";
      repo   = "lean";
      rev    = "v${version}";
      sha256 = "sha256-IzoFE92F559WeSUCiYZ/fx2hrsyRzgOACr3/pzJ4OOY=";
    };
  });
}
