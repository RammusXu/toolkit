kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml

kubectl create namespace cert-manager



# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io && helm repo update

helm fetch jetstack/cert-manager --untar
helm template \
  --name cert-manager \
  --namespace cert-manager \
  cert-manager > 02-cert-manager.yaml
