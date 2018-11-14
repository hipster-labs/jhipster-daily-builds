#!/bin/bash

set -e

#-------------------------------------------------------------------------------
# Test Docker image
#-------------------------------------------------------------------------------
docker container run -d -e JHI_DISABLE_WEBPACK_LOGS=true --name jhipster jhipster/jhipster:master
docker container ps
docker container exec -it jhipster npm --version
docker container exec -it jhipster yarn --version
docker container exec -it jhipster yo --version
docker container exec -it jhipster jhipster --help --no-insight
docker container exec -it jhipster jhipster info --no-insight
docker container exec -it jhipster curl https://raw.githubusercontent.com/jhipster/generator-jhipster/master/test-integration/samples/ngx-default/.yo-rc.json -o .yo-rc.json
docker container exec -it jhipster ls -al
docker container exec -it jhipster jhipster --force --no-insight --skip-checks --with-entities
docker container exec -it jhipster ./mvnw test
docker container exec -it jhipster npm test
