FROM centos:7

MAINTAINER Wang Lilong "wanglilong007@gmail.com"

ENV VERSION=7.0.3

RUN set -x \
	&& yum install -y epel-release  \
	&& yum install -y python-pip \
	&& buildDeps='python-pip curl gcc make linux-headers libffi-dev zlib-dev mariadb-dev python-devel' \
	&& yum install -y $buildDeps \
    && curl -fSL https://github.com/openstack/ironic/archive/${VERSION}.tar.gz -o ironic-${VERSION}.tar.gz \
    && tar xf ironic-${VERSION}.tar.gz \
    && cd ironic-${VERSION} \
    && pip install -r requirements.txt \
    && PBR_VERSION=${VERSION}  pip install . \
    && pip install PyMySQL==0.7.4 \
    && yum install -y \
    	libffi qemu iscsi-initiator psmisc genisoimage \
    && cp -r etc / \
    && pip install python-openstackclient python-ironicclient[cli]\
    && cd - \
    && rm -rf ironic-${VERSION}* \
    #&& yum remove -y $buildDeps \
	&& yum clean all
