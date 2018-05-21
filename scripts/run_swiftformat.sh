#!/bin/sh

OPTIONS="--indent tabs"

echo $FOLDERS

if which swiftformat >/dev/null; then
    swiftformat . $OPTIONS
else
	echo "warning: SwiftFormat is not installed."
fi
