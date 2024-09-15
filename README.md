# inception-of-things


`--advertise-address`   
Purpose: This option specifies the IP address that the node should advertise to other nodes in the cluster for inter-node communication.
Usage: It is used to set the address that other nodes in the cluster will use to communicate with this node.
Example: If you have a node with multiple network interfaces, you might want to specify which IP address should be used for cluster communication.


`--node-external-ip`  
Purpose: This option specifies the external IP address of the node.
Usage: It is used to set the external IP address that will be used for external communication, such as accessing services from outside the cluster.
Example: If your node is behind a NAT or has multiple IP addresses, you might want to specify which IP address should be used for external access.


k9s --kubeconfig k3s.yaml


vagrant global-status
vagrant global-status --prune

vagrant plugin install vagrant-vbguest

kubectl config view --raw