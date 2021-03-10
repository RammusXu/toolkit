# GCP
## GKE(Google Kubernetes Engine)

```bash
gcloud components update
gcloud container clusters list
gcloud container clusters get-credentials staging --region=asia-east1

kubectl config get-contexts
kubectl config use-context production
kubectl config set-context --current --namespace=dev

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user user-account

gcloud container operations list
```

Create a regional GKE
```bash
CLUSTER_NAME=old
REGION=asia-east2

# Choose a static version or a release channel
CLUSTER_VERSION="--cluster-version=1.14.10-gke.50"
# CLUSTER_VERSION="--release-channel regular"

gcloud beta container clusters create ${CLUSTER_NAME} --region ${REGION} \
    ${CLUSTER_VERSION} \
    --machine-type "n2-highcpu-2" --image-type "COS" --disk-size "100" --disk-type "pd-ssd" \
    --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only",\
"https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring",\
"https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly",\
"https://www.googleapis.com/auth/trace.append","https://www.googleapis.com/auth/cloud-platform" \
    --num-nodes "1" --preemptible --enable-autoscaling --min-nodes "1" --max-nodes "3" \
    --enable-stackdriver-kubernetes --enable-ip-alias --async
```

### Create static ip address
ref: https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip
```bash
gcloud compute addresses create dnsmasq-ip-2 --region asia-east1
gcloud compute addresses describe dnsmasq-ip-2 --region asia-east1
```

### Use google service account key as Kubernetes secret
Import google service account key to Kubernetes secret
```bash
kubectl create secret generic my-sa-key --from-file=key.json=my-sa-key.json
```

```yaml
    spec:
      volumes:
      - name: google-cloud-key
        secret:
          secretName: my-sa-key
      containers:
      - name: subscriber
        image: gcr.io/google-samples/pubsub-sample:v1
        volumeMounts:
        - name: google-cloud-key
          mountPath: /var/secrets/google
        env:
        - name: GOOGLE_APPLICATION_CREDENTIALS
          value: /var/secrets/google/key.json
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

### gsutil - Verify a google service account with docker and a environment variable
```bash
docker run -it --rm --entrypoint bash gcr.io/cloud-builders/gsutil
sa='{key.json,....}'
gcloud auth activate-service-account --key-file=<(echo $sa)
gsutil ls gs://rammus.dev
```

## GCR(Container Registry)
### Use service account json to login GCR
```
gcloud auth activate-service-account --key-file=gcloud.json

# https://cloud.google.com/container-registry/docs/advanced-authentication
cat gcloud.json | docker login -u _json_key --password-stdin https://asia.gcr.io
```

## Projects
### Switch projects
```bash
gcloud projects list
gcloud config set project my-project
```

### Use GCP service account
```bash
gcloud auth activate-service-account sa-devops@rammus-xu.iam.gserviceaccount.com --key-file=$GOOGLE_APPLICATION_CREDENTIALS
```
