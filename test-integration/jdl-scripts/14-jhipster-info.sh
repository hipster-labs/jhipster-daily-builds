#!/bin/bash

set -e
source $(dirname $0)/00-init-env.sh

cd "$JHI_FOLDER_APP"

for local_folder in $(ls "$JHI_FOLDER_APP"); do
    if [ -d "$JHI_FOLDER_APP"/"$local_folder" ];
    then
        cd "$JHI_FOLDER_APP"/"$local_folder"
        jhipster info
    fi
done