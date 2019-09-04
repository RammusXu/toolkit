

## Deploy

https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md
```
kubectl apply -f controller
```

https://kubernetes.github.io/ingress-nginx/user-guide/monitoring/
```
kubectl apply -k prometheus
kubectl apply -k grafanaa
```

## Configs, Annotations
https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/


## Note
```
curl http://rammus.cf -H "Host: ddos.demo" -H "User-Agent:A" -v
```
```
│ 118.160.49.111 - [118.160.49.111] - - [28/Aug/2019:03:16:48 +0000] "GET / HTTP/1.1" 503 203 "-" "A" 254 0.000 [ingress-nginx-echoserver-80] [] - - - - e126b312b62aee709289494c888e25db
│ 2019/08/28 03:16:49 [error] 3145#3145: *1683794 limiting requests, excess: 5.575 by zone "ingress-nginx_ingress-nginx_rpm", client: 118.160.49.111, server: ddos.demo, request: "GET / HTTP/1.1", host:
│ "ddos.demo"
 118.160.49.111 - [118.160.49.111] - - [28/Aug/2019:03:18:16 +0000] "GET / HTTP/1.1" 200 778 "-" "A" 255 0.003 [ingress-nginx-echoserver-80] [] 10.20.0.3:8080 778 0.004 200 c73506e7c55c3145e979743dadd6
│ 0c80
```

```
curl "http://rammus.cf/?search=<scritp>alert('xss');</script>" -H "Host: ddos.demo" -H "User-Agent:Rammus Mac" -v
```
```
│ 2019/08/28 04:26:06 [warn] 3703#3703: *1788071 [lua] log.lua:52: {"timestamp":1566966366,"request_headers":{"host":"http://rammus.cf","postman-token":"2302d597-aa3e-4b20-b253-21892933612f","accept":"*\/*
│ ","x-cloud-trace-context":"e4ce1487d2d07a4c498deaebad085d66\/270423908846992963","cache-control":"no-cache","accept-encoding":"gzip, deflate","user-agent":"PostmanRuntime\/7.15.2","connection":"Keep-A
│ live","x-forwarded-proto":"http","x-forwarded-for":"118.160.49.111, http://rammus.cf","via":"1.1 google"},"id":"f7aef3cde794a88392fa","method":"GET","uri":"\/","client":"118.160.49.111","uri_args":{"sear
│ ch":"<scritp>alert('xss');<\/script>"},"alerts":[{"msg":"Host header contains an IP address","id":21010,"match":1},{"msg":"Repetitive non-word characters anomaly detected","id":40002,"match":19},{"msg
│ ":"SQL Tautologies","id":41005,"match":2},{"msg":"SQL Injection character anomaly - ARGS","id":41015,"match":1},{"msg":"SQL probing attempt","id":41036,"match":8},{"msg":"XSS (Cross-Site Scripting)","
│ id":42043,"match":9},{"msg":"XSS (Cross-Site Scripting) - JS Fragments","id":42076,"match":9},{"msg":"XSS (Cross-Site Scripting) - xss testing alert","id":42079,"match":15},{"logdata":30,"msg":"Reques
│ t score greater than score threshold","id":99001,"match":30},{"logdata":30,"msg":"Request score greater than score threshold","id":99002,"match":30},{"logdata":30,"msg":"Request score greater than sco
│ re threshold","id":99003,"match":30}]} while logging request, client: 118.160.49.111, server: _, request: "GET /?search=%3Cscritp%3Ealert%28%27xss%27%29;%3C/script%3E HTTP/1.1", upstream: "http://10.2
│ 0.0.3:8080/?search=%3Cscritp%3Ealert%28%27xss%27%29;%3C/script%3E", host: "http://rammus.cf"
│ 118.160.49.111 - [118.160.49.111] - - [28/Aug/2019:04:26:06 +0000] "GET /?search=%3Cscritp%3Ealert%28%27xss%27%29;%3C/script%3E HTTP/1.1" 200 625 "-" "PostmanRuntime/7.15.2" 441 0.019 [ingress-nginx-e
│ hoserver-80[] [] 10.20.0.3:8080 1171 0.016 200 ddb354319b711187f2340bbe58797e1f
```

`whitelist-source-range` > `block-cidrs`

`enable-modsecurity: "true"` is detection only in `/var/log/modsec_audit.log`.

## Benchmark
```
docker run --rm jordi/ab -k -c 100 -n 10000 http://rammus.cf
wrk2 -t2 -c50 -d30s -R2000 -L http://rammus.cf
curl -o /dev/null -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} Size: %{size_download} \n" -H "Accept-Encoding: gzip"  http://rammus.cf

docker run --rm williamyeh/wrk -t10 -c100 -d30 --latency http://rammus.cf
docker run --rm williamyeh/wrk -t10 -c100 -d30 --latency https://rammus.cf
docker run --rm williamyeh/wrk -t10 -c100 -d120 --latency -H "accept-encoding: gzip, deflate, br" https://rammus.cf

```


```
# https://github.com/giltene/wrk2/wiki/Installing-wrk2-on-Mac
brew tap jabley/homebrew-wrk2
brew install --HEAD wrk2
```

SaaS:
- https://app.flood.io
- https://app.octoperf.com
- https://www.blazemeter.com

## Keypoint
- Google Ingress reject SQL Injection from curl, but not from browser? (/?id=1%20AND%201=1)
- lua-resty-waf: https://github.com/p0pr0ck5/lua-resty-waf/tree/84b4f40362500dd0cb98b9e71b5875cb1a40f1ad/rules
    - XSS
    - SQL Injection
    - nginx.ingress.kubernetes.io/lua-resty-waf-allow-unknown-content-types: "true"
      - just got 403 when content-type not equal: `text/html`, `text/json`, `application/json`

## Reference
- 后端nginx使用set_real_ip_from获取用户真实IP https://devops.webres.wang/2017/03/nginx-using-set_real_ip_from-get-client-ip/
- Nginx下limit_req模块burst参数超详细解析 https://blog.csdn.net/hellow__world/article/details/78658041
- Differences Between nginxinc/kubernetes-ingress and kubernetes/ingress-nginx Ingress Controllers https://github.com/nginxinc/kubernetes-ingress/blob/master/docs/nginx-ingress-controllers.md