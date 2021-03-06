--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local UIVarBinding = require('utils.UIVariableBinding')
local utils = require('utils.utils')

local RoleImages = require('roleImages')


local GameResultDialog2 = class('GameResultDialog2', function() 
  return cc.Layer:create()
end)

function GameResultDialog2:ctor(onCloseCallback, onNewGameCallback)
  self.onCloseCallback = onCloseCallback
  self.onNewGameCallback = onNewGameCallback

  self:init()
end

function GameResultDialog2:init()
  local widget = cc.CSLoader:createNode('GameOverLayer.csb')
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

function GameResultDialog2:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    print('[GameResultDialog2:initKeypadHandler] ', keyCode, event, this:isVisible())
    if not this:isVisible() then
      return false
    end

    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      self:hide()
      utils.invokeCallback(self.onCloseCallback, self)
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


function GameResultDialog2:show(balance, selfPlayer, prevPlayer, nextPlayer)
  -- 修改标题
  if balance.lordWon > 0 then
    -- 地主是赢家
  --   if selfPlayer.role == ddz.PlayerRoles.Lord then
  --     -- 自己就是地主，显示地主胜利
  --     self.ImageTitle:loadTexture('images/end0.png', ccui.TextureResType.localType)
  --   else
  --     -- 自己是农民，显示农民失败
  --     self.ImageTitle:loadTexture('images/end3.png', ccui.TextureResType.localType)
  --   end
  -- else
  --   -- 农民是赢家
  --   if selfPlayer.role == ddz.PlayerRoles.Lord then
  --     -- 自己是地主，显示地主失败
  --     self.ImageTitle:loadTexture('images/end1.png', ccui.TextureResType.localType)
  --   else
  --     -- 自己是农民，显示农民胜利
  --     self.ImageTitle:loadTexture('images/end2.png', ccui.TextureResType.localType)
  --   end
  end

  local selfResult
  local prevResult
  local nextResult

  selfResult = balance.playersMap[selfPlayer.userId]
  prevResult = balance.playersMap[prevPlayer.userId]
  nextResult = balance.playersMap[nextPlayer.userId]

  dump(selfResult, 'selfResult')
  dump(prevResult, 'prevResult')
  dump(nextResult, 'nextResult')

  -- if balance.players[1].userId == selfPlayer.userId then
  --   selfResult = balance.players[1]
  --   prevResult = balance.players[2]
  --   nextResult = balance.players[3]
  -- elseif balance.players[2].userId == selfPlayer.userId then
  --   selfResult = balance.players[2]
  --   prevResult = balance.players[1]
  --   nextResult = balance.players[3]
  -- else
  --   selfResult = balance.players[3]
  --   prevResult = balance.players[1]
  --   nextResult = balance.players[2]    
  -- end
  -- local selfResult = balance.players[selfPlayer.userId].score
  -- local prevPlayer = selfPlayer.prevPlayer
  -- local nextPlayer = selfPlayer.nextPlayer


  local function getScoreString(score, thePlayer)
    local theScore = score
    theScore = ddz.formatNumberThousands(theScore, true)
    if score == 0 then
      if balance.lordWon > 0 then
        theScore = "-0"
        if thePlayer:isLord() then
          theScore = "+0"
        end
      else
        theScore = "+0"
        if thePlayer:isLord() then
          theScore = "-0"
        end
      end
    end
    return theScore
  end

  -- 显示得分
  local selfScore = getScoreString(selfResult.score, selfPlayer)
  local prevScore = getScoreString(prevResult.score, prevPlayer)
  local nextScore = getScoreString(nextResult.score, nextPlayer)

  print('selfPlayer.isLord: ', selfPlayer:isLord(), ', selfScore: ', selfScore)
  print('prevPlayer.isLord: ', prevPlayer:isLord(), ', prevScore: ', prevScore)
  print('nextPlayer.isLord: ', nextPlayer:isLord(), ', nextScore: ', nextScore)

  local winNumFont = 'NewRes/fonts/win_num_28.fnt'
  local loseNumFont = 'NewRes/fonts/lose_num_28.fnt'

  if string.sub(selfScore, 1, 1) == '+' then
    self.LabelSelfPlayerResult:setFntFile(winNumFont)
  else
    self.LabelSelfPlayerResult:setFntFile(loseNumFont)
  end
  if string.sub(prevScore, 1, 1) == '+' then
    self.LabelPrevPlayerResult:setFntFile(winNumFont)
  else
    self.LabelPrevPlayerResult:setFntFile(loseNumFont)
  end
  if string.sub(nextScore, 1, 1) == '+' then
    self.LabelNextPlayerResult:setFntFile(winNumFont)
  else
    self.LabelNextPlayerResult:setFntFile(loseNumFont)
  end

  -- selfScore = string.format('%+d', selfScore)
  -- prevScore = string.format('%+d', prevScore)
  -- nextScore = string.format('%+d', nextScore)
  -- selfScore = ddz.formatNumberThousands(selfScore, true)
  -- prevScore = ddz.formatNumberThousands(prevScore, true)
  -- nextScore = ddz.formatNumberThousands(nextScore, true)
  self.LabelSelfPlayerResult:setString(selfScore)
  self.LabelPrevPlayerResult:setString(prevScore)
  self.LabelNextPlayerResult:setString(nextScore)

  -- 显示昵称
  self.LabelSelfPlayerName:setString(selfPlayer.nickName)
  self.LabelPrevPlayerName:setString(prevResult.nickName)
  self.LabelNextPlayerName:setString(nextResult.nickName)

  -- 显示底数、倍数和佣金
  -- self.LabelBetBase:setString(balance.ante)
  -- self.LabelLordValue:setString(balance.lordValue)
  -- self.LabelRakeValue:setString(balance.rakeValue)

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
  -- self.LabelBombs:setString(bombsInfo)

  self.PanelWinTop:setVisible(false)
  self.PanelLoseTop:setVisible(false)

  local gender = '男'
  local winlose = 'win'
  if string.sub(selfScore, 1, 1) == '+' then
    self:showWinTop()
    self.ImageWinLine:loadTexture('NewRes/bg/bg_table_vnf_line_v.png', ccui.TextureResType.localType)
    self.ImageWinBg:loadTexture('NewRes/bg/bg_table_vnf_v.png', ccui.TextureResType.localType)
  else
    self:showLoseTop()
    winlose = 'lose'
    self.ImageWinLine:loadTexture('NewRes/bg/bg_table_vnf_line_f.png', ccui.TextureResType.localType)
    self.ImageWinBg:loadTexture('NewRes/bg/bg_table_vnf_f.png', ccui.TextureResType.localType)
  end
  if selfPlayer.gender ~= nil then 
    gender = selfPlayer.gender
  end
  local roleImage = RoleImages[selfPlayer.role][gender][winlose]
  self.ImageSelfRole:loadTexture(roleImage, ccui.TextureResType.localType)

  self:setPosition(0,0)
  self:setVisible(true)

  if self.keypadListener ~= nil then
    self.keypadListener:setEnabled(true)
  end

  self.ImageSelfIcon:loadTexture(string.format('NewRes/idImg/idImg_head_%02d.jpg', selfPlayer.headIcon), ccui.TextureResType.localType)
  self.ImagePrevIcon:loadTexture(string.format('NewRes/idImg/idImg_head_%02d.jpg', prevPlayer.headIcon), ccui.TextureResType.localType)
  self.ImageNextIcon:loadTexture(string.format('NewRes/idImg/idImg_head_%02d.jpg', nextPlayer.headIcon), ccui.TextureResType.localType)

end

function GameResultDialog2:showWinTop()
  self.PanelWinTop:setVisible(true)
  self.PanelWinLight:runAction(cc.RepeatForever:create(
      cc.RotateBy:create(1, 60)
    ))
end

function GameResultDialog2:showLoseTop()
  self.PanelLoseTop:setVisible(true)
  self.spriteLoseAnim:runAction(cc.RepeatForever:create(
    cc.Sequence:create(
      cc.MoveBy:create(0.6, cc.p(0, 20)),
      cc.MoveBy:create(0.6, cc.p(0, -20))
    )))
end

function GameResultDialog2:hide()
  self.PanelWinLight:stopAllActions()
  self.spriteLoseAnim:stopAllActions()
  self:setVisible(false)
  self:setPosition(1000, 1000)
  if self.keypadListener ~= nil then
    self.keypadListener:setEnabled(false)
  end
end

function GameResultDialog2:PanelBg_onClicked()
  self:ButtonClose_onClicked()
end

function GameResultDialog2:ButtonClose_onClicked(sender, event)
  self:hide()
  utils.invokeCallback(self.onCloseCallback, self)
end

function GameResultDialog2:ButtonNewGame_onClicked(sender, event)
  self:hide()
  utils.invokeCallback(self.onNewGameCallback, self)
end

return GameResultDialog2