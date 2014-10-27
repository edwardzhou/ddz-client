
--------------------------------
-- @module MobClickCpp
-- @parent_module umeng

--------------------------------
--  使用在线参数功能，可以让你动态修改应用中的参数值,<br>
-- 调用此方法您将自动拥有在线更改SDK端发送策略的功能,您需要先在服务器端设置好在线参数.<br>
-- 请在startWithAppkey方法之后调用;<br>
-- param 无.<br>
-- return void.
-- @function [parent=#MobClickCpp] updateOnlineConfig 
-- @param self
        
--------------------------------
--  设置玩家等级属性.<br>
-- param level 玩家等级<br>
-- return void
-- @function [parent=#MobClickCpp] setUserLevel 
-- @param self
-- @param #char level
        
--------------------------------
--  玩家使用虚拟币购买道具<br>
-- param item 道具名称<br>
-- param amount 道具数量<br>
-- param price 道具单价<br>
-- return void
-- @function [parent=#MobClickCpp] use 
-- @param self
-- @param #char item
-- @param #int amount
-- @param #double price
        
--------------------------------
--  设置app切到后台经过多少秒之后，切到前台会启动新session,默认30<br>
-- param seconds 秒数<br>
-- return .<br>
-- exception .
-- @function [parent=#MobClickCpp] setSessionIdleLimit 
-- @param self
-- @param #int seconds
        
--------------------------------
--  获取缓存的在线参数的数值<br>
-- 带参数的方法获取某个key的值，不带参数的获取所有的在线参数.<br>
-- 需要先调用updateOnlineConfig才能使用<br>
-- param key<br>
-- return const char *  .
-- @function [parent=#MobClickCpp] getConfigParam 
-- @param self
-- @param #char key
-- @return string#string ret (return value: string)
        
--------------------------------
-- @overload self, double, int, char, int, double         
-- @overload self, double, int, double         
-- @function [parent=#MobClickCpp] pay
-- @param self
-- @param #double cash
-- @param #int source
-- @param #char item
-- @param #int amount
-- @param #double price

--------------------------------
--  页面时长统计,记录某个view被打开多长时间,可以自己计时也可以调用beginLogPageView,endLogPageView自动计时<br>
-- param pageName 需要记录时长的view名称.<br>
-- return void.
-- @function [parent=#MobClickCpp] beginLogPageView 
-- @param self
-- @param #char pageName
        
--------------------------------
-- 
-- @function [parent=#MobClickCpp] endLogPageView 
-- @param self
-- @param #char pageName
        
--------------------------------
--  设置统计sdk网络连接的代理服务器 仅供调试抓包使用 release包中不要调用<br>
-- param <br>
-- return .<br>
-- exception .
-- @function [parent=#MobClickCpp] setProxy 
-- @param self
-- @param #char host
-- @param #int port
        
--------------------------------
--  玩家使用虚拟币购买道具<br>
-- param item 道具名称<br>
-- param amount 道具数量<br>
-- param price 道具单价<br>
-- return void
-- @function [parent=#MobClickCpp] buy 
-- @param self
-- @param #char item
-- @param #int amount
-- @param #double price
        
--------------------------------
--  未通过关卡.<br>
-- param level 关卡,如果level == NULL 则为当前关卡<br>
-- return void
-- @function [parent=#MobClickCpp] failLevel 
-- @param self
-- @param #char level
        
--------------------------------
-- @overload self, char, int, double, int         
-- @overload self, double, int         
-- @function [parent=#MobClickCpp] bonus
-- @param self
-- @param #char item
-- @param #int amount
-- @param #double price
-- @param #int source

--------------------------------
--  请在调用CCDirector的end()方法前调用。<br>
-- return void
-- @function [parent=#MobClickCpp] end 
-- @param self
        
--------------------------------
--  设置是否打印sdk的log信息,默认不开启<br>
-- param value 设置为true,umeng SDK 会输出log信息,记得release产品时要设置回false.<br>
-- return .<br>
-- exception .
-- @function [parent=#MobClickCpp] setLogEnabled 
-- @param self
-- @param #bool value
        
--------------------------------
--  进入关卡.<br>
-- param level 关卡<br>
-- return void
-- @function [parent=#MobClickCpp] startLevel 
-- @param self
-- @param #char level
        
--------------------------------
--  在AppDelegate的applicationDidEnterBackground中调用。<br>
-- return void
-- @function [parent=#MobClickCpp] applicationDidEnterBackground 
-- @param self
        
--------------------------------
--  在AppDelegate的applicationWillEnterForeground中调用。<br>
-- return void
-- @function [parent=#MobClickCpp] applicationWillEnterForeground 
-- @param self
        
--------------------------------
--  开启友盟统计,默认以BATCH方式发送log.<br>
-- param appKey 友盟appKey.<br>
-- param channelId 渠道名称,为NULL或""时,ios默认会被被当作@"App Store"渠道，android默认为“Unknown”。<br>
-- return void
-- @function [parent=#MobClickCpp] startWithAppkey 
-- @param self
-- @param #char appKey
-- @param #char channelId
        
--------------------------------
-- 
-- @function [parent=#MobClickCpp] setUserInfo 
-- @param self
-- @param #char userId
-- @param #int sex
-- @param #int age
-- @param #char platform
        
--------------------------------
--  通过关卡.<br>
-- param level 关卡,如果level == NULL 则为当前关卡<br>
-- return void
-- @function [parent=#MobClickCpp] finishLevel 
-- @param self
-- @param #char level
        
return nil
