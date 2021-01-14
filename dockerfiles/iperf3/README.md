## Docker CLI
```
docker build -t rammusxu/iperf3 .
docker push rammusxu/iperf3
```

## Example
```
iperf3 -c iperf3-udp.default.svc.cluster.local -u -i 1 -b 200M
iperf3 -c localhost -u -i 1 -b 200M

iperf3 -c iperf3-udp -u

iperf3 -c iperf3
```

## Known Issue
> Can't connect to a UDP Kubernetes service

iperf client need to initiate communication to server through TCP. Due to [1], it's not possible to connect through Service for now.

[1] https://github.com/kubernetes/kubernetes/issues/39188
