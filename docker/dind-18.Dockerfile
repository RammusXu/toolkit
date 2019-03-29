FROM docker:18.09-git

RUN apk add --update python py-pip yarn bash curl 

RUN pip install awscli

RUN curl -L --fail https://github.com/docker/compose/releases/download/1.23.2/run.sh -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose