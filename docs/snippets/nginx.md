---
description:
---

Nginx 實用筆記
## Commands
```bash
nginx -s reload
```


## proxy_cache
### upstream hash
增刪 server 會重新產生 hash。
```nginx
upstream proxy {
  hash $scheme$host$request_uri consistent;

  server                        cache-server-0.cache-server;
  server                        cache-server-1.cache-server;
}
```

### cache loader process
```s
/ # ps
PID   USER     TIME  COMMAND
    1 root      0:00 {openresty} nginx: master process /usr/local/openresty/bin/openresty -g daemon off;
    7 nobody    0:00 {openresty} nginx: worker process
    8 nobody    0:00 {openresty} nginx: worker process
    9 nobody    0:00 {openresty} nginx: cache manager process
   10 nobody    0:00 {openresty} nginx: cache loader process
```


## Reference
- 常用的 linux 指令集與範例 - https://www.nginx.com/blog/rate-limiting-nginx/
