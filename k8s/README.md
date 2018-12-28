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
```

## cert-manager
```
helm install \
    --name cert-manager \
    --namespace kube-system \
    --set ingressShim.defaultIssuerName=issuer-prod \
    --set ingressShim.defaultIssuerKind=ClusterIssuer \
    stable/cert-manager
```