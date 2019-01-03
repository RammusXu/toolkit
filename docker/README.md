# Debugging Containers

For Gitlab CI
```
docker run -it --rm -v $PWD:/app docker:18.09-git sh
```


```
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