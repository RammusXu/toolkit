# toolkit
My toolkit

[Dockerhub](https://hub.docker.com/r/rammusxu/docker-box)

## Setup
In `Visual Studio Code`:
Command + Shift + P -> Python: Select Interpreter


## Image Tags
- rammusxu/docker-box:node [docker/dind-18-node.Dockerfile](https://github.com/RammusXu/toolkit/blob/master/docker/dind-18-node.Dockerfile)

    Include: 
    > python py-pip "nodejs>8.9.3" "nodejs-npm>8.9.3" yarn bash curl awscli

- rammusxu/docker-box:python [docker/dind-18.Dockerfile](https://github.com/RammusXu/toolkit/blob/master/docker/dind-18.Dockerfile)

    Include:
    > python py-pip yarn bash curl awscli docker-compose