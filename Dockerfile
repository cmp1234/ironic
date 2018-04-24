FROM centos:7

MAINTAINER Wang Lilong "wanglilong007@gmail.com"

ENV VERSION=7.0.3
ENV MYSQL_VERSION=5.7.20
ENV NGINX_VERSION=1.13.3
ENV NGINX_DOWNLOAD_URL=http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
ENV ERLANG_DOWNLOAD_URL=https://github.com/rabbitmq/erlang-rpm/releases/download/v19.3.6.8/erlang-19.3.6.8-1.el7.centos.x86_64.rpm
ENV RABBIT_DOWNLOAD_URL=https://dl.bintray.com/rabbitmq/all/rabbitmq-server/3.7.4/rabbitmq-server-3.7.4-1.el7.noarch.rpm
ENV MYSQL_DOWNLOAD_URL=https://downloads.mysql.com/archives/get/file/mysql-$MYSQL_VERSION-1.el7.x86_64.rpm-bundle.tar

COPY nginx.repo /etc/yum.repos.d/nginx.repo

RUN set -x \
	&& yum install -y epel-release  \
	&& yum install -y python-pip vim \
	&& buildDeps='python-pip curl gcc make linux-headers libffi-dev zlib-dev mariadb-dev python-devel' \
	&& yum install -y $buildDeps iptables-services sudo \
    && curl -fSL https://github.com/openstack/ironic/archive/${VERSION}.tar.gz -o ironic-${VERSION}.tar.gz \
    && tar xf ironic-${VERSION}.tar.gz \
    && cd ironic-${VERSION} \
    && sed -i 's/>/=/g' requirements.txt \
    && pip install -r requirements.txt \
    && PBR_VERSION=${VERSION}  pip install . \
    && pip install PyMySQL==0.7.4 \
    && yum install -y \
    	libffi qemu iscsi-initiator-utils psmisc genisoimage ipmitool tftp-server syslinux-tftpboot xinetd dhcp \
    && cp -r etc / \
    && pip install python-openstackclient python-ironicclient[cli]\
    && cd - \
    && rm -rf ironic-${VERSION}* \
    && curl -fSL $ERLANG_DOWNLOAD_URL -o erlang.rpm \
    && echo "installing rabbitmq ..................................." \
    && rpm -ivh erlang.rpm \
    && curl -fSL $RABBIT_DOWNLOAD_URL -o rabbit.rpm \
    && rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc \
    && yum install -y rabbit.rpm \
    && rm *.rpm -rf \
    && echo "install mysql .............................." \
    && yum install -y numactl net-tools \
    && curl -fSL $MYSQL_DOWNLOAD_URL -o msyql.tar.gz \
    && tar xf msyql.tar.gz \
    && rpm -ivh mysql-community-common-$MYSQL_VERSION-1.el7.x86_64.rpm  \
    && rpm -ivh mysql-community-libs-$MYSQL_VERSION-1.el7.x86_64.rpm  \
    && rpm -ivh mysql-community-client-$MYSQL_VERSION-1.el7.x86_64.rpm  \
    && rpm -ivh mysql-community-server-$MYSQL_VERSION-1.el7.x86_64.rpm \
    && rm *.rpm msyql.tar.gz -rf \
    && mysqld --initialize-insecure \
    && echo "install nginx .............................." \
    && yum install -y nginx-$NGINX_VERSION \
    && echo "fix ironic reference oslo.middleware bug, should reference <3.32.1" \
    && pip uninstall kombu -y \
    && pip install "kombu==3.0.32" \
    #&& yum remove -y $buildDeps \
    && yum clean all
COPY ironic.conf /etc/ironic/ironic.conf
