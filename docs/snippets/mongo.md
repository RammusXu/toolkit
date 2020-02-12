
## Cluster setup
```
rs.initiate(
  {
    _id: "<replSetName>",
    configsvr: true,
    members: [
      { _id : 0, host : "cfg1.example.net:27019" },
      { _id : 1, host : "cfg2.example.net:27019", priority : 0.5 },
      { _id : 2, host : "cfg3.example.net:27019", priority : 0.5 }
    ]
  }
)

rs.initiate(
  {
    _id: "configReplSet",
    configsvr: true,
    members: [
      { _id : 0, host : "mongo-configsvr-0.mongo-configsvr:27019" },
      { _id : 1, host : "mongo-configsvr-1.mongo-configsvr:27019", priority : 0.5  },
      { _id : 2, host : "mongo-configsvr-2.mongo-configsvr:27019", priority : 0.5  }
    ]
  }
)

rs.initiate(
  {
    _id: "rs0",
    members: [
      { _id : 0, host : "mongo-sh0-0.mongo-sh0:27017" },
      { _id : 1, host : "mongo-sh0-1.mongo-sh0:27017", priority : 0.5 },
      { _id : 2, host : "mongo-sh0-2.mongo-sh0:27017", priority : 0.5 }
    ]
  }
)

sh.addShard( "<replSetName>/s1-mongo1.example.net:27017")

sh.addShard( "rs0/mongo-sh0-0.mongo-sh0:27017")

```

```
rs.initiate()

rs.status()
rs.isMaster()
rs.config()
sh.status()

rs.reconfig(rs.config(),{force:true})
mongo --port 27019 --eval "rs.reconfig(rs.config(),{force:true})"

```

## Config
```
db.getMongo().setReadPref('secondaryPreferred')
```


## Usage
```
use myNewDatabase
db.myCollection.insertOne( { x: 1 } )
db.myCollection.find()
```

Connection pools
```
db.serverStatus().connections
db.currentOp(true)
db.runCommand( { "connPoolStats" : 1 } )
```

Index
```
db.demo.createIndex({name:1})
db.demo.createIndex({name:1},{background:true})

db.demo.dropIndex({name:1})

db.demo.getIndexes()

```

Array
```
db.getCollection('feat.rammus').insertOne(
    {name:"rammus"}
)
db.getCollection('feat.rammus').update(
    {name:"rammus"},
    { 
        $addToSet: {tags: { $each : ["ban","hid","3"]}}
    }
)
db.getCollection('feat.rammus').update(
    {name:"rammus"},
    { 
        $pull: {tags: { $in : ["ban","3"]}}
    }
)
```

Find
```
db.getCollection('feat.rammus').find(
    { tags: /cover/i }
)

```

Log
```
db.getCollection('oplog.rs').find({}).sort({$natural: -1})
```

Test
```
while true; do kubectl exec -it mongo-mongos-0 -- mongo mongo-mongos:27017/rammus --eval "db.serverStatus().connections;" ; done;


while true; do 
  kubectl exec -it mongo-sh0-0 -- mongo mongo-sh0-0.mongo-sh0:27017/rammus --eval "db.serverStatus().connections;"
  kubectl exec -it mongo-sh0-0 -- mongo mongo-sh0-1.mongo-sh0:27017/rammus --eval "db.serverStatus().connections;"
  kubectl exec -it mongo-sh0-0 -- mongo mongo-sh0-2.mongo-sh0:27017/rammus --eval "db.serverStatus().connections;"
done;

kubectl exec -it mongo-mongos-0 -- mongo --eval "db.serverStatus().connections;"
kubectl exec -it mongo-mongos-1 -- mongo --eval "db.serverStatus().connections;"
kubectl exec -it mongo-mongos-2 -- mongo --eval "db.serverStatus().connections;"

```

## Troubleshooting
> current 都是一樣的

mongos 不一定連到這個 replica，一個 replica set 有三個 node，所以三個都要檢查