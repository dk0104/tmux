{
  description = "My tmux configuration";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;

      src = ./.;

      snowfall = {
        namespace = "flocke";
      };

      channels-config.allwoUnfree = true;
      alias.packages.default = "tmux";

      outputs-builder = channels: {
        formatter = channels.nixpkgs.nixfmt-rfc-style;

        checks.pre-commit-check = inputs.pre-commit-hooks.lib.${channels.nixpkgs.system}.run {
          src = ./.;
          hooks = {
            nixfmt = {
              enable = true;
              entry = "${channels.nixpkgs.nixfmt-rfc-style}/bin/nixfmt";
              extraPackages = [ channels.nixpkgs.nixfmt-rfc-style ];
            };
          };
        };
      };
    };
}
