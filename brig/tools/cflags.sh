#!/bin/bash

QT_INCLUDE_STR=`qmake -query | grep QT_INSTALL_HEADERS`
QT_INCLUDE="${QT_INCLUDE_STR##*:}"
QT_VERSION_STR=`qmake -query | grep QT_VERSION`
QT_VERSION="${QT_VERSION_STR##*:}"
for module in "$@";
do
	qt_module="${module##Qt5}"
	if [ "${module}" != "${qt_module}" ];
	then
		echo -n `pkg-config --cflags "${module}"` "-I${QT_INCLUDE}/Qt${qt_module}/${QT_VERSION}" ''
	else
		echo -n `pkg-config --cflags "${module}"` ''
	fi
done
echo
