FROM cmp1234/nginx-python:1.10.3-python2.7.13-alpine3.6

MAINTAINER Wang Lilong "wanglilong007@gmail.com"

ENV VERSION=7.0.3

RUN set -x \  
    && apk add --no-cache --virtual .build-deps \
		coreutils \
		curl \
		gcc \
		linux-headers \
		make \
		musl-dev \
		zlib \
		libffi-dev \
                python-dev \
		zlib-dev \
		mariadb-dev \
    && curl -fSL https://github.com/openstack/ironic/archive/${VERSION}.tar.gz -o ironic-${VERSION}.tar.gz \
    && tar xf ironic-${VERSION}.tar.gz \
    && cd ironic-${VERSION} \
    #&& pip install -r requirements.txt \
    #&& PBR_VERSION=${VERSION}  pip install . \
    && pip install uwsgi==2.0.15 PyMySQL==0.7.4 \
    && apk add --no-cache --virtual .run-deps  \
    	libffi=3.2.1-r3 \
    && cp -r etc / \
    && pip install python-openstackclient \
    && cd - \
    && rm -rf ironic-${VERSION}* \
    && apk del .build-deps
