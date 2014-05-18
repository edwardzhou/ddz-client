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
  ReGrabLord = 5        -- 抢地主
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

GlobalSetting = {
  content_scale_factor = 1
}

return ddz