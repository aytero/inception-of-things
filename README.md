# inception-of-things

# p1
vagrant box choice
https://stackshare.io/stackups/alpine-linux-vs-centos
https://portal.cloud.hashicorp.com/vagrant/discover


### Commands

Use k9s with a cluster in vagrant vm
```bash
k9s --kubeconfig k3s.yaml
```

See VMs status
```bash
vagrant global-status 
```

Clean
```bash
vagrant global-status --prune
```

&nbsp;

`kubectl config view --raw`

to access clister via agent node:  
`kubectl get nodes --kubeconfig /vagrant/k3s.yaml`

explanation:  
https://github.com/k3s-io/k3s/issues/3862

https://docs.k3s.io/cluster-access

https://jaehong21.com/posts/k3s/02-access-outside/



### Check network settings
```bash
ifconfig eth1
```

### SSH into vagrant machine
If machine is re-created/changed, ssh fingerprint will change, causing error when trying to ssh into a machine.
Remove the old host key for these IPs manually
Use the ssh-keygen command to remove the offending line:
```bash
ssh-keygen -R 192.168.56.110
ssh-keygen -R 192.168.56.111
```

### Other way to access vagrant vm via ssh, without copying keys into a machine
https://stackoverflow.com/questions/10864372/how-to-ssh-to-vagrant-without-actually-running-vagrant-ssh

#### save config to a file
vagrant ssh-config > vagrant-ssh

#### run ssh with the file.
ssh -F vagrant-ssh [vm-name]

ssh vagrant@IP -p PORT -i path/to/privatekey



&nbsp; 
# p2

This test app is used in this project  
https://github.com/paulbouwer/hello-kubernetes

In Kubernetes, it is generally recommended to apply the Deployment configuration before the Service configuration. This ensures that the pods are created and running before the Service tries to route traffic to them.


```bash
curl -H "Host:app1.com" 192.168.56.110
curl 192.168.56.110 => default app3
```

Add this extention to change HOST header in the browser
https://addons.mozilla.org/en-US/firefox/addon/modify-header-value/



### Add hosts
```bash
echo "192.168.56.110 app1.com" >> /etc/hosts
echo "192.168.56.110 app2.com" >> /etc/hosts
echo "192.168.56.110 app3.com" >> /etc/hosts
cat /etc/hosts
```

&nbsp; 
# p3

To check that cluster is up and ready run 
```bash
k3d cluster list
```
   
### ArgoCD

#### Go to http://localhost:8080 to access ArgoCD dashboard.


Run this command and check the dashboard. ArgoCD will suppress changes and keep 1 replica as specified in .yaml configs.
```bash
kubectl scale deployment wil-playground --replicas=3 -n dev
```

in the repository with deployment files, check that deployed app version is v1

```bash
cat wil42/deployment.yaml | grep v1
>    image: wil42/playground:v1
```

then

```bash
curl localhost:8888/
>    {"status":"ok", "message": "v1"}
```

change version to v2, commit and push, wait to set up, check again

```bash
curl localhost:8888/
>    {"status":"ok", "message": "v2"}
```


&nbsp; 
# Bonus

### Useful commands
To start script from a specific line
```bash
sed -n '80,$p' ./scripts/setup_cluster.sh | bash
```

To kill a port-forwarding processes 
```bash
ps aux | grep 'kubectl port-forward' | grep -v grep
kill <PID>
```

To get argocd and gitlab passwords
```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d; echo
```

To run gitlab-rails console manually
```bash
kubectl -n gitlab exec -it -c toolbox gitlab-toolbox-574c9b58b5-q9nkg -- gitlab-rails console
```

To port-forward
```bash
kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n gitlab 8181:8181
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443
kubectl port-forward --address 0.0.0.0 svc/wil-playground-service -n dev 8888:8888
```

&nbsp; 

### GitLab
To deploy gitlab to k3d we need this-looking command  
source: https://docs.gitlab.com/charts/installation/deployment.html
```bash
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=example.com \
  --set global.hosts.externalIP=10.10.10.10 \
  --set certmanager-issuer.email=me@example.com
```
Full GitLab app is too big for the school machine so we take a small version from here and specify it with the option -f  
https://gitlab.com/gitlab-org/charts/gitlab/-/tree/master/examples?ref_type=heads

```bash
helm upgrade --install gitlab gitlab/gitlab \
    -n gitlab \
    -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
    --set global.hosts.domain=localhost \
    --set global.hosts.externalIP=0.0.0.0 \
    --set global.hosts.https=false \
    --timeout 600s
```

If timeout
```bash
helm upgrade gitlab gitlab/gitlab -n gitlab
```

If failed
```bash
helm uninstall gitlab -n gitlab
kubectl delete namespace gitlab
```

This command lists all of the releases for a specified namespace  
`helm list -n gitlab`

&nbsp; 

Gitlab access token is needed to use gitlab api and create and set repo from the script. It is possible to create this token from the Rails console.  
About gitlab Rails console and where to get it in a helm chart:
https://docs.gitlab.com/ee/administration/operations/rails_console.html?tab=Helm+chart+%28Kubernetes%29

&nbsp; 

### Curl requests to the GitLab API

To retrieve the project ID
```bash
curl --request GET "http://localhost:<forwarded-port>/api/v4/projects" --header "PRIVATE-TOKEN: <ACCESS-TOKEN>"
```
&nbsp; 


Create README.md in the gitlab repo
```bash
curl --request POST "http://localhost:8181/api/v4/projects/1/repository/files/docs%2FREADME.md"
    --header "PRIVATE-TOKEN: token1"
    --header "Content-Type: application/json"
    --data '{
        "branch": "main",
        "content": "This is a readme file",
        "commit_message": "Add docs/README.md"
    }'
```
&nbsp;


Update a file in a gitlab repo
```bash
curl --request PUT "http://localhost:8181/api/v4/projects/<project-id>/repository/files/<file-path>"
    --header "PRIVATE-TOKEN: <your-token-string-here>"
    --header "Content-Type: application/json"
    --data '{
        "branch": "main",
        "content": "'"$(cat path/to/your/file | jq -sR .)"'",
        "commit_message": "Update <file-path>"
    }'
```
&nbsp;

For the evaluation  
Update version in the deployment.yaml
```bash
curl --request PUT "http://localhost:8181/api/v4/projects/1/repository/files/wil42%2fdeployment.yaml"
    --header "PRIVATE-TOKEN: token1"
    --header "Content-Type: application/json"
    --data '{
        "branch": "main",
        "content": '"$(cat deployment/wil42/deployment.yaml | jq -sR .)"',
        "commit_message": "Update deployment"
    }'
```
