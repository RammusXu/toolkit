
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
