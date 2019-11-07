#!/bin/bash
set -e

docker run -it --rm --entrypoint bash -v $PWD/test:/test gcr.io/cloud-builders/kubectl -c "
    export KUBECONFIG=/tmp/config
    echo "$1" | base64 --decode > /tmp/config
    bash
"