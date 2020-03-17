Blog: https://rammusxu.github.io/2020/03/16/Test-and-validate-dnssec-in-dnsmasq-by-docker-compose/


Config:

- /etc/conf.d/dnsmasq 
- /etc/dnsmasq.conf 
- /etc/hosts 
- /etc/resolv.conf 

### Test it
```bash
apk add bind-tools
```

```bash
nslookup swag.live localhost
nslookup swag.live 127.0.0.1
```

```bash
dig @localhost swag.live
dig @127.0.0.1 swag.live
dig @8.8.8.8 swag.live
```

```
dig +trace swag.live
dig +short swag.live ns
```

```
dig @dnsmasq +dnssec swag.live
dig @dnsmasq +dnssec google.com
```