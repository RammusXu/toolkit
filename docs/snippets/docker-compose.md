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

## Connect to redis
```yaml
version: '3'
services:
  redis:
    image: "redis:alpine"
    ports:
      - "6379:6379"
  celery:
    image: "celery:4.0.2"
    environment:
      - CELERY_BROKER_URL=redis://redis
  celery-2:
    image: "celery:4.0.2"
    environment:
      - CELERY_BROKER_URL=redis://redis
```

```bash
docker exec -it celery_celery_1 ping redis
docker exec -it celery_celery_1 ping redis-not-found
```

## Reference
- https://docs.docker.com/compose/compose-file/