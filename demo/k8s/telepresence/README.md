## Install
```
brew cask install osxfuse
brew install datawire/blackbird/telepresence
```

## Run
```
kubectl apply -f telepresence.yaml
sudo telepresence --deployment telepresence-rammus --expose 5000:80 --namespace dev --run sh -c "FLASK_DEBUG=1 flask run"
```