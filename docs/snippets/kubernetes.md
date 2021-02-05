---
description: Kubernetes cheatsheet, snippets, troubleshooting, tips, hints
---

Kubernetes cheatsheet, snippets, troubleshooting, tips, hints

## Table of Contents
- [Installation](#installation)
- [Volumes](#volumes)
- [StatefulSet](#statefulset)
- [Resources](#resources)
- [PVC](#pvc)
- [Affinity](#affinity)
- [Helm](#helm)

## Installation
### kubectl
ref: https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-with-curl-on-linux

Get stable version
```bash
curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
```

Install kubectl
```bash
VERSION=1.18.0
wget -q https://storage.googleapis.com/kubernetes-release/release/v$VERSION/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
```


## Volumes
```yaml
spec:
  template:
    spec:
      volumes:
      - name: plugindir
        emptyDir: {}

      containers:
      - name: mongos
        image: mongo:4.0.2
        volumeMounts:
        - name: mongo-socket
          mountPath: /tmp
```

```yaml
      - name: myconfigmap
        configMap:
          name: myconfigmap
      - name: mysecret
        secret:
          secretName: mysecret
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "ls /etc/config/" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: test-config
  restartPolicy: Never
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-config
data:
  domains.json: |
    [
      "google.com",
      "facebook.com",
      "amazon.com",
      "swag.live"
    ]

```

## StatefulSet
### volumeClaimTemplates
```yaml
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: ssd
      resources:
        requests:
          storage: 50Gi
```

## Resources
```yaml
        resources:
          limits:
            cpu: 1
            memory: 2G
          requests:
            cpu: 1
            memory: 2G
```

## PVC
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana
  labels:
    app: grafana
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  strategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: grafana
    spec:
      volumes:
        - name: storage
          persistentVolumeClaim:
            claimName: standard
          # emptyDir: {}
```

## Affinity
### Keywords
operators:
```yaml
In, NotIn, Exists, DoesNotExist, Gt, Lt
```

Scheduling:

- preferredDuringSchedulingIgnoredDuringExecution
- requiredDuringSchedulingIgnoredDuringExecution

### Pod 只能放在符合以下條件的 Node
```yaml
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: cloud.google.com/gke-preemptible
                operator: NotIn
                values:
                - "true"
              - key: sysctl/vm.max_map_count
                operator: In
                values:
                - "262144"
```

### 同一個 Node 不放一樣的 Pod
```yaml
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - topologyKey: "kubernetes.io/hostname"
              labelSelector:
                matchExpressions:
                  - key: "app"
                    operator: In
                    values:
                    - mongo-sh0
```


## env

### Pod env
```yaml
spec:
  containers:
  - name: envar-demo-container
    image: gcr.io/google-samples/node-hello:1.0
    env:
    - name: DEMO_GREETING
      value: "Hello from the environment"
    - name: DEMO_FAREWELL
      value: "Such a sweet sorrow"
```

### metadata.annotations
```yaml
      template:
        metadata:
          annotations:
            version: abc4444

        spec:
          containers:
          - name: cronjob
            env:
            - name: MY_VERSION
              valueFrom:
                fieldRef:
                  fieldPath: metadata.annotations['version']
```

### metadata.name metadata.namespace
ref: https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/#capabilities-of-the-downward-api
```yaml
          env:
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
```

### Secret

Encode/Decode
```bash
echo -n 'mykey' | base64
echo -n 'bXlrZXk=' | base64 -D
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  mykey: bXlrZXk=
```

```yaml
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
    - name: SECRET_USERNAME
      valueFrom:
        secretKeyRef:
          name: mysecret
          key: mykey
```

```
kubectl get secret tls -o "jsonpath={.data['tls\.key']}"
```

### envFrom
```yaml
spec:
  containers:
  - name: http
    image: asia.gcr.io/swag-2c052/swag:42ff66b1
    envFrom:
    - configMapRef:
      name: myconfigmap
    - secretRef:
      name: mysecret
```

### volumeMounts from configmap
=== "Pod"
    ```yaml
        spec:
          volumes:
          - name: config
            configMap:
              name: nginx-config

          containers:
          - name: echoserver
            image: gcr.io/google_containers/echoserver:1.10
            ports:
            - containerPort: 8080

            # nginx.conf override
            volumeMounts:
            - name: config
              subPath: nginx.conf
              mountPath: /etc/nginx/nginx.conf
              # mountPath: /usr/local/openresty/nginx/conf/nginx.conf
              readOnly: true
    ```

=== "ConfigMap"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: nginx-config
      namespace: ingress-nginx
    data:
      nginx.conf: |-
        events {
          worker_connections 1024;
        }
    ```

## Container Injection

### /etc/hosts and /etc/resolv.conf

ref:

- https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/#adding-additional-entries-with-hostaliases
- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-config

This will append hostname and overwrite /etc/resolv.conf

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: dnsmasq
  labels:
    name: dnsmasq
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        name: dnsmasq
    spec:
      hostAliases:
      - ip: "35.227.233.133"
        hostnames:
        - "swag.live"
      dnsPolicy: "None"
      dnsConfig:
        nameservers:
          - 1.1.1.1
          - 8.8.8.8
      containers:
      - image: rammusxu/dnsmasq
        name: dnsmasq
        resources:
          requests:
            cpu: "100m"
            memory: "100M"
        ports:
        - containerPort:  53
          name: dnsmasq
        - containerPort:  53
          protocol: UDP
          name: dnsmasq-udp
        imagePullPolicy: Always
```

### Container with commands
```yaml
      - name: imagemagick
        image: swaglive/imagemagick:lastest
        command: ["/bin/sh","-c"]
        args:
        - |
          magick montage -quality 90 -resize 211x292^ -gravity center -crop 211x292+0+0 -geometry +4+4 -tile 7x4 -background none +repage $(cat /tmp/covers.txt) /tmp/montage.jpg
        volumeMounts:
        - name: tmp
          mountPath: /tmp
```

## GKE
### Enable CDN in Service
```yaml
apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  namespace: default
  name: gclb-cdn-hpq
spec:
  cdn:
    enabled: true
    cachePolicy:
      includeHost: true
      includeProtocol: true
      includeQueryString: true
---
apiVersion: v1
kind: Service
metadata:
  namespace: default
  name: webapp
  annotations:
    beta.cloud.google.com/backend-config: '{"ports": {"http":"gclb-cdn-hpq"}}'
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
  - name: http
    port: 80
    targetPort: http
```

## Helm
### Install a 3rd party chart
ref: https://artifacthub.io/packages/helm/kvaps/nfs-server-provisioner?modal=install

```
helm repo add kvaps https://kvaps.github.io/charts
helm install nfs-server-provisioner kvaps/nfs-server-provisioner --version 1.2.1
helm show values kvaps/nfs-server-provisioner --version 1.2.1
helm show values kvaps/nfs-server-provisioner --version 1.2.1 > value.yaml
```

### Uninstall
```bash
helm uninstall nfs-server-provisioner -n nfs-server
```

### Render a chart to a yaml file
```
helm template nfs-server-provisioner kvaps/nfs-server-provisioner \
  --version 1.2.1 \
  -f values.yaml \
  -n nfs-server > nfs-server.yaml
```

## Frequent Commands
### Gracefully rolling restart deployment.
```bash
kubectl rollout restart deployment/my-sites --namespace=default
```

### Wait another deployment restart then do something
```
kubectl rollout restart deployment/storage --namespace=google-cloud
kubectl rollout status deployment/storage  --namespace=google-cloud
kubectl rollout restart deployment/sites --namespace=default
kubectl rollout status deployment/sites --namespace=default
```

log:
```bash
deployment.apps/storage restarted
Waiting for deployment "storage" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "storage" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "storage" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "storage" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "storage" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "storage" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "storage" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "storage" rollout to finish: 1 old replicas are pending termination...
deployment "storage" successfully rolled out
deployment.apps/sites restarted
Waiting for deployment "sites" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "sites" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "sites" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "sites" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "sites" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "sites" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "sites" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "sites" rollout to finish: 1 old replicas are pending termination...
deployment "sites" successfully rolled out
```

### Create new job from cronjob
```bash
kubectl create job --from=cronjob/my-daily-task manual-20200101
```

## Reference
- [feiskyer Handbook](https://kubernetes.feisky.xyz/)
- [feiskyer Examples](https://github.com/feiskyer/kubernetes-handbook/tree/master/examples)
