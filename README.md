# 斗地主游戏客户端

斗地主客户端采用cocos2dx-lua + CocoStudio完成. 
逻辑代码全用lua脚本编写，通过WebSocket + Protobuf 与 服务端通信，protobuf与消息协议的优化，可以极大压缩消息包，一局消耗的流量大约在 2k ~ 4k 之间。
我们前一个版本用json，一局下来消耗的流量基本上 > 200K.

目前只有安卓版，其他平台的版本，可以自己按照cocos2dx的规则修改编译。

开发工具： 

  Cocos2dx-3.7.1 Lua
  
  CocoStudio 2.x
  
  Android NDK r10e
  
  Android SDK R22
  
  Apache Ant 1.10.1
  
  
后台服务器采用 Nodejs Pomelo 开发， https://github.com/edwardzhou/ddz-server
  
编译环境配置:

```
mkdir ~/develop
cd ~/develop

# 解压 cocos2d-x
unzip ~/Downloads/cocos2d-x-3.7.1.zip
ln -nfs cocos2d-x-3.7.1 cocos2d-x-current

# 解压 ant
tar xvf ~/Downloads/apache-ant-10.1-bin.tar.gz

# 解压 android sdk
unzip ~/Downloads/android22-sdk-macosx.zip

# 解压 ndk
unzip ~/Downloads/android-ndk-r10e-darwin-x86_64.zip

```

#### 添加环境变量 ~/.bashrc 或者 ~/.zshrc (如果使用zsh)

vi ~/.bashrc
```
export NDK_ROOT=$HOME/develop/android-ndk-r10e
export SDK_ROOT=$HOME/develop/sdk
export ANDROID_SDK_HOME=$SDK_ROOT
export ANDROID_SDK_ROOT=$SDK_ROOT
export ANDROID_NDK_ROOT=$NDK_ROOT
export ANDROID_HOME=$SDK_ROOT
export ANT_HOME=$HOME/develop/apache-ant-1.10.1
export ANT_ROOT=$ANT_HOME/bin
export M2_HOME=$HOME/develop/maven
export GRADLE_HOME=$HOME/develop/gradle

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_151.jdk/Contents/Home
export PATH=$HOME/bin:$SDK_ROOT/platform-tools:$SDK_ROOT/tools:$ANT_HOME/bin:$PATH
```

运行android下载 platform
```
android
```
下载 Android 4.4.2 (API 19) 包括 ARM EABI v7a System Image.


  
  
编译:
```
git clone https://github.com/edwardzhou/ddz-client.git
cd ddz-client
# 启动多个编译进程并行编译 (建议CPU核数x2) , 如我的是 MBP I7 4核，可以启动 8个编译进程
cocos compile -pandroid -j8

# 编译好的apk在 simulator/android/DDZ-debug.apk 
```

启动模拟器运行
```
android avd 
# 创建新的AVD启动模拟器，把apk拖进模拟器进行安装
```

也可以下载 网易的MuMu模拟器运行, 这个会快很多


# 版权说明
代码仅供学习使用，如果要作为商用，游戏的资源必须全部替换。

