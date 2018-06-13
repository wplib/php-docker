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


if [ ! -d /build ]
then
	echo "# WPLib: /build doesn't exist."
	exit
fi


# BUILD_DEPS="autoconf binutils bison coreutils diffutils dpkg fakeroot file flex g++ gcc gnupg gpgme libarchive libarchive-tools libcurl libintl libpthread-stubs libressl2.6-libcrypto make musl musl-utils pacman pkgconf re2c rsync aspell-dev bzip2-dev curl-dev db-dev dpkg-dev enchant-dev freetds-dev freetype-dev gdbm-dev gmp-dev icu-dev imagemagick6-dev imap-dev jpeg-dev libc-dev libedit-dev libmcrypt-dev libpng-dev readline-dev libressl-dev libxml2-dev libxpm-dev libxslt-dev mariadb-dev musl-dev net-snmp-dev openldap-dev pcre-dev postgresql-dev sqlite-dev unixodbc-dev"
BUILD_DEPS="imagemagick autoconf binutils coreutils diffutils dpkg fakeroot file flex g++ gcc gnupg gpgme libarchive libarchive-tools libcurl libintl libpthread-stubs libressl2.6-libcrypto make musl musl-utils pacman pkgconf re2c rsync aspell-dev bzip2-dev curl-dev db-dev dpkg-dev enchant-dev freetds-dev freetype-dev gdbm-dev gmp-dev icu-dev imagemagick6-dev imap-dev jpeg-dev libc-dev libedit-dev libmcrypt-dev libpng-dev readline-dev libressl-dev libxml2-dev libxpm-dev libxslt-dev musl-dev net-snmp-dev openldap-dev pcre-dev postgresql-dev sqlite-dev unixodbc-dev"

PERSIST_DEPS="bash sudo wget curl gnupg openssl shadow pcre ca-certificates tar xz libressl"

BUILDDIR="/build"
PHPDIR="${BUILDDIR}/php-${PACKAGE_VERSION}"
MYSQL_VERSION="5.1.72"
MYSQLDIR="${BUILDDIR}/mysql-${MYSQL_VERSION}"
BISON_VERSION="2.3"
BISONDIR="${BUILDDIR}/bison-${BISON_VERSION}"

CFLAGS="-fstack-protector-strong -fpic -fpie -O2"; export CFLAGS
CPPFLAGS="$CFLAGS"; export CPPFLAGS
LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"; export LDFLAGS
EXTENSION_DIR=/usr/lib/php/modules; export EXTENSION_DIR


echo "# WPLib: Adding packages."
apk update; checkExit
apk add --no-cache --virtual wplib.persist $PERSIST_DEPS; checkExit
apk add --no-cache --virtual wplib.build $BUILD_DEPS; checkExit


echo "# WPLib: Creating user accounts."
echo "%${WPLIB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
mkdir /var/mail; checkExit
groupadd -g ${WPLIB_UID} ${WPLIB_USER}; checkExit
useradd -d /home/${WPLIB_USER} -c "WPLib ${WPLIB_USER} user" -u ${WPLIB_UID} -g ${WPLIB_GID} -N -s /bin/bash ${WPLIB_USER}; checkExit


echo "# WPLib: Fetching tarballs."
cd /build; checkExit
wget -nv -O "php-${PACKAGE_VERSION}.tar.gz" -nv "$PACKAGE_URL"; checkExit
tar zxf php-${PACKAGE_VERSION}.tar.gz; checkExit
wget -nv https://downloads.mysql.com/archives/get/file/mysql-${MYSQL_VERSION}.tar.gz; checkExit
tar zxf mysql-${MYSQL_VERSION}.tar.gz; checkExit
wget -nv ftp://ftp.gnu.org/gnu/bison/bison-2.3.tar.gz; checkExit
tar zxf bison-2.3.tar.gz; checkExit


echo "# WPLib: Configure Bison ${BISON_VERSION}."
cd ${BISONDIR}; checkExit
./configure --prefix=/usr; checkExit
make install; checkExit


echo "# WPLib: Configure MySQL ${MYSQL_VERSION}."
cd ${BUILDDIR}; checkExit
patch -p0 < mysql-5.1.72.patch
cd ${MYSQLDIR}; checkExit
./configure --prefix=/usr --disable-thread-safe-client --includedir=/usr/include --libdir=/usr/lib; checkExit
ln include/config.h include/my_config.h; checkExit


echo "# WPLib: Build MySQL ${MYSQL_VERSION}."
cd ${MYSQLDIR}/libmysql; checkExit
perl -p -i -e 's#pkglibdir = \$\(libdir\)/mysql#pkglibdir = \$(libdir)#g; s#pkgincludedir = \$\(includedir\)/mysql#pkgincludedir = \$(includedir)#g;' Makefile; checkExit
make install; checkExit
cd ${MYSQLDIR}/include; checkExit
perl -p -i -e 's#pkglibdir = \$\(libdir\)/mysql#pkglibdir = \$(libdir)#g; s#pkgincludedir = \$\(includedir\)/mysql#pkgincludedir = \$(includedir)#g;' Makefile; checkExit
make install; checkExit
cp mysqld_error.h /usr/include; checkExit
cd ${MYSQLDIR}/scripts; checkExit
make install; checkExit


echo "# WPLib: Patching PHP ${PACKAGE_VERSION}."
cd ${BUILDDIR}; checkExit
patch -p0 < php-5.2.4-gmp.patch; checkExit
patch -p0 < php-5.2.4-libxml29_compat.patch; checkExit
# patch -p0 < php-5.2.4-mysql.patch; checkExit
patch -p0 < php-5.2.4-openssl.patch; checkExit
patch -p0 < php-5.2.4-pcre_fix.patch; checkExit
patch -p0 < php-5.2.4-fpm-0.5.3.patch; checkExit
perl -p -i -e 's/HAVE_SYS_TIME_H/HAVE_SYS_TIME_H\n#define CLOCK_REALTIME 0/g' php-${PACKAGE_VERSION}/libevent/event.c; checkExit

# Because configure is broken in 5.2.4.
cp ${BUILDDIR}/config.cache ${PHPDIR}; checkExit


echo "# WPLib: Configure PHP ${PACKAGE_VERSION}."
cd ${PHPDIR}; checkExit

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
	--enable-fpm \
	--enable-cgi --enable-fastcgi --enable-force-cgi-redirect \
	--enable-cli \
	--disable-debug \
	--disable-rpath \
	--disable-static \
	--enable-shared \
	--with-pic \
	--without-mhash \
	--with-pear \
	--with-libedit \
	--enable-bcmath=shared \
	--with-bz2=shared \
	--enable-calendar=shared \
	--with-cdb \
	--enable-ctype=shared \
	--with-curl=shared \
	--with-freetype-dir=shared,/usr \
	--enable-ftp=shared \
	--enable-exif=shared \
	--with-gd=shared --enable-gd-native-ttf \
	--with-png-dir=shared,/usr \
	--with-gettext=shared \
	--with-gmp=shared \
	--with-iconv=shared \
	--with-imap=shared \
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
	--without-mssql \
	--enable-pdo=static \
	--with-pdo-mysql=shared,/usr/bin/mysql_config \
	--with-pdo-odbc=shared,unixODBC,/usr \
	--with-pdo-pgsql=shared \
	--with-pdo-sqlite=shared,/usr \
	--without-pdo-dblib \
	--with-pgsql=shared; checkExit

#	--with-imap-ssl=shared --with-openssl=shared
#	--enable-option-checking=fatal
#	--with-fpm-user=${WPLIB_USER}
#	--with-fpm-group=${WPLIB_GROUP}
#	--with-readline
#	--enable-phpdbg
#	--with-enchant=shared
#	--with-icu-dir=/usr
#	--enable-intl=shared
#	--enable-phar=shared
#	--with-sqlite3=shared,/usr
#	--enable-opcache


echo "# WPLib: Compile PHP ${PACKAGE_VERSION}."
make; checkExit


echo "# WPLib: Install PHP ${PACKAGE_VERSION}."
make install; checkExit
install -d -m755 /etc/php/conf.d/; checkExit
rmdir /usr/include/php/include; checkExit
mkdir -p /var/run/php; checkExit
ln /usr/bin/php-cgi /usr/sbin/php-fpm


echo "# WPLib: pecl update-channels."
# Fixup pecl errors.
# EG: "Warning: Invalid argument supplied for foreach() in /usr/share/pear/PEAR/Command.php
#     "Warning: Invalid argument supplied for foreach() in Command.php on line 249"
sed -i 's/^exec $PHP -C -n -q/exec $PHP -C -q/' /usr/bin/pecl; checkExit
pecl update-channels; checkExit


echo "# WPLib: Adding mbstring extension."
cd ${PHPDIR}/ext/mbstring; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# WPLib: Adding Imagick extension, (3.4.3)."
cd ${PHPDIR}/ext; checkExit
wget -nv http://pecl.php.net/get/imagick-3.4.3.tgz; checkExit
tar zxf imagick-3.4.3.tgz; checkExit
cd imagick-3.4.3; checkExit
patch -p0 < ${BUILDDIR}/php-5.2.4-imagick-3.4.3.patch
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


echo "# WPLib: Adding Xdebug extension, (2.2.7)."
cd ${PHPDIR}/ext; checkExit
wget -nv https://xdebug.org/files/xdebug-2.2.7.tgz; checkExit
tar zxf xdebug-2.2.7.tgz; checkExit
cd xdebug-2.2.7; checkExit
phpize; checkExit
./configure; checkExit
make; checkExit
make install; checkExit


# Produces this error:
# Failed loading /usr/lib/php/modules/opcache.so:  Error relocating /usr/lib/php/modules/opcache.so: expand_filepath_ex: symbol not found
#echo "# WPLib: Adding opcache extension, (7.0.4)."
#cd ${PHPDIR}/ext; checkExit
#wget -nv https://pecl.php.net/get/zendopcache-7.0.4.tgz; checkExit
#tar zxf zendopcache-7.0.4.tgz; checkExit
#cd zendopcache-7.0.4; checkExit
#phpize; checkExit
#./configure; checkExit
#make; checkExit
#make install; checkExit


if [ "$DEBUG_ME" == "1" ]
then
	exit
fi

# find . -type f -perm +0111 -exec strip --strip-all '{}'

echo "# WPLib: Removing build packages."
apk del wplib.build; checkExit

echo "# WPLib: Adding packages required by PHP ${PACKAGE_VERSION}."
RUNTIME_DEPS="$(scanelf --needed --nobanner --format '%n#p' --recursive /usr | tr ',' '\n' | sort -u | awk '/libmysqlclient.so.16/{next} system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }')"
echo "# ${RUNTIME_DEPS}"
apk add --no-cache --virtual wplib.runtime ${RUNTIME_DEPS}; checkExit

echo "# WPLib: Cleaning up."
rm -rf ${BUILDDIR}
unset BUILD_DEPS PERSIST_DEPS RUNTIME_DEPS CPPFLAGS LDFLAGS CFLAGS EXTENSION_DIR


################################################################################
