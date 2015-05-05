#!/usr/bin/env bash

DIR="$(cd -P "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")" )" && pwd)"

BINDIR="${HOME}/bin"

mkdir -p "${BINDIR}"
ln -s -f -n "${DIR}/newkey.sh" "${BINDIR}/newkey-shared-screen"
hash -r

