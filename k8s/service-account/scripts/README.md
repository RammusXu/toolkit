
## Genereate Kubeconfig from Service Account
```
./scripts/export-service-account.sh ops:ops
```

## Deploy resources with service account token
```
export KUBECONFIG=/tmp/kubeconfig
kubectl ...
```