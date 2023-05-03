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

## Best Practice
### Index template for log index
```
{
  "index_patterns": [
    "rammus-log-*"
  ],
  "template": {
    "settings": {
      "index": {
        "lifecycle": {
          "name": "rammus-log",
          "rollover_alias": "rammus-log"
        },
        "routing": {
          "allocation": {
            "total_shards_per_node": "1"
          }
        },
        "codec": "best_compression",
        "refresh_interval": "3m",
        "number_of_shards": "6",
        "translog": {
          "sync_interval": "15s",
          "durability": "async"
        },
        "number_of_replicas": "0",
        "write": {
          "wait_for_active_shards": "0"
        }
      }
    },
    "mappings": {
      "dynamic_templates": [
        {
          "strings": {
            "mapping": {
              "type": "keyword"
            },
            "match_mapping_type": "string"
          }
        }
      ],
      "properties": {
        "timestamp": {
          "format": "yyyy.MM.dd HH:mm:ss.SSS||yyyy.MM.dd HH:mm:ss||yyyy-MM-dd HH:mm:ss.SSS||yyyy-MM-dd HH:mm:ss||yyyy.MM.dd||yyyy-MM-dd||yyyy-MM||yyyy.MM||epoch_millis||strict_date_optional_time",
          "type": "date"
        }
      }
    }
  },
  "priority": 500
}

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

## Backgroud tasks
```
GET _tasks?detailed=true&actions=*reindex
GET _cat/thread_pool/snapshot?v
GET _cluster/allocation/explain
POST /_cluster/reroute?retry_failed
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

## Troubles

### Wildcard expressions or all indices are not allowed


```
DELETE partial-*-2022.06*
```

Need to disable this config
```
PUT _cluster/settings
{
  "transient": {
    "action.destructive_requires_name": false
  }
}
```

enable config after deletey
```
PUT _cluster/settings
{
  "transient": {
    "action.destructive_requires_name": null
  }
}
```


### EC2 debug
```bash
systemctl restart elasticsearch
systemctl cat elasticsearch
journalctl -u elasticsearch

# Enable start-on-boot
systemctl enable elasticsearch
systemctl status elasticsearch
```
