
k3d cluster create iot

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

## waitpod
kubectl wait --for=condition=ready --timeout=600s pod --all -n argocd

# # password to argocd (user: admin)
# kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode

kubectl create namespace dev
kubectl apply -f /vagrant/deployment.yaml
# kubectl apply -f deployment.yaml

kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443
# https://{vm-ip}:8080