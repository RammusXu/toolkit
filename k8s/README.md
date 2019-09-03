# Setup

```
kubectl apply -f setup
```

## Helm
```
brew install kubernetes-helm
helm init --service-account tiller
```

## Dashboard
```
helm install stable/kubernetes-dashboard --name kubernetes-dashboard --namespace kube-system --set rbac.clusterAdminRole=true
```

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login

取得 token
```
kubectl config view
kubectl get secret
kubectl describe secret kubernetes-dashboard-token-rkq9g -n kube-system

```

## nginx-ingress
```
helm install --name nginx-ingress stable/nginx-ingress \
    --set controller.kind=DaemonSet \
    --set controller.hostNetwork=true \
    --namespace kube-system

helm install --name nginx-ingress stable/nginx-ingress \
    --set controller.kind=DaemonSet \
    --set controller.hostNetwork=true \
    --set rbac.create=true \
    --namespace kube-system
```
https://medium.com/containerum/how-to-launch-nginx-ingress-and-cert-manager-in-kubernetes-55b182a80c8f


## Commands

### kops

Install
```
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x ./kops
sudo mv ./kops /usr/local/bin/
```

```
export NAME=k8s.rammus.com
export KOPS_STATE_STORE=s3://k8s.rammus.com

kops create cluster \
    --zones=ap-southeast-1a,ap-southeast-1b,ap-southeast-1c \
    --master-size=t2.small \
    --master-count=1 \
    --node-size=t2.medium \
    --node-count=2 \
    --name ${NAME} \
    --yes 
```

```
kops delete cluster \
    --state ${KOPS_STATE_STORE} \
    ${NAME}
```

```
kops edit cluster
  additionalPolicies:
    node: |
      [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "*"
            ]
        }
      ]
```

```
kops validate cluster
kops get ig
kops edit ig nodes
kops edit ig master-ap-southeast-1a
kops update cluster --yes
kops rolling-update cluster --yes
kops rolling-update cluster --cloudonly --force --yes

```

### kubectl

```
kubectl create secret docker-registry gitlab-auth \
  --docker-server=https://registry.gitlab.com \
  --docker-username=xxxxxxxx \
  --docker-password=xxxxxxxx \
  --docker-email=xxxxxxxx@gmail.com
```

```
kubectl version
kubectl get nodes
kubectl cluster-info
kubectl config get-contexts
kubectl config set-context $(kubectl config current-context) --namespace=kube-system
kubectl run -it busybox --image=busybox -- sh

kubectl get all
kubectl get pod,deploy
kubectl logs -f -l app=kibana

kubectl run -i --tty python3 --image=python:3.7 -- bash
kubectl run -i --tty --image python dns-test --restart=Never --rm /bin/bash

kubectl apply -R -f .
kubectl delete  -R -f mongo-sh0/ --cascade

# Get secret
kubectl get secrets flux-git-deploy -o=jsonpath={.data.identity} | base64 -D

```

### Doc
```
curl elasticsearch-client.elasticsearch:9200

my-svc.my-namespace.svc.cluster.local
auto-generated-name.my-svc.my-namespace.svc.cluster.local
```

### helm
```
helm package .  
helm install -n demo --namespace dev .
helm upgrade demo .

helm delete demo
helm list
helm delete demo --purge

mkdir values manifests
helm fetch --repo https://helm.elastic.co --untar --untardir ./charts --version 7.0.0-alpha1 elasticsearch
cp ./charts/elasticsearch/values.yaml ./values/elasticsearch.yaml
helm template --values ./values/elasticsearch.yaml --output-dir ./manifests ./charts/elasticsearch


helm fetch --untar --untardir ./charts --version 3.3.6 stable/grafana
cp ./charts/grafana/values.yaml ./values/grafana.yaml
helm template --values ./values/grafana.yaml --output-dir ./manifests ./charts/grafana
```

## Troubleshooting
```
https://github.com/kubernetes/kubectl/issues/151
kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found -l <label>=<value> -n <namespace>
```