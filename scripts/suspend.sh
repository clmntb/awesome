#!/bin/sh

# Ubuntu:
#dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend

# Archlinux:
systemctl suspend &
i3lock-fancy
