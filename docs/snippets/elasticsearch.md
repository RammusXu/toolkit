## Status


```
curl elasticsearch-client.elasticsearch:9200

URL="localhost:9200"
URL="elasticsearch-client:9200"
curl -X GET $URL/
curl -X GET "$URL/_cat/health?v"
curl -X GET "$URL/_cat/nodes?v"
curl -X GET "$URL/_cat/indices?v"
curl -X GET "$URL/_cat/allocation?v"
curl -X GET "$URL/_cat/shards?v"

curl -X GET "$URL/_all/_settings?pretty"

curl -X GET http://$URL/_nodes/jvm?pretty
curl -X GET http://$URL/_nodes/process?pretty


curl -X GET "$URL/_nodes/stats?pretty"
curl -X GET "$URL/_nodes/nodeId1,nodeId2/stats"
curl -X GET "$URL/_nodes/elasticsearch-data-2/stats"


curl -X GET $URL/_cluster/health?pretty
curl -X GET $URL/_cluster/settings?pretty

# Check jvm
curl -X GET "$URL/_nodes/stats/jvm?pretty"
curl -X GET "$URL/_nodes/stats/jvm?pretty" |grep heap_used_in_bytes

## Auth
GET /_security/_authenticate


```

## Index, Aliases
```
# PUT /<my-index-{now/d}-000001>
PUT /%3Cmy-index-%7Bnow%2Fd%7D-000001%3E
{
  "aliases": {
    "my-index": {}
  }
}


GET _cat/aliases?v=true
```

## CRUD
```
URL="elasticsearch-client:9200"
curl -X PUT "$URL/customer?pretty"
curl -X PUT "$URL/customer/_doc/1?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "John Doe"
}
'
curl -X GET "$URL/customer/_doc/1?pretty"


curl -X GET "$URL/_cat/indices?v"
curl -X DELETE $URL/
```

## Plugin
```
/bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.0.0/elasticsearch-analysis-ik-7.0.0.zip


curl -X GET "$URL/_cat/plugins?v&s=component&h=name,component,version,description"
curl -X GET "$URL/_cat/plugins"
```


## Benchmark
```
esrally --track=geonames --pipeline=benchmark-only --target-hosts=elasticsearch-client:9200
esrally --track=pmc --pipeline=benchmark-only --target-hosts=elasticsearch-client:9200
```
