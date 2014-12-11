#!/bin/sh

serials=`adb devices | grep -v List | awk '{print $1;}'`

pkg="com.fungame.DDZ"
apk="runtime/android/DDZ-debug.apk"

#echo "pkg => " $1

rm -rf Resources/NewUI/*
cp -r ../DDZ_Res/NewGameUI/res/* Resources/NewUI/

rm -f res.zip
zip -r res.zip Resources

#echo $serials
for sid in $serials
do
  #echo "adb -s $sid uninstall $pkg"
  #adb -s $sid push luaScripts/ /sdcard/fungame/DDZ/lua
  adb -s $sid push res.zip /sdcard/fungame/DDZ/
  adb -s $sid shell "cd /sdcard/fungame/DDZ ; unzip -o res.zip"
done

