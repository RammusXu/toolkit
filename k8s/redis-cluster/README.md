## Environment
- bitnami/redis-cluster: 4.3.3
- k3s: v4.0.0
- gke: v1.18.12-gke.1210

## Start
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm update

helm show values bitnami/redis-cluster --version 4.3.3 > values.yaml
helm install redis-cluster bitnami/redis-cluster --version 4.3.3 -f values.yaml,values-overwrite.yaml -n default --set cluster.init=true
helm upgrade redis-cluster bitnami/redis-cluster -f values.yaml,values-overwrite.yaml -n default --set cluster.init=true
```

## Create template
```bash
helm template redis-cluster bitnami/redis-cluster --version 4.3.3 -f values.yaml,values-overwrite.yaml -n default > template.yaml
```

## Clean
```
helm uninstall redis-cluster
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

Get all service IP and create redis cluster
```
SERVICE_NAMES="redis-cluster-0.default redis-cluster-1.default redis-cluster-2.default redis-cluster-3.default redis-cluster-4.default redis-cluster-5.default"
REDIS_NODES=$(getent hosts ${SERVICE_NAMES} | awk 'BEGIN{ORS=" ";} {print $1":6379"}')

redis-cli --cluster create ${REDIS_NODES} --cluster-replicas 1 --cluster-yes
```

## Configs

```redis.conf
cluster-config-file /bitnami/redis/data/nodes.conf

dir /bitnami/redis/data
```

config path: `/opt/bitnami/redis/etc/redis.conf`

endpoint:
- `cache-redis-cluster`
- `cache-redis-cluster-0.cache-redis-cluster-headless cache-redis-cluster-1.cache-redis-cluster-headless cache-redis-cluster-2.cache-redis-cluster-headless`

## What I see
> cluster-allow-reads-when-down no

A shard down will cause whole cluster can't read/write.

> Don't gurantee which are masters

And won't elect new masters.

> --set persistence.enabled=false

Will cause redis can't failover. It relates to `cluster-config-file /bitnami/redis/data/nodes.conf`. Redis need to keep cluster informations.

> bitnami/redis-cluster image will update redis node.conf when start up

redis-cli doesn't support this part.

## References
- https://redis.io/topics/cluster-spec
- https://github.com/bitnami/charts/tree/master/bitnami/redis-cluster
- https://github.com/bitnami/bitnami-docker-redis-cluster
