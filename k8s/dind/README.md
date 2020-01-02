## DinD on Kubernetes
This is example of running dind (docker in docker daemon) with a test container on kubernetes

## Deploy
```
kubectl apply -f deployment.yaml
kubectl apply -f deployment-no-tls.yaml
```

## Cleanup
```
kubectl delete -f deployment.yaml
kubectl delete -f deployment-no-tls.yaml
```