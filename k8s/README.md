# Setup

```
kubectl apply -f setup
```

## Helm
```
helm init --service-account tiller
```

## Dashboard
```
helm install stable/kubernetes-dashboard --name kubernetes-dashboard --namespace kube-system --set rbac.clusterAdminRole=true
```

URL https://api.stage.k8s.feversocial.com/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview

取得 token
```
kubectl config view
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

## cert-manager
```
helm install \
    --name cert-manager \
    --namespace kube-system \
    --set ingressShim.defaultIssuerName=issuer-prod \
    --set ingressShim.defaultIssuerKind=ClusterIssuer \
    stable/cert-manager
```

# Cheat sheet

```
kubectl create secret docker-registry gitlab-auth \
  --docker-server=https://registry.gitlab.com \
  --docker-username=xxxxxxxx \
  --docker-password=xxxxxxxx \
  --docker-email=xxxxxxxx@gmail.com
```

## Commands

### kops
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
kops edit cluster
  additionalPolicies:
    node: |
      [
        {
            "Sid": "Stmt1505293246000",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData"
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
kubectl cluster-info
kubectl config set-context $(kubectl config current-context) --namespace=kube-system
```

### helm
```
helm package .  
helm install -n demo --namespace dev .
helm upgrade demo .
```