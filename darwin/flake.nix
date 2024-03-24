{
  description = "Hyunggyu's darwin system";

  inputs = {
    nixpkgs.url = "github:HyunggyuJang/nixpkgs/c95e47775fd13f2ec10014b746a53343c2f0b25f";
    nix-darwin.url = "github:LnL7/nix-darwin/bcc8afd06e237df060c85bad6af7128e05fd61a3";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/1c2c5e4cabba4c43504ef0f8cc3f3dfa284e2dbb";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR/8ef4be789b09122a98de08ef3496c65511b3b35d";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nur }: {
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;
    darwinConfigurations."Hyunggyus-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [ ./configuration.nix nur.nixosModules.nur ];
      specialArgs = { inherit inputs; };
    };
  };
}
