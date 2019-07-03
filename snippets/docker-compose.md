```
version: '3'
services:
  web:
    build: .
    ports:
      - "5000:5000"
  redis:
    image: "redis:alpine"
```

```

    networks:
      - frontend
 
networks:
  frontend:
    name: custom_frontend
```