local Res = require('Resources')
local UIButtonsPlugin = {}


function UIButtonsPlugin.bind( theClass )
  function theClass:showGrabLordButtonsPanel(show, currentLordValue)
    currentLordValue = currentLordValue or 0
    --print('[theClass:showGrabLordButtonsPanel] currentLordValue: ', currentLordValue)
    self.GrabLordButtonsPanel:setVisible(show)
    if show then
      if currentLordValue == 0 then
        self.ImageNoGrabLord:loadTexture(Res.Images.PlayerStatus.NoGrabLord, ccui.TextureResType.localType)
        self.ImageGrabLord:loadTexture(Res.Images.PlayerStatus.GrabLord, ccui.TextureResType.localType)
      else
        self.ImageNoGrabLord:loadTexture(Res.Images.PlayerStatus.PassGrabLord, ccui.TextureResType.localType)
        self.ImageGrabLord:loadTexture(Res.Images.PlayerStatus.ReGrabLord, ccui.TextureResType.localType)
      end
    end
  end

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
    self.ButtonReset:setBright(enabled)
    self.ButtonReset:setTouchEnabled(enabled)

    --self.ButtonReset:setEnabled(enabled)
    local imgPath = 'images/game12.png'
    if not enabled then
      imgPath = 'images/game16.png'
    end
    self.ImageReset:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonTip(enabled)
    self.ButtonTip:setBright(enabled)
    self.ButtonTip:setTouchEnabled(enabled)
    --self.ButtonTip:setEnabled(enabled)
    local imgPath = 'images/game13.png'
    if not enabled then
      imgPath = 'images/game17.png'
    end
    self.ImageTip:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonPlay(enabled)
    self.ButtonPlay:setBright(enabled)
    self.ButtonPlay:setTouchEnabled(enabled)
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

  function theClass:ButtonReady_onClicked(sender, event)
    local this = self
    --PokeCard.releaseAllCards()
    --PokeCard.reloadAllCardSprites(self.pokeCardsBatchNode)
    self:resetScene()
    self.pokeGame = nil
    PokeCard.resetAll()
    this.cardContentSize = PokeCard.getByPokeChars('A')[1].card_sprite:getContentSize()
    this:runAction(
      cc.CallFunc:create( function() 
        self.gameService:readyGame(function(data)
          this.ButtonReady:setVisible(false)
          this:stopCountdown()
          self:startWaitingEffect()
        end)

        -- this.SelfUserStatus:loadTexture(Res.Images.PlayerStatus.Ready, ccui.TextureResType.localType)
        -- this.SelfUserStatus:setVisible(false)
        -- this:animateStatus(this.SelfUserStatus)
      end))
  end

  function theClass:ButtonPass_onClicked(sender, event)
    self:showButtonsPanel(false)
    self:resetPickedPokecards()
    self.gameService:playCard(self.selfUserId, '', function(data)
        if data.result.retCode ~= 0 then
          self:showButtonsPanel(true)
        end
      end)
  end

  function theClass:ButtonReset_onClicked(sender, event)
    --self:enableButtonTip(true)
    self:resetPickedPokecards()
    self:updateButtonsState()
  end

  function theClass:ButtonTip_onClicked(sender, event)
    if self.tipPokeChars == nil or self.tipPokeChars == '' then
      self:ButtonPass_onClicked(self.ButtonPass, event)
      return
    end

    local pokeCards = PokeCard.getByPokeChars(self.tipPokeChars)
    self:pickupPokecards(pokeCards)
    self:updateButtonsState()

    -- --self:enableButtonPlay( not self.ButtonPlay:isEnabled() )
    -- local analyzedCards = self.selfPlayerInfo.analyzedCards
    -- local cards
    -- local pokeCards = {}
    -- cards = analyzedCards.straightsCards
    -- if #cards == 0 then
    --   cards = analyzedCards.pairsStraightsCards
    -- end
    -- if #cards == 0 then
    --   cards = analyzedCards.threesCards
    -- end
    -- if #cards == 0 then
    --   cards = analyzedCards.pairsCards
    -- end
    -- if #cards == 0 then
    --   cards = analyzedCards.singlesCards
    -- end

    -- if #cards > 0 then
    --   local card = cards[1]
    --   local pokeCards = table.dup(card.pokeCards)
    --   if card.cardType == CardType.THREE then
    --     local singleCards = analyzedCards.singlesCards
    --     if #singleCards > 0 then
    --       table.insert(pokeCards, singleCards[1].pokeCards[1])
    --     else
    --       local pairsCards = analyzedCards.pairsCards
    --       if #pairsCards > 0 then
    --         table.append(pokeCards, pairsCards[1].pokeCards)
    --       end
    --     end
    --   elseif card.CardType == CardType.THREE_STRAIGHT then
    --     local singleCards = analyzedCards.singlesCards
    --     if #singleCards >= card.cardLength then
    --       for i=1,card.cardLength do
    --         table.insert(pokeCards, singleCards[i].pokeCards[1])
    --       end
    --     else
    --       local pairsCards = analyzedCards.pairsCards
    --       if #pairsCards >= card.cardLength then
    --         table.append(pokeCards, pairsCards[i].pokeCards)
    --       end 
    --     end
    --   end

    --   self:pickupPokecards(pokeCards)
    --   self:updateButtonsState()
    -- end

  end

  function theClass:ButtonPlay_onClicked(sender, event)
    local pokeCards = self:getPickedPokecards()
    local pokeIdChars = PokeCard.getIdChars(pokeCards)

    if self.tipPokeChars == '' then
      self:ButtonPass_onClicked(self.ButtonPass, event)
      return;
    end

    local card = Card.create(pokeCards)
    -- dump(card, '[theClass:ButtonPlay_onClicked] card')
    if card.cardType == CardType.NONE then
      self.PlayTipsLabel:setVisible(false)
      self.PlayTipsLabel:setOpacity(0)
      self.PlayTipsLabel:setString('所选牌型无效')
      self.PlayTipsLabel:runAction(
        cc.Sequence:create(
            cc.Show:create(),
            cc.FadeIn:create(0.5),
            cc.DelayTime:create(2),
            cc.Hide:create()
          )
        )
      return
    end

    local pomeGame = self.pokeGame
    local lastPlay = pomeGame.lastPlay
    if lastPlay ~= nil and lastPlay.player.userId ~= self.selfUserId then
      if not card:isGreaterThan(lastPlay.card) then
        self.PlayTipsLabel:setVisible(false)
        self.PlayTipsLabel:setOpacity(0)
        self.PlayTipsLabel:setString('您所要出的牌没有大过对方')
        self.PlayTipsLabel:runAction(
          cc.Sequence:create(
              cc.Show:create(),
              cc.FadeIn:create(0.5),
              cc.DelayTime:create(2),
              cc.Hide:create()
            )
          )
        return
      end
    end

    self:showButtonsPanel(false)
    self.gameService:playCard(self.selfUserId, pokeIdChars, function(data)
        if data.result.retCode ~= 0 then
          self:showButtonsPanel(true)

          -- self.PlayTipsLabel:setVisible(false)
          -- self.PlayTipsLabel:setOpacity(0)
          -- self.PlayTipsLabel:setString('您所要出的牌没有大过对方')
          -- self.PlayTipsLabel:runAction(
          --   cc.Sequence:create(
          --       cc.Show:create(),
          --       cc.FadeIn:create(0.5),
          --       cc.DelayTime:create(2),
          --       cc.Hide:create()
          --     )
          --   )
        else
          self.PlayTipsLabel:setVisible(false)
        end
      end)
  end

  function theClass:ButtonNoGrabLord_onClicked(sender, event)
    self.gameService:grabLord(self.selfUserId, ddz.Actions.GrabbingLord.None)
    self:showGrabLordButtonsPanel(false)
  end

  function theClass:ButtonGrabLord_onClicked(sender, event)
    self.gameService:grabLord(self.selfUserId, ddz.Actions.GrabbingLord.Grab)
    self:showGrabLordButtonsPanel(false)
  end

  function theClass:ButtonConfig_onClicked(sender, event)
    -- if self.gameOverDialog == nil then
    --   local onClose = function() end
    --   local onNewGame = function() end
    --   self.gameOverDialog = require('gaming.GameResultDialog').new(onClose, onNewGame)
    --   self:addChild(self.gameOverDialog)      
    -- end

    -- self.gameOverDialog:setPosition(0,0)
    -- self.gameOverDialog:setVisible(true)
    -- self.gameOverDialog.keypadListener:setEnabled(true)
    -- ddz.pomeloClient:disconnect()

    --self:playCardEffect({gender='女'}, {cardType = 10})
    local audioConfig = require('sysConfig.AudioConfigScene').showAudioConfig(self, {})
  end

  function theClass:ButtonBack_onClicked(sender, event)
    local gameConn = require('network.GameConnection')
    gameConn:reconnect()
  end

  function theClass:ButtonDelegate_onClicked( sender, event )
    print("[ButtonDelegate_onClicked] start to call cancel delegate" )
    self.gameService:cancelDelegate(function(data)
        self.ButtonDelegate:setVisible(false)
      end)
  end

end

return UIButtonsPlugin