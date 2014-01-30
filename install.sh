#!/usr/bin/env bash

DIR="$(cd -P "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd)"

ln -s -f -n "${DIR}/newkey.sh" "${HOME}/bin/newkey-shared-screen"

