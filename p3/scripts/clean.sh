#!/bin/bash

kubectl delete namespace argocd
kubectl delete namespace dev
k3d cluster delete iot