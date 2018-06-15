#!/bin/sh


checkExit()
{
	if [ "$?" != "0" ]
	then
		echo "# WPLib Box: Exit reason \"$@\""
		exit $?
	fi
}

if [ "$BUILD_TYPE" != "" ]
then
	echo "# WPLib Box: Maintaining build packages for build type \"$BUILD_TYPE\"."
	exit
fi

# find . -type f -perm +0111 -exec strip --strip-all '{}'

echo "# WPLib Box: Removing build packages for runtime."
apk del wplib.build; checkExit

echo "# WPLib Box: Adding packages required by PHP ${PACKAGE_VERSION}."
RUNTIME_DEPS="$(scanelf --needed --nobanner --format '%n#p' --recursive /usr | tr ',' '\n' | sort -u | awk '/libmysqlclient.so.16/{next} system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }')"
echo "# ${RUNTIME_DEPS}"
apk add --no-cache --virtual wplib.runtime ${RUNTIME_DEPS}; checkExit

echo "# WPLib Box: Cleaning up."
rm -rf ${BUILDDIR}
unset BUILD_DEPS PERSIST_DEPS RUNTIME_DEPS CPPFLAGS LDFLAGS CFLAGS EXTENSION_DIR

apk del libx11-1.6.5-r1 gnupg-2.2.3-r1 imagemagick6-libs-6.9.9.26-r0 ncurses-terminfo-6.0_p20171125-r0 ghostscript-9.22-r0 net-snmp-libs-5.7.3-r10 shared-mime-info-1.9-r0 harfbuzz-1.6.3-r0 gnupg1-1.4.22-r0 gnutls-3.6.1-r0 libxcb-1.12-r1 c-client-2007f-r7 cairo-1.14.10-r0 shadow-4.5-r0 db-5.3.28-r0 sqlite-libs-3.21.0-r1 cups-libs-2.2.5-r0 linux-pam-1.3.0-r0 freetype-2.8.1-r3 unixodbc-2.3.4-r2 p11-kit-0.23.2-r2 pango-1.40.14-r0 pixman-0.34.0-r3 musl-1.1.18-r3 wget-1.19.5-r0 libldap-2.4.45-r3

