local SGamingActionsPlugin = {}

function SGamingActionsPlugin.bind(theClass)

  function theClass:onStartNewGameMsg(pokeGame, nextUserId)
    self:doServerGameStart(pokeGame, nextUserId)
  end

  function theClass:onPlayCardMsg(userId, pokeIdChars)
    local pokeCards = PokeCard.getByPokeChars(pokeIdChars)
    local card = Card.create(pokeCards)
    if userId == self.selfPlayerInfo.userId then
      self:onSelfPlayerPlayCard(card)
    elseif userId == self.prevPlayerInfo.userId then
      self:onPrevPlayerPlayCard(card)
    elseif userId == self.nextPlayerInfo.userId then
      self:onNextPlayerPlayCard(card)
    else
      -- error
    end
    if self.pokeGame.currentPlayer.userId == self.selfPlayerInfo.userId then
      self:showButtonsPanel(true)
    end
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

end

return SGamingActionsPlugin