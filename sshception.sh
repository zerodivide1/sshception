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

[ ! -z "$1" ] || failOut "You must specify the SSH tunnel host"
[ ! -z "$2" ] || failOut "You must specify the target host"

TUNNEL_USERNAME=$(echo $1 | cut -d'@' -f1)
TUNNEL_HOST=$(echo $1 | cut -d'@' -f2 | cut -d':' -f1)
TUNNEL_PORT=$(echo $1 | cut -d'@' -f2 | cut -d':' -f2)

TARGET_USERNAME=$(echo $2 | cut -d'@' -f1)
TARGET_HOST=$(echo $2 | cut -d'@' -f2 | cut -d':' -f1)
TARGET_PORT=$(echo $2 | cut -d'@' -f2 | cut -d':' -f2)
