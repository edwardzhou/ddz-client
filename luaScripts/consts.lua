ddz = ddz or {}

ddz.SignInType = {
  BY_AUTH_TOKEN = 1,
  BY_SESSION_TOKEN = 2,
  BY_PASSWORD = 3
}

ddz.PlayerStatus = {
  None = 0,             -- 无效
  Ready = 1,            -- 准备
  NoGrabLord = 2,       -- 不叫
  GrabLord = 3,         -- 叫地主
  PassGrabLord = 4,     -- 不抢
  ReGrabLord = 5,       -- 抢地主
  Playing = 6
}

ddz.PlayerRoles = {
  None = 0,
  Farmer = 1,
  Lord = 2
}

ddz.PokecardPickTags = {
  Unpicked = 1000,
  Picked = 1003
}

ddz.PokecardPickColors = {
  Normal = cc.c3b(255, 255, 255),
  Selected = cc.c3b(0x99, 0x99, 0x99)
}

ddz.PokeGameStatus = {
  None = 0,
  WaitingForReady = 1,
  GrabbingLord = 2,
  Playing = 3,
  GameOver = 4
}

ddz.Actions = {}
ddz.Actions.GrabbingLord = {
  None = 0, -- 不叫
  Grab = 1, -- 叫地主
}

ddz.ErrorCode = {
  -- 成功，正常
  SUCCESS = 0,
  OK = 0,

  -- 连接未授权
  CONNECTION_NOT_AUTHED = 10,
  -- 连接授权失败
  CONNECTION_AUTH_FAILED = 11,
  -- 客户端版本被禁用
  CLIENT_APP_VERSION_PROHIBITTED = 12,
  -- 客户端设备被禁用
  CLIENT_DEVICE_PROHIBITTED = 13,
  -- 未登录
  CLIENT_NOT_SIGNED_YET = 14,

  -- 用户不存在
  USER_NOT_FOUND = 100,
  -- 用户被禁用
  USER_PROHIBITTED = 110,
  -- 密码不匹配
  PASSWORD_INCORRECT = 101,
  -- 登录token无效
  AUTH_TOKEN_INVALID = 102,
  -- 会话token过期
  SESSION_TOKEN_EXPIRED = 103,

  -- 无效请求
  INVALID_REQUEST = 1001,
  -- 非本轮玩家的请求
  NOT_IN_TURN = 1002,
  -- 无效的叫地主分 (地主分必须>=0 <=3, 且>0时，必须大于前一个地主分)
  INVALID_GRAB_LORD_VALUE = 1003,

  -- 桌子已经有3个用户
  TABLE_FULL = 2001,
  CANNOT_ENTER_ROOM = 2100,

  -- 无效牌型
  INVALID_CARD_TYPE = 3001,
  -- 牌型打不过上手牌（1. 牌型不配， 2. 没有大过对方）
  INVALID_PLAY_CARD = 3002,


  SYSTEM_ERROR = 100000,

  -- no use, just for a stub.
  STUB  = -1
}

GlobalSetting = {
  content_scale_factor = 1
}

return ddz