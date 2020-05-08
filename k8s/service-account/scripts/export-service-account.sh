#!/bin/bash
set -e

# Desription: Generate a kube_config from a service account.
# Usage: ./export-service-account.sh [-p /tmp/kubeconfig] [-d] <namespace>:<service_account>
# Example: 
#     ./export-service-account.sh ops:ops
#     ./export-service-account.sh -d ops:ops
#     ./export-service-account.sh -p /tmp/kubeconfig ops:ops
# Options:
#     -d: Debug mode.
#     -p: Path of existed kubeconfig to append new config.

while getopts "dp:" opt; do
  case $opt in
    d) debug_mode=true ;;
    p) kube_config=$OPTARG ;;
  esac
done

namespace_sa=${@: -1}

if [ $# -eq 0 ]; then
    echo "Usage: ./export-service-account.sh [-p /tmp/kubeconfig] <namespace>:<service_account>"
    exit 0
fi

service_account=${namespace_sa%:*}
namespace=${namespace_sa#*:}

## Get infomations from current cluster
secret_name=$(kubectl get serviceaccounts -n $namespace $service_account -o "jsonpath={.secrets[].name}")
token=$(kubectl get secrets -n $namespace $secret_name -o "jsonpath={.data.token}" | base64 -D)

ca_crt=$(mktemp)
kubectl get secrets -n $namespace $secret_name -o "jsonpath={.data['ca\.crt']}" | base64 -D > $ca_crt
ca=$(kubectl get secrets -n $namespace $secret_name -o "jsonpath={.data['ca\.crt']}" | base64 -D)

cluster_name=$(kubectl config view -o "jsonpath={.current-context}")
server_url=$(kubectl config view -o "jsonpath={.clusters[?(@.name == '$cluster_name')].cluster.server}")
context_name=$cluster_name:$namespace_sa

## Generate new config
test $kube_config && export KUBECONFIG=$kube_config || export KUBECONFIG=$(mktemp)
tempout=$(mktemp)
printf "\n========== Generating ==========\n" >$tempout
kubectl config set-cluster $cluster_name --embed-certs=true --server=$server_url --certificate-authority=$ca_crt >>$tempout
kubectl config set-credentials $context_name --token=$token >>$tempout
kubectl config set-context $context_name --cluster=$cluster_name --user=$context_name --namespace=$namespace >>$tempout
kubectl config use-context $context_name >>$tempout


if [[ $debug_mode ]]; then
  cat $tempout
  printf "\n========== KUBECONFIG ==========\n"
  cat $KUBECONFIG

  echo "========== Usage =========="
  echo "export KUBECONFIG=$KUBECONFIG"
  echo "base64 $KUBECONFIG"
else
  base64 $KUBECONFIG
fi