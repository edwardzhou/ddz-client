#!/bin/sh

serials=`adb devices | grep -v List | awk '{print $1;}'`

pkg="com.fungame.DDZ"
apk="runtime/android/DDZ-debug.apk"

#echo "pkg => " $1

#zip -r lua.zip luaScripts/*

#echo $serials
for sid in $serials
do
  #echo "adb -s $sid uninstall $pkg"
  adb -s $sid push luaScripts/ /sdcard/fungame/DDZ/luaScripts
  #adb -s $sid push lua.zip /sdcard/fungame/DDZ/
  #adb -s $sid shell "cd /sdcard/fungame/DDZ ; unzip -o lua.zip"
done

