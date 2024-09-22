# inception-of-things

vagrant box choice
https://stackshare.io/stackups/alpine-linux-vs-centos

`--advertise-address`   
Purpose: This option specifies the IP address that the node should advertise to other nodes in the cluster for inter-node communication.
Usage: It is used to set the address that other nodes in the cluster will use to communicate with this node.
Example: If you have a node with multiple network interfaces, you might want to specify which IP address should be used for cluster communication.


k9s --kubeconfig k3s.yaml


vagrant global-status
vagrant global-status --prune

vagrant plugin install vagrant-vbguest

kubectl config view --raw

to access clister via agent node:
kubectl get nodes --kubeconfig /vagrant/k3s.yaml
explanation: 
https://github.com/k3s-io/k3s/issues/3862
https://docs.k3s.io/cluster-access
https://jaehong21.com/posts/k3s/02-access-outside/


ifconfig eth1



In Kubernetes, it is generally recommended to apply the Deployment configuration before the Service configuration. This ensures that the pods are created and running before the Service tries to route traffic to them.


curl -H "Host:app1.com" 192.168.56.110
curl 192.168.56.110 => default app3

sudo vi /etc/hosts
192.168.56.110  app1.com
192.168.56.110  app2.com
192.168.56.110  app3.com

