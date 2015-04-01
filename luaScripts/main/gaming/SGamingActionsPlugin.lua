local scheduler = require('framework.scheduler')
local SGamingActionsPlugin = {}
local AccountInfo = require('AccountInfo')
local utils = require('utils.utils')
local RoleImages = require('roleImages')

local Res = require('Resources')

function SGamingActionsPlugin.bind(theClass)

  function theClass:onStartNewGameMsg(pokeGame, pokeIdChars, nextUserId, timing, data)
    self:doServerGameStart(pokeGame, pokeIdChars, nextUserId, timing, data)
    --self:showPlaycardClock(nil, nextTimeout)
  end

  function theClass:onGrabbingLordMsg(userId, grabState, nextUserId, nextTimeout, pokeGame, isGiveup, isGrabLordFinish, data)
    local this = self
    print('userId: ', userId, self.selfPlayerInfo.userId, self.prevPlayerInfo.userId, self.nextPlayerInfo.userId)
    if userId == self.selfPlayerInfo.userId then
      --dump(self.selfPlayerInfo, 'selfPlayerInfo')
      self:updateSelfPlayerUI(self.selfPlayerInfo)
      --self:animateStatus(self.SelfUserStatus)
      self:playGrabLordEffect(self.selfPlayerInfo, self.SelfUserStatus, grabState)
    elseif userId == self.prevPlayerInfo.userId then
      --dump(self.prevPlayerInfo, 'self.prevPlayerInfo')
      self:updatePrevPlayerUI(self.prevPlayerInfo)
      --self:animateStatus(self.PrevUserStatus)
      self:playGrabLordEffect(self.prevPlayerInfo, self.PrevUserStatus, grabState)
    elseif userId == self.nextPlayerInfo.userId then
      --dump(self.nextPlayerInfo, 'self.nextPlayerInfo')
      self:updateNextPlayerUI(self.nextPlayerInfo)
      --self:animateStatus(self.NextUserStatus)
      self:playGrabLordEffect(self.nextPlayerInfo, self.NextUserStatus, grabState)
    else
      -- error
    end
    if nextUserId == self.selfPlayerInfo.userId and not isGiveup then
      print('[theClass:onGrabbingLordMsg] show grab lord buttons.')
      self:showGrabLordButtonsPanel(true, self.pokeGame.grabbingLord.lordValue)
      --self:onGameOverMsg({})
    else
      self:showGrabLordButtonsPanel(false, self.pokeGame.grabbingLord.lordValue)
    end

    --self.LabelLordValue:setText("x " .. self.pokeGame.grabbingLord.lordValue)

    if isGiveup then
      self:hideSelfPokecards()
    end

    if isGrabLordFinish then
      self.LordCard1:loadTexture('lord_' .. self.pokeGame.lordPokeCards[3].image_filename, ccui.TextureResType.plistType)
      self.LordCard2:loadTexture('lord_' .. self.pokeGame.lordPokeCards[2].image_filename, ccui.TextureResType.plistType)
      self.LordCard3:loadTexture('lord_' .. self.pokeGame.lordPokeCards[1].image_filename, ccui.TextureResType.plistType)

      if pokeGame.lordPlayer.userId == self.selfPlayerInfo.userId then
        table.append(self.selfPlayerInfo.pokeCards, pokeGame.lordPokeCards)
        table.sort(self.selfPlayerInfo.pokeCards, sortDescBy('index'))
        self.pokeCards = self.selfPlayerInfo.pokeCards
      end

      -- 根据记牌器道具位来控制记牌器是否显示
      self.JipaiqiPanel:setVisible( bit.band(pokeGame.assetBits, 0x01) > 0 )

      self:doUpdatePlayersUI()


      -- self.PanelPrevHead:setVisible(false)
      -- self.PanelNextHead:setVisible(false)
      -- self.SelfUserHead:setVisible(false)

      local roleImage = ''

      roleImage = RoleImages[self.prevPlayerInfo.role][self.prevPlayerInfo.gender or '男']['left']
      self.PrevUserRole:loadTexture(roleImage, ccui.TextureResType.localType)

      roleImage = RoleImages[self.nextPlayerInfo.role][self.nextPlayerInfo.gender or '男']['right']
      self.NextUserRole:loadTexture(roleImage, ccui.TextureResType.localType)

      roleImage = RoleImages[self.selfPlayerInfo.role][self.selfPlayerInfo.gender or '男']['left']
      self.SelfUserRole:loadTexture(roleImage, ccui.TextureResType.localType)

      self.PrevUserRole:setVisible(true)
      self.NextUserRole:setVisible(true)
      self.SelfUserRole:setVisible(true)

      self.PrevUserRole:setScale(0.01)
      self.NextUserRole:setScale(0.01)
      self.SelfUserRole:setScale(0.01)

      local timing = 0.4
      self.PanelPrevHead:runAction(cc.Sequence:create(
            cc.EaseElasticInOut:create(cc.ScaleTo:create(timing, 0.01), timing),
            cc.TargetedAction:create(self.PrevUserRole, cc.EaseElasticInOut:create(cc.ScaleTo:create(timing, 1), timing)),
            cc.CallFunc:create(function(sender) 
                sender:setVisible(false)
                sender:setScale(1.0)
              end)
          )
        )

      self.SelfUserHead:runAction(cc.Sequence:create(
            cc.EaseElasticInOut:create(cc.ScaleTo:create(timing, 0.01), timing),
            cc.TargetedAction:create(self.NextUserRole, cc.EaseElasticInOut:create(cc.ScaleTo:create(timing, 1), timing)),
            cc.CallFunc:create(function(sender) 
                sender:setVisible(false)
                sender:setScale(1.0)
              end)
          )
        )

      self.PanelNextHead:runAction(cc.Sequence:create(
            cc.EaseElasticInOut:create(cc.ScaleTo:create(timing, 0.01), timing),
            cc.TargetedAction:create(self.SelfUserRole, cc.EaseElasticInOut:create(cc.ScaleTo:create(timing, 1), timing)),
            cc.CallFunc:create(function(sender) 
                sender:setVisible(false)
                sender:setScale(1.0)
              end)
          )
        )

      -- self.NextUserStatus:setVisible(false)
      -- self.SelfUserStatus:setVisible(false)
      -- self.PrevUserStatus:setVisible(false)

      self:showGrabLordButtonsPanel(false)
      if self.pokeGame.lordPlayer == self.selfPlayerInfo then
        self:showCards(self.selfPlayerInfo.pokeCards, false)
        self:showButtonsPanel(true)
        self.tipPokeChars = data.tipPokeChars
        --if userId == self.selfPlayerInfo.userId then
          self:stopCountdown(true)
          self:runAction(cc.Sequence:create(
              cc.DelayTime:create(1),
              cc.CallFunc:create(function() 
                  this:showPlaycardClock(nil, nextTimeout)
                end)
            ))
          return
        --end
      else
        self.tipPokeChars = ''
      end
    end

    self:showPlaycardClock(nil, nextTimeout)
  end

  function theClass:onPlayCardMsg(userId, card, nextPlayer, nextTimeout, isDelegating, data)
    if userId == self.selfPlayerInfo.userId then
      self:onSelfPlayerPlayCard(card)
      if isDelegating then
        self.ButtonDelegate:setVisible(true)
      end
      -- nextPlayer = self.nextPlayerInfo
    elseif userId == self.prevPlayerInfo.userId then
      self:onPrevPlayerPlayCard(card)
      -- nextPlayer = self.selfPlayerInfo
    elseif userId == self.nextPlayerInfo.userId then
      self:onNextPlayerPlayCard(card)
      -- nextPlayer = self.prevPlayerInfo
    else
      -- error
    end

    if card:isValid() then
      self.jipaiqi:updateStatus(data.playedPokeBits)
    end

    if nextPlayer then
      self:hideCard(nextPlayer.lastCard)
    end

    self:showButtonsPanel(nextPlayer.userId == self.selfPlayerInfo.userId)
    if nextPlayer.userId == self.selfPlayerInfo.userId then
      self:updateButtonsState()
      self.tipPokeChars = data.tipPokeChars
      if self.tipPokeChars == '' and data.player.pokeCount > 0 then
        self:showSelfPlayTips('您没有大过对方的牌')
      end
    else
      self.tipPokeChars = ''
      self:hideSelfPlayTips()
    end

    self:showPlaycardClock(nil, nextTimeout)
  end

  function theClass:onSelfPlayerPlayCard(card)
    self:playCardEffect(self.selfPlayerInfo, card)

    self:hideCard(self.selfPlayerInfo.lastCard)
    self:selfPlayCardEffect(card)
    self:updateSelfPlayerUI(self.selfPlayerInfo)
    self.selfPlayerInfo.lastCard = card
    if not card:isValid() then
      self:showPlayPassInfo(self.SelfUserStatus)
    end
    --self.selfPlayerInfo:analyzePokecards()
  end

  function theClass:onPrevPlayerPlayCard(card)
    self:hidePrevPlayTips()
    self:playCardEffect(self.prevPlayerInfo, card)
    self:hideCard(self.prevPlayerInfo.lastCard)
    self:prevPlayCardEffect(card)
    self:updatePrevPlayerUI(self.prevPlayerInfo)
    self.prevPlayerInfo.lastCard = card
    if not card:isValid() then
      self:showPlayPassInfo(self.PrevUserStatus)
    end
  end

  function theClass:onNextPlayerPlayCard(card)
    self:hideNextPlayTips()
    self:playCardEffect(self.nextPlayerInfo, card)
    self:hideCard(self.nextPlayerInfo.lastCard)
    self:nextPlayCardEffect(card)
    self:updateNextPlayerUI(self.nextPlayerInfo)
    self.nextPlayerInfo.lastCard = card
    if not card:isValid() then
      self:showPlayPassInfo(self.NextUserStatus)
    end
  end

  function theClass:onLordValueUpgrade(newLordValue)
    self.LabelLordValue:setString(newLordValue)
    local scaleTo = cc.ScaleTo:create(0.15, 2.5)
    self.LabelLordValue:runAction(cc.Sequence:create(
        scaleTo,
        cc.CallFunc:create(function(sender)
          sender:setScale(1, 1) 
        end)
      ))
  end

  function theClass:onGameOverMsg(balance)
    -- self:hideCard(self.selfPlayerInfo.lastCard)
    local this = self
    self:showPrevPlayerRestPokecards()
    self:showNextPlayerRestPokecards()
    self.ButtonDelegate:setVisible(false)

    self.selfPlayerInfo.status = ddz.PlayerStatus.None
    self.prevPlayerInfo.status = ddz.PlayerStatus.None
    self.nextPlayerInfo.status = ddz.PlayerStatus.None
    self:doUpdatePlayersUI()
    self:showButtonsPanel(false)
    self:showGrabLordButtonsPanel(false)
    --self:startSelfPlayerCountdown(nil, 15)

    local prevPokeChars = balance.playersMap[self.prevPlayerInfo.userId].pokeCards
    local nextPokeChars = balance.playersMap[self.nextPlayerInfo.userId].pokeCards
    local prevPokeCards = PokeCard.getByPokeChars(prevPokeChars)
    local nextPokeCards = PokeCard.getByPokeChars(nextPokeChars)

    self:showPrevPlayerRestPokecards(prevPokeCards)
    self:showNextPlayerRestPokecards(nextPokeCards)

    local currentUser = AccountInfo.getCurrentUser()
    local selfDdzProfile = balance.playersMap[currentUser.userId].ddzProfile
    table.merge(currentUser.ddzProfile, selfDdzProfile)

    if balance.playersMap[self.selfPlayerInfo.userId].score > 0 then
      self:playWinEffect()
    else
      self:playLoseEffect()
    end

    -- self:showPlayerWinCoins(self.SelfUserCoins, balance.playersMap[self.selfPlayerInfo.userId].score)
    -- self:showPlayerWinCoins(self.PrevUserCoins, balance.playersMap[self.prevPlayerInfo.userId].score)
    -- self:showPlayerWinCoins(self.NextUserCoins, balance.playersMap[self.nextPlayerInfo.userId].score, function() 
    --     this.ButtonReady:setVisible(true)
    --     this.ButtonReady:setBright(true)        
    --   end)

    -- this.ButtonReady:setVisible(true)
    -- this.ButtonReady:setBright(true)        

    if this.gameResultPanel == nil then
      this.gameResultPanel = require('gaming.GameResultDialog2').new()
      this:addChild(self.gameResultPanel)
    end

    scheduler.performWithDelayGlobal(function() 
        this.ButtonReady:setVisible(true)
        this.gameResultPanel:show(balance, this.selfPlayerInfo, this.prevPlayerInfo, this.nextPlayerInfo)
      end, 1)

    self:stopCountdown(true)
    self:updateUserInfo()
    self:updateTask()

    print('[Gaming] GAME OVER. =========')
    self.gameConnection:dumpBytesStat()
    self.gameConnection:resetBytesStat()

    -- --self.self
    -- local this = self
    -- if self.gameResultPanel == nil then
    --   --self.gameResultPanel = ccs.GUIReader:getInstance():widgetFromJsonFile('gameUI/GameResult/GameResult.json')
    --   local onClose = function ( ... )
    --     -- body
    --   end
    --   local onNewGame = function()
    --     --PokeCard.resetAll(this.pokeCardsLayer)
    --     --PokeCard.reloadAllCardSprites(this.pokeCardsLayer)
    --     --this.gameService:
    --     self:ButtonReady_onClicked(self.ButtonReady, ccui.TouchEventType.ended)
    --   end

    --   self.gameResultPanel = require('gaming.GameResultDialog').new(onClose, onNewGame)
    --   self:addChild(self.gameResultPanel)
    -- end
    --scheduler.performWithDelayGlobal(function() 
        --self.ButtonReady:setVisible(true)
        --this.gameResultPanel:show(balance, this.selfPlayerInfo)
      --end, 1)
  end

  function theClass:showPlayerWinCoins(coinLabel, coins, cb)
    local pos = cc.p(coinLabel:getPosition())
    coinLabel:setVisible(false)
    coinLabel:setString(string.format('%+d', coins))
    coinLabel:setPosition( pos.x, pos.y - 60 )

    if coins > 0 then
      coinLabel:setColor(cc.c4b(0xff, 0xff, 0xff, 0xff))
    else
      coinLabel:setColor(cc.c4b(0xff, 0xed, 0x92, 0xed))
    end

    coinLabel:setVisible(true)
    coinLabel:setOpacity(0)

    coinLabel:runAction(
      cc.Sequence:create(
        cc.Spawn:create(
          cc.FadeIn:create(0.5),
          cc.MoveBy:create(0.8, cc.p(0, 60))
        )
        , cc.DelayTime:create(2.5)
        , cc.CallFunc:create(function() 
          coinLabel:setVisible(false)
          coinLabel:setOpacity(0)
          utils.invokeCallback(cb)
        end)
      )
    )
  end

  function theClass:showPlayPassInfo(statusUI)
    print('show Player Pass')
    -- local parentSize = statusUI:getParent():getContentSize()
    -- local statusUISize = statusUI:getContentSize()
    -- local pos = cc.p(statusUI:getPosition())
    statusUI:setVisible(false)
    statusUI:setString('不出')
    -- statusUI:loadTexture(Res.Images.PlayerStatus.PassPlay, ccui.TextureResType.localType)
    self:animateStatus(statusUI)

  end
end

return SGamingActionsPlugin