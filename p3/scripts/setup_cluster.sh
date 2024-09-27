
#!/bin/bash

# ----------------------- Setup kubernetes cluster ----------------------- 

# Create k3d cluster
k3d cluster create iot

# Wait for k3d cluster to be ready
echo "Waiting for k3d cluster to be ready..."
while [[ $(kubectl get nodes --no-headers 2>/dev/null | wc -l) -eq 0 ]]; do
  echo "no nodes in the cluster yet. Waiting..."
  sleep 5
done
kubectl wait --for=condition=ready nodes --all --timeout=600s
echo "k3d cluster is ready"

# Write kubeconfig to the user's home directory, to use kubectl without sudo
mkdir -p $HOME/.kube
touch $HOME/.kube/config
k3d kubeconfig write iot --output $HOME/.kube/config
chown -R $USER $HOME/.kube


# ----------------------- Install ArgoCD ----------------------- 

echo "installing argocd"
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "argocd installation done"

# Wait for all ArgoCD pods to be created in the argocd namespace
echo "waiting for ArgoCD pods to be created..."
while [[ $(kubectl get pods -n argocd --no-headers 2>/dev/null | wc -l) -eq 0 ]]; do
  echo "no pods found in argocd namespace yet. Waiting..."
  sleep 5
done

kubectl wait --for=condition=ready pod --all -n argocd --timeout=600s
echo "argocd app is ready"

# get password to argocd (user: admin)
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo


# ----------------------- Setup wil42 application ----------------------- 

kubectl create namespace dev

# Create the argocd-wil42 application
kubectl apply -f /deployment/argocd.yaml


while [[ $(kubectl get pods -n dev --no-headers 2>/dev/null | wc -l) -eq 0 ]]; do
  echo "no pods found in dev namespace yet. Waiting..."
  sleep 5
done
kubectl wait --for=condition=ready pod --all -n dev --timeout=600s


# https://{vm-ip}:8080
echo "port forwarding argocd server to 8080, go to https://localhost:8080"
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443