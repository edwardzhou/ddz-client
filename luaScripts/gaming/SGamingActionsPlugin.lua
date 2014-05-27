local scheduler = require('framework.scheduler')
local SGamingActionsPlugin = {}

function SGamingActionsPlugin.bind(theClass)

  function theClass:onStartNewGameMsg(pokeGame, pokeIdChars, nextUserId)
    self:doServerGameStart(pokeGame, pokeIdChars, nextUserId)
  end

  function theClass:onGrabbingLordMsg(userId, nextUserId, isGiveup, isFinish)
    if userId == self.selfPlayerInfo.userId then
      self:updateSelfPlayerUI(self.selfPlayerInfo)
    elseif userId == self.prevPlayerInfo.userId then
      self:updatePrevPlayerUI(self.prevPlayerInfo)
    elseif userId == self.nextPlayerInfo.userId then
      self:updateNextPlayerUI(self.nextPlayerInfo)
    else
      -- error
    end
    if self.pokeGame.currentPlayer.userId == self.selfPlayerInfo.userId and not isGiveup then
      self:showGrabLordButtonsPanel(true, self.pokeGame.grabbingLord.lordValue)
      --self:onGameOverMsg({})
    end

    --self.LabelLordValue:setText("x " .. self.pokeGame.grabbingLord.lordValue)

    self:showPlaycardClock()

    if isGiveup then
      self:hideSelfPokecards()
    end

    if isFinish then
      self.LordCard1:loadTexture(self.pokeGame.lordPokeCards[1].image_filename, ccui.TextureResType.plistType)
      self.LordCard2:loadTexture(self.pokeGame.lordPokeCards[2].image_filename, ccui.TextureResType.plistType)
      self.LordCard3:loadTexture(self.pokeGame.lordPokeCards[3].image_filename, ccui.TextureResType.plistType)
      self:doUpdatePlayersUI()

      self:showGrabLordButtonsPanel(false)
      if self.pokeGame.lordPlayer == self.selfPlayerInfo then
        self:showCards()
        self:showButtonsPanel(true)
      end      
    end

  end

  function theClass:onPlayCardMsg(userId, pokeIdChars)
    local pokeCards = PokeCard.getByPokeChars(pokeIdChars)
    local card = Card.create(pokeCards)
    local nextPlayer = nil
    if userId == self.selfPlayerInfo.userId then
      self:onSelfPlayerPlayCard(card)
      nextPlayer = self.nextPlayerInfo
    elseif userId == self.prevPlayerInfo.userId then
      self:onPrevPlayerPlayCard(card)
      nextPlayer = self.selfPlayerInfo
    elseif userId == self.nextPlayerInfo.userId then
      self:onNextPlayerPlayCard(card)
      nextPlayer = self.prevPlayerInfo
    else
      -- error
    end

    if nextPlayer then
      self:hideCard(nextPlayer.lastCard)
    end

    if self.pokeGame.currentPlayer.userId == self.selfPlayerInfo.userId then
      self:showButtonsPanel(true)
    end

    self:showPlaycardClock()
  end

  function theClass:onSelfPlayerPlayCard(card)
    self:hideCard(self.selfPlayerInfo.lastCard)
    self:selfPlayCardEffect(card)
    self:updateSelfPlayerUI(self.selfPlayerInfo)
    self.selfPlayerInfo.lastCard = card
    self.selfPlayerInfo:analyzePokecards()
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
    self.LabelLordValue:setStringValue(newLordValue)
    local scaleBy = cc.ScaleBy:create(0.15, 2.5)
    self.LabelLordValue:runAction(cc.Sequence:create(
        scaleBy,
        scaleBy:reverse()
      ))
  end

  function theClass:onGameOverMsg(balance)
    -- self:hideCard(self.selfPlayerInfo.lastCard)
    self:showPrevPlayerRestPokecards()
    self:showNextPlayerRestPokecards()
    self:stopCountdown()

    self.selfPlayerInfo.status = ddz.PlayerStatus.None
    self.prevPlayerInfo.status = ddz.PlayerStatus.Ready
    self.nextPlayerInfo.status = ddz.PlayerStatus.Ready
    self:doUpdatePlayersUI()
    self:showButtonsPanel(false)
    self:startSelfPlayerCountdown(nil, 15)

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
    scheduler.performWithDelayGlobal(function() 
        self.ButtonReady:setVisible(true)
        this.gameResultPanel:show(balance, this.selfPlayerInfo)
      end, 1)
  end

end

return SGamingActionsPlugin