#!/bin/bash

# export k3s environment variables
export INSTALL_K3S_EXEC=""

# isntall curl if not installed

# install k3s
curl -sfL https://get.k3s.io | sh -

echo "Finished server setup"