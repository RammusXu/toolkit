
## Environment
- bitnami/redis-cluster: 4.2.8
- k3s: v4.0.0

## Start
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami

CHART_VERSION=4.3.3
helm show values bitnami/redis-cluster --version ${CHART_VERSION} > values.yaml
helm install redis-cluster bitnami/redis-cluster --version ${CHART_VERSION} -f values.yaml -n default
helm upgrade redis-cluster bitnami/redis-cluster -f values.yaml -n default
```


## Commands
```bash
redis-cli -c -u redis://redis-cluster
```


## Configs
```yaml
cluster:
  nodes: 3

  configmap: |-
    maxmemory-policy volatile-lru

    appendonly yes
    aof-use-rdb-preamble yes
    auto-aof-rewrite-percentage 50
    auto-aof-rewrite-min-size 64mb

    client-output-buffer-limit pubsub 256mb 256mb 3600

    lazyfree-lazy-eviction yes
    lazyfree-lazy-expire yes
    lazyfree-lazy-server-del yes
    slave-lazy-flush yes


usePassword: false

persistence:
  storageClass:
  accessModes:
    - ReadWriteOnce
  size: 8Gi


metrics:
  enabled: true

sysctlImage:
  enabled: true

```

config path: /opt/bitnami/redis/etc/redis.conf

## References
- https://redis.io/topics/cluster-spec
