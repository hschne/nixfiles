{
  description = "Hans's NixOS hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paseo = {
      url = "github:getpaseo/paseo/v0.12.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      neovim-nightly,
      disko,
      agenix,
      paseo,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      packages.${system} = {
        agenix = agenix.packages.${system}.agenix;

        # Bootable installer ISO: nix build .#installer-iso
        installer-iso = self.nixosConfigurations.installer.config.system.build.isoImage;
      };

      nixosConfigurations = {
        anubis = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            paseo.nixosModules.default
            {
              # npm cache hashes depend on the nixpkgs revision followed by Paseo.
              services.paseo.package = paseo.packages.${system}.default.override {
                npmDepsHash = "sha256-ObBdUmNSW+vDjzA7EbCDfZrB0nYDmcWmWe+UCoTMh/M=";
              };
            }
            ./hosts/anubis
          ];
        };

        rocinante = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/rocinante
            {
              # Keep the packaged wrapper while using the multi-client inlay-hint fix.
              nixpkgs.overlays = [
                (final: prev: {
                  neovim-unwrapped = neovim-nightly.packages.${system}.default;
                })
              ];
            }
          ];
        };

        installer = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self; };
          modules = [ ./hosts/installer ];
        };
      };
    };
}
