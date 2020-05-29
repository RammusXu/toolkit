---
description: Dockerfile examples, template, snippet
---

Dockerfile examples, template, snippet

## Javascript
```
FROM        node:12.14.0-alpine3.11 as builder

ENV         NODE_ENV=production
WORKDIR     /app
COPY        ./app/package.json ./
RUN         npm install
COPY        ./app ./

###
FROM        node:12.14.0-alpine3.11

ENTRYPOINT npm start

ENV         NODE_ENV=production
WORKDIR     /app
COPY        --from=builder /app /app
```