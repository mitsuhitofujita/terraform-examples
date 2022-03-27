FROM hashicorp/terraform:1.1.7

RUN apk update && \
    apk add --no-cache \
        docker-cli \
        docker-compose

ENV GLIBC_VER=2.34-r0
RUN apk --no-cache add curl && \
    curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub && \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk && \
    curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk && \
    apk add --no-cache glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

ARG TERRAFORM_UID=1000
ARG TERRAFORM_USER=terraform
ARG TERRAFORM_HOME=/home/terraform
ARG DOCKER_GID=998
ARG DOCKER_GROUP=docker
RUN addgroup -g ${DOCKER_GID} ${DOCKER_GROUP} && \
    adduser -D -u ${TERRAFORM_UID} -G ${DOCKER_GROUP} -h ${TERRAFORM_HOME} ${TERRAFORM_USER} 
