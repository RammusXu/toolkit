#!/bin/bash
set -e

service_account="ops"
namespace="ops"

secret_name=$(kubectl get serviceaccounts -n $namespace $service_account -o "jsonpath={.secrets[].name}")
token=$(kubectl get secrets -n $namespace $secret_name -o "jsonpath={.data.token}" | base64 -D)
ca=$(kubectl get secrets -n $namespace $secret_name -o "jsonpath={.data['ca\.crt']}" | base64 -D)
server_url=$(kubectl cluster-info | grep "Kubernetes master" | grep -E -o "https://([0-9]{1,3}[\.]){3}[0-9]{1,3}")

docker run -it --rm --entrypoint bash gcr.io/cloud-builders/kubectl -c "echo \"$ca\" > ca.crt
    kubectl config set-cluster my_cluster --embed-certs=true --server=$server_url --certificate-authority=./ca.crt
    kubectl config set-credentials sa --token=$token
    kubectl config set-context sa --cluster=my_cluster --user=sa --namespace=$namespace
    kubectl config use-context sa
    cat ~/.kube/config | base64 -w0
"
