#!/bin/bash
set -e

kubectl apply -f sa-ci.yaml

server_url=$1
service_account="sa-ci"
namespace="default"

secret_name=$(kubectl get serviceaccounts -n $namespace $service_account -o "jsonpath={.secrets[].name}")
token=$(kubectl get secrets -n $namespace $secret_name -o "jsonpath={.data.token}" | base64 -D)
ca=$(kubectl get secrets -n $namespace $secret_name -o "jsonpath={.data['ca\.crt']}" | base64 -D)

docker run -it --rm --entrypoint bash gcr.io/cloud-builders/kubectl -c "echo \"$ca\" > ca.crt &&\
    kubectl config set-cluster my_cluster --embed-certs=true --server=$server_url --certificate-authority=./ca.crt
    kubectl config set-credentials sa-admin --token=$token &&\
    kubectl config set-context sa-admin --cluster=my_cluster --user=sa-admin --namespace=default &&\
    kubectl config use-context sa-admin &&\
    cat ~/.kube/config | base64 -w0
"
