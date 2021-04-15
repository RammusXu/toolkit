## Generate fake data
```bash
git clone git@github.com:feliixx/mgodatagen.git
go install
go build
./main -f datagen/testdata/big.json
```

## Sharding Mongo
1. Initialize shard `rs0`
    ```bash
    docker-compose exec mongo mongo --eval "rs.initiate({_id: 'rs0', members: [{ _id:0, host:'mongo:27017' }]})"
    ```
2. Initialize configsvr `configReplSet`
    ```bash
    docker-compose exec mongo-configsvr mongo --port 27019 --eval "rs.initiate({_id: 'configReplSet', configsvr: true, members: [{'_id': 0, 'host': 'mongo-configsvr:27019'}]})"
    ```
3. Add Shard `rs0` to mongos
    ```bash
    docker-compose exec mongos mongo --port 27017 --eval "sh.addShard('rs0/mongo:27017')"
    ```

4. Initialize shard `rs1`
    ```bash
    docker-compose exec mongo-rs1 mongo --eval "rs.initiate({_id: 'rs1', members: [{ _id:0, host:'mongo-rs1:27017' }]})"
    ```

5. Add Shard `rs1` to mongos
    ```bash
    docker-compose exec mongos mongo --port 27017 --eval "sh.addShard('rs1/mongo-rs1:27017')"
    ```

## Indexing and sharding collection

```bash
db.test.createIndex( { "c32": 1, "c64": 1 } )
sh.enableSharding("datagen_it_test")
sh.shardCollection("datagen_it_test.test", { "c32": 1, "c64": 1 } )
```
