## Create a static IP
```bash
gcloud compute addresses create my-ip1 --global
```

```bash
gcloud compute addresses list
NAME    ADDRESS/RANGE   TYPE      PURPOSE  NETWORK  REGION  SUBNET  STATUS
my-ip1  34.120.159.115  EXTERNAL                                    IN_USE
```

## Request a ssl cert,key
```bash
openssl genrsa -out my-ip1.key 2048
openssl req -new -key my-ip1.key -out my-ip1.csr -subj "/CN=34.120.159.115"
openssl x509 -req -days 365 -in my-ip1.csr -signkey my-ip1.key -out my-ip1.crt
```

## Import ssl cert to kubernetes secret
```bash
kubectl create secret tls my-ip1 \
  --cert my-ip1.crt --key my-ip1.key
```

## Reference
- https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-multi-ssl#secrets
