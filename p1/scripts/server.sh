#!/bin/bash

# export k3s environment variables
export INSTALL_K3S_EXEC="--bind-address=$1 --node-external-ip=$1 --advertise-address=$1 --flannel-iface=eth1"

echo "installing curl"
sudo apk add curl

# install k3s
# curl -sfL https://get.k3s.io | sh -

if curl -sfL https://get.k3s.io | sh -; then
	echo -e "k3s server installation SUCCEEDED"
else
	echo -e "k3s server installation FAILED"
fi

echo "sleeping for 5 seconds to wait for k3s to start"
sleep 5

# copy k3s token to synced folder
cp /var/lib/rancher/k3s/server/token /vagrant
# copy kubernetes config to synced folder to access cluster from host
cp /etc/rancher/k3s/k3s.yaml /vagrant

echo "finished server setup"