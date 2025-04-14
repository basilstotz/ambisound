#!/bin/sh

#unstet
find . -name "unstet_*_all.deb" -exec rm \{\} \;
sed  unstet/DEBIAN/control.template -e "s/%%version%%/$(date +%s)/" > unstet/DEBIAN/control
dpkg-deb -b unstet .
rm unstet/DEBIAN/control

#osctools
find . -name "osctools_*_all.deb" -exec rm \{\} \;
sed  osctools/DEBIAN/control.template -e "s/%%version%%/$(date +%s)/" > osctools/DEBIAN/control
dpkg-deb -b osctools .
rm osctools/DEBIAN/control

