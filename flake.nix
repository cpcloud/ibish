{
  description = "Expressive Python analytics at any scale.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, flake-utils, gitignore, nixpkgs, poetry2nix, ... }: {
    overlays.default = nixpkgs.lib.composeManyExtensions [
      gitignore.overlay
      poetry2nix.overlays.default
      (import ./nix/overlay.nix)
    ];
  } // flake-utils.lib.eachDefaultSystem (
    localSystem:
    let
      pkgs = import nixpkgs {
        inherit localSystem;
        overlays = [ self.overlays.default ];
      };

      preCommitDeps = with pkgs; [
        actionlint
        deadnix
        git
        just
        nixpkgs-fmt
        nodePackages.prettier
        shellcheck
        shfmt
        statix
        taplo-cli
      ];

      mkDevShell = env: pkgs.mkShell {
        name = "ibish-${env.python.version}";
        nativeBuildInputs = (with pkgs; [
          # python dev environment
          env
          # poetry executable
          poetry
          # rendering release notes
          changelog
          glow
          # commit linting
          commitlint
          # release automation
          nodejs
        ])
        ++ preCommitDeps;
      };
    in
    rec {
      packages = {
        inherit (pkgs) ibish312;

        default = pkgs.ibish312;

        inherit (pkgs) update-lock-files check-release-notes-spelling;
      };

      devShells = rec {
        ibish312 = mkDevShell pkgs.ibishDevEnv312;

        default = ibish312;

        preCommit = pkgs.mkShell {
          name = "preCommit";
          nativeBuildInputs = [ pkgs.ibisSmallDevEnv ] ++ preCommitDeps;
        };

        release = pkgs.mkShell {
          name = "release";
          nativeBuildInputs = with pkgs; [ git poetry nodejs unzip gnugrep ];
        };
      };
    }
  );
}
