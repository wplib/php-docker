FROM alpine:3.7

MAINTAINER WPLib Team <team@wplib.org>

ARG PACKAGE_VERSION="7.0.30"
ARG PACKAGE_URL="http://php.net/get/php-7.0.30.tar.gz/from/this/mirror"
ARG PACKAGE_ROOT="/"
ARG WPLIB_USER="vagrant"
ARG WPLIB_UID="1000"
ARG WPLIB_GROUP="vagrant"
ARG WPLIB_GID="1000"


################################################################################
ENV PACKAGE_VERSION $PACKAGE_VERSION
ENV PACKAGE_URL $PACKAGE_URL
ENV PACKAGE_ROOT $PACKAGE_ROOT
ENV WPLIB_USER $WPLIB_USER
ENV WPLIB_UID $WPLIB_UID
ENV WPLIB_GROUP $WPLIB_GROUP
ENV WPLIB_GID $WPLIB_GID

USER root

COPY build/* /build/
COPY container.json /etc/container.json
COPY files /

RUN	/bin/sh /build/build.sh && \
	wget -nv https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 && \
	mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail && \
	chmod a+x /usr/local/bin/*

WORKDIR /var/www
USER vagrant
# ENTRYPOINT ["/usr/local/bin/php-entrypoint"]
CMD ["/usr/sbin/php-fpm", "-F"]
