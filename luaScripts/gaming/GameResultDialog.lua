local UIVarBinding = require('utils.UIVariableBinding')

local GameResultDialog = class('GameResultDialog', function() 
  return cc.Layer:create()
end)

function GameResultDialog:ctor(onCloseCallback, onNewGameCallback)
  self.onCloseCallback = onCloseCallback
  self.onNewGameCallback = onNewGameCallback

  self:init()
end

function GameResultDialog:init()
  local widget = ccs.GUIReader:getInstance():widgetFromJsonFile('UI/GameResult.json')
  UIVarBinding.bind(widget, self, self)
  self:addChild(widget)
  self.widget = widget
  self:hide()
  self:initKeypadHandler()

  -- self:registerScriptHandler(function(event)
  --   print('event => ', event)
  --   if event == "enter" then
  --     self:initKeypadHandler()
  --   elseif event == 'exit' then
  --     self:cleanup()
  --   end
  -- end)

end

function GameResultDialog:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    print('[GameResultDialog:initKeypadHandler] ', keyCode, event, this:isVisible())
    if not this:isVisible() then
      return false
    end

    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      self:hide()
      self.onCloseCallback(self)
      --cc.Director:getInstance():popScene()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
    end

    event:stopPropagation()
    return true
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
  self.keypadListener = listener
end


function GameResultDialog:show(balance, selfPlayer)
  -- 修改标题
  if balance.lordWon > 0 then
    -- 地主是赢家
    if selfPlayer.role == ddz.PlayerRoles.Lord then
      -- 自己就是地主，显示地主胜利
      self.ImageTitle:loadTexture('images/end0.png', ccui.TextureResType.localType)
    else
      -- 自己是农民，显示农民失败
      self.ImageTitle:loadTexture('images/end3.png', ccui.TextureResType.localType)
    end
  else
    -- 农民是赢家
    if selfPlayer.role == ddz.PlayerRoles.Lord then
      -- 自己是地主，显示地主失败
      self.ImageTitle:loadTexture('images/end1.png', ccui.TextureResType.localType)
    else
      -- 自己是农民，显示农民胜利
      self.ImageTitle:loadTexture('images/end2.png', ccui.TextureResType.localType)
    end
  end

  -- 显示得分
  local selfResult = balance.players[selfPlayer.userId].score
  local prevResult = balance.players[selfPlayer.prevPlayer.userId].score
  local nextResult = balance.players[selfPlayer.nextPlayer.userId].score
  selfResult = string.format('%+d', selfResult)
  prevResult = string.format('%+d', prevResult)
  nextResult = string.format('%+d', nextResult)
  self.LabelSelfPlayerResult:setString(selfResult)
  self.LabelPrevPlayerResult:setString(prevResult)
  self.LabelNextPlayerResult:setString(nextResult)

  -- 显示昵称
  self.LabelSelfPlayerName:setString(selfPlayer.nickName)
  self.LabelPrevPlayerName:setString(selfPlayer.prevPlayer.nickName)
  self.LabelNextPlayerName:setString(selfPlayer.nextPlayer.nickName)

  -- 显示底数、倍数和佣金
  self.LabelBetBase:setString(balance.ante)
  self.LabelLordValue:setString(balance.lordValue)
  self.LabelRakeValue:setString(balance.rakeValue)

  local bombsInfo = ''
  if balance.bombs > 0 then
    bombsInfo = '炸弹 x ' .. balance.bombs
  end
  if balance.spring ~= 0 then
    if #bombsInfo > 0 then
      bombsInfo = bombsInfo .. ', '
    end
    if balance.spring > 0 then
      bombsInfo = bombsInfo .. '春天'
    else
      bombsInfo = bombsInfo .. '反春'
    end
  end
  self.LabelBombs:setString(bombsInfo)

  self:setPosition(0,0)
  self:setVisible(true)

  if self.keypadListener ~= nil then
    self.keypadListener:setEnabled(true)
  end
end

function GameResultDialog:hide()
  self:setVisible(false)
  self:setPosition(1000, 1000)
  if self.keypadListener ~= nil then
    self.keypadListener:setEnabled(false)
  end
end

function GameResultDialog:ButtonClose_onClicked(sender, event)
  self:hide()
  self.onCloseCallback(self)
end

function GameResultDialog:ButtonNewGame_onClicked(sender, event)
  self:hide()
  self.onNewGameCallback(self)
end

return GameResultDialog