#!/bin/sh
if test -d /usr/share/doc/unstet/raspi-autostart/; then
   mkdir -p $HOME/.config/autostart
   cp /usr/share/doc/unstet/raspi-autostart/* $HOME/.config/autostart/
fi
