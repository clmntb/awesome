#!/bin/sh

# Ubuntu:
#dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Hibernate

# Archlinux
systemctl hibernate &
i3lock-fancy
