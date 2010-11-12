#!/bin/sh

LINSTALLED="/Library/Input Methods/Baram.app/Contents/SharedSupport/BaramRemapper"
HINSTALLED="$HOME/Library/Input Methods/Baram.app/Contents/SharedSupport/BaramRemapper"

if [ -e "$HINSTALLED" ]; then
    echo "Execute $HINSTALLED"
    exec "$HINSTALLED"
else
    echo "Execute $LINSTALLED"
    exec "$LINSTALLED"
fi

