#!/bin/sh


LINK="https://github.com/Cycling74/max-sdk/releases/download/v8.2.0/max-sdk-8.2-release.zip"
NAME=$(basename -s .zip $LINK)


if [ ! -d /usr/local/include/c74support ]; then
	if [ ! -f $NAME.zip ]; then
		wget $LINK -o $NAME.zip
	fi
	test -d max-sdk || unzip $NAME.zip
	sudo cp -r max-sdk/source/max-sdk-base/c74support/ /usr/local/include/
fi 
