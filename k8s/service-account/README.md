## Validate Kubernetes Config
```
docker run -it -v $PWD/kubernetes:/kubernetes garethr/kubeval -d kubernetes --strict
```

## Genereate Kubeconfig from Service Account
```
# Genereate kube config
./export-service-account.sh https://your_cluster_ip
```

## Debug
Use service account config
```
./debug-container.sh KUBE_CONFIG_FROM_SCRIPT_ABOVE

kubectl apply -k test/base
kubectl apply -k test/ns-ci
```

Update service account permissions
```
kubectl apply -f sa-ci.yaml
```

## Reference
Inspired by https://github.com/steebchen/kubectl
