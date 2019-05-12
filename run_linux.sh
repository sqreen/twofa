#!/bin/bash

CONFIG=debug
swift build -c $CONFIG
EXECUTABLE="$(find .build -name TwoFa | grep $CONFIG | grep -v dSYM | grep linux)"

PYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so.1 $EXECUTABLE $@

