# Gitlab CI

## Debugging Containers

For Gitlab CI
```bash
docker run -it --rm -v $PWD:/app docker:18.09-git sh
```

```yaml
rammusxu/docker-box:python
rammusxu/docker-box:node
```

```yaml
image: docker:stable

services:
  - docker:dind

variables:
  DOCKER_DRIVER: overlay2
  IMAGE_LATEST: $CI_REGISTRY_IMAGE:latest

before_script:
  - docker login -u gitlab-ci-token -p $CI_JOB_TOKEN $CI_REGISTRY

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:master .
    - docker push $CI_REGISTRY_IMAGE:master
```


## Quick build
```yaml
image: docker:18.09-git

services:
  - docker:dind

variables:
  DOCKER_DRIVER: overlay2

build:
  stage: build
  script:
    - docker images
    - docker build .
    - docker images
```