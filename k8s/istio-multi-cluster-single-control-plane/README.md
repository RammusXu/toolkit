https://cloud.google.com/solutions/building-multi-cluster-service-mesh-across-gke-clusters-using-istio-single-control-plane-architecture-single-vpc

## Create cluster


```bash
gcloud container clusters create control --zone us-west2-a --username "admin" \
    --machine-type "n1-standard-2" --image-type "COS" --disk-size "100" \
    --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only",\
https://www.googleapis.com/auth/logging.write,"https://www.googleapis.com/auth/monitoring",\
https://www.googleapis.com/auth/servicecontrol,"https://www.googleapis.com/auth/service.management.readonly",\
https://www.googleapis.com/auth/trace.append \
    --num-nodes "4" --network "default" --enable-cloud-logging --enable-cloud-monitoring --enable-ip-alias --async

gcloud container clusters create remote --zone us-central1-f --username "admin" \
    --machine-type "n1-standard-2" --image-type "COS" --disk-size "100" \
    --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only",\
https://www.googleapis.com/auth/logging.write,"https://www.googleapis.com/auth/monitoring",\
https://www.googleapis.com/auth/servicecontrol,"https://www.googleapis.com/auth/service.management.readonly",\
https://www.googleapis.com/auth/trace.append \
    --num-nodes "4" --network "default" --enable-cloud-logging --enable-cloud-monitoring --enable-ip-alias
```

## Setup kubeconfig
```bash
touch .kubecfg
export KUBECONFIG=.kubecfg
export PROJECT_ID=$(gcloud info --format='value(config.project)')
gcloud container clusters get-credentials control --zone us-west2-a --project ${PROJECT_ID}
gcloud container clusters get-credentials remote --zone us-central1-f --project ${PROJECT_ID}
kubectx control=gke_${PROJECT_ID}_us-west2-a_control
kubectx remote=gke_${PROJECT_ID}_us-central1-f_remote
kubectl create clusterrolebinding user-admin-binding \
    --clusterrole=cluster-admin --user=$(gcloud config get-value account) \
    --context control
kubectl create clusterrolebinding user-admin-binding \
    --clusterrole=cluster-admin --user=$(gcloud config get-value account) \
    --context remote
```

## Setup network
```bash
CONTROL_POD_CIDR=$(gcloud container clusters describe control --zone us-west2-a --format=json | jq -r '.clusterIpv4Cidr')
REMOTE_POD_CIDR=$(gcloud container clusters describe remote --zone us-central1-f --format=json | jq -r '.clusterIpv4Cidr')
ALL_CLUSTER_CIDRS=$CONTROL_POD_CIDR,$REMOTE_POD_CIDR
ALL_CLUSTER_NETTAGS=$(gcloud compute instances list --format=json | jq -r '.[].tags.items[0]' | uniq | awk 'BEGIN { ORS= ","} { print $1 }' | sed 's/,$/\n/')


gcloud compute firewall-rules create istio-multicluster-pods \
    --allow=tcp,udp,icmp,esp,ah,sctp \
    --direction=INGRESS \
    --priority=900 \
    --source-ranges="${ALL_CLUSTER_CIDRS}" \
    --target-tags="${ALL_CLUSTER_NETTAGS}" --quiet

```

## Install Istio
```bash
export ISTIO_VERSION=1.4.1
wget "https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-osx.tar.gz"
tar -xzf istio-${ISTIO_VERSION}-osx.tar.gz
rm -r istio-${ISTIO_VERSION}-osx.tar.gz

./istio-${ISTIO_VERSION}/bin/istioctl --context control manifest apply \
    --set values.prometheus.enabled=true \
    --set values.grafana.enabled=true \
    --set values.kiali.enabled=true \
    --set values.kiali.createDemoSecret=true

kubectl --context control get pods -n istio-system
```

## Install Istio in Remote
```bash
export PILOT_POD_IP=$(kubectl --context control -n istio-system get pod -l istio=pilot -o jsonpath='{.items[0].status.podIP}')
export POLICY_POD_IP=$(kubectl --context control -n istio-system get pod -l istio=mixer -o jsonpath='{.items[0].status.podIP}')
export TELEMETRY_POD_IP=$(kubectl --context control -n istio-system get pod -l istio-mixer-type=telemetry -o jsonpath='{.items[0].status.podIP}')
./istio-${ISTIO_VERSION}/bin/istioctl --context remote manifest apply \
    --set profile=remote \
    --set values.global.controlPlaneSecurityEnabled=false \
    --set values.global.remotePilotCreateSvcEndpoint=true \
    --set values.global.remotePilotAddress=${PILOT_POD_IP} \
    --set values.global.remotePolicyAddress=${POLICY_POD_IP} \
    --set values.global.remoteTelemetryAddress=${TELEMETRY_POD_IP} \
    --set gateways.enabled=false \
    --set autoInjection.enabled=true
kubectl --context remote -n istio-system get pods
```


## Get CA Token
```bash
kubectx remote
CLUSTER_NAME=$(kubectl config view --minify=true -o "jsonpath={.clusters[].name}")
CLUSTER_NAME="${CLUSTER_NAME##*_}"
export KUBECFG_FILE=${WORKDIR}/${CLUSTER_NAME}
SERVER=$(kubectl config view --minify=true -o "jsonpath={.clusters[].cluster.server}")
NAMESPACE=istio-system
SERVICE_ACCOUNT=istio-reader-service-account
SECRET_NAME=$(kubectl get sa ${SERVICE_ACCOUNT} -n ${NAMESPACE} -o jsonpath='{.secrets[].name}')
CA_DATA=$(kubectl get secret ${SECRET_NAME} -n ${NAMESPACE} -o "jsonpath={.data['ca\.crt']}")
TOKEN=$(kubectl get secret ${SECRET_NAME} -n ${NAMESPACE} -o "jsonpath={.data['token']}" | base64 --decode)

cat <<EOF > ${KUBECFG_FILE}
apiVersion: v1
clusters:
   - cluster:
       certificate-authority-data: ${CA_DATA}
       server: ${SERVER}
     name: ${CLUSTER_NAME}
contexts:
   - context:
       cluster: ${CLUSTER_NAME}
       user: ${CLUSTER_NAME}
     name: ${CLUSTER_NAME}
current-context: ${CLUSTER_NAME}
kind: Config
preferences: {}
users:
   - name: ${CLUSTER_NAME}
     user:
       token: ${TOKEN}
EOF

kubectx control
kubectl create secret generic ${CLUSTER_NAME} --from-file ${KUBECFG_FILE} -n ${NAMESPACE}
kubectl label secret ${CLUSTER_NAME} istio/multiCluster=true -n ${NAMESPACE}
```

## Deploy App
```
for cluster in $(kubectx);
do
    kubectx $cluster;
    kubectl create namespace hipster;
done
for cluster in $(kubectx);
do
    kubectx $cluster;
    kubectl label namespace hipster istio-injection=enabled
done

kubectl --context control -n hipster apply -f $WORKDIR/istio-single-controlplane/single-network/control
kubectl --context remote -n hipster apply -f $WORKDIR/istio-single-controlplane/single-network/remote

kubectl --context control -n hipster get pods
kubectl --context remote -n hipster get pods
```


```
kubectl --context control get -n istio-system service istio-ingressgateway -o json | jq -r '.status.loadBalancer.ingress[0].ip'
```
