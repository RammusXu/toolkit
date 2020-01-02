This is a docker-compose example of `docker-in-docker`

## Keypoint
Docker client need:
- `DOCKER_CERT_PATH=/certs/client`. Default is ~/.docker. It causes `unable to resolve docker endpoint: open /root/.docker/ca.pem: no such file or directory`
- `DOCKER_TLS_VERIFY=1`. Default is 0. It causes `Error response from daemon: Client sent an HTTP request to an HTTPS server.`
- Can't be `DOCKER_HOST=tcp://dind:2376`. It causes `error during connect: Get https://dind:2376/v1.40/containers/json: x509: certificate is valid for 0ed0e9c634ce, docker, localhost, not dind`
  - Therefore:
  ```
  dind:
     networks:
      dind:
        aliases:
          - docker
  ```