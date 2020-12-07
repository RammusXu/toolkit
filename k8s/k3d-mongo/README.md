## Prerequisites
- k3d `v3.3.0`
- helm `v3.2.4`
- kubectl `v1.18.6`

## Create Cluster
```bash
k3d cluster create -p "8081:80@loadbalancer" mongo
```

### Demo Nginx
```bash
kubectl apply -f demo-nginx.yaml
curl localhost:8081
```

Clean
```bash
kubectl delete -f demo-nginx.yaml
```

##
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/mongodb
