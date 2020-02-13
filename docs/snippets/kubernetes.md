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
```yaml
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

## env

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

## Container with commands
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