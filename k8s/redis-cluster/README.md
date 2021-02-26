## Environment
- bitnami/redis-cluster: 4.3.3
- k3s: v4.0.0
- gke: v1.18.12-gke.1210
- ## Start
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm update

helm show values bitnami/redis-cluster --version 4.3.3 > values.yaml
helm install redis-cluster bitnami/redis-cluster --version 4.3.3 -f values.yaml,values-overwrite.yaml -n default
helm upgrade redis-cluster bitnami/redis-cluster -f values.yaml,values-overwrite.yaml -n default
```

## Create template
```bash
helm template redis-cluster bitnami/redis-cluster --version 4.3.3 -f values.yaml,values-overwrite.yaml -n default > template.yaml
```

## Commands
```bash
redis-cli -c -u redis://redis-cluster
kubectl exec redis-cluster-2 -c redis-cluster -- redis-cli cluster nodes
```

```
redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 \
127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 \
--cluster-replicas 1
```


## Configs
```yaml
cluster:
  configmap: |-
    maxmemory-policy allkeys-lfu
    maxmemory 4g

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: cloud.google.com/gke-preemptible
            operator: NotIn
            values:
            - "true"

    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - topologyKey: "kubernetes.io/hostname"
          labelSelector:
            matchExpressions:
              - key: "app.kubernetes.io/name"
                operator: In
                values:
                - redis-cluster

usePassword: false

persistence:
  storageClass: ssd
  accessModes:
    - ReadWriteOnce
  size: 64Gi

metrics:
  enabled: true

sysctlImage:
  enabled: true

```

```redis.conf
cluster-config-file /bitnami/redis/data/nodes.conf

dir /bitnami/redis/data
```

config path: /opt/bitnami/redis/etc/redis.conf


## What I see
> cluster-allow-reads-when-down no
A master down will cause whole cluster can't read/write

> Don't gurantee which are masters


## References
- https://redis.io/topics/cluster-spec
