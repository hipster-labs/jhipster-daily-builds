#!/bin/bash

set -e
source $(dirname $0)/00-init-env.sh

#-------------------------------------------------------------------------------
# Connecting to cluster
#-------------------------------------------------------------------------------
export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
kubectl cluster-info

#-------------------------------------------------------------------------------
# Start kubernetes deployment
#-------------------------------------------------------------------------------
if [ -d "$JHI_FOLDER_APP"/kubernetes ]; then
    cd "$JHI_FOLDER_APP"/kubernetes
    if [ -a kubectl-apply.sh ]; then
        ./kubectl-apply.sh
    fi
fi

kubectl get service -n jhipster