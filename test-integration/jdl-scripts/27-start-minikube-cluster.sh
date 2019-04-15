#!/bin/bash

set -e
source $(dirname $0)/00-init-env.sh

#-------------------------------------------------------------------------------
# Stopping docker containers
#-------------------------------------------------------------------------------
# docker stop $(docker ps -a)
# docker rm $(docker ps -a -q)

#-------------------------------------------------------------------------------
# Starting local cluster
#-------------------------------------------------------------------------------
echo "--> Starting minikube"
sudo minikube start --vm-driver=none --bootstrapper=kubeadm --kubernetes-version=v1.12.0
# Fix permissions issue in AzurePipelines
sudo chmod --recursive 777 $HOME/.minikube
sudo chmod --recursive 777 $HOME/.kube
# Fix the kubectl context, as it's often stale.
minikube update-context

echo "--> Waiting for cluster to be usable"
# Wait for Kubernetes to be up and ready.
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl -n kube-system get pods -lcomponent=kube-addon-manager -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for kube-addon-manager to be available"; kubectl get pods --all-namespaces; done
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl -n kube-system get pods -lk8s-app=kube-dns -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for kube-dns to be available"; kubectl get pods --all-namespaces; done


echo "--> Get cluster details to check its running"
kubectl cluster-info