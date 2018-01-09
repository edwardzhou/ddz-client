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
  Apache Ant 1.9
  
  
编译环境配置:
  
  
编译:


运行


# 版权说明
代码仅供学习使用，如果要作为商用，游戏的资源必须全部替换。

