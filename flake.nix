{
  description = "Hans's NixOS hosts";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      packages.${system} = {
        picoclaw = pkgs.callPackage ./packages/picoclaw.nix { };

        # Bootable installer ISO: nix build .#installer-iso
        installer-iso = self.nixosConfigurations.installer.config.system.build.isoImage;
      };

      nixosConfigurations = {
        anubis = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/anubis ];
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
