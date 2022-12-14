#!/usr/bin/env bash

set -ex

# Turn on export DEBIAN_FRONTEND=noninteractive if docker run mysql
#export DEBIAN_FRONTEND=noninteractive

sudo apt update

sudo apt install -y systemd systemd-sysv kmod coreutils lsb-release wget curl zip unzip tar busybox iputils-ping iproute2 net-tools jq gnupg2 netcat bind9-dnsutils openssh-client git binutils ripgrep bash-completion

sudo apt install -y redis-server redis-sentinel

#curl https://getmic.ro | bash && mv micro /usr/local/bin

sudo sed -i -E 's/^bind [0-9.]+ :+[0-9]$/bind 0.0.0.0/g' /etc/redis/redis.conf

sudo sed -i -E 's/^bind [0-9.]+ :+[0-9]$/bind 0.0.0.0/g' /etc/redis/sentinel.conf
