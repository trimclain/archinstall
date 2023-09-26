#!/bin/bash

###############################################################################
# Create Touchpad Config
###############################################################################
# Useful Info in /usr/share/X11/xorg.conf.d/40-libinput.conf

MSG="Section \"InputClass\"\n\tIdentifier \"Touchpad\"\n\tMatchDriver \"libinput\"\n\tMatchIsTouchpad \"on\"\n\tOption \"Tapping\" \"on\"\n\tOption \"NaturalScrolling\" \"true\"\nEndSection"
CONFIG="/etc/X11/xorg.conf.d/30-touchpad.conf"

if [[ ! -f "$CONFIG" ]]; then
    echo -e "$MSG" | sudo tee "$CONFIG" > /dev/null
fi
