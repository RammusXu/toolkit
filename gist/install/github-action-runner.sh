#!/bin/sh

## Add user
adduser runner --disabled-password  --gecos ""
echo "runner ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers &&\
usermod -aG sudo runner