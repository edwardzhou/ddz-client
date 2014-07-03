local scheduler = require('framework.scheduler')
local SGamingActionsPlugin = {}

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
    elseif userId == self.prevPlayerInfo.userId then
      --dump(self.prevPlayerInfo, 'self.prevPlayerInfo')
      self:updatePrevPlayerUI(self.prevPlayerInfo)
    elseif userId == self.nextPlayerInfo.userId then
      --dump(self.nextPlayerInfo, 'self.nextPlayerInfo')
      self:updateNextPlayerUI(self.nextPlayerInfo)
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
    --self.selfPlayerInfo:analyzePokecards()
  end

  function theClass:onPrevPlayerPlayCard(card)
    self:hideCard(self.prevPlayerInfo.lastCard)
    self:prevPlayCardEffect(card)
    self:updatePrevPlayerUI(self.prevPlayerInfo)
    self.prevPlayerInfo.lastCard = card
  end

  function theClass:onNextPlayerPlayCard(card)
    self:hideCard(self.nextPlayerInfo.lastCard)
    self:nextPlayCardEffect(card)
    self:updateNextPlayerUI(self.nextPlayerInfo)
    self.nextPlayerInfo.lastCard = card
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

    --self.self
    local this = self
    if self.gameResultPanel == nil then
      --self.gameResultPanel = ccs.GUIReader:getInstance():widgetFromJsonFile('UI/GameResult/GameResult.json')
      local onClose = function ( ... )
        -- body
      end
      local onNewGame = function()
        --PokeCard.resetAll(this.pokeCardsLayer)
        --PokeCard.reloadAllCardSprites(this.pokeCardsLayer)
        --this.gameService:
        self:ButtonReady_onClicked(self.ButtonReady, ccui.TouchEventType.ended)
      end

      self.gameResultPanel = require('gaming.GameResultDialog').new(onClose, onNewGame)
      self:addChild(self.gameResultPanel)
    end
    --scheduler.performWithDelayGlobal(function() 
        self.ButtonReady:setVisible(true)
        this.gameResultPanel:show(balance, this.selfPlayerInfo)
      --end, 1)
  end

end

return SGamingActionsPlugin