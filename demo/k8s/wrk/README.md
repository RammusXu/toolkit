```
sleep 600
docker run --rm williamyeh/wrk -t10 -c100 -d600 --latency -H "accept-encoding: gzip, deflate, br" https://rammus.cf/echo
sleep 600
docker run --rm williamyeh/wrk -t10 -c100 -d600 --latency -H "accept-encoding: gzip, deflate, br" https://rammus.cf/


docker run --rm williamyeh/wrk -t10 -c100 -d120 --latency -H "accept-encoding: gzip, deflate, br" https://rammus.cf/echo
docker run --rm williamyeh/wrk -t10 -c100 -d120 --latency -H "accept-encoding: gzip, deflate, br" https://rammus.cf

```


wrk2
```
wrk2 -t4 -c100 -d30s -R6000 -L https://rammus.cf
```