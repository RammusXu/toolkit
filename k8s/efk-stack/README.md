## Elasticsearch
- headless service
- 3 pods: 

Test it locally:
```
kubectl port-forward es-cluster-0 9200:9200 --namespace=elastic
curl http://localhost:9200/_cluster/state?pretty
```

## Kibana

Test it locally:
```
kubectl port-forward service/kibana 5601:5601 --namespace=elastic
open -a "Google Chrome" "http://localhost:5601"
```

## Reference
- https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes