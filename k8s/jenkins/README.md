安裝 Jenkins
```
helm install --name jenkins -f value.yaml stable/jenkins
```

更新 Jenkins
```
helm upgrade -f value.yaml jenkins stable/jenkins
```