## Create k8s
ref: https://github.com/GoogleCloudPlatform/gke-networking-recipes/blob/master/cluster-setup.md

```bash
export PROJECT=$(gcloud config get-value project)

## Enable googleapis
gcloud services enable \
  container.googleapis.com \
  gkehub.googleapis.com \
  anthos.googleapis.com \
  multiclusteringress.googleapis.com

## Create kubernetes clusters
gcloud container clusters create gke-us \
  --zone us-west1-a \
  --enable-ip-alias \
  --release-channel rapid

gcloud container clusters create gke-asia \
  --zone asia-east1-b \
  --enable-ip-alias \
  --release-channel rapid

## Rename
kubectl config rename-context gke_${PROJECT}_us-west1-a_gke-us gke-us
kubectl config rename-context gke_${PROJECT}_asia-east1-b_gke-asia gke-asia
```

## Create service account
`gcloud container hub memberships register` need service account.

```bash
MEMBERSHIP_NAME=mci
SERVICE_ACCOUNT_NAME=mci-sa
HUB_PROJECT_ID=swag-rammus-xu-2

gcloud services enable \
 --project=${HUB_PROJECT_ID} \
 container.googleapis.com \
 gkeconnect.googleapis.com \
 gkehub.googleapis.com \
 cloudresourcemanager.googleapis.com

gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} --project=${HUB_PROJECT_ID}

gcloud projects add-iam-policy-binding ${HUB_PROJECT_ID} \
 --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${HUB_PROJECT_ID}.iam.gserviceaccount.com" \
 --role="roles/gkehub.connect"

gcloud iam service-accounts keys create mci-sa.json \
  --iam-account=${SERVICE_ACCOUNT_NAME}@${HUB_PROJECT_ID}.iam.gserviceaccount.com \
  --project=${HUB_PROJECT_ID}
```

## Register cluster memberships

```bash
gcloud container clusters list --uri

gcloud container hub memberships register gke-us \
    --gke-uri=https://container.googleapis.com/v1/projects/swag-rammus-xu-2/zones/us-west1-a/clusters/gke-us \
    --service-account-key-file=mci-sa.json


gcloud container hub memberships register gke-asia \
    --gke-uri=https://container.googleapis.com/v1/projects/swag-rammus-xu-2/zones/asia-east1-b/clusters/gke-asia \
    --service-account-key-file=mci-sa.json

gcloud container hub memberships list

gcloud alpha container hub ingress enable \
  --config-membership=projects/${HUB_PROJECT_ID}/locations/global/memberships/gke-asia

```

Verify hub status
```bash
> gcloud alpha container hub ingress describe

createTime: '2021-03-26T09:36:27.265220552Z'
featureState:
  details:
    code: OK
    description: Ready to use
  detailsByMembership:
    projects/926709855108/locations/global/memberships/gke-asia:
      code: OK
    projects/926709855108/locations/global/memberships/gke-us:
      code: OK
  lifecycleState: ENABLED
multiclusteringressFeatureSpec:
  configMembership: projects/swag-rammus-xu-2/locations/global/memberships/gke-asia
name: projects/swag-rammus-xu-2/locations/global/features/multiclusteringress
updateTime: '2021-03-26T09:36:28.368252527Z'
```


## Create multi cluster ingress/service
ref: https://github.com/GoogleCloudPlatform/gke-networking-recipes/tree/master/multi-cluster-ingress/multi-cluster-ingress-basic

```bash
app_yaml=https://raw.githubusercontent.com/GoogleCloudPlatform/gke-networking-recipes/master/multi-cluster-ingress/multi-cluster-ingress-basic/app.yaml
ingress_yaml=https://raw.githubusercontent.com/GoogleCloudPlatform/gke-networking-recipes/master/multi-cluster-ingress/multi-cluster-ingress-basic/ingress.yaml

kubectl --context gke-asia apply -f $ingress_yaml

kubectl --context gke-asia apply -f $app_yaml
kubectl --context gke-us apply -f $app_yaml

```

Verify connections
```bash
export MCI_ENDPOINT=$(kubectl --context=gke-asia get mci -n multi-cluster-demo -o yaml | grep "VIP" | awk 'END{ print $2}')
while true; do curl -s -H "host: foo.example.com" ${MCI_ENDPOINT} | jq -c '{cluster: .cluster_name, pod: .pod_name}'; sleep 2; done

```

## Reference
- https://www.getambassador.io/learn/multi-cluster-kubernetes/
- https://github.com/GoogleCloudPlatform/gke-networking-recipes/blob/master/cluster-setup.md
- https://github.com/GoogleCloudPlatform/gke-networking-recipes/tree/master/multi-cluster-ingress/multi-cluster-ingress-basic
