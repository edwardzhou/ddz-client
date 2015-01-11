#!/bin/sh

serials=`adb devices | grep -v List | awk '{print $1;}'`

pkg="com.fungame.DDZ"
apk="runtime/android/DDZ-debug.apk"

#echo "pkg => " $1

cd luaScripts
zip -r ../luaScripts.zip *
cd ../src
zip -r ../luaScripts.zip *
cd ..

#echo $serials
for sid in $serials
do
  #echo "adb -s $sid uninstall $pkg"
  adb -s $sid push luaScripts.zip /sdcard/fungame/DDZ/luaScripts.zip
  #adb -s $sid push lua.zip /sdcard/fungame/DDZ/
  #adb -s $sid shell "cd /sdcard/fungame/DDZ ; unzip -o lua.zip"
done

