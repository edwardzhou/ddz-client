//
//  MobClickCpp.m
//  MobClickCpp
//
//  Created by zhangziqi on 14-2-24.
//  Copyright (c) 2014年 Umeng Inc. All rights reserved.
//

#ifndef __MobClickGameAnalytics__MobClickCpp__
#define __MobClickGameAnalytics__MobClickCpp__

#include <string>
#include <map>
using namespace std;


namespace umeng {
    class MobClickOnlineConfigUpdateDelegate {
        
    public:
        virtual void onUpdateFinished(bool succeed, void* pUserData) = 0;
    };
    
    typedef map<string, string> eventDict;
    typedef map<string, string> checkResultDict;
    
    
    class MobClickCpp {
    public:
        /** 设置是否打印sdk的log信息,默认不开启
         @param value 设置为true,umeng SDK 会输出log信息,记得release产品时要设置回false.
         @return .
         @exception .
         */
        
        static void setLogEnabled(bool value);
        
        
        /** 设置统计sdk网络连接的代理服务器 仅供调试抓包使用 release包中不要调用
         @param 
         @return .
         @exception .
         */
        static void setProxy(const char* host, int port);
        
        /** 设置app切到后台经过多少秒之后，切到前台会启动新session,默认30
         @param seconds 秒数
         @return .
         @exception .
         */
        static void setSessionIdleLimit(int seconds);
        
        ///---------------------------------------------------------------------------------------
        /// @name  开启统计
        ///---------------------------------------------------------------------------------------
        
        
        /** 开启友盟统计,默认以BATCH方式发送log.
         
         @param appKey 友盟appKey.
         @param channelId 渠道名称,为NULL或""时,ios默认会被被当作@"App Store"渠道，android默认为“Unknown”。
         @return void
         */
        static void startWithAppkey(const char * appKey, const char * channelId = NULL);
        
        /** 在AppDelegate的applicationDidEnterBackground中调用。
         
         @return void
         */
        static void applicationDidEnterBackground();
        
        /** 在AppDelegate的applicationWillEnterForeground中调用。
         
         @return void
         */
        static void applicationWillEnterForeground();
        
        /** 请在调用CCDirector的end()方法前调用。
         
         @return void
         */
        static void end();
        
        static void mainloop(float dt);
        
        ///---------------------------------------------------------------------------------------
        /// @name  事件统计
        ///---------------------------------------------------------------------------------------
        
        
        /** 自定义事件,数量统计.
         使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID
         
         @param  eventId 网站上注册的事件Id.
         @param  label 分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比,为NULL或空字符串时后台会生成和eventId同名的标签.
         @return void.
         */
        static void event(const char * eventId, const char * label = NULL);
        /** 自定义事件,数量统计.
         使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID
         */
        static void event(const char * eventId, eventDict * attributes, int counter = 0);

        
        ///---------------------------------------------------------------------------------------
        /// @name  页面计时
        ///---------------------------------------------------------------------------------------
        
        
        /** 页面时长统计,记录某个view被打开多长时间,可以自己计时也可以调用beginLogPageView,endLogPageView自动计时
         
         @param pageName 需要记录时长的view名称.
         @return void.
         */
        
        static void beginLogPageView(const char *pageName);
        static void endLogPageView(const char *pageName);
        
        ///---------------------------------------------------------------------------------------
        /// @name  在线参数
        ///---------------------------------------------------------------------------------------
        
        
        /** 使用在线参数功能，可以让你动态修改应用中的参数值,
         调用此方法您将自动拥有在线更改SDK端发送策略的功能,您需要先在服务器端设置好在线参数.
         请在startWithAppkey方法之后调用;
         @param 无.
         @return void.
         */
        
        static void updateOnlineConfig(MobClickOnlineConfigUpdateDelegate* pDelegate = NULL, void *pUserData = NULL);
        
        /** 获取缓存的在线参数的数值
         带参数的方法获取某个key的值，不带参数的获取所有的在线参数.
         需要先调用updateOnlineConfig才能使用
         
         @param key
         @return const char *  .
         */
        
        static string getConfigParam(const char * key);
        
        //游戏统计开始
        
        ///---------------------------------------------------------------------------------------
        /// @name  玩家属性设置
        ///---------------------------------------------------------------------------------------
        
        /** 设置玩家的等级、游戏中的唯一Id、性别、年龄和来源.
         */
        
        /** 设置玩家等级属性.
         @param level 玩家等级
         @return void
         */
        static void setUserLevel(const char *level);
        
        /** 设置玩家等级属性.
         @param userId 玩家Id
         @param sex 性别
         @param age 年龄
         @param platform 来源
         @return void
         */
        
        enum Sex{
            Unkonwn = 0,
            Male = 1,
            Female = 2,
        };
        static void setUserInfo(const char * userId, Sex sex, int age, const char * platform);
        
        ///---------------------------------------------------------------------------------------
        /// @name  关卡统计
        ///---------------------------------------------------------------------------------------
        
        /** 记录玩家进入关卡，通过关卡及失败的情况.
         */
        
        
        /** 进入关卡.
         @param level 关卡
         @return void
         */
        static void startLevel(const char * level);
        
        /** 通过关卡.
         @param level 关卡,如果level == NULL 则为当前关卡
         @return void
         */
        static void finishLevel(const char * level);
        
        /** 未通过关卡.
         @param level 关卡,如果level == NULL 则为当前关卡
         @return void
         */
        
        static void failLevel(const char * level);
        
        ///---------------------------------------------------------------------------------------
        /// @name  支付统计
        ///---------------------------------------------------------------------------------------
        
        /** 记录玩家使用真实货币的消费情况
         */
        
        
        /** 玩家支付货币兑换虚拟币.
         @param cash 真实货币数量
         @param source 支付渠道
         @param coin 虚拟币数量
         @return void
         */
        
        static void pay(double cash, int source, double coin);
        
        /** 玩家支付货币购买道具.
         @param cash 真实货币数量
         @param source 支付渠道
         @param item 道具名称
         @param amount 道具数量
         @param price 道具单价
         @return void
         */
        static void pay(double cash, int source, const char * item, int amount, double price);
        
        ///---------------------------------------------------------------------------------------
        /// @name  虚拟币购买统计
        ///---------------------------------------------------------------------------------------
        
        /** 记录玩家使用虚拟币的消费情况
         */
        
        
        /** 玩家使用虚拟币购买道具
         @param item 道具名称
         @param amount 道具数量
         @param price 道具单价
         @return void
         */
        static void buy(const char *item, int amount, double price);
        
        
        ///---------------------------------------------------------------------------------------
        /// @name  道具消耗统计
        ///---------------------------------------------------------------------------------------
        
        /** 记录玩家道具消费情况
         */
        
        
        /** 玩家使用虚拟币购买道具
         @param item 道具名称
         @param amount 道具数量
         @param price 道具单价
         @return void
         */
        
        static void use(const char * item, int amount, double price);
        
        
        ///---------------------------------------------------------------------------------------
        /// @name  虚拟币及道具奖励统计
        ///---------------------------------------------------------------------------------------
        
        /** 记录玩家获赠虚拟币及道具的情况
         */
        
        
        /** 玩家获虚拟币奖励
         @param coin 虚拟币数量
         @param source 奖励方式
         @return void
         */
        
        static void bonus(double coin, int source);
        
        /** 玩家获道具奖励
         @param item 道具名称
         @param amount 道具数量
         @param price 道具单价
         @param source 奖励方式
         @return void
         */
        
        static void bonus(const char * item, int amount, double price, int source);
        
        //游戏统计结束
    };

}
#ifndef UMENG_MOBCLICKCPP_SOURCE

#define INSTALL_UMENG_MAIN_LOOP \
umeng::MobClickCppDelegate* delegete = new umeng::MobClickCppDelegate; \
cocos2d::CCDirector::sharedDirector()->getScheduler()->scheduleSelector(schedule_selector(umeng::MobClickCppDelegate::mainloop), (delegete), 0, false);

#include "cocos2d.h"

namespace umeng {
    class MobClickCppDelegate : public cocos2d::CCObject {
        
    public:
        virtual void mainloop(float dt){
            MobClickCpp::mainloop(dt);
        }
    };
    
}

#define MOBCLICKCPP_START_WITH_APPKEY_AND_CHANNEL(appkey, channel)  \
INSTALL_UMENG_MAIN_LOOP;\
umeng::MobClickCpp::startWithAppkey((appkey), (channel));

#define MOBCLICKCPP_START_WITH_APPKEY(appkey)   MOBCLICKCPP_START_WITH_APPKEY_AND_CHANNEL(appkey, NULL)


#endif

#endif
