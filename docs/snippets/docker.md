
## Install docker
ref: https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker rammus
```

## Minimize docker image
### Delete libraries only used in build time
```bash
apk update \
	&& apk add --no-cache --virtual .build-deps curl \
	&& curl -sL $TOOL_URL | gzip -d - > /usr/local/bin/new_tool \
	&& chmod +x /usr/local/bin/new_tool \
	&& apk del .build-deps
```

## Clena docker legacy data
```
docker image prune -af
docker rmi $(docker images -f "dangling=true" -q) -f
docker volume rm $(docker volume ls -qf dangling=true)
```


## Buildkit

### Troubleshooting

####
不能和 registry-mirrors 一起用 (issue: https://github.com/moby/moby/issues/39120)

{"registry-mirrors": ["https://mirror.gcr.io"]} to /etc/docker/daemon.json


#### resolve image config for docker.io/docker/dockerfile:experimental:
```bash
DOCKER_BUILDKIT=1 docker build -t demo .

[+] Building 0.5s (3/3) FINISHED
 => [internal] load build definition from Dockerfile                                                                         0.0s
 => => transferring dockerfile: 259B                                                                                         0.0s
 => [internal] load .dockerignore                                                                                            0.0s
 => => transferring context: 2B                                                                                              0.0s
 => ERROR resolve image config for docker.io/docker/dockerfile:experimental                                                  0.5s
------
 > resolve image config for docker.io/docker/dockerfile:experimental:
------
failed to solve with frontend dockerfile.v0: failed to solve with frontend gateway.v0: docker.io/docker/dockerfile:experimental not found
```

!!! solution
	在 `~/.docker/daemon.json` 加入
	```json
	"features": {
		"buildkit": true
	}
	```
	或是
	```bash
	DOCKER_BUILDKIT=1
	```

要在 Dockerfile 開頭加入 `# syntax = docker/dockerfile:experimental`
```
# syntax = docker/dockerfile:experimental
FROM alpine:3.10
```
```
failed to solve with frontend dockerfile.v0: failed to create LLB definition: Dockerfile parse error line 3: Unknown flag: mount
```


### error: failed to get status: rpc error: code = Unavailable desc = connection error: desc = "transport: error while dialing: dial unix /run/buildkit/buildkitd.sock: connect: no such file or directory"

```bash
error: failed to get status: rpc error: code = Unavailable desc = connection error: desc = "transport: error while dialing: dial unix /run/buildkit/buildkitd.sock: connect: no such file or directory"
```

```bash

buildctl build \
  --frontend=dockerfile.v0 \
  --local context=echo-box/2.0 --local dockerfile=echo-box/2.0 \
  --output type=image,name=ghcr.io/swaglive/action-demo:2.0,push=true \
  --export-cache type=inline \
  --import-cache type=registry,ref=ghcr.io/swaglive/action-demo:2.0
```
