# build
/android/android-ndk-r8e/ndk-build -j 2

echo
if [ "0" != "$?" ]; then
    echo "Build error occoured!!!"
    exit 1
fi

echo
echo "Native build action success."
exit 0