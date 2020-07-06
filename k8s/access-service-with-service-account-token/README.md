Get service account token
```bash
NAMESPACE=default
SERVICE_ACCOUNT_NAME=service-proxy
APISERVER=$(kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " ")
SECRET_NAME=$(kubectl get secrets -n $NAMESPACE | grep ^$SERVICE_ACCOUNT_NAME | cut -f1 -d ' ')
TOKEN=$(kubectl describe secret $SECRET_NAME -n $NAMESPACE | grep -E '^token' | cut -f2 -d':' | tr -d " ")
```


```bash
curl $APISERVER/api/v1/namespaces/default/services/httpbin:http/proxy/get --header "Authorization: Bearer $TOKEN" --insecure

{
  "args": {},
  "headers": {
    "Accept": "*/*",
    "Accept-Encoding": "gzip",
    "Host": "35.10.10.10",
    "User-Agent": "curl/7.54.0",
    "X-Forwarded-Uri": "/api/v1/namespaces/default/services/httpbin:http/proxy/get"
  },
  "origin": "59.10.10.10",
  "url": "http://35.10.10.10/get"
}
```
