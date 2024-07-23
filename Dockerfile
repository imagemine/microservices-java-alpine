FROM alpine:3.20.2@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5

ARG ZULU_PKG="zulu11"
ARG UID="1000"
ARG JAVA_VERSION="11"
LABEL base=alpine engine=jvm version=${JAVA_VERSION} timezone=UTC port=8080 dir=/opt/app user=app uid=${UID}

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apk update && wget -P /etc/apk/keys/ https://cdn.azul.com/public_keys/alpine-signing@azul.com-5d5dc44c.rsa.pub && \
    echo "https://repos.azul.com/zulu/alpine" >> /etc/apk/repositories && \
    apk --no-cache add ${ZULU_PKG}-jdk

ENV JAVA_HOME=/usr/lib/jvm/${ZULU_PKG}-ca

RUN apk update && apk add --no-cache tzdata bash gcompat && rm -rf /var/cache/apk/*
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 8080

RUN mkdir -p /opt/app && ln -s /opt/app /libs && mkdir -p /opt/db-migrations && ln -s /opt/db-migrations /flyway

WORKDIR /opt/app

RUN addgroup -g ${UID} -S app && adduser -u ${UID} -G app -S app \
&& chown -R app:app /opt/app /libs /opt/db-migrations /flyway

USER app
