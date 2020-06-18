#!/bin/sh

## Add user
adduser runner --disabled-password  --gecos ""
echo "runner ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers &&\
usermod -aG sudo runner

## Pre-installed softwares
curl -sL https://deb.nodesource.com/setup_12.x | bash - &&\
    apt-get install -y nodejs

curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
    apt-get update && apt-get install -y yarn

apt-get install -y --no-install-recommends iputils-ping git

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker runner

## Install action-runner
su - runner
curl -O -L https://github.com/actions/runner/releases/download/v2.263.0/actions-runner-linux-x64-2.263.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.263.0.tar.gz
sudo ./bin/installdependencies.sh
