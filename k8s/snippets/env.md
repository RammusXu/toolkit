
## metadata.annotations
```
      template:
        metadata:
          annotations:
            baseKey: appqqO48ONr9XON9p
            tableId: tblCrSq37JnIMDkmE
            
        spec:
          containers:
          - name: cronjob
            env:
            - name: MY_VERSION
              valueFrom:
                fieldRef:
                  fieldPath: metadata.annotations['version']
```

## Secret
```
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  mykey: bXlrZXk=
```

```
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

Encode/Decode
```
echo -n 'mykey' | base64
echo -n 'bXlrZXk=' | base64 -D
```
