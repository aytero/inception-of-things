#!/bin/bash

sudo apk add curl

export K3S_TOKEN_FILE="/vagrant/token"

cat $K3S_TOKEN_FILE

export INSTALL_K3S_EXEC="agent --server https://$1:6443 --token-file $K3S_TOKEN_FILE --flannel-iface=eth1"

# export K3S_TOKEN_FILE=/vagrant/token
# export K3S_URL=https://$1:6443
# export INSTALL_K3S_EXEC="--flannel-iface=eth1"

# curl -sfL https://get.k3s.io | sh -

if curl -sfL https://get.k3s.io | sh -; then
	echo -e "k3s agent installation SUCCEEDED"
else
	echo -e "k3s agent installation FAILED"
fi

echo "finished agent setup"