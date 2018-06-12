#!/bin/sh

# ssh-keygen -A


checkExit()
{
	if [ "$?" != "0" ]
	then
		echo "# WPLib: Exit reason \"$@\""
		exit $?
	fi
}

BUILD_DEPS="autoconf binutils bison coreutils diffutils dpkg fakeroot file g++ gcc gnupg gpgme libarchive libarchive-tools libcurl libintl libressl2.6-libcrypto make musl pacman pkgconf re2c rsync aspell-dev bzip2-dev curl-dev db-dev dpkg-dev enchant-dev freetds-dev freetype-dev gdbm-dev gmp-dev icu-dev imagemagick-dev imap-dev jpeg-dev libc-dev libedit-dev libmcrypt-dev libpng-dev readline-dev libressl-dev libxml2-dev libxpm-dev libxslt-dev mariadb-dev musl-dev net-snmp-dev openldap-dev pcre-dev postgresql-dev sqlite-dev unixodbc-dev"

PERSIST_DEPS="bash sudo wget curl gnupg imagemagick openssl shadow pcre ca-certificates curl tar xz libressl"

apk update; checkExit
echo "# WPLib: Adding packages."
apk add --no-cache --virtual wplib.persist $PERSIST_DEPS; checkExit
apk add --no-cache --virtual wplib.build $BUILD_DEPS; checkExit

echo "%${WPLIB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "# WPLib: Creating user accounts."
mkdir /var/mail; checkExit
addgroup -g 82 -S www-data; checkExit
adduser -u 82 -D -S -G www-data www-data; checkExit
groupadd -g ${WPLIB_UID} ${WPLIB_USER}; checkExit
useradd -d /home/${WPLIB_USER} -c "WPLib ${WPLIB_USER} user" -u ${WPLIB_UID} -g ${WPLIB_GID} -N -s /bin/bash ${WPLIB_USER}; checkExit

if [ ! -d /build ]
then
	echo "# WPLib: /build doesn't exist."
	exit
fi

echo "# WPLib: Configure PHP ${PACKAGE_VERSION}."
cd /build; checkExit
wget -O "php-${PACKAGE_VERSION}" -nv "$PACKAGE_URL"; checkExit
tar zxf php-${PACKAGE_VERSION}.tar.gz; checkExit

patch -p0 < php-5.2.4-gmp.patch
patch -p0 < php-5.2.4-libxml29_compat.patch
patch -p0 < php-5.2.4-mysql.patch
patch -p0 < php-5.2.4-openssl.patch
patch -p0 < php-5.2.4-pcre_fix.patch
patch -p0 < php-5.2.4-fpm-0.5.3.patch
perl -p -i -e 's/HAVE_SYS_TIME_H/HAVE_SYS_TIME_H\n#define CLOCK_REALTIME 0/g' php-${PACKAGE_VERSION}/libevent/event.c

cd php-${PACKAGE_VERSION}; checkExit
BUILDDIR="/build/php-${PACKAGE_VERSION}"

# Because configure is broken in 5.2.4.
cp /build/config.cache .

CFLAGS="-fstack-protector-strong -fpic -fpie -O2"; export CFLAGS
CPPFLAGS="$CFLAGS"; export CPPFLAGS
LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"; export LDFLAGS
EXTENSION_DIR=/usr/lib/php/modules; export EXTENSION_DIR

# https://php-fpm.org/downloads/php-5.2.17-fpm-0.5.14.diff.gz
# https://php-fpm.org/downloads/php-5.2.4-fpm-0.5.3.diff.gz

./configure --prefix=/usr \
	--sysconfdir=/etc/php \
	--localstatedir=/var \
	--with-layout=GNU \
	--with-config-file-path=/etc/php \
	--with-config-file-scan-dir=/etc/php/conf.d \
	--mandir=/usr/share/man \
	--enable-inline-optimization \
	--enable-option-checking=fatal \
	--enable-fpm --with-fpm-user=${WPLIB_USER} --with-fpm-group=${WPLIB_GROUP} \
	--enable-cgi --enable-fastcgi --enable-force-cgi-redirect \
	--enable-cli \
	--disable-debug \
	--disable-rpath \
	--disable-static \
	--enable-shared \
	--with-pic \
	--without-mhash \
	--with-pear \
	--with-readline \
	--with-libedit \
	--enable-phpdbg \
	--enable-bcmath=shared \
	--with-bz2=shared \
	--enable-calendar=shared \
	--with-cdb \
	--enable-ctype=shared \
	--with-curl=shared \
	--with-enchant=shared \
	--with-freetype-dir=shared,/usr \
	--enable-ftp=shared \
	--enable-exif=shared \
	--with-gd=shared --enable-gd-native-ttf \
	--with-png-dir=shared,/usr \
	--with-gettext=shared \
	--with-gmp=shared \
	--with-iconv=shared \
	--with-icu-dir=/usr \
	--with-imap=shared \
	--enable-intl=shared \
	--with-jpeg-dir=shared,/usr \
	--enable-json=shared \
	--with-ldap=shared \
	--enable-mbregex \
	--enable-mbstring=all \
	--with-mcrypt=shared \
	--with-mysql=shared,/usr/bin/mysql_config --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-mysqli=shared,/usr/bin/mysql_config \
	--without-imap-ssl --without-openssl \
	--with-pcre-regex=/usr \
	--enable-pcntl=shared \
	--enable-phar=shared \
	--enable-posix=shared \
	--with-pspell=shared \
	--with-regex=php \
	--enable-session \
	--enable-shmop=shared \
	--with-snmp=shared \
	--enable-soap=shared \
	--enable-sockets=shared \
	--enable-sysvmsg=shared --enable-sysvsem=shared --enable-sysvshm=shared \
	--with-unixODBC=shared,/usr \
	--enable-dom=shared --enable-libxml=shared --enable-xml=shared --enable-xmlreader=shared --with-xmlrpc=shared --with-xsl=shared \
	--enable-wddx=shared \
	--enable-zip=shared --with-zlib=shared \
	--enable-dba=shared \
	--with-gdbm=shared \
	--without-db4 \
	--without-db1 --without-db2 --without-db3 --without-qdbm \
	--with-sqlite3=shared,/usr \
	--without-mssql \
	--enable-pdo=static \
	--with-pdo-mysql=shared,/usr/bin/mysql_config \
	--with-pdo-odbc=shared,unixODBC,/usr \
	--with-pdo-pgsql=shared \
	--with-pdo-sqlite=shared,/usr \
	--without-pdo-dblib \
	--with-pgsql=shared \
	--enable-opcache; checkExit

#	--with-imap-ssl=shared --with-openssl=shared

echo "# WPLib: Compile PHP ${PACKAGE_VERSION}."
make; checkExit

echo "# WPLib: Install PHP ${PACKAGE_VERSION}."
make install; checkExit
install -d -m755 /etc/php/conf.d/; checkExit
rmdir /usr/include/php/include; checkExit
mkdir -p /var/run/php; checkExit
ln /usr/bin/php-cgi /usr/bin/php-fpm

echo "# WPLib: pecl update-channels."
# Fixup pecl errors.
# EG: "Warning: Invalid argument supplied for foreach() in /usr/share/pear/PEAR/Command.php
#     "Warning: Invalid argument supplied for foreach() in Command.php on line 249"
sed -i 's/^exec $PHP -C -n -q/exec $PHP -C -q/' /usr/bin/pecl; checkExit
pecl update-channels; checkExit

#chown -fhR ${WPLIB_USER}:${WPLIB_USER} /build; checkExit
#chgrp ${WPLIB_USER} /var/lib/pacman
#chmod 775 /var/lib/pacman
#su -c 'makepkg --force --log' ${WPLIB_USER}; checkExit
#
#echo "# WPLib: Packaging PHP ${PACKAGE_VERSION}."
#pacman --upgrade --noconfirm --noprogressbar --color auto php-${PACKAGE_VERSION}*.pkg.tar.gz; checkExit

#echo "# WPLib: Adding Imagick extension."
#cd ${BUILDDIR}/ext; checkExit
#wget -nv http://pecl.php.net/get/imagick-3.4.3.tgz; checkExit
#tar zxf imagick-3.4.3.tgz; checkExit
#cd imagick-3.4.3; checkExit
#phpize; checkExit
#./configure; checkExit
#make; checkExit
#make install; checkExit

echo "# WPLib: Adding Imagick extension."
cd ${BUILDDIR}/ext; checkExit
wget -nv https://xdebug.org/files/xdebug-2.2.7.tgz; checkExit
tar zxf xdebug-2.2.7.tgz; checkExit
cd xdebug-2.2.7; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit

# find . -type f -perm +0111 -exec strip --strip-all '{}'

echo "# WPLib: Removing build packages."
apk del wplib.build; checkExit

echo "# WPLib: Adding packages required by PHP ${PACKAGE_VERSION}."
RUNTIME_DEPS="$(scanelf --needed --nobanner --format '%n#p' --recursive /usr | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }')"
echo "# ${RUNTIME_DEPS}"
apk add --no-cache --virtual wplib.runtime ${RUNTIME_DEPS}; checkExit

echo "# WPLib: Cleaning up."
rm -rf /build
unset BUILD_DEPS PERSIST_DEPS RUNTIME_DEPS CPPFLAGS LDFLAGS CFLAGS EXTENSION_DIR


################################################################################
