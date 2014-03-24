#!/bin/sh
rm -rf bin
./build_native.py
ant debug install
adb shell monkey -p com.fungame.DDZ -v 1
