#!/bin/bash

init_var() {
    result=""
    if [[ $1 != "" ]]; then
        result=$1
    elif [[ $2 != "" ]]; then
        result=$2
    elif [[ $3 != "" ]]; then
        result=$3
    fi
    echo $result
}

init_jhi_samples() {
    result=""
    if [[ $JHI_GITHUB_CI ]]; then
        # GITHUB ACTIONS
        result="$JHI_INTEG"/jdl-samples
    else
        # AZURE PIPELINES
        result="$HOME"/work/1/s/test-integration/jdl-samples
    fi
    echo $result
}

# uri of repo
JHI_REPO=$(init_var "$BUILD_REPOSITORY_URI" "$TRAVIS_REPO_SLUG" "$GITHUB_REPOSITORY")

# folder where the repo is cloned
JHI_CLONED=$(init_var "$BUILD_REPOSITORY_LOCALPATH" "$TRAVIS_BUILD_DIR" "$GITHUB_WORKSPACE")

# folder where the generator-jhipster is cloned
JHI_HOME="$HOME"/generator-jhipster

# folder for test-integration
JHI_INTEG="$JHI_HOME"/test-integration

# folder for samples
JHI_SAMPLES=$(init_jhi_samples)

# folder for scripts
JHI_SCRIPTS="$JHI_INTEG"/jdl-scripts
# folder for app
JHI_FOLDER_APP="$HOME"/app

# folder for uaa app
JHI_FOLDER_UAA="$HOME"/app/uaa
