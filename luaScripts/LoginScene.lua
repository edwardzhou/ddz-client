require 'CCBReaderLoad'
require 'GuiConstants'

local LoginScene = class('LoginScene')

function LoginScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, LoginScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function LoginScene:ctor(...)
  self:init()
end

function LoginScene:init()
  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)
  
  local ui = ccs.GUIReader:getInstance():widgetFromJsonFile('UI/Landing/Landing.json')
--  ui:setAnchorPoint(0, 0)
--  ui:setPosition(0, 0)
  rootLayer:addChild(ui)
  local buttonHolder = ccui.Helper:seekWidgetByName(ui, 'buttonHolder')
  local loadingBar = ccui.Helper:seekWidgetByName(ui, 'loadingBar')
  loadingBar = tolua.cast(loadingBar, 'ccui.LoadingBar')
  local percent = 0
  ui:runAction( cc.Sequence:create(
    cc.Repeat:create(
      cc.Sequence:create(
        cc.DelayTime:create(0.02),
        cc.CallFunc:create(function()
          percent = percent + 1
          loadingBar:setPercent(percent) 
        end)), 
      100),
    cc.CallFunc:create(function()
        loadingBar:setVisible(false)
        buttonHolder:setVisible(true)
      end)
  ))
  
  local snow = cc.ParticleSystemQuad:create('scenes/Resources/snow.plist')
  snow:setPosition(200, 480)
  rootLayer:addChild(snow)

  snow = cc.ParticleSystemQuad:create('scenes/Resources/snow.plist')
  snow:setPosition(600, 480)
  rootLayer:addChild(snow)
  
  local function touchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      print('button clicked')
      cc.Director:getInstance():replaceScene(require('HallScene')())
    end
  end
  
  local buttonS = ccui.Helper:seekWidgetByName(ui, 'ButtonS')
  buttonS:addTouchEventListener(touchEvent)
  
  
--  local snow2 = cc.ParticleSnow:createWithTotalParticles(300)
--  --snow2:setPosition(400, 480)
--  snow2:setSpeed(40)
--  snow2:setSpeedVar(30)
--  snow2:setStartSize(18)
--  snow2:setStartSizeVar(14)
--  
--  -- Gravity Mode: radial
--  snow2:setRadialAccel(10);
--  snow2:setRadialAccelVar(1);
--  rootLayer:addChild(snow2)
  
  local editName = cc.EditBox:create(cc.size(120, 40), cc.Scale9Sprite:create('green_edit.png'))
  editName:setPosition(150, 50)
  ui:addNode(editName, 1000)

--  local proxy = cc.CCBReader
  
  
end

local function createScene()
  local scene = cc.Scene:createWithPhysics()
  return LoginScene.extend(scene)
end

return createScene