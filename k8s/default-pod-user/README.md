## Create
```
kubectl apply -f .
```

## Demo
```
Rammus:~ rammus$ kubectl logs sysctl-vm-s8m79 -c id --namespace=kube-system
uid=0(root) gid=0(root) groups=10(wheel)
```

## Clean
```
kubectl delete -f .
```