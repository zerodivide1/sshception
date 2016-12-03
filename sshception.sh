#!/bin/bash
# Name: sshception
# Version: 0.1.0
# Date: 2016-05-21
# Author: Sean Payne
# Website: https://github.com/zerodivide1/sshception
# Inspired by this StackOverflow post: http://stackoverflow.com/a/15198031
# Usage:
# sshception <tunnel_username>@<tunnel_host>:<tunnel_port> <target_username>@<target_host>:<target_port>

failOut() {
  echo $@ >&2
  exit -1
}

SHUFCMD=$(which shuf)
if [ -z "$SHUFCMD" ] ; then
  # Maybe we're running on OSX with the Homebrew-installed 'coreutils'?
  SHUFCMD=$(which gshuf)
  [ ! -z "$SHUFCMD" ] || failOut "No 'shuf' command found"
fi

PORTLO=1024
PORTHI=65535

generateRandomPort() {
  POTENTIAL_PORT=$($SHUFCMD -i $PORTLO-$PORTHI -n1)
  for i in $(seq 1 100) ; do
    if [ -z "$(lsof -i :$POTENTIAL_PORT)" ] ; then
      echo $POTENTIAL_PORT
      break
    fi
  done
}

DEFAULT_SSH_PORT=22

[ ! -z "$1" ] || failOut "You must specify the SSH tunnel host"
[ ! -z "$2" ] || failOut "You must specify the target host"

TUNNEL_HOST=$1
TUNNEL_USERNAME=
TUNNEL_PORT=$DEFAULT_SSH_PORT

if [[ $TUNNEL_HOST == *"@"* ]] ; then
  TUNNEL_USERNAME=$(echo $TUNNEL_HOST | cut -d'@' -f1)
  TUNNEL_HOST=$(echo $TUNNEL_HOST | cut -d'@' -f2)
fi

if [[ $TUNNEL_HOST == *":"* ]] ; then
  TUNNEL_PORT=$(echo $TUNNEL_HOST | cut -d':' -f2)
  TUNNEL_HOST=$(echo $TUNNEL_HOST | cut -d':' -f1)
fi

TARGET_HOST=$2
TARGET_USERNAME=
TARGET_PORT=$DEFAULT_SSH_PORT

if [[ $TARGET_HOST == *"@"* ]] ; then
  TARGET_USERNAME=$(echo $TARGET_HOST | cut -d'@' -f1)
  TARGET_HOST=$(echo $TARGET_HOST | cut -d'@' -f2)
fi

if [[ $TARGET_HOST == *":"* ]] ; then
  TARGET_PORT=$(echo $TARGET_HOST | cut -d':' -f2)
  TARGET_HOST=$(echo $TARGET_HOST | cut -d':' -f1)
fi

TUNNELING_PORT=$(generateRandomPort)
[ ! -z "$TUNNELING_PORT" ] || failOut "Unable to find a random tunneling port"

CTL_SOCKET_UUID=$(uuidgen)
[ ! -z "$CTL_SOCKET_UUID" ] || failOut "Unable to generate a UUID for the tunnel connection"

TUNNEL_CONNECTION_STRING=
if [ -z "$TUNNEL_USERNAME" ] ; then
  TUNNEL_CONNECTION_STRING="$TUNNEL_HOST"
else
  TUNNEL_CONNECTION_STRING="$TUNNEL_USERNAME@$TUNNEL_HOST"
fi

ssh -M -S $CTL_SOCKET_UUID -fnNT -L $TUNNELING_PORT:$TARGET_HOST:$TARGET_PORT $TUNNEL_CONNECTION_STRING -p $TUNNEL_PORT || failOut "Unable to establish tunnel."

echo "$CTL_SOCKET_UUID=$TUNNEL_CONNECTION_STRING" >> ~/.ssh/open_connections


disconnect() {
  ssh -S $CTL_SOCKET_UUID -O exit $TUNNEL_CONNECTION_STRING || failOut "Unable to clean up tunnel. Verify the tunnel isn't still open."
  sed -i.bak "/$CTL_SOCKET_UUID/d" ~/.ssh/open_connections
}

failOutAndDisconnect() {
  disconnect
  failOut "$1"
}

(ssh -S $CTL_SOCKET_UUID -O check $TUNNEL_CONNECTION_STRING && \
  ssh -o 'UserKnownHostsFile /dev/null' -o 'StrictHostKeyChecking=no' $TARGET_USERNAME@localhost -p $TUNNELING_PORT) || failOutAndDisconnect "Unable to establish tunnel."

disconnect
