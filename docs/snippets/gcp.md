# GCP
## k8s

```bash
gcloud components update
gcloud container clusters list
gcloud container clusters get-credentials staging --region=asia-east1

kubectl config get-contexts
kubectl config use-context production
kubectl config set-context --current --namespace=dev
```

### Create static ip address
ref: https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip
```bash
gcloud compute addresses create dnsmasq-ip-2 --region asia-east1
gcloud compute addresses describe dnsmasq-ip-2 --region asia-east1
```