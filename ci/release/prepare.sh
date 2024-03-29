#!/usr/bin/env bash

set -euo pipefail

version="${1}"

# set version
nix develop '.#release' -c poetry version "$version"

# ensure that the built wheel has the correct version number
nix develop '.#release' -c unzip -p "dist/ibish-${version}-py3-none-any.whl" ibish/__init__.py | \
  nix develop '.#release' -c grep -q "__version__ = \"$version\""
