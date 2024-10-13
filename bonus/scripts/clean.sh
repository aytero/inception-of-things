#!/bin/bash

helm uninstall gitlab -n gitlab
kubectl delete namespace gitlab
kubectl delete namespace argocd
kubectl delete namespace dev
k3d cluster delete bonus