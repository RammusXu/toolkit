
## Environment
- bitnami/redis-cluster: 4.2.8
- k3s: v4.0.0

## Start
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm show values bitnami/redis-cluster --version 4.3.3 > values.yaml
helm install redis-cluster bitnami/redis-cluster -f values.yaml
```


## Commands
```bash
redis-cli -c -u redis://redis-cluster
```


## Configs
```yaml
  podAntiAffinityPreset: soft

  nodes: 3
  replicas: 1


usePassword: false
password: ""

  storageClass:
  accessModes:
    - ReadWriteOnce
  size: 8Gi

```

## References
- https://redis.io/topics/cluster-spec
