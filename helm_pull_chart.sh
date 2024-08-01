#!/bin/bash
# set -x

REGISTRY='localhost:5000'

function add_get_repo() {
    read -p 'what repo: ' REPO
    helm repo add repo $REPO
    helm search repo -r "repo" | awk '{print $1}'
    read -p 'what chart: ' CHART
}


function save_image() {

    mkdir -p ./out_image

    CONTAINER_RUNTIME="docker"
    if command -v podman &> /dev/null
    then
        CONTAINER_RUNTIME="podman"
    fi

    image_tag=$(helm template dummy $CHART --dry-run | grep image: | sed -e 's/[ ]*image:[ ]*//' -e 's/"//g' | sort -u)
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
        echo "=================================================================================================================================================================="
        echo "DEBUG: ${CONTAINER_RUNTIME} image tag $i $REGISTRY/$i"
        echo "=================================================================================================================================================================="
        ${CONTAINER_RUNTIME} image tag $i $REGISTRY/$i
        echo ""; echo ""

        echo "=================================================================================================================================================================="
        echo "DEBUG: ${CONTAINER_RUNTIME} save -o ./out_image/${file}.tar $i"
        echo "=================================================================================================================================================================="
        ${CONTAINER_RUNTIME} save -o ./out_image/${file}.tar $i
        echo ""; echo ""

    done
}

function remove_repo() {
    helm repo remove repo
}

add_get_repo
save_image
remove_repo

