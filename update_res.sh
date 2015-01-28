#!/bin/sh

serials=`adb devices | grep -v List | awk '{print $1;}'`

pkg="com.fungame.DDZ"
apk="runtime/android/DDZ-debug.apk"

#echo "pkg => " $1

rm -rf Resources/NewUI/*
cp -r ../DDZ_Res/NewGameUI/res/* Resources/NewUI/
