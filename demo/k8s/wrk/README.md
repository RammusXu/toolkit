```
docker run --rm williamyeh/wrk -t10 -c100 -d120 --latency -H "accept-encoding: gzip, deflate, br" https://rammus.cf/echo
sleep 5
docker run --rm williamyeh/wrk -t10 -c100 -d120 --latency -H "accept-encoding: gzip, deflate, br" https://rammus.cf/


docker run --rm williamyeh/wrk -t10 -c100 -d120 --latency -H "accept-encoding: gzip, deflate, br" https://rammus.cf/echo
docker run --rm williamyeh/wrk -t10 -c100 -d120 --latency -H "accept-encoding: gzip, deflate, br" https://rammus.cf

```