{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
    };
    nix-alien.url = "github:thiagokokada/nix-alien";
    obs-localvocal = {
      url = "path:/home/jessea/Documents/projects/obs-localvocal-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # -- added: ragenix (age-encrypted secrets) --
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # -- added: machine-local personal values, gitignored (see local.nix.example).
    # Referenced by absolute path so it works even though it is not tracked by git.
    # After editing /etc/nixos/local.nix, re-lock it:  sudo nix flake update localcfg
    localcfg = {
      url = "path:/etc/nixos/local.nix";
      flake = false;
    };
  };

  outputs =
    {
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      # machine-local personal values (from gitignored /etc/nixos/local.nix)
      local = import inputs.localcfg;
    in
    {
      # Please replace nixos with your hostname
      nixosConfigurations."framework-16" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs pkgs-unstable local;
        };
        modules = [
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./configuration.nix
          # -- added: ragenix NixOS module (provides `age.secrets`) --
          inputs.ragenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "hm-backup";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.jessea = import ./home.nix;
              extraSpecialArgs = {
                inherit inputs pkgs-unstable system;
              };
            };
          }
        ];
      };
    };
}
