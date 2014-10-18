#!/bin/bash

DIR="$(cd -P "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

GC_RUNNER="$(whoami)"
GC_USER="${1:-$GC_RUNNER}"
GC_HOME="~${GC_USER}"
GC_SUFFIX="shared"
GC_TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"

GC_KEYNAME="${GC_USER}_${GC_SUFFIX}_${GC_TIMESTAMP}"
GC_KEYSDIR="${DIR}/keys"
GC_KEYPATH="${GC_KEYSDIR}/${GC_KEYNAME}"

echo "Creating new key pair for secure shared screen access"
mkdir -p "${GC_KEYSDIR}"
ssh-keygen -C "${GC_KEYNAME}" -f "${GC_KEYPATH}"
SSH_PUBKEY="$(cat "${GC_KEYPATH}.pub")"
cp "${GC_KEYPATH}" "${DIR}/${GC_SUFFIX}-current-key"

SCREEN_ATTACH_COMMAND="screen -r ${GC_RUNNER}/${GC_SUFFIX}"
SSH_AUTHOPTS="no-port-forwarding,no-X11-forwarding,no-agent-forwarding"
SSH_AUTHPREFIX="command=\"${SCREEN_ATTACH_COMMAND}\",${SSH_AUTHOPTS}"
SSH_AUTHLINE="${SSH_AUTHPREFIX} ${SSH_PUBKEY}"
SSH_DIR="${GC_HOME}/.ssh"
SSH_AUTHKEYSFILE="${SSH_DIR}/authorized_keys"

echo "Writing new sharedscreen key to authorized_keys file of user ${GC_USER}"
echo "The commands need to be run with the privileges of user ${GC_USER}"
sudo -u "${GC_USER}" mkdir -p "${SSH_DIR}"
echo -e "\nkey:"
echo -n "${SSH_AUTHLINE}" | sudo -u "${GC_USER}" tee "${SSH_AUTHKEYSFILE}"
echo -e "\n\nKey ${GC_KEYNAME} wrote to: ${SSH_AUTHKEYSFILE}.  Previous key(s) revoked/removed."


PUBIP="$(wget 'http://ipecho.net/plain' -O - -q)"
echo "This is your public IP address:  ${PUBIP}"
echo "Tell your Linux/Mac clients to connect using the following command:"
echo "ssh -t -i <PATH_TO_KEYFILE> <EXTRA_OPTIONS> ${GC_USER}@${PUBIP}  \"${SCREEN_ATTACH_COMMAND}\""
echo ""
echo "Don't forget to give the user \"${GC_USER}\" the permission access in your screen session"
echo "by using the screen command \":acladd ${GC_USER}\" or something along these lines."
echo "To kick \"${GC_USER}\" out of the session, use \":acldel ${GC_USER}\"."

