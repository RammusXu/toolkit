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

## GCS(Google Cloud Stroge)
### Public to internet
Edit bucket permissions -> Add member -> allUsers: Storage Object Viewer

### Test service accout permission
```bash
SA=$(cat service-account.json | base64)
docker run -it --rm --entrypoint bash gcr.io/cloud-builders/gsutil -c "
        echo $SA | base64 -d > sa.json
        gcloud auth activate-service-account --key-file=sa.json
        bash
    "
```

```bash
gsutil ls gs://<replace_this_with_your_bucket>
```