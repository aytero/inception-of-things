# inception-of-things

# p1
vagrant box choice
https://stackshare.io/stackups/alpine-linux-vs-centos
https://portal.cloud.hashicorp.com/vagrant/discover

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

Remove the old host key for this IP manually
Use the ssh-keygen command to remove the offending line:
```bash
ssh-keygen -R 192.168.56.110
ssh-keygen -R 192.168.56.111
```

https://stackoverflow.com/questions/10864372/how-to-ssh-to-vagrant-without-actually-running-vagrant-ssh

### save the config to a file
vagrant ssh-config > vagrant-ssh

### run ssh with the file.
ssh -F vagrant-ssh [vm-name]


ssh vagrant@IP -p PORT -i path/to/privatekey



# p2


https://github.com/paulbouwer/hello-kubernetes

In Kubernetes, it is generally recommended to apply the Deployment configuration before the Service configuration. This ensures that the pods are created and running before the Service tries to route traffic to them.


curl -H "Host:app1.com" 192.168.56.110
curl 192.168.56.110 => default app3


https://addons.mozilla.org/en-US/firefox/addon/modify-header-value/



## add hosts
```bash
echo "192.168.56.110 app1.com" >> /etc/hosts
echo "192.168.56.110 app2.com" >> /etc/hosts
echo "192.168.56.110 app3.com" >> /etc/hosts
cat /etc/hosts
```

# p3

k3d cluster list

kubectl scale deployment wil-playground --replicas=3 -n dev


# Bonus

gitlab rails console in a helm chart
https://docs.gitlab.com/ee/administration/operations/rails_console.html?tab=Helm+chart+%28Kubernetes%29

