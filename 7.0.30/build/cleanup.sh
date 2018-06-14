#!/bin/sh

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

