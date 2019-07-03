FROM docker:18.09-git

RUN apk add --update python py-pip yarn bash curl 

# Install docker-compose
RUN apk add --update \
    libffi-dev \
    openssl-dev \
    python-dev \
    python3-dev \
    build-base \
  && pip install virtualenv \
  && pip install docker-compose \
  && rm -rf /var/cache/apk/*

RUN pip install awscli