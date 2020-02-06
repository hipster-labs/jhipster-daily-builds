#!/bin/bash

set -e
source $(dirname $0)/00-init-env.sh

#-------------------------------------------------------------------------------
# Package UAA
#-------------------------------------------------------------------------------
if [[ "$JHI_APP" == *"uaa"* ]]; then
    cd "$JHI_FOLDER_UAA"
    ./mvnw -ntp verify -DskipTests -Pdev
    mv target/*.jar app.jar
fi

cd "$JHI_FOLDER_APP"
ls -ll
for local_folder in $(ls "$JHI_FOLDER_APP"); do
    if [ -d "$JHI_FOLDER_APP"/"$local_folder" ];
    then
        cd "$JHI_FOLDER_APP"/"$local_folder"
        echo "went into $JHI_FOLDER_APP/$local_folder"
        ls -ll
        #-------------------------------------------------------------------------------
        # Decrease Angular timeout for Protractor tests
        #-------------------------------------------------------------------------------
        if [ "$JHI_PROTRACTOR" == 1 ] && [ -e "src/main/webapp/app/app.module.ts" ]; then
            sed -e 's/alertTimeout: 5000/alertTimeout: 1/1;' src/main/webapp/app/core/core.module.ts > src/main/webapp/app/core/core.module.ts.sed
            mv -f src/main/webapp/app/core/core.module.ts.sed src/main/webapp/app/core/core.module.ts
            cat src/main/webapp/app/core/core.module.ts | grep alertTimeout
        fi

        #-------------------------------------------------------------------------------
        # Package the application
        #-------------------------------------------------------------------------------
        if [ -f "mvnw" ]; then
            ./mvnw -ntp verify -DskipTests -P"$JHI_PROFILE"
            mv target/*.jar app.jar
        elif [ -f "gradlew" ]; then
            ./gradlew bootJar -P"$JHI_PROFILE" -x test
            mv build/libs/*SNAPSHOT.jar app.jar
        else
            echo "*** no mvnw or gradlew"
            # exit 0 - No actions to be done, go next
            continue
        fi
        if [ $? -ne 0 ]; then
            echo "*** error when packaging"
            exit 1
        fi

        #-------------------------------------------------------------------------------
        # Package the application as War
        #-------------------------------------------------------------------------------
        if [ "$JHI_WAR" == 1 ]; then
            if [ -f "mvnw" ]; then
                ./mvnw -ntp verify -DskipTests -P"$JHI_PROFILE",war
                mv target/*.war app.war
            elif [ -f "gradlew" ]; then
                ./gradlew bootWar -P"$JHI_PROFILE" -Pwar -x test
                mv build/libs/*SNAPSHOT.war app.war
            else
                echo "*** no mvnw or gradlew"
                # exit 0 - No actions to be done, go next
                continue
            fi
            if [ $? -ne 0 ]; then
                echo "*** error when packaging"
                exit 1
            fi
        fi

        #-------------------------------------------------------------------------------
        # Package the application as Docker image
        #-------------------------------------------------------------------------------
        # if [ "$JHI_PKG_DOCKER" == 1 ]; then
            if [ -f "mvnw" ]; then
                ./mvnw -ntp -Pprod verify jib:dockerBuild
            elif [ -f "gradlew" ]; then
                ./gradlew bootJar -Pprod jibDockerBuild
            else
                echo "*** no mvnw or gradlew"
                # exit 0 - No actions to be done, go next
                continue
            fi
            if [ $? -ne 0 ]; then
                echo "*** error when building docker images"
                exit 1
            fi

        # fi
    fi
done
