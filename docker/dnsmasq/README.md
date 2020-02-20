
## Reference 
- https://www.linux.com/tutorials/advanced-dnsmasq-tips-and-tricks/


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
