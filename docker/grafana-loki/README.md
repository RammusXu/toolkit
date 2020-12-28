```bash
gist=https://raw.githubusercontent.com/RammusXu/toolkit/master/docker/grafana-prometheus/docker-compose.yaml
curl -sLO $gist
```

## Steps
```bash
wget https://raw.githubusercontent.com/grafana/loki/master/production/docker-compose.yaml
```

```bash
docker-compose up -d
```

Open localhost:3000

Default Grafana:
```
account: admin
password: admin
```

Import Dashboard: dashboard.json

## Test command
```bash
quantile_over_time(
  0.5,
  {job="benchmark"} |= "target" | logfmt | unwrap speedDownload [1m]
) by (target)

curl -G -s  "http://localhost:3100/loki/api/v1/query" --data-urlencode 'query={job="benchmark"}' |jq
```

## Backup and Restore
```bash
docker exec -it grafana-loki_loki_1 sh -c "
    cd /home/loki
    tar -czvf loki.tar.gz /loki/
"

docker cp grafana-loki_loki_1:/home/loki/loki.tar.gz .
scp ubuntu@x.x.x.x:~/loki.tar.gz .

tar -xzvf loki.tar.gz
```
