
## Add static manifest
install:
```
https://github.com/jetstack/cert-manager/releases/download/<version>/cert-manager.yaml
https://github.com/jetstack/cert-manager/releases/download/v0.9.1/cert-manager.yaml
```


## Add Ingress, Certificate, issuer
```
kustomize build overlays/production |kubectl apply -f -
```

## 踩雷
**secret** 一定要放在跟 cert-manager controller 同一個 namespace [Thank @pentago](https://github.com/jetstack/cert-manager/issues/263#issuecomment-412022694)
```
API_KEY=$(echo -n API_KEY_FROM_GLOBAL_KEY | base64 -)
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-key
  namespace: cert-manager
type: Opaque
data:
  api-key: ${API_KEY}
EOF
```
```
      dns01:
        # Adjust the configuration below according to your environment.
        # You can view more example configurations for different DNS01
        # providers in the documentation: https://docs.cert-manager.io/en/latest/tasks/issuers/setup-acme/dns01/index.html
        cloudflare:
          email: comte_ken@hotmail.com
          apiKeySecretRef:
            name: cloudflare-api-key
            key: api-key
```