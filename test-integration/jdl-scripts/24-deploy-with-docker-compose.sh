#!/bin/bash

set -e
source $(dirname $0)/00-init-env.sh


#-------------------------------------------------------------------------------
# Start docker container
#-------------------------------------------------------------------------------
if [ -d "$JHI_FOLDER_APP"/docker-compose ]; then
    cd "$JHI_FOLDER_APP"/docker-compose
    if [ -a docker-compose.yml ]; then
        docker-compose up -d
    fi
fi

docker ps -a

echo "*** waiting 60sec"
sleep 60
docker ps -a
