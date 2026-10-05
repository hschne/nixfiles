{
  description = "Hans's NixOS hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      packages.${system} = {
        # Bootable installer ISO: nix build .#installer-iso
        installer-iso = self.nixosConfigurations.installer.config.system.build.isoImage;
      };

      nixosConfigurations = {
        anubis = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            disko.nixosModules.disko
            ./hosts/anubis
          ];
        };

        rocinante = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/rocinante ];
        };

        installer = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self; };
          modules = [ ./hosts/installer ];
        };
      };
    };
}
