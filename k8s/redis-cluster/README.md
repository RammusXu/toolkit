
## Environment
- bitnami/redis-cluster: 4.2.8
- k3s: v4.0.0

## Start
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm show values bitnami/redis-cluster --version 4.2.8
helm install redis-cluster bitnami/redis-cluster
```




## References
- https://redis.io/topics/cluster-spec
