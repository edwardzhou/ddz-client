local UIButtonsPlugin = {}

function UIButtonsPlugin.bind( theClass )
  function theClass:showButtonsPanel(show)
    self.ButtonsPanel:setVisible(show)
    self:updateButtonsState()
  end

  function theClass:enableButtonPass(enabled)
    self.ButtonPass:setEnabled(enabled)
    local imgPath = 'images/game11.png'
    if not enabled then
      imgPath = 'images/game15.png'
    end
    self.ImagePass:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonReset(enabled)
    self.ButtonReset:setEnabled(enabled)
    local imgPath = 'images/game12.png'
    if not enabled then
      imgPath = 'images/game16.png'
    end
    self.ImageReset:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonTip(enabled)
    self.ButtonTip:setEnabled(enabled)
    local imgPath = 'images/game13.png'
    if not enabled then
      imgPath = 'images/game17.png'
    end
    self.ImageTip:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonPlay(enabled)
    self.ButtonPlay:setEnabled(enabled)
    local imgPath = 'images/game14.png'
    if not enabled then
      imgPath = 'images/game18.png'
    end
    self.ImagePlay:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:updateButtonsState()
    local pickedPokecards = self:getPickedPokecards()
    local hasPicked = #pickedPokecards > 0
    self:enableButtonPlay(hasPicked)
    self:enableButtonReset(hasPicked)
  end

  function theClass:Ready_onClicked(sender, event)
    local this = self
    PokeCard.releaseAllCards()
    PokeCard.reloadAllCardSprites(self.pokeCardsLayer)
    this.cardContentSize = PokeCard.getByPokeChars('A')[1].card_sprite:getContentSize()
    self.gameService:readyGame(__bind(self.onServerGameStart, self))
  end

  function theClass:ButtonPass_onClicked(sender, event)
    self:showButtonsPanel(false)
    self.gameService:playCard(self.selfUserId, '')
  end

  function theClass:ButtonReset_onClicked(sender, event)
    --self:enableButtonTip(true)
    self:resetPickedPokecards()
    self:updateButtonsState()
  end

  function theClass:ButtonTip_onClicked(sender, event)
    --self:enableButtonPlay( not self.ButtonPlay:isEnabled() )
    local analyzedCards = self.selfPlayerInfo.analyzedCards
    local cards
    local pokeCards = {}
    cards = analyzedCards.straightsCards
    if #cards == 0 then
      cards = analyzedCards.pairsStraightsCards
    end
    if #cards == 0 then
      cards = analyzedCards.threesCards
    end
    if #cards == 0 then
      cards = analyzedCards.pairsCards
    end
    if #cards == 0 then
      cards = analyzedCards.singlesCards
    end

    if #cards > 0 then
      local card = cards[1]
      local pokeCards = table.dup(card.pokeCards)
      if card.cardType == CardType.THREE then
        local singleCards = analyzedCards.singlesCards
        if #singleCards > 0 then
          table.insert(pokeCards, singleCards[1].pokeCards[1])
        else
          local pairsCards = analyzedCards.pairsCards
          if #pairsCards > 0 then
            table.append(pokeCards, pairsCards[1].pokeCards)
          end
        end
      elseif card.CardType == CardType.THREE_STRAIGHT then
        local singleCards = analyzedCards.singlesCards
        if #singleCards >= card.cardLength then
          for i=1,card.cardLength do
            table.insert(pokeCards, singleCards[i].pokeCards[1])
          end
        else
          local pairsCards = analyzedCards.pairsCards
          if #pairsCards >= card.cardLength then
            table.append(pokeCards, pairsCards[i].pokeCards)
          end 
        end
      end

      self:pickupPokecards(pokeCards)
      self:updateButtonsState()
    end

  end

  function theClass:ButtonPlay_onClicked(sender, event)
    local pokeCards = self:getPickedPokecards()
    local pokeIdChars = PokeCard.getIdChars(pokeCards)

    local card = Card.create(pokeCards)
    -- dump(card, '[theClass:ButtonPlay_onClicked] card')
    if card.cardType == CardType.NONE then
      return
    end

    self:showButtonsPanel(false)
    self.gameService:playCard(self.selfUserId, pokeIdChars)
  end
end

return UIButtonsPlugin