## Test
```
bash-5.0$ docker-compose exec redis-slave redis-cli --raw get Rammus

bash-5.0$ docker-compose exec redis-master redis-cli --raw set Rammus 222
OK
bash-5.0$ docker-compose exec redis-slave redis-cli --raw get Rammus
222
```
