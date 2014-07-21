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

  if ddz.GlobalSettings.userInfo and ddz.GlobalSettings.userInfo.userId ~= nil then
    self.InputUserId:setText(ddz.GlobalSettings.userInfo.userId)
    self.InputPassword:setText(ddz.GlobalSettings.userInfo.authToken or '')
  else
    self.InputUserId:setText('')
    self.InputPassword:setText('')
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
  local params = {buttonType = 'ok'}

  local userId = string.trim(self.InputUserId:getStringValue())
  local password = string.trim(self.InputPassword:getStringValue())
  if #userId == 0 and #password == 0 then
    params.msg = '请输入账户ID和密码'
  elseif #userId == 0 then
    params.msg = '请输入账户ID'
  elseif #password == 0 then
    params.msg = '请输入密码'
  end

  if params.msg then
    require('UICommon.MessageBox').showMessageBox(self.rootLayer, params)
    return
  end
end

function LoginScene:ButtonQuickSignUp_onClicked(sender, event)
  local this = self
  local msg = '请输入ID和密码请输入ID和密码码....'
  local n = 1
  this:runAction(cc.Repeat:create(cc.Sequence:create(
      cc.CallFunc:create(function() 
          local closeOnTouch = math.random(10000) % 2
          local params = {
            msg = msg .. n .. ' closeOnTouch => ' .. closeOnTouch,
            showingTime = 3,
            --grayBackground = math.random(10000) % 2 == 1,
            showLoading = math.random(10000) % 2 == 1,
            closeOnTouch = closeOnTouch == 1,
          }
          require('UICommon.ToastBox').showToastBox(this.rootLayer, params)
          n = n + 1
        end),
      cc.DelayTime:create(3.2)
    ), 10))
          -- local params = {
          --   msg = msg .. n,
          --   showingTime = 3,
          --   grayBackground = math.random(10000) % 2 == 1,
          --   showLoading = math.random(10000) % 2 == 1,
          -- }
          -- require('UICommon.ToastBox').showToastBox(this.rootLayer, params)
          -- n = n + 1
end

function LoginScene:ButtonSwitchAccount_onClicked(sender, eventType)  local userIds = {'11111111', '22222222', '33333333', '44444444', '55555555', '666666666', '7777777'}
  if #self.ListViewAccounts:getItems() == 0 then
    local panelSpan = ccui.Layout:create()
    panelSpan:setContentSize(cc.size(180, 5))
    --self.ListViewAccounts:pushBackCustomItem(panelSpan)
    for _, userId in ipairs(userIds) do 
      print('[LoginScene:ButtonSwitchAccount_onClicked] userId => ', userId)
      local button = self.ButtonModel:clone()
      button:setTitleText(userId)
      button:setVisible(true)
      button:setTouchEnabled(true)
      button:setScale9Enabled(true)
      button:setContentSize(cc.size(180, 40))
      button:setTitleFontSize(22)

      button:addTouchEventListener(__bind(self.Account_onClicked, self))

      self.ListViewAccounts:pushBackCustomItem(button)
    end
  end

  self.PanelAccounts:setVisible(true)
end

function LoginScene:Account_onClicked(sender, eventType)
  local btn = sender
  if eventType == ccui.TouchEventType.ended then
    print('[LoginScene:Account_onClicked] userId => ' , btn:getTitleText())
    self.InputUserId:setText(btn:getTitleText())
  end
end

function LoginScene:PanelAccounts_onClicked(sender, eventType)
  self.PanelAccounts:setVisible(false)
end

function LoginScene:ListViewAccounts_onEvent(sender, eventType)
  if eventType == 1 then
    self.PanelAccounts:setVisible(false)
  end
end


local function createScene()
  local scene = cc.Scene:create()
  return LoginScene.extend(scene)
end

return createScene