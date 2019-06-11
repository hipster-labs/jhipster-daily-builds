#!/bin/bash

set -e
source $(dirname $0)/00-init-env.sh


#-------------------------------------------------------------------------------
# Updating
#-------------------------------------------------------------------------------

sudo apt-get purge docker-engine
sudo apt-get autoremove --purge docker-engine
sudo rm -rf /var/lib/docker
curl https://releases.rancher.com/install-docker/17.03.sh | sh


#-------------------------------------------------------------------------------
# Installing minikube
#-------------------------------------------------------------------------------

# Adapted from: https://github.com/LiliC/travis-minikube/blob/minikube-26-kube-1.10/.travis.yml

export CHANGE_MINIKUBE_NONE_USER=true

echo "--> Downloading minikube"
# Make root mounted as rshared to fix kube-dns issues.
sudo mount --make-rshared /
# Download kubectl, which is a requirement for using minikube.
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
# Download minikube.
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.30.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

