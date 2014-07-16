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
  self.rootLayer = rootLayer
  self:addChild(rootLayer)

  local guiReader = ccs.GUIReader:getInstance()
  local uiRoot = guiReader:widgetFromBinaryFile('UI/Login.csb')
  self.uiRoot = guiReader
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  self:bindPanelInput(self.PanelUserId, self.InputUserId)
  self:bindPanelInput(self.PanelPassword, self.InputPassword)

  if ddz.GlobalSettings.userInfo.userId ~= nil then
    self.InputUserId:setText(ddz.GlobalSettings.userInfo.userId)
    self.InputPassword:setText('********')
  end

end

function LoginScene:bindPanelInput(panel, input)
  panel:addTouchEventListener( function(sender, eventType) 
      if eventType == ccui.TouchEventType.ended then
        input:attachWithIME()
      end
    end)
end

function LoginScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
--      if type(self.onMainMenu) == 'function' then
--        self.onMainMenu()
--      end
      event:stopPropagation()
      cc.Director:getInstance():popScene() 
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function LoginScene:ButtonSignIn_onClicked(sender, event)
  require('UICommon.MessageBox').showMessageBox(self.rootLayer, '请输入', '请输入ID和密码')
end


local function createScene()
  local scene = cc.Scene:create()
  return LoginScene.extend(scene)
end

return createScene