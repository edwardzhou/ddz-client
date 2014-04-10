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
  local widget = ccs.GUIReader:getInstance():widgetFromJsonFile('UI/GameResult/GameResult.json')
  UIVarBinding.bind(widget, self, self)
  self:addChild(widget)
  self.widget = widget
  self:hide()
end

function GameResultDialog:show(balance, selfPlayer)
  -- 修改标题
  if selfPlayer.role == ddz.PlayerRoles.Lord then
    if balance.winner.userId == selfPlayer.userId then
      self.ImageTitle:loadTexture('images/end0.png', ccui.TextureResType.localType)
    else
      self.ImageTitle:loadTexture('images/end1.png', ccui.TextureResType.localType)
    end
  else
    if balance.winner.role == ddz.PlayerRoles.Farmer then
      self.ImageTitle:loadTexture('images/end2.png', ccui.TextureResType.localType)
    else
      self.ImageTitle:loadTexture('images/end3.png', ccui.TextureResType.localType)
    end
  end

  local selfResult = balance.playerResults[selfPlayer.userId].balance
  local prevResult = balance.playerResults[selfPlayer.prevPlayer.userId].balance
  local nextResult = balance.playerResults[selfPlayer.nextPlayer.userId].balance
  if selfResult > 0 then
    selfResult = '+' .. selfResult
  end

  if nextResult > 0 then
    nextResult = '+' .. nextResult
  end

  if prevResult > 0 then
    prevResult = '+' .. prevResult
  end

  self.LabelSelfPlayerResult:setText(selfResult)
  self.LabelPrevPlayerResult:setText(prevResult)
  self.LabelNextPlayerResult:setText(nextResult)

  self.LabelSelfPlayerName:setText(selfPlayer.name)
  self.LabelPrevPlayerName:setText(selfPlayer.prevPlayer.name)
  self.LabelNextPlayerName:setText(selfPlayer.nextPlayer.name)

  self.LabelBetBase:setText(balance.betBase)
  self.LabelLordValue:setText(balance.lordValue)

  self:setPosition(0,0)
  self:setVisible(true)
end

function GameResultDialog:hide()
  self:setVisible(false)
  self:setPosition(1000, 1000)
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