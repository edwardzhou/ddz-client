local MessageBox = class('MessageBox')


function MessageBox.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, MessageBox)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function MessageBox:ctor(title, msg, width, height)
  self.title = title
  self.msg = msg

  self:init()
end

function MessageBox:init()
  -- local rootLayer = cc.Layer:create()
  -- self.rootLayer = rootLayer
  -- self:addChild(rootLayer)
  local this = self
  local rootLayer = self

  local guiReader = ccs.GUIReader:getInstance()
  local uiRoot = guiReader:widgetFromBinaryFile('UI/MessageBox.csb')
  self.uiRoot = uiRoot
  rootLayer:addChild(uiRoot)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()

  self.LabelTitle:setString(self.title)
  self.LabelMessage:setString(self.msg)

  --self.MsgPanel:setScale(0.01)

  self:registerScriptHandler(function(event)
    print('event => ', event)
    if event == "enter" then
      local pos = cc.p(self.MsgPanel:getPosition())
      --self.MsgPanel:setAnchorPoint(0, 0)
      --this.MsgPanel:setPosition(cc.p(pos.x, 480))
      --this.MsgPanel:runAction(cc.MoveBy:create(0.1, cc.p(0, -340)))
    elseif event == 'exit' then
    end
  end)

end

function MessageBox:close()
  local this = self
  self.MsgPanel:runAction( 
    cc.Sequence:create(
      --cc.MoveBy:create(0.1, cc.p(0, 340)),
      cc.CallFunc:create( function()
          this:removeFromParent()
        end)
    )
  )
end

function MessageBox:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
--      if type(self.onMainMenu) == 'function' then
--        self.onMainMenu()
--      end
      event:stopPropagation()
      self:close()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end


local function showMessageBox(container, title, message, width, height)
  local layer = cc.Layer:create()
  local msgBox = MessageBox.extend(layer, title, message, width, height)

  msgBox:setLocalZOrder(1000)
  container:addChild(msgBox)
end

return {
  showMessageBox = showMessageBox
}