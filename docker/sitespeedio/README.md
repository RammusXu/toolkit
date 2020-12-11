```
docker run --rm -v "$(pwd):/sitespeed.io" sitespeedio/sitespeed.io:15.9.0 --graphite.host=host.docker.internal https://google.com/
docker run --rm -v "$(pwd):/sitespeed.io" sitespeedio/sitespeed.io:15.9.0 --graphite.host=host.docker.internal --graphite.namespace=sitespeed_io.another_device https://google.com/
```

## Reference
https://www.sitespeed.io/documentation/sitespeed.io/configuration/
