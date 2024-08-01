# ============================================================================ #
# Author: Mark Taguiad <marktaguiad@tagsdev.xyz>
# ============================================================================ #

#!/bin/bash
# set -x

REGISTRY='localhost:5000'

function add_get_repo() {
    read -p 'repo name: ' REPO_NAME
    read -p 'repo url: ' REPO_URL
    helm repo add ${REPO_NAME} ${REPO_URL}
    helm search repo -r "${REPO_NAME}" | awk '{print $1}'
    read -p 'what chart: ' CHART
    
}

function save_chart() {
    helm fetch --untar --untardir charts ${CHART}
}

function save_image() {
    
    chart_dir=$(echo ${CHART} | cut -d'/' -f2-)
    mkdir -p ./charts/${chart_dir}/images
    echo ${chart_dir}

    CONTAINER_RUNTIME="podman"

    image_tag=$(helm template $REPO_NAME $CHART --dry-run | grep image: | sed -e 's/[ ]*image:[ ]*//' -e 's/"//g' | sort -u)
    for i in $image_tag
    do
        file=$(sed 's#\/#\_#g; s#:#\_#g' <<< $i)
        image=$(cut -d'/' -f2- <<< $i)
        image=$(sed 's/:.*//' <<< $image)
        tag=$(cut -d : -f 2 <<< $i)

        echo "=================================================================================================================================================================="
        echo "DEBUG: ${CONTAINER_RUNTIME} pull $i"
        echo "=================================================================================================================================================================="
        ${CONTAINER_RUNTIME} pull $i
        echo ""; echo ""

        # retag to new registry
        # echo "=================================================================================================================================================================="
        # echo "DEBUG: ${CONTAINER_RUNTIME} image tag $i $REGISTRY/$i"
        # echo "=================================================================================================================================================================="
        # ${CONTAINER_RUNTIME} image tag $i $REGISTRY/$i
        # echo ""; echo ""

        echo "=================================================================================================================================================================="
        echo "DEBUG: ${CONTAINER_RUNTIME} save -o ./charts/${chart_dir}/images/${file}.tar $i"
        echo "=================================================================================================================================================================="
        ${CONTAINER_RUNTIME} save -o ./charts/${chart_dir}/images/${file}.tar $i
        echo ""; echo ""

    done
}

function update_pull_policy() {
    sed -i 's/Always/Never/' ./charts/${chart_dir}/values.yaml
}

function remove_repo() {
    helm repo remove ${REPO_NAME}
}

add_get_repo
save_chart
save_image
update_pull_policy
remove_repo