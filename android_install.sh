#!/bin/sh
#`awk '{system("cocos compile -j8 -p android")}'`
if [ "$1" != "-nobuild" ]
then
  cocos compile -j8 -p android $*
  cocos_ret=$?
  echo "cocos build returns " $cocos_ret
  if [ $cocos_ret != 0 ]
  then
    exit 1;
  fi
fi

serials=`adb devices | grep -v List | awk '{print $1;}'`

pkg="com.fungame.DDZ"
apk="runtime/android/DDZ-debug.apk"
act="com.fungame.DDZ.AppActivity"

#echo "pkg => " $1

#echo $serials
for sid in $serials
do
  echo "adb -s $sid uninstall $pkg"
  adb -s $sid uninstall $pkg
  echo "adb -s $sid install -r $apk"
  adb -s $sid install -r $apk 
  adb -s $sid shell am start -n  "$pkg/$act"
done

