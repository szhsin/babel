#!/bin/bash

#==============================================================================#
#                                  SETUP                                       #
#==============================================================================#

# Start in scripts/integration-tests/ even if run from root directory
cd "$(dirname "$0")" || exit
root="$PWD"

source utils/local-registry.sh
source utils/cleanup.sh

# Echo every command being executed
set -x

# Clone prettier
git clone --depth=1 --single-branch --branch next https://github.com/prettier/prettier tmp/prettier
cd tmp/prettier || exit

# Update @babel/* dependencies
bump_deps="$root/utils/bump-babel-dependencies.js"
node "$bump_deps"

#==============================================================================#
#                                 ENVIRONMENT                                  #
#==============================================================================#
node -v
yarn --version

#==============================================================================#
#                                   TEST                                       #
#==============================================================================#

startLocalRegistry "$root"/verdaccio-config.yml
yarn install --no-immutable
yarn info

# https://github.com/babel/babel/pull/14892#issuecomment-1233180626
echo "export default () => () => {}" > src/main/create-print-pre-check-function.js

yarn test "tests/format/(jsx?|misc|typescript|flow|flow-repo)/" --update-snapshot --runInBand

cleanup
