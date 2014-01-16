#!/bin/bash

DIR="$(cd -P "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

GC_RUNNER=$(whoami)  # User running this script, and which will create the shared sessions
GC_USER=${1:-$GC_RUNNER}  # "guest" user of the sessions. Can be the creator or another one
GC_HOME=$(eval "echo ~${GC_USER}")
GC_SUFFIX="shared"
GC_TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

GC_KEYNAME="${GC_USER}_${GC_SUFFIX}_${GC_TIMESTAMP}"
GC_KEYSDIR="${DIR}/keys"
GC_KEYPATH="${GC_KEYSDIR}/${GC_KEYNAME}"

# Create a SSH keypair for one-time-like access to the shared session
echo "Creating new key pair for secure shared screen access"
mkdir -p "${GC_KEYSDIR}"
ssh-keygen -C "${GC_KEYNAME}" -f "${GC_KEYPATH}"
SSH_PUBKEY=$(cat "${GC_KEYPATH}.pub")
cp "${GC_KEYPATH}" "${GC_SUFFIX}-current-key"  # makes a copy in the repo root for easy access

# The access directive that will be added to the guest authorized_keys. JUST ENOUGH
# for accessing the shared session, no more permissions
SCREEN_ATTACH_COMMAND="screen -r ${GC_RUNNER}/${GC_SUFFIX}"
SSH_AUTHOPTS="no-port-forwarding,no-X11-forwarding,no-agent-forwarding"
SSH_AUTHPREFIX="command=\"${SCREEN_ATTACH_COMMAND}\",${SSH_AUTHOPTS}"
SSH_AUTHLINE="${SSH_AUTHPREFIX} ${SSH_PUBKEY}"

# Writing the access directive to the guest user's authorized_keys file
SSH_DIR="${GC_HOME}/.ssh"
SSH_AUTHKEYSFILE="${SSH_DIR}/authorized_keys"
echo "Writing new sharedscreen key to authorized_keys file of user ${GC_USER}"
echo "The commands need to be run with the privileges of user ${GC_USER}"

sudo -u "${GC_USER}" mkdir -p "${SSH_DIR}"
echo -e "\nkey:"
echo -n "${SSH_AUTHLINE}" | sudo -u "${GC_USER}" tee "${SSH_AUTHKEYSFILE}"
echo -e "\n\nKey ${GC_KEYNAME} wrote to: ${SSH_AUTHKEYSFILE}.  Previous key(s) revoked/removed."


PUBIP=$(wget http://ipecho.net/plain -O - -q ; echo)
CONNECTION_COMMAND="ssh -t -i <PATH_TO_KEYFILE> <EXTRA_OPTIONS> ${GC_USER}@${PUBIP}  \"${SCREEN_ATTACH_COMMAND}\""

echo "This is your public IP address:  ${PUBIP}"
echo "Tell your Linux/Mac clients to connect using the following command:"
echo "${CONNECTION_COMMAND}"
echo ""
echo "Don't forget to give the user \"${GC_USER}\" the permission access in your screen session"
echo "by using the screen command \":acladd ${GC_USER}\" or something along these lines."
echo "To kick \"${GC_USER}\" out of the session, use \":acldel ${GC_USER}\"."

