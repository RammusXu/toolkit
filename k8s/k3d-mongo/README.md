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

## Install mongo

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mongo bitnami/mongodb
```



Testing
```
kubectl port-forward --namespace default svc/mongo-mongodb 27017:27017
```

```
export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace default mongo-mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)
mongo admin  --authenticationDatabase admin -u root -p $MONGODB_ROOT_PASSWORD

```

## Reference
- https://github.com/bitnami/charts/tree/master/bitnami/mongodb
- https://github.com/percona/mongodb_exporter
- https://github.com/percona/grafana-dashboards
- https://github.com/prometheus-community/helm-charts/tree/main/charts
