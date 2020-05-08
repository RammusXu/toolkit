```bash
docker-compose up -d
```


```bash
celery -A app worker --loglevel=info
```

https://docs.celeryproject.org/en/stable/userguide/monitoring.html