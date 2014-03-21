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
    self:selfPlayCardEffect(card)
  end

  function theClass:onPrevPlayerPlayCard(card)
    self:prevPlayCardEffect(card)
    self:updatePrevPlayerUI(self.prevPlayerInfo)
  end

  function theClass:onNextPlayerPlayCard(card)
    self:nextPlayCardEffect(card)
    self:updateNextPlayerUI(self.nextPlayerInfo)
  end

end

return SGamingActionsPlugin