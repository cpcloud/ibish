#!/usr/bin/env bash

set -euo pipefail

version="${1}"

# set version
nix develop '.#release' -c poetry version "$version"

# build artifacts
nix develop '.#release' -c poetry build --format=sdist
