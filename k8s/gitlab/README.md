
## gitlab-runner
https://docs.gitlab.com/ee/install/kubernetes/gitlab_runner_chart.html
```
helm repo add gitlab https://charts.gitlab.io
helm install --namespace default \
    --name gitlab-runner \
    -f value.yaml gitlab/gitlab-runner

helm upgrade  \
    -f value.yaml \
    gitlab-runner gitlab/gitlab-runner
```