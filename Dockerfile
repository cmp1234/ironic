FROM python:2.7-slim-jessie

MAINTAINER Wang Lilong "wanglilong007@gmail.com"

ENV VERSION=7.0.3

RUN set -x \  
    && apt-get update \
	&& buildDeps='curl gcc make libffi-dev' \
	&& apt-get install -y --no-install-recommends $buildDeps linux-headers-$(uname -r) \
    && curl -fSL https://github.com/openstack/ironic/archive/${VERSION}.tar.gz -o ironic-${VERSION}.tar.gz \
    && tar xf ironic-${VERSION}.tar.gz \
    && cd ironic-${VERSION} \
    && pip install -r requirements.txt \
    && PBR_VERSION=${VERSION}  pip install . \
    && apt-get install -y --no-install-recommends \
    	libffi qemu open-iscsi psmisc genisoimage \
    && cp -r etc / \
    && pip install PyMySQL python-openstackclient python-ironicclient[cli] \
    && cd - \
    && rm -rf ironic-${VERSION}* \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -rf /var/lib/apt/lists/*
