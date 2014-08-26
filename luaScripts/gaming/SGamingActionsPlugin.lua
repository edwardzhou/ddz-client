local scheduler = require('framework.scheduler')
local SGamingActionsPlugin = {}
local AccountInfo = require('AccountInfo')

local Res = require('Resources')

function SGamingActionsPlugin.bind(theClass)

  function theClass:onStartNewGameMsg(pokeGame, pokeIdChars, nextUserId)
    self:doServerGameStart(pokeGame, pokeIdChars, nextUserId)
    self:showPlaycardClock(nil, nextTimeout)
  end

  function theClass:onGrabbingLordMsg(userId, nextUserId, nextTimeout, pokeGame, isGiveup, isGrabLordFinish)
    print('userId: ', userId, self.selfPlayerInfo.userId, self.prevPlayerInfo.userId, self.nextPlayerInfo.userId)
    if userId == self.selfPlayerInfo.userId then
      --dump(self.selfPlayerInfo, 'selfPlayerInfo')
      self:updateSelfPlayerUI(self.selfPlayerInfo)
      self:animateStatus(self.SelfUserStatus)
    elseif userId == self.prevPlayerInfo.userId then
      --dump(self.prevPlayerInfo, 'self.prevPlayerInfo')
      self:updatePrevPlayerUI(self.prevPlayerInfo)
      self:animateStatus(self.PrevUserStatus)
    elseif userId == self.nextPlayerInfo.userId then
      --dump(self.nextPlayerInfo, 'self.nextPlayerInfo')
      self:updateNextPlayerUI(self.nextPlayerInfo)
      self:animateStatus(self.NextUserStatus)
    else
      -- error
    end
    if nextUserId == self.selfPlayerInfo.userId and not isGiveup then
      self:showGrabLordButtonsPanel(true, self.pokeGame.grabbingLord.lordValue)
      --self:onGameOverMsg({})
    else
      self:showGrabLordButtonsPanel(false, self.pokeGame.grabbingLord.lordValue)
    end

    --self.LabelLordValue:setText("x " .. self.pokeGame.grabbingLord.lordValue)

    self:showPlaycardClock(nil, nextTimeout)

    if isGiveup then
      self:hideSelfPokecards()
    end

    if isGrabLordFinish then
      self.LordCard1:loadTexture(self.pokeGame.lordPokeCards[3].image_filename, ccui.TextureResType.plistType)
      self.LordCard2:loadTexture(self.pokeGame.lordPokeCards[2].image_filename, ccui.TextureResType.plistType)
      self.LordCard3:loadTexture(self.pokeGame.lordPokeCards[1].image_filename, ccui.TextureResType.plistType)

      if pokeGame.lordPlayer.userId == self.selfPlayerInfo.userId then
        table.append(self.selfPlayerInfo.pokeCards, pokeGame.lordPokeCards)
        table.sort(self.selfPlayerInfo.pokeCards, sortDescBy('index'))
        self.pokeCards = self.selfPlayerInfo.pokeCards
      end

      self:doUpdatePlayersUI()

      self.NextUserStatus:setVisible(false)
      self.SelfUserStatus:setVisible(false)
      self.PrevUserStatus:setVisible(false)

      self:showGrabLordButtonsPanel(false)
      if self.pokeGame.lordPlayer == self.selfPlayerInfo then
        self:showCards()
        self:showButtonsPanel(true)
      end      
    end

  end

  function theClass:onPlayCardMsg(userId, card, nextPlayer, nextTimeout, isDelegating)
    -- local pokeCards = PokeCard.getByPokeChars(pokeIdChars)
    -- local card = Card.create(pokeCards)
    -- local nextPlayer = self.pokeGame:


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

    if nextPlayer then
      self:hideCard(nextPlayer.lastCard)
    end

    --if nextPlayer.userId == self.selfPlayerInfo.userId then
      self:showButtonsPanel(nextPlayer.userId == self.selfPlayerInfo.userId)
    --end

    self:showPlaycardClock(nil, nextTimeout)
  end

  function theClass:onSelfPlayerPlayCard(card)
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
    self:hideCard(self.prevPlayerInfo.lastCard)
    self:prevPlayCardEffect(card)
    self:updatePrevPlayerUI(self.prevPlayerInfo)
    self.prevPlayerInfo.lastCard = card
    if not card:isValid() then
      self:showPlayPassInfo(self.PrevUserStatus)
    end
  end

  function theClass:onNextPlayerPlayCard(card)
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
          sender:setScale(0.5, 0.5) 
        end)
      ))
  end

  function theClass:onGameOverMsg(balance)
    -- self:hideCard(self.selfPlayerInfo.lastCard)
    self:showPrevPlayerRestPokecards()
    self:showNextPlayerRestPokecards()
    self:stopCountdown()
    self.ButtonDelegate:setVisible(false)

    self.selfPlayerInfo.status = ddz.PlayerStatus.None
    self.prevPlayerInfo.status = ddz.PlayerStatus.None
    self.nextPlayerInfo.status = ddz.PlayerStatus.None
    self:doUpdatePlayersUI()
    self:showButtonsPanel(false)
    self:showGrabLordButtonsPanel(false)
    self:startSelfPlayerCountdown(nil, 15)

    local prevPokeChars = balance.playersMap[self.prevPlayerInfo.userId].pokeCards
    local nextPokeChars = balance.playersMap[self.nextPlayerInfo.userId].pokeCards
    local prevPokeCards = PokeCard.getByPokeChars(prevPokeChars)
    local nextPokeCards = PokeCard.getByPokeChars(nextPokeChars)

    self:showPrevPlayerRestPokecards(prevPokeCards)
    self:showNextPlayerRestPokecards(nextPokeCards)

    local currentUser = AccountInfo.getCurrentUser()
    local selfDdzProfile = balance.playersMap[currentUser.userId].ddzProfile
    table.merge(currentUser.ddzProfile, selfDdzProfile)

    self:showPlayerWinCoins(self.SelfUserCoins, balance.playersMap[self.selfPlayerInfo.userId].score)
    self:showPlayerWinCoins(self.PrevUserCoins, balance.playersMap[self.prevPlayerInfo.userId].score)
    self:showPlayerWinCoins(self.NextUserCoins, balance.playersMap[self.nextPlayerInfo.userId].score)


    -- --self.self
    -- local this = self
    -- if self.gameResultPanel == nil then
    --   --self.gameResultPanel = ccs.GUIReader:getInstance():widgetFromJsonFile('UI/GameResult/GameResult.json')
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
        self.ButtonReady:setVisible(true)
        --this.gameResultPanel:show(balance, this.selfPlayerInfo)
      --end, 1)
  end

  function theClass:showPlayerWinCoins(coinLabel, coins)
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
    statusUI:loadTexture(Res.Images.PlayerStatus.PassPlay, ccui.TextureResType.localType)
    self:animateStatus(statusUI)

    -- statusUI:setVisible(true)
    -- statusUI:setOpacity(0);

    -- statusUI:setPosition(cc.p(pos.x, parentSize.height))
    -- statusUI:runAction(cc.Sequence:create(
    --     cc.Spawn:create(
    --       cc.FadeIn:create(0.5),
    --       cc.MoveTo:create(0.5, cc.p(pos.x, parentSize.height / 2.0))
    --     ),
    --     cc.DelayTime:create(1.5),
    --     cc.CallFunc:create(function()
    --         statusUI:setVisible(false)
    --         statusUI:setOpacity(255)
    --       end)
    --   ))

    -- statusUI:runAction(cc.Sequence:create(
    --     cc.FadeIn:create(0.5),
    --     cc.DelayTime:create(1.0),
    --     cc.FadeOut:create(0.5),
    --     cc.CallFunc:create(function()
    --         statusUI:setVisible(false)
    --         statusUI:setOpacity(255)
    --       end)
    --   ))
  end
end

return SGamingActionsPlugin