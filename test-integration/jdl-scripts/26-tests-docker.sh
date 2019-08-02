#!/bin/bash

set -e

#-------------------------------------------------------------------------------
# Test Docker image
#-------------------------------------------------------------------------------
docker container run -d -e JHI_DISABLE_WEBPACK_LOGS=true --name jhipster jhipster/jhipster:master
docker container ps
docker container exec -i jhipster npm --version
docker container exec -i jhipster yarn --version
docker container exec -i jhipster yo --version
docker container exec -i jhipster git config --global user.name "JHipster Bot"
docker container exec -i jhipster git config --global user.email "jhipster-bot@jhipster.tech"
docker container exec -i jhipster jhipster --help --no-insight
docker container exec -i jhipster jhipster info --no-insight

# install JHipster dependencies
docker container exec -i jhipster git clone https://github.com/jhipster/jhipster /home/jhipster/jhipster
docker container exec -w /home/jhipster/jhipster -e JAVA_HOME=/home/jhipster/.sdkman/candidates/java/current -i jhipster ./mvnw -ntp clean install -Dgpg.skip=true

# generate sample
docker container exec -i jhipster curl https://raw.githubusercontent.com/jhipster/generator-jhipster/master/test-integration/samples/ngx-default/.yo-rc.json -o .yo-rc.json
docker container exec -i jhipster ls -al
docker container exec -i jhipster jhipster --force --no-insight --skip-checks --with-entities
docker container exec -i jhipster ls -al /home/jhipster/app/
docker container exec -e JAVA_HOME=/home/jhipster/.sdkman/candidates/java/current -i jhipster ./mvnw -ntp test
docker container exec -i jhipster npm test
docker container exec -e JAVA_HOME=/home/jhipster/.sdkman/candidates/java/current -i jhipster ./mvnw -ntp package -Pprod
