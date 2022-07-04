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


curl -X PUT "$URL/_cluster/settings" -u "elastic:xxx" \
  -H 'Content-Type: application/json; charset=utf-8' \
  --data-binary @- << EOF
{
  "persistent": {
    "cluster.routing.allocation.enable": "primaries"
  }
}
EOF
```

## Dynamic Mapping

https://www.elastic.co/guide/en/elasticsearch/reference/current/dynamic-templates.html
```
  "http_status": {
    "type": "text",
    "fields": {
      "keyword": {
        "type": "keyword",
        "ignore_above": 256
      }
    }
  },
```

```
{
  "mappings": {
    "dynamic_templates": [
      {
        "strings_as_keywords": {
          "match_mapping_type": "string",
          "mapping": {
            "type": "keyword"
            "ignore_above": 256
          }
        }
      }
    ]
  }
}

{
  "mappings": {
    "dynamic_templates": [
      {
        "longs_as_strings": {
          "match_mapping_type": "string",
          "match":   "long_*",
          "unmatch": "*_text",
          "mapping": {
            "type": "long"
          }
        }
      }
    ]
  }
}

```

## Plugin
```
/bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.0.0/elasticsearch-analysis-ik-7.0.0.zip


curl -X GET "$URL/_cat/plugins?v&s=component&h=name,component,version,description"
curl -X GET "$URL/_cat/plugins"
```


## Benchmark - esrally

https://esrally.readthedocs.io/en/stable/quickstart.html

```bash
docker run -d --name esrally --entrypoint tail -v $PWD/ral:/ral elastic/rally -f /dev/null
docker exec -it esrally bash

esrally list tracks
esrally info --track=http_logs

# List and compare
esrally list races
esrally compare \
    --baseline=04714e80-9578-4cda-9a79-6d5ffff2c557 \
    --contender=daa58545-7e0f-4ae1-b47f-c5b7511c69ce
```

tl;dr
```bash
esrally race --pipeline=benchmark-only \
    --track=http_logs --challenge=append-no-conflicts-index-only \
    --report-file=~/benchmark/eck-$(date -Iminutes) \
    --target-hosts="http://localhost:9200" \
    --client-options="basic_auth_user:'elastic',basic_auth_password:'0MVVQ9B1Fq0'"
```

```bash
# --test-mode: run it as fast as possible for testing a track
# --pipeline=benchmark-only: docker needs this

esrally race --track=http_logs --test-mode \
    --pipeline=benchmark-only \
    --target-hosts=192.168.0.1:9200 \
    --track-params="ingest_percentage:1" \
    --client-options="basic_auth_user:'elastic',basic_auth_password:'xxxxxxxxxxxx'"

esrally race --track=http_logs \
    --pipeline=benchmark-only \
    --target-hosts=192.168.0.1:9200 \
    --track-params="ingest_percentage:1" \
    --client-options="basic_auth_user:'elastic',basic_auth_password:'xxxxxxxxxxxx'"


    --include-tasks="index,delete-index,create-index,index-append" \
    --include-tasks="index,term" \

```
