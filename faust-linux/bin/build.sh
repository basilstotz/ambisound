#!/bin/sh

NAME="faust-linux"

find . -name "*_all.deb" -exec rm \{\} \;
sed  $NAME/DEBIAN/control.template -e "s/%%version%%/$(date +%s)/" > $NAME/DEBIAN/control
dpkg-deb -b $NAME .
rm $NAME/DEBIAN/control

