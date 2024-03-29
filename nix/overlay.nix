pkgs: _:
let
  mkPoetryEnv = { groups, python, extras ? [ "*" ] }: pkgs.poetry2nix.mkPoetryEnv {
    inherit python groups extras;
    projectDir = pkgs.gitignoreSource ../.;
    editablePackageSources = { ibish = pkgs.gitignoreSource ../ibish; };
    overrides = [
      (import ../poetry-overrides.nix)
      pkgs.poetry2nix.defaultPoetryOverrides
    ];
    preferWheels = true;
  };

  mkPoetryDevEnv = python: mkPoetryEnv {
    inherit python;
    groups = [ "dev" "test" ];
  };
in
{
  ibish312 = pkgs.callPackage ./ibish.nix { python3 = pkgs.python312; };

  ibishDevEnv312 = mkPoetryDevEnv pkgs.python312;

  ibishSmallDevEnv = mkPoetryEnv {
    python = pkgs.python312;
    groups = [ "dev" ];
    extras = [ ];
  };

  changelog = pkgs.writeShellApplication {
    name = "changelog";
    runtimeInputs = [ pkgs.nodePackages.conventional-changelog-cli ];
    text = ''
      conventional-changelog --config ./.conventionalcommits.js "$@"
    '';
  };

  check-release-notes-spelling = pkgs.writeShellApplication {
    name = "check-release-notes-spelling";
    runtimeInputs = [ pkgs.changelog pkgs.coreutils pkgs.ibisSmallDevEnv ];
    text = ''
      tmp="$(mktemp)"
      changelog --release-count 1 --output-unreleased --outfile "$tmp"
      if ! codespell "$tmp"; then
        # cat -n to output line numbers
        cat -n "$tmp"
        exit 1
      fi
    '';
  };

  update-lock-files = pkgs.writeShellApplication {
    name = "update-lock-files";
    runtimeInputs = with pkgs; [ just poetry ];
    text = "just lock";
  };
}
