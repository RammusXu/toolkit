# Docker Compose

```yaml
version: '3'
services:
  web:
    build: .
    ports:
      - "5000:5000"
  redis:
    image: "redis:alpine"
```

```yaml
    networks:
      - frontend
 
networks:
  frontend:
    name: custom_frontend
```