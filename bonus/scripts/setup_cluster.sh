#!/bin/bash

BLUE='\033[0;34m'
LBLUE='\033[1;34m'
ORANGE='\033[0;33m'
RESET='\033[0m'


# ----------------------- Setup kubernetes cluster ----------------------- 

echo -e "${BLUE}Setting up kubernetes cluster${RESET}"

# Create k3d cluster
k3d cluster create bonus

sleep 5
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
k3d kubeconfig write bonus --output $HOME/.kube/config
chown -R $USER $HOME/.kube

kubectl config use-context k3d-bonus

echo -e "${BLUE}Kubernetes cluster is set up${RESET}"



# ----------------------- Setup ArgoCD ----------------------- 

echo -e "${BLUE}Setting up ArgoCD${RESET}"

kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "ArgoCD installation done"

# Wait for all ArgoCD pods to be created in the argocd namespace
echo "waiting for ArgoCD pods to be created..."
while [[ $(kubectl get pods -n argocd --no-headers 2>/dev/null | wc -l) -eq 0 ]]; do
  echo "no pods found in argocd namespace yet. Waiting..."
  sleep 5
done

echo "waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=ready pod --all -n argocd --timeout=600s
echo "ArgoCD pods are ready"

# get password to argocd (user: admin)
ARGOCD_PWD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
echo -e "${BLUE}ArgoCD user: ${LBLUE}admin"
echo -e "${BLUE}ArgoCD password: ${LBLUE}${ARGOCD_PWD}${RESET}"

echo "Port-forwarding ArgoCD server to 8080"
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443 2>&1 >/dev/null &

echo -e "${BLUE}ArgoCD is ready${RESET}"



# ----------------------- Setup Helm and GitLab -----------------------

echo -e "${BLUE}Setting up GitLab${RESET}"

kubectl create namespace gitlab

echo "Installing Helm"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


echo "Installing GitLab"

helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
    -n gitlab \
    -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
    --set global.hosts.domain=localhost \
    --set global.hosts.externalIP=0.0.0.0 \
    --set global.hosts.https=false \
    --timeout 600s


echo "Installed GitLab, waiting for it to set up"
kubectl wait --for=condition=ready --timeout=2400s pod -l app=webservice -n gitlab
if [ $? -ne 0 ]; then
  echo -e "${ORANGE}Error: GitLab setup timed out, try again${RESET}"
  exit 1
fi
echo "GitLab is ready"


# get password to gitlab (user: root)
GITLAB_PWD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --d)
echo -e "${BLUE}GitLab user: ${LBLUE}root"
echo -e "${BLUE}GitLab password: ${LBLUE}${GITLAB_PWD}${RESET}"


echo "Port-forwarding GitLab to 8181"
kubectl port-forward --address 0.0.0.0 svc/gitlab-webservice-default -n gitlab 8181:8181 2>&1 >/dev/null &


echo "Creating gitlab access token"
toolbox_pod=$(kubectl get pods -n gitlab -l app=toolbox -o jsonpath="{.items[0].metadata.name}")
kubectl cp ./scripts/generate_token.rb $toolbox_pod:/tmp/generate_token.rb -n gitlab
kubectl exec -it $toolbox_pod -n gitlab -- gitlab-rails runner /tmp/generate_token.rb
echo "GitLab access token created"

token="token1"

# Create GitLab repostory
curl --request POST "http://localhost:8181/api/v4/projects" --header "PRIVATE-TOKEN: $token" --header "Content-Type: application/json" --data '{"name": "iot-config-lpeggy"}'
echo "Repository iot-config-lpeggy created in GitLab"


# Add wil42 deployment.yaml and service.yaml files to the repository
curl --request POST "http://localhost:8181/api/v4/projects/1/repository/files/wil42%2Fdeployment.yaml" --header "PRIVATE-TOKEN: $token" --header "Content-Type: application/json" --data '{"branch": "main","content": '"$(cat deployment/wil42/deployment.yaml | jq -sR .)"',"commit_message": "Add wil42/deployment.yaml"}'
curl --request POST "http://localhost:8181/api/v4/projects/1/repository/files/wil42%2Fservice.yaml" --header "PRIVATE-TOKEN: $token" --header "Content-Type: application/json" --data '{"branch": "main","content": '"$(cat deployment/wil42/service.yaml | jq -sR .)"',"commit_message": "Add wil42/service.yaml"}'

# Make repository public. This is required for ArgoCD to access the repo
curl --request PUT "http://localhost:8181/api/v4/projects/1?visibility=public" --header "PRIVATE-TOKEN: $token"
# curl --request PUT "http://localhost:8181/api/v4/projects/1" --header "PRIVATE-TOKEN: $token" --header "Content-Type: application/json" --data '{"visibility": "public"}'

sleep 10

echo -e "${BLUE}GitLab is ready${RESET}"



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



# ----------------------- ----------------------- ----------------------- 
echo -e "${BLUE}The project is set up and ready ${RESET}"
echo "ArgoCD: http://localhost:8080"
echo "GitLab: http://localhost:8181"
echo "wil42: http://localhost:8888"