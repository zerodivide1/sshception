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
