#!/bin/sh

# ssh-keygen -A
BUILDDIR="/build"


checkExit()
{
	if [ "$?" != "0" ]
	then
		echo "# WPLib Box: Exit reason \"$@\""
		exit $?
	fi
}


if [ ! -d ${BUILDDIR} ]
then
	echo "# WPLib Box: ${BUILDDIR} doesn't exist."
	exit
fi


BUILD_BINS="autoconf binutils bison build-base coreutils fakeroot file g++ gcc gnupg gpgme libarchive-tools make musl pacman pkgconf re2c rsync"
BUILD_LIBS="apache2-dev aspell-dev bzip2-dev curl-dev db-dev dpkg-dev enchant-dev freetds-dev freetype-dev gdbm-dev gettext-dev gmp-dev icu-dev imagemagick-dev imap-dev jpeg-dev krb5-dev libarchive libcurl libintl libressl2.6-libcrypto libc-dev libedit-dev libical-dev libjpeg-turbo-dev libmcrypt-dev libpng-dev libressl-dev libsodium-dev libssh2-dev libwebp-dev libxml2-dev libxpm-dev libxslt-dev libzip-dev musl-dev net-snmp-dev openldap-dev pcre-dev postgresql-dev readline-dev recode-dev sqlite-dev tidyhtml-dev unixodbc-dev zlib-dev"
BUILD_DEPS="${BUILD_BINS} ${BUILD_LIBS}"

PERSIST_DEPS="bash sudo wget curl gnupg openssl shadow pcre ca-certificates tar xz imagemagick"

PHPDIR="${BUILDDIR}/php-${PACKAGE_VERSION}"

CFLAGS="-fstack-protector-strong -fpic -fpie -O2"; export CFLAGS
CPPFLAGS="$CFLAGS"; export CPPFLAGS
LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"; export LDFLAGS
EXTENSION_DIR=/usr/lib/php/modules; export EXTENSION_DIR


echo "# WPLib Box: Adding packages."
apk update; checkExit
apk add --no-cache --virtual wplib.persist $PERSIST_DEPS; checkExit
apk add --no-cache --virtual wplib.build $BUILD_DEPS; checkExit


echo "# WPLib Box: Creating user accounts."
echo "%${WPLIB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
mkdir /var/mail; checkExit
groupadd -g ${WPLIB_UID} ${WPLIB_USER}; checkExit
useradd -d /home/${WPLIB_USER} -c "WPLib Box ${WPLIB_USER} user" -u ${WPLIB_UID} -g ${WPLIB_GID} -N -s /bin/bash ${WPLIB_USER}; checkExit


echo "# WPLib Box: Fetching tarballs."
cd /build; checkExit
wget -nv -O "php-${PACKAGE_VERSION}.tar.gz" -nv "$PACKAGE_URL"; checkExit
tar zxf php-${PACKAGE_VERSION}.tar.gz; checkExit


echo "# WPLib: Patching PHP ${PACKAGE_VERSION}."
cd ${BUILDDIR}; checkExit
patch -p0 < install-pear.patch; checkExit
# patch -p0 < libressl-2.7.patch; checkExit
patch -p0 < allow-build-recode-and-imap-together.patch; checkExit
ln /usr/include/tidybuffio.h /usr/include/buffio.h


echo "# WPLib Box: Configure PHP ${PACKAGE_VERSION}."
cd ${PHPDIR}; checkExit
autoconf; checkExit
./configure --config-cache --cache-file=config.cache \
	--enable-fpm --with-fpm-user=${WPLIB_USER} --with-fpm-group=${WPLIB_GROUP} \
	--datadir=/usr/share/php \
	--disable-gd-jis-conv \
	--disable-short-tags \
	--enable-bcmath=shared \
	--enable-calendar=shared \
	--enable-ctype=shared \
	--enable-dba=shared \
	--enable-dom=shared \
	--enable-exif=shared \
	--enable-fileinfo=shared \
	--enable-ftp=shared \
	--enable-intl=shared \
	--enable-json=shared \
	--enable-libxml \
	--enable-mbstring=shared \
	--enable-mysqlnd=shared \
	--enable-opcache=shared \
	--enable-pcntl=shared \
	--enable-pdo=shared \
	--enable-phar=shared \
	--enable-posix=shared \
	--enable-session=shared \
	--enable-shmop=shared \
	--enable-simplexml=shared \
	--enable-soap=shared \
	--enable-sockets=shared \
	--enable-sysvmsg=shared \
	--enable-sysvsem=shared \
	--enable-sysvshm=shared \
	--enable-tokenizer=shared \
	--enable-wddx=shared \
	--enable-xml=shared \
	--enable-xmlreader=shared \
	--enable-xmlwriter=shared \
	--enable-zip=shared \
	--libdir=/usr/lib/php \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc/php \
	--with-bz2=shared \
	--with-config-file-path=/etc/php \
	--with-config-file-scan-dir=/etc/php/conf.d \
	--with-curl=shared \
	--with-db4 \
	--with-dbmaker=shared \
	--with-enchant=shared \
	--with-freetype-dir=/usr \
	--with-gd=shared \
	--with-gdbm \
	--with-gettext=shared \
	--with-gmp=shared \
	--with-iconv=shared \
	--with-icu-dir=/usr \
	--with-imap-ssl \
	--with-imap=shared \
	--with-jpeg-dir=/usr \
	--with-kerberos \
	--with-layout=GNU \
	--with-ldap-sasl \
	--with-ldap=shared \
	--with-libedit \
	--with-libxml-dir=/usr \
	--with-libzip=/usr \
	--with-mysql-sock=/run/mysqld/mysqld.sock \
	--with-mysqli=shared,mysqlnd \
	--with-openssl=shared \
	--with-pcre-regex=/usr \
	--with-pdo-dblib=shared \
	--with-pdo-mysql=shared,mysqlnd \
	--with-pdo-odbc=shared,unixODBC,/usr \
	--with-pdo-pgsql=shared \
	--with-pdo-sqlite=shared,/usr \
	--with-pear=/usr/share/php \
	--with-pgsql=shared \
	--with-pic \
	--with-png-dir=/usr \
	--with-pspell=shared \
	--with-recode=shared \
	--with-snmp=shared \
	--with-sodium=shared \
	--with-sqlite3=shared,/usr \
	--with-system-ciphers \
	--with-tidy=shared \
	--with-unixODBC=shared,/usr \
	--with-webp-dir=/usr \
	--with-xmlrpc=shared \
	--with-xpm-dir=/usr \
	--with-xsl=shared \
	--with-zlib \
	--with-zlib-dir=/usr \
	--without-readline; checkExit

#	--enable-gd-native-ttf

echo "# WPLib Box: Compile PHP ${PACKAGE_VERSION}."
make; checkExit

echo "# WPLib Box: Install PHP ${PACKAGE_VERSION}."
make install; checkExit
install -d -m755 /etc/php/conf.d/; checkExit
rmdir /usr/include/php/include; checkExit
mkdir -p /var/run/php; checkExit


echo "# WPLib Box: Adding Imagick extension, (3.4.3)."
cd ${PHPDIR}/ext; checkExit
wget -nv http://pecl.php.net/get/imagick-3.4.3.tgz; checkExit
tar zxf imagick-3.4.3.tgz; checkExit
cd imagick-3.4.3; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# WPLib Box: Adding Xdebug extension, (2.6.0)."
cd ${PHPDIR}/ext; checkExit
wget -nv https://xdebug.org/files/xdebug-2.6.0.tgz; checkExit
tar zxf xdebug-2.6.0.tgz; checkExit
cd xdebug-2.6.0; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# WPLib Box: Adding mcrypt extension, (1.0.1)."
cd ${PHPDIR}/ext; checkExit
wget -nv http://pecl.php.net/get/mcrypt-1.0.1.tgz; checkExit
tar zxf mcrypt-1.0.1.tgz; checkExit
cd mcrypt-1.0.1; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# WPLib Box: Adding ssh2 extension, (1.1.2)."
cd ${PHPDIR}/ext; checkExit
wget -nv http://pecl.php.net/get/ssh2-1.1.2.tgz; checkExit
tar zxf ssh2-1.1.2.tgz; checkExit
cd ssh2-1.1.2; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# WPLib Box: pecl update-channels."
# Fixup pecl errors.
# EG: "Warning: Invalid argument supplied for foreach() in /usr/share/pear/PEAR/Command.php
#     "Warning: Invalid argument supplied for foreach() in Command.php on line 249"
sed -i 's/^exec $PHP -C -n -q/exec $PHP -C -q/' /usr/bin/pecl; checkExit
pecl update-channels; checkExit
