{ poetry2nix, python3, gitignoreSource }:
poetry2nix.mkPoetryApplication rec {
  python = python3;
  groups = [ ];
  checkGroups = [ "test" ];
  projectDir = gitignoreSource ../.;
  src = gitignoreSource ../.;
  overrides = [
    (import ../poetry-overrides.nix)
    poetry2nix.defaultPoetryOverrides
  ];
  preferWheels = true;

  POETRY_DYNAMIC_VERSIONING_BYPASS = "1";

  preCheck = ''
    set -euo pipefail

    HOME="$(mktemp -d)"
    export HOME
  '';

  checkPhase = ''
    set -euo pipefail

    runHook preCheck

    pytest --numprocesses "$NIX_BUILD_CORES" --dist loadgroup

    runHook postCheck
  '';

  doCheck = true;

  pythonImportsCheck = [ "ibish" ];
}
