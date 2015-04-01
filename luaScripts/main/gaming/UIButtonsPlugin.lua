local Res = require('Resources')
local UIButtonsPlugin = {}


function UIButtonsPlugin.bind( theClass )
  function theClass:showGrabLordButtonsPanel(show, currentLordValue)
    local this = self
    --__G__TRACKBACK__('theClass:showGrabLordButtonsPanel')
    currentLordValue = currentLordValue or 0
    print('[theClass:showGrabLordButtonsPanel] show: ', show, ' , currentLordValue: ', currentLordValue)
    self.GrabLordButtonsPanel:setVisible(show)
    if show then
      if currentLordValue == 0 then
        self.LabelNoGrab:setString('不叫')
        self.LabelGrab:setString('叫地主')
        -- self.ImageNoGrabLord:loadTexture(Res.Images.PlayerStatus.NoGrabLord, ccui.TextureResType.localType)
        -- self.ImageGrabLord:loadTexture(Res.Images.PlayerStatus.GrabLord, ccui.TextureResType.localType)
      else
        self.LabelNoGrab:setString('不抢')
        self.LabelGrab:setString('抢地主')
        -- self.ImageNoGrabLord:loadTexture(Res.Images.PlayerStatus.PassGrabLord, ccui.TextureResType.localType)
        -- self.ImageGrabLord:loadTexture(Res.Images.PlayerStatus.ReGrabLord, ccui.TextureResType.localType)
      end
    end
  end

  function theClass:showButtonsPanel(show)
    self.ButtonsPanel:setVisible(show)
    self:updateButtonsState()
  end

  function theClass:enableButtonPass(enabled)
    self.ButtonPass:setBright(enabled)
    self.ButtonPass:setEnabled(enabled)
    -- local imgPath = 'images/game11.png'
    -- if not enabled then
    --   imgPath = 'images/game15.png'
    -- end
    -- self.ImagePass:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonReset(enabled)
    self.ButtonReset:setBright(enabled)
    self.ButtonReset:setEnabled(enabled)

    --self.ButtonReset:setEnabled(enabled)
    -- local imgPath = 'images/game12.png'
    -- if not enabled then
    --   imgPath = 'images/game16.png'
    -- end
    -- self.ImageReset:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonTip(enabled)
    self.ButtonTip:setBright(enabled)
    self.ButtonTip:setEnabled(enabled)
    --self.ButtonTip:setEnabled(enabled)
    -- local imgPath = 'images/game13.png'
    -- if not enabled then
    --   imgPath = 'images/game17.png'
    -- end
    -- self.ImageTip:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonPlay(enabled)
    self.ButtonPlay:setBright(enabled)
    self.ButtonPlay:setEnabled(enabled)
    -- local imgPath = 'images/game14.png'
    -- if not enabled then
    --   imgPath = 'images/game18.png'
    -- end
    -- self.ImagePlay:loadTexture(imgPath, ccui.TextureResType.localType)
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
    self.JipaiqiPanel:setVisible(false)
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


  end

  function theClass:ButtonPlay_onClicked(sender, event)
    local pokeCards = self:getPickedPokecards()
    local pokeIdChars = PokeCard.getIdChars(pokeCards)

    -- if self.tipPokeChars == '' then
    --   self:ButtonPass_onClicked(self.ButtonPass, event)
    --   return;
    -- end

    local card = Card.create(pokeCards)
    -- dump(card, '[theClass:ButtonPlay_onClicked] card')
    if card.cardType == CardType.NONE then
      self:showSelfPlayTips('所选牌型无效', 2)
      -- self.PlayTipsLabel:setVisible(false)
      -- self.PlayTipsLabel:setOpacity(0)
      -- self.PlayTipsLabel:setString('所选牌型无效')
      -- self.PlayTipsLabel:runAction(
      --   cc.Sequence:create(
      --       cc.Show:create(),
      --       cc.FadeIn:create(0.5),
      --       cc.DelayTime:create(2),
      --       cc.Hide:create()
      --     )
      --   )
      return
    end

    local pomeGame = self.pokeGame
    local lastPlay = pomeGame.lastPlay
    if lastPlay ~= nil and lastPlay.player.userId ~= self.selfUserId then
      if not card:isGreaterThan(lastPlay.card) then
        self:showSelfPlayTips('您所要出的牌没有大过对方', 2)
        return
      end
    end

    self:showButtonsPanel(false)
    self.gameService:playCard(self.selfUserId, pokeIdChars, function(data)
        if data.result.retCode ~= 0 then
          self:showButtonsPanel(true)
        else
          self:hideSelfPlayTips()
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
    local this = self
    -- local gameConn = require('network.GameConnection')
    -- gameConn:reconnect()
   --  local dialog = require('chat.ChatLayer').new()
  	-- self:addChild(dialog)
    this:onBackClicked()
  end

  function theClass:ButtonChat_onClicked(sender, event)
    local dialog = require('chat.ChatLayer').new()
    self:addChild(dialog)
  end

  function theClass:ButtonDelegate_onClicked( sender, event )
    print("[ButtonDelegate_onClicked] start to call cancel delegate" )
    self.gameService:cancelDelegate(function(data)
        self.ButtonDelegate:setVisible(false)
      end)
  end

  function theClass:ButtonRecharge_onClicked(sender, event)
    print('[theClass:ButtonRecharge_onClicked]');
  end

  function theClass:SelfUserHead(sender, event)
    print('[theClass:SelfUserHead]');
  end

  function theClass:sendRandMessage(userHead)
  	print('sendRandMessage')
  	local heads = {self.SelfUserHead, self.PrevUserHead, self.NextUserHead}
  	local anims = {'boom','rottenegg','diamond','flower'}
  	local msgs = {'我等的假花儿都谢了！','真怕猪一样的队友！','一走一停真有型，一秒一卡好','我炸你个桃花朵朵开！',
  		'姑娘，你真是条汉子。','风吹鸡蛋壳，牌去人安乐。','搏一搏，单车变摩托。','炸得好！'}
    local from = userHead
    local rheads = {}
    for _,v in pairs(heads) do
    	if v ~= userHead then
    		table.insert(rheads, v)
    	end
    end
    local to = rheads[math.random(2)]
    local anim = anims[math.random(4)]
    local randNum = math.random()
    if randNum < 0.5 then
    	print('send danmu ')
    	require('chat.DanMuChat').sendDanmu(from,to,anim)
    else
    	print('send emoji')
    	local index = math.random(12)
    	require('chat.EmojiChat').onUserEmoji(userHead, index, userHead == self.SelfUserHead)
    end
	end

  function theClass:PrevUserHead_onClicked(sender, event)
  	print('PrevUserHead_onClicked')
  	self:sendRandMessage(self.PrevUserHead)
  end

  function theClass:NextUserHead_onClicked(sender, event)
  	print('NextUserHead_onClicked')
  	self:sendRandMessage(self.NextUserHead)
  end

  function theClass:SelfUserHead_onClicked(sender, event)
  	print('SelfUserHead_onClicked')
  	self:sendRandMessage(self.SelfUserHead)
  end

end

return UIButtonsPlugin