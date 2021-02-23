helm repo add elastic https://helm.elastic.co

helm show values elastic/elasticsearch > elasticsearch/values.yaml
helm install elasticsearch elastic/elasticsearch -f elasticsearch/values.yaml

helm show values elastic/kibana > kibana/values.yaml
helm install kibana elastic/kibana -f kibana/values.yaml

helm show values elastic/apm-server  > apm-server/values.yaml
helm install apm-server elastic/apm-server -f apm-server/values.yaml
helm upgrade apm-server elastic/apm-server -f apm-server/values.yaml


## Reference
- https://www.elastic.co/guide/en/apm/agent/rum-js/current/intro.html
