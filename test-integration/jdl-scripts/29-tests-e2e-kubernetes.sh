#!/bin/bash

source $(dirname $0)/00-init-env.sh

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------
launchCurlOrProtractor() {
    retryCount=1
    maxRetry=60

    kubectl cluster-info
    kubectl get nodes -o wide
    kubectl get service -n jhipster


    CLUSTERIP=$(kubectl get nodes -o wide | grep master | awk '{print $6; }')
    CLUSTERPORT=$(kubectl get service -n jhipster | grep LoadBalancer | awk '{print $5; }' | cut -d ':' -f2 | cut -d '/' -f1)
    httpUrl="http://$CLUSTERIP:$CLUSTERPORT"

    rep=$(curl -v "$httpUrl")
    status=$?
    while [ "$status" -ne 0 ] && [ "$retryCount" -le "$maxRetry" ]; do
        echo "**********************LOG INFO************************************"
        kubectl get service -n jhipster
        kubectl get pods -n jhipster

        echo "*** [$(date)] Application not reachable yet. Sleep and retry - retryCount =" $retryCount "/" $maxRetry
        retryCount=$((retryCount+1))
        sleep 10
        rep=$(curl -v "$httpUrl")
        status=$?
    done

    # kubectl exec $(kubectl get pods -n jhipster -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep store-mysql) sudo chmod +r /etc/mysql/conf.d/
    kubectl get service -n jhipster
    kubectl get pods -n jhipster
    # echo $(kubectl get pods -n jhipster -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep store-mysql)
    echo "**********************POD DATABASE***********************************"
    kubectl logs -n jhipster $(kubectl get pods -n jhipster -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep -E "store-mysql|store-mariadb")
    echo "*************************POD STORE***********************************"
    kubectl logs -n jhipster $(kubectl get pods -n jhipster -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep store- | awk '{if (NR==1) print $0}')

    if [ "$status" -ne 0 ]; then
        echo "*** [$(date)] Not connected after" $retryCount " retries."
        return 1
    fi

    if [ "$JHI_PROTRACTOR" != 1 ]; then
        return 0
    fi

    retryCount=0
    maxRetry=1
    until [ "$retryCount" -ge "$maxRetry" ]
    do
        result=0
        if [[ -f "tsconfig.json" ]]; then
            npm run e2e
        fi
        result=$?
        [ $result -eq 0 ] && break
        retryCount=$((retryCount+1))
        echo "*** e2e tests failed... retryCount =" $retryCount "/" $maxRetry
        sleep 15
    done
    return $result
}

#-------------------------------------------------------------------------------
# Run the application
#-------------------------------------------------------------------------------
if [ "$JHI_RUN_APP" == 1 ]; then
    # After the script 28 (deploy with kubernetes), the app should be already up
    export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
    launchCurlOrProtractor
fi