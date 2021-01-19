## Create certficate

```bash
docker run -it --rm -v $PWD/cert2:/cert alpine sh -c '
  apk add openssl
  cd /cert
  DOMAIN=rammus.tw
  openssl req -x509 -sha256 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 3650 -nodes -subj "/CN=${DOMAIN}"

  openssl req -new -newkey rsa:4096 -keyout server.key -out server.csr -nodes -subj "/CN=${DOMAIN}"
  openssl x509 -req -sha256 -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

  openssl req -new -newkey rsa:4096 -keyout client.key -out client.csr -nodes -subj "/CN=${DOMAIN}"
  openssl x509 -req -sha256 -days 3650 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 02 -out client.crt
'
```

or

```bash
docker run -it --rm -v $PWD/cert2:/home/step/cert smallstep/step-cli bash -c '
  DOMAIN=rammus.tw
  step certificate create ${DOMAIN} cert/ca.crt cert/ca.key \
    --profile root-ca --no-password --insecure
  step certificate create ${DOMAIN} cert/server.crt cert/server.key \
    --profile leaf --no-password --insecure \
    --ca cert/ca.crt --ca-key cert/ca.key
'
```

## Test

```bash
curl -k --cert cert/client.crt --key cert/client.key https://localhost:8443
curl -k --cacert cert/ca.crt --cert cert/server.crt --key cert/server.key https://localhost:8443

curl -k --cert cert/ca.crt --key cert/ca.key https://localhost:8443
curl -k --cacert cert/ca.crt https://localhost:8443

curl -k --cert cert2/server.crt --key cert2/server.key https://localhost:8443


curl -k --cert client.crt --key client.key https://server:443
curl localhost:8001
```

## Reference
- https://docs.nginx.com/nginx/admin-guide/security-controls/securing-http-traffic-upstream/
- https://smallstep.com/hello-mtls/doc/client/nginx-proxy
- https://zhuanlan.zhihu.com/p/140752944
- https://www.nginx.com/blog/http2-module-nginx/#keepalive


## k8s

- https://cert-manager.io/docs/configuration/selfsigned/
```bash
kubectl apply -f k8s/cert.yaml

kubectl get secrets aliyun-edge-tls -o jsonpath='{.data.tls\.crt}' | base64 -D > tls.crt
kubectl get secrets aliyun-edge-tls -o jsonpath='{.data.tls\.key}' | base64 -D > tls.key

kubectl create secret tls aliyun-edge-tls --cert=tls.crt --key=tls.key -n web
```

```bash
curl -k --cert tls.crt --key tls.key https://localhost:443
```
