```
docker run -it --rm --cap-add net_admin --cap-add sys_module \
       -v $PWD/wireguard:/etc/wireguard -v /lib/modules:/lib/modules \
       -p 5555:5555/udp activeeos/wireguard-docker
```


```
docker run -it --rm --cap-add sys_module -v $PWD/modules:/lib/modules cmulk/wireguard-docker install-module

docker run -it --rm cmulk/wireguard-docker genkeys


docker run --cap-add net_admin --cap-add sys_module -v $PWD/data:/etc/wireguard -p 5555:5555/udp cmulk/wireguard-docker

```