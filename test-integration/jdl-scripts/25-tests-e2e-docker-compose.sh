#!/bin/bash

source $(dirname $0)/00-init-env.sh

#-------------------------------------------------------------------------------
# Specific for couchbase
#-------------------------------------------------------------------------------
cd "$JHI_FOLDER_APP"
if [ -a src/main/docker/couchbase.yml ]; then
    docker-compose -f src/main/docker/couchbase.yml up -d
    sleep 20
    docker ps -a
fi

echo "sleep 120s before starting e2e..."
sleep 120

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------
launchCurlOrEndToEnd() {
    retryCount=1
    maxRetry=30
    httpUrl="http://localhost:8080"
    if [[ "$JHI_APP" == *"micro"* ]]; then
        httpUrl="http://localhost:8081/management/health"
    fi

    rep=$(curl -v "$httpUrl")
    status=$?
    while [ "$status" -ne 0 ] && [ "$retryCount" -le "$maxRetry" ]; do
        echo "*** [$(date)] Application not reachable yet. Sleep and retry - retryCount =" $retryCount "/" $maxRetry
        retryCount=$((retryCount+1))
        sleep 10
        rep=$(curl -v "$httpUrl")
        status=$?
    done

    if [ "$status" -ne 0 ]; then
        echo "*** [$(date)] Not connected after" $retryCount " retries."
        return 1
    fi

    if [ "$JHI_E2E" != 1 ]; then
        return 0
    fi
    
    endToEndResult=0
    for local_folder in $(ls "$JHI_FOLDER_APP"); do
        if [ -d "$JHI_FOLDER_APP"/"$local_folder" ];
        then
            cd "$JHI_FOLDER_APP"/"$local_folder"
            retryCount=0
            maxRetry=1
            until [ "$retryCount" -ge "$maxRetry" ]
            do
                result=0
                if [[ -f "tsconfig.json" ]]; then
                    npm run e2e:headless
                fi
                result=$?
                [ $result -eq 0 ] && break
                retryCount=$((retryCount+1))
                echo "*** e2e tests failed... retryCount =" $retryCount "/" $maxRetry
                sleep 15
            done
            endToEndResult=$((endToEndResult + $result))
        fi
    done

    if [ "$endToEndResult" -ne 0 ]; then
        return 1
    fi
    
    return 0
}

#-------------------------------------------------------------------------------
# Run the application
#-------------------------------------------------------------------------------
if [ "$JHI_RUN_APP" == 1 ]; then
    # After the script 24 (deploy with docker compose), the app should be already up
    launchCurlOrEndToEnd
fi
