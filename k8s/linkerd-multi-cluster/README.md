https://linkerd.io/2/tasks/multicluster/

## Requirements
- [gcloud](https://cloud.google.com/sdk/docs/downloads-interactive)
- [linkerd](https://linkerd.io/2/getting-started/)
- [step](https://smallstep.com/cli/): Create certificate more easier.
- [kubectx](https://github.com/ahmetb/kubectx): Switch kubernetes context.

## Create cluster
```bash
gcloud beta container clusters create tw --region "asia-east1" --release-channel "regular" \
    --machine-type "n2-highcpu-2" --image-type "COS" --disk-size "100" --disk-type "pd-ssd" \
    --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only",\
"https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring",\
"https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly",\
"https://www.googleapis.com/auth/trace.append","https://www.googleapis.com/auth/cloud-platform" \
    --num-nodes "1" --preemptible --enable-autoscaling --min-nodes "1" --max-nodes "3" \
    --enable-stackdriver-kubernetes --enable-ip-alias --async

gcloud beta container clusters create ore --region "us-west1" --release-channel "regular" \
    --machine-type "n2-highcpu-2" --image-type "COS" --disk-size "100" --disk-type "pd-ssd" \
    --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only",\
"https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring",\
"https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly",\
"https://www.googleapis.com/auth/trace.append","https://www.googleapis.com/auth/cloud-platform" \
    --num-nodes "1" --preemptible --enable-autoscaling --min-nodes "1" --max-nodes "3" \
    --enable-stackdriver-kubernetes --enable-ip-alias --async
```

## Setup kubeconfig
```bash
touch .kubecfg
export KUBECONFIG=.kubecfg
export PROJECT_ID=$(gcloud info --format='value(config.project)')
gcloud container clusters get-credentials tw --region "asia-east1" --project ${PROJECT_ID}
gcloud container clusters get-credentials ore --region "us-west1" --project ${PROJECT_ID}
kubectx control=gke_${PROJECT_ID}_asia-east1_tw
kubectx remote=gke_${PROJECT_ID}_us-west1_ore
kubectl create clusterrolebinding user-admin-binding \
    --clusterrole=cluster-admin --user=$(gcloud config get-value account) \
    --context control
kubectl create clusterrolebinding user-admin-binding \
    --clusterrole=cluster-admin --user=$(gcloud config get-value account) \
    --context remote
```

## Create CA certificate
```bash
step certificate create identity.linkerd.cluster.local root.crt root.key \
  --profile root-ca --no-password --insecure
step certificate create identity.linkerd.cluster.local issuer.crt issuer.key \
  --profile intermediate-ca --not-after 87600h --no-password --insecure \
  --ca root.crt --ca-key root.key
```

## Linkerd
```bash

for ctx in $(kubectx); do
    kubectx ${ctx}
    echo "Checking cluster: ${ctx} .........\n"
    linkerd install \
        --identity-trust-anchors-file root.crt \
        --identity-issuer-certificate-file issuer.crt \
        --identity-issuer-key-file issuer.key \
        | kubectl apply -f -
    linkerd check || break
    echo "-------------\n"
done

for ctx in $(kubectx); do
  echo "Installing on cluster: ${ctx} ........."
  linkerd --context=${ctx} multicluster install | \
    kubectl --context=${ctx} apply -f - || break
  echo "-------------\n"
done

for ctx in $(kubectx); do
    echo "Checking gateway on cluster: ${ctx} ........."
    kubectl --context=${ctx} -n linkerd-multicluster \
        rollout status deploy/linkerd-gateway || break
    linkerd --context=${ctx} check --multicluster || break
    linkerd --context=${ctx} multicluster gateways
    echo "-------------\n"
done
```

Link cluster
```bash
linkerd --context=remote multicluster link --cluster-name remote |
  kubectl --context=control apply -f -
```

Verify installation
```bash
linkerd --context=control check --multicluster
linkerd --context=control multicluster gateways
```

## Deploy test app
```bash
kubectl --context=control apply \
    -k "github.com/linkerd/website/multicluster/west/"
kubectl --context=control -n test rollout status deploy/podinfo || break

kubectl --context=remote apply \
    -k "github.com/linkerd/website/multicluster/east/"
kubectl --context=remote -n test rollout status deploy/podinfo || break

kubectl --context=control -n test port-forward svc/frontend 8080
```

Export service
```bash
kubectl --context=remote get svc -n test podinfo -o yaml | \
  linkerd multicluster export-service - | \
  kubectl --context=remote apply -f -

# or add annotations in service
  annotations:
    mirror.linkerd.io/gateway-name: linkerd-gateway
    mirror.linkerd.io/gateway-ns: linkerd-multicluster
```

Check endpoint IP
```bash
kubectl --context=control -n test get endpoints podinfo-remote \
  -o 'custom-columns=ENDPOINT_IP:.subsets[*].addresses[*].ip'
kubectl --context=remote -n linkerd-multicluster get svc linkerd-gateway \
  -o "custom-columns=GATEWAY_IP:.status.loadBalancer.ingress[*].ip"
```

Test connection
```bash
kubectl --context=control -n test exec -c nginx -it \
  $(kubectl --context=control -n test get po -l app=frontend \
    --no-headers -o custom-columns=:.metadata.name) \
  -- /bin/sh -c "apk add curl && curl http://podinfo-remote:9898"

linkerd --context=control -n test stat --from deploy/frontend svc
```

Open grafana: http://localhost:50750/grafana/
```bash
linkerd --context=control dashboard
```

Validate mTLS
```bash
linkerd --context=control -n test tap deploy/frontend | \
  grep "$(kubectl --context=remote -n linkerd-multicluster get svc linkerd-gateway \
    -o "custom-columns=GATEWAY_IP:.status.loadBalancer.ingress[*].ip")"
```

```bash
kubectl --context=control -n test port-forward svc/frontend 8080
watch -n0.1 curl localhost:8080
```

Try traffic split
```
kubectl --context=control apply -f test/traffic-split.yaml
linkerd --context=west -n test stat trafficsplit
```

## Reference
- https://linkerd.io/2/tasks/multicluster/
- https://linkerd.io/2/tasks/installing-multicluster/
- https://github.com/linkerd/website/blob/master/multicluster
