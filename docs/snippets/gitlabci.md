# Gitlab CI

## Debugging Containers

For Gitlab CI
```bash
docker run -it --rm -v $PWD:/app docker:18.09-git sh
```

```yaml
rammusxu/docker-box:python
rammusxu/docker-box:
```

## Build docker image and push to gitlab registry
ref: https://gitlab.com/gableroux/gitlab-ci-example-docker

```yaml
image: docker:latest

services:
  - docker:dind

before_script:
  - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY

build-master:
  stage: build
  script:
    - docker build --pull -t "$CI_REGISTRY_IMAGE" .
    - docker push "$CI_REGISTRY_IMAGE"
  only:
    - master

build:
  stage: build
  script:
    - docker build --pull -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG" .
    - docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG"
  except:
    - master
```

## References
- CI 環境變數 https://docs.gitlab.com/ee/ci/variables/predefined_variables.html