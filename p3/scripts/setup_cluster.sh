#!/bin/bash

BLUE='\033[0;34m'
LBLUE='\033[1;34m'
ORANGE='\033[0;33m'
RESET='\033[0m'


# ----------------------- Setup kubernetes cluster ----------------------- 

echo -e "${BLUE}Setting up kubernetes cluster${RESET}"

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

kubectl config use-context k3d-iot

echo -e "${BLUE}Kubernetes cluster is set up${RESET}"



# ----------------------- Setup ArgoCD ----------------------- 

echo -e "${BLUE}Setting up ArgoCD${RESET}"

kubectl create namespace argocd

echo "Installing ArgoCD"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "ArgoCD installation is done"

# Wait for all ArgoCD pods to be created in the argocd namespace
echo "waiting for ArgoCD pods to be created..."
while [[ $(kubectl get pods -n argocd --no-headers 2>/dev/null | wc -l) -eq 0 ]]; do
  echo "no pods found in argocd namespace yet. Waiting..."
  sleep 5
done

kubectl wait --for=condition=ready pod --all -n argocd --timeout=600s
echo "ArgoCD pods are ready"

# get password to argocd (user: admin)
ARGOCD_PWD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
echo -e "${BLUE}ArgoCD user: ${LBLUE}admin"
echo -e "${BLUE}ArgoCD password: ${LBLUE}${ARGOCD_PWD}${RESET}"

# https://{vm-ip}:8080
echo "Port-forwarding ArgoCD server to 8080"
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 2>&1 >/dev/null &

echo -e "${BLUE}ArgoCD is ready${RESET}"



# ----------------------- Setup wil42 application ----------------------- 

echo -e "${BLUE}Setting up wil42 application${RESET}"

kubectl create namespace dev

# Create the argocd-wil42 application
kubectl apply -f ./deployment/argocd.yaml


while [[ $(kubectl get pods -n dev --no-headers 2>/dev/null | wc -l) -eq 0 ]]; do
  echo "no pods found in dev namespace yet. Waiting..."
  sleep 5
done
kubectl wait --for=condition=ready pod --all -n dev --timeout=600s

echo "Port-forwarding wil42 app to 8888"
kubectl port-forward --address 0.0.0.0 svc/wil-playground-service -n dev 8888:8888 2>&1 >/dev/null &

echo -e "${BLUE}wil42 application is ready${RESET}"



# ----------------------- Fin ----------------------- 
echo -e "${BLUE}The project is set up and ready, go to ${RESET}"
echo "ArgoCD: http://localhost:8080"
echo "wil42: http://localhost:8888"
