#!/bin/sh

serials=`adb devices | grep -v List | awk '{print $1;}'`

pkg="com.fungame.DDZ"
apk="runtime/android/DDZ-debug.apk"

#echo "pkg => " $1

#echo $serials
for sid in $serials
do
  #echo "adb -s $sid uninstall $pkg"
  adb -s $sid push Resources/ /sdcard/fungame/DDZ/res
done

