
## Create service account and namespace
```
kubectl apply -f sa-ci.yaml
kubectl apply -f sa-cluster-admin.yaml
```

## Genereate Kubeconfig from Service Account
```
# Genereate kube config
./export-service-account.sh
```

## Debug
Use service account config
```
./debug-container.sh KUBE_CONFIG_FROM_SCRIPT_ABOVE

root@94d47211817d:/# kubectl get po
root@94d47211817d:/# kubectl apply -k test/base
root@94d47211817d:/# kubectl apply -k test/ns-ci
```

Update service account permissions
```
kubectl apply -f sa-ci.yaml
```

## Reference
Inspired by https://github.com/steebchen/kubectl
