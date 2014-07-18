--require 'CCBReaderLoad'
require 'GuiConstants'

require 'PokeCard'

local cjson = require('cjson.safe')

local LandingScene = class('LandingScene')

function LandingScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, LandingScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function LandingScene:ctor(...)
  self:init()
end

function LandingScene:init()
  local this = self

  umeng.MobClickCpp:beginScene('landing scene')
  umeng.MobClickCpp:beginEvent('test')
  umeng.MobClickCpp:pay(10, 2, 1000)


  self:registerScriptHandler(function(event)
    print('event => ', event)
    if event == "enterTransitionFinish" then
      self:initKeypadHandler()
    elseif event == 'exit' then
      -- umeng:stopSession()
    end
  end)

  local rootLayer = cc.Layer:create()

  self:addChild(rootLayer)
  self.rootLayer = rootLayer
  
  local uiRoot = ccs.GUIReader:getInstance():widgetFromBinaryFile('UI/Landing.csb')
  print( 'uiRoot => ', uiRoot)
  rootLayer:addChild(uiRoot)
  self.uiRoot = uiRoot

  require('utils.UIVariableBinding').bind(uiRoot, self, self)

  local percent = 0
  uiRoot:runAction( cc.Sequence:create(
    cc.Repeat:create(
      cc.Sequence:create(
        cc.DelayTime:create(0.02),
        cc.CallFunc:create(function()
          percent = percent + 1
          this.LoadingBar:setPercent(percent) 
        end)), 
      100),
    cc.CallFunc:create(function()
        this.LoadingBar:setVisible(false)
        umeng.MobClickCpp:endEvent('test')
      end)
  ))
  
  local snow = cc.ParticleSystemQuad:create('snow.plist')
  snow:setPosition(200, 480)
  rootLayer:addChild(snow)

  snow = cc.ParticleSystemQuad:create('snow.plist')
  snow:setPosition(600, 480)
  rootLayer:addChild(snow)

  cc.SpriteFrameCache:getInstance():addSpriteFrames('dialogs.plist')

  self:runAction(cc.Sequence:create(
    cc.DelayTime:create(0.3),
    cc.CallFunc:create(function()
      print('start to load allCardTypes.json')
      local jsonStr = cc.FileUtils:getInstance():getStringFromFile('allCardTypes.json')
      print('start to decode allCardTypes.json')
      AllCardTypes = cjson.decode(jsonStr)
      print('decode allCardTypes.json finished')
    end),
    cc.DelayTime:create(0.1),
    cc.CallFunc:create(function()
      PokeCard.sharedPokeCard()
      local pokefile = 'pc.png'
      if not cc.FileUtils:getInstance():isFileExist(pokefile) then
        cc.SpriteFrameCache:getInstance():addSpriteFrames('pokecards.plist')
        this:generatePokecards()
      else
        local tex = cc.Director:getInstance():getTextureCache():addImage(pokefile)
        PokeCard.createPokecardsFrames(tex)
        PokeCard.createPokecardsWithFrames(tex)
      end
    end)
  ))
  
end

function LandingScene:ButtonStart_onClicked(sender, eventType)
  local scene = require('HallScene')()
  cc.Director:getInstance():pushScene(scene)
end

function LandingScene:ButtonSignIn_onClicked(sender, eventType)
  cc.Director:getInstance():endToLua()
end

function LandingScene:ButtonSignUp_onClicked(sender, eventType)
  local scene = require('login.LoginScene')()
  cc.Director:getInstance():pushScene(scene)
end

function LandingScene:ButtonConnect_onClicked(sender, eventType)
  self:connectToServer()
end

function LandingScene:generatePokecards()
  local this = self
  local function screenCap()
      local batchNode = PokeCard.createRawPokecardTextures()
      local renderTexture = cc.RenderTexture:create(1024, 1024, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
      this.renderTexture = renderTexture

      batchNode:retain()
      renderTexture:retain()

      renderTexture:begin()

      for row=0, 5 do
        for col=1, 10 do
          if row == 5 and col >4 then
            break
          end

          local index = row * 10 + col
          local poke = g_shared_cards[index]
          local sprite = poke.card_sprite
          sprite:setVisible(true)
          sprite:setPosition((col-1) * 100, row * 140)
        end
      end

      batchNode:visit()

      renderTexture:endToLua()

      --local this = self
      this:runAction(cc.Sequence:create(
          cc.DelayTime:create(0.01),
          cc.CallFunc:create(function() 
            --renderTexture:saveToFile(ddz.getDataStorePath() .. '/pc.png', cc.IMAGE_FORMAT_PNG)
            local pImage = renderTexture:newImage()
            pImage:saveToFile(ddz.getDataStorePath() .. '/pc.png', false);

            local tex = cc.Director:getInstance():getTextureCache():addUIImage(pImage, 'pc.png')

            pImage:release()

            -- local sprite = cc.Sprite:createWithTexture(tex, cc.rect(0, 1024-140, 100, 140))
            -- sprite:setAnchorPoint(0,0)
            -- sprite:setPosition(0, 0)
            -- sprite:setLocalZOrder(200)
            -- this.uiRoot:addChild(sprite)
            renderTexture:release()
            batchNode:release()
            PokeCard.createPokecardsFrames(tex)
            PokeCard.createPokecardsWithFrames(tex)

            -- g_pokecards_node:setLocalZOrder(200)
            -- this.uiRoot:addChild(g_pokecards_node)
            -- local sprite = PokeCard.getCardById('b03').card_sprite
            -- sprite:setPosition(0, 0)
            -- sprite:setVisible(true)
           end)
        ))
  end

  screenCap()

end

function LandingScene:reconnectToServer()
  self.connection:reconnect()
end

function LandingScene:connectToServer()
  local this = self

  local sessionInfo = ddz.loadSessionInfo() or {}
  local sessionToken = sessionInfo.sessionToken
  local lastSessionToken = sessionInfo.sessionToken
  local userId = sessionInfo.userId

  local function queryRooms()
    ddz.pomeloClient:request('ddz.entryHandler.queryRooms', {}, function(data) 
      dump(data, 'queryRooms => ')
      if data.err == nil then
        ddz.GlobalSettings.rooms = data.rooms
        this.ButtonStart:setVisible(true)
      end
    end)
  end

  local function onGameServerConnected(sender, pomelo, data)
    queryRooms()
  end

  local function connectToGameServer(success, userInfo)
    if not success then
      this:signUp(connectToGameServer)
      return
    end

    local userId = ddz.GlobalSettings.session.userId
    if ddz.GlobalSettings.session and ddz.GlobalSettings.session.sessionToken then
      sessionToken = ddz.GlobalSettings.session.sessionToken 
    else
      sessionToken = lastSessionToken
    end
    local serverInfo = ddz.GlobalSettings.serverInfo
    self:connectTo(serverInfo.host, serverInfo.port, userId, sessionToken, onGameServerConnected)
  end

  local onConnectionReady = function(sender, pomelo, data)
    if userId == nil or data.needSignUp == true then
      this:signUp(connectToGameServer)
    elseif data.needSignIn == true then
      this:signIn(sessionInfo, connectToGameServer)
    else
      local newUserInfo = data.user
      local serverInfo = data.server
      ddz.GlobalSettings.userInfo = newUserInfo
      ddz.GlobalSettings.session.userId = newUserInfo.userId
      ddz.GlobalSettings.session.authToken = newUserInfo.authToken
      ddz.GlobalSettings.session.sessionToken = data.sessionToken
      ddz.GlobalSettings.serverInfo = table.dup(data.server)
      newUserInfo.sessionToken = data.sessionToken
      sessionToken = data.sessionToken
      ddz.saveSessionInfo(newUserInfo)
      connectToGameServer(true, newUserInfo, serverInfo)
    end
  end

  -- if ddz.pomeloClient then
  --   ddz.pomeloClient:disconnect()
  -- end



  --self:connectTo('192.168.1.165', '4001', sessionInfo.userId, sessionInfo.sessionToken, onConnectionReady)
  if self.connection == nil then
    self.connection = require('network.GameConnection')
    self.connection:on('connectionReady', function()
        queryRooms()
      end)
  end

  self.connection:connectToServer({
    host = '192.168.1.165',
    port = 4001
  });

end

function LandingScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    print('[LandingScene:initKeypadHandler] keyCode : ', keyCode, 'event: ', event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      --      if type(self.onMainMenu) == 'function' then
      --        self.onMainMenu()
      --      end
      umeng.MobClickCpp:endScene('landing scene')
      umeng.MobClickCpp:endToLua()
      cc.Director:getInstance():endToLua()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      self:connectToServer()
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

end

-- require('network.ConnectionPlugin').bind(LandingScene)
-- require('landing.SignInPlugin').bind(LandingScene)
-- require('landing.SignUpPlugin').bind(LandingScene)

local function createScene()
  local scene = cc.Scene:create()
  return LandingScene.extend(scene)
end

return createScene