local UIPokecardsPlugin = {}

PokecardPickAI = require('PokecardPickAI')


function UIPokecardsPlugin.bind( theClass )
  local lastIndexBegin, lastIndexEnd = nil, nil
  local thisObj = nil

  local function pickPokecard(pokeCard)
    if not pokeCard.picked then
      pokeCard.picked = true
      pokeCard.card_sprite:runAction(cc.MoveBy:create(0.07, cc.p(0, 30)))
    end
  end

  local function unpickPokecard(pokeCard)
    if pokeCard.picked then
      pokeCard.picked = false
      pokeCard.card_sprite:runAction(cc.MoveBy:create(0.07, cc.p(0, -30)))
    end
  end

  local function togglePokecard(pokeCard)
    if pokeCard.picked then
      unpickPokecard(pokeCard)
    else
      pickPokecard(pokeCard)
    end
  end

  local function highlightPokecard(pokeCard)
    if pokeCard.card_sprite:getTag() ~= ddz.PokecardPickTags.Picked then
      pokeCard.card_sprite:setColor(ddz.PokecardPickColors.Selected)
      pokeCard.card_sprite:setTag(ddz.PokecardPickTags.Picked)
    end
  end

  local function unhighlightPokecard(pokeCard)
    if pokeCard.card_sprite:getTag() ~= ddz.PokecardPickTags.Unpicked then
      pokeCard.card_sprite:setColor(ddz.PokecardPickColors.Normal)
      pokeCard.card_sprite:setTag(ddz.PokecardPickTags.Unpicked)
    end
  end


  --[[-----------------------------------------------------------
  获取loc坐标所在的牌, 由于牌是从大到小排序的显示的，小的牌显示在前面。
  所以需要从最后一个元素开始往回找。
  返回：找到就返回牌在数组中的index, -1 表示该位置无牌 
  --]]-----------------------------------------------------------
  local function getCardIndex(loc)
    local result = -1
    for index = #thisObj.pokeCards, 1, -1 do
      local pokeCard = thisObj.pokeCards[index]
      local cardBoundingBox = pokeCard.card_sprite:getBoundingBox()
      if cc.rectContainsPoint(cardBoundingBox, loc) then
        result = index
        break
      else
      end
    end
    return result
  end

  --[[-----------------------------------------------------------
  显示手指划过的牌的效果
  --]]-----------------------------------------------------------
  local function move_check(indexBegin, indexEnd)
    -- 确保 indexBegin <= indexEnd
    if indexBegin > indexEnd then
      indexBegin, indexEnd = indexEnd, indexBegin
    end

    for index = #thisObj.pokeCards, 1, -1 do
      local pokeCard = thisObj.pokeCards[index]
      if index > indexEnd or index < indexBegin then
        -- 不在本次手指划过范围内的牌，恢复正常状态
        unhighlightPokecard(pokeCard)
      else
        -- 在本次划过范围内的牌，如果还没设置选取标志的，设置牌划过效果和标志
        highlightPokecard(pokeCard)
      end
    end
  end

  
  --[[-----------------------------------------------------------
  手指点击开始
  --]]-----------------------------------------------------------
  local function onTouchBegan(touch, event)
    -- 如果当前还没有牌，直接返回false
    if thisObj.pokeCards == nil then
      return false
    end

    -- 转换触点坐标
    local locationInNode = thisObj:convertToNodeSpace(touch:getLocation())
    -- 取该点的牌index
    lastIndexBegin = getCardIndex(locationInNode)
    if lastIndexBegin > 0 then
      -- 有牌，显示效果
      move_check(lastIndexBegin, lastIndexBegin)
    end

    return true
  end

  --[[-----------------------------------------------------------
  手指移动, 每次移动都判断位置变化并更新划过的牌的效果
  --]]-----------------------------------------------------------
  local function onTouchMoved(touch, event)
    -- 转换触点坐标
    local locationInNode = thisObj:convertToNodeSpace(touch:getLocation())
    -- 取该点的牌index
    local curIndex = getCardIndex(locationInNode)
    if curIndex < 0 or curIndex == lastIndexEnd then
      -- 如果没牌，或在同一张牌上划动，直接返回
      return
    end

    -- 记下本次的牌位置为lastIndexEnd
    lastIndexEnd = curIndex
    -- 如果还没有lastIndexBegin
    if lastIndexBegin < 0 then
      lastIndexBegin = curIndex
    end
    -- 更新划过效果
    move_check(lastIndexBegin , lastIndexEnd)
  end

  
  --[[-----------------------------------------------------------
  手指移动结束， 对所划过的牌进行抽牌、退牌处理
  --]]-----------------------------------------------------------
  local function onTouchEnded(touch, event)
    local indexBegin, indexEnd = lastIndexBegin , lastIndexEnd
    -- 重置划牌index
    lastIndexBegin , lastIndexEnd = -1, -1

    -- 如果没有牌被划过，直接返回
    if (indexBegin == nil or indexBegin < 0) then
      thisObj:updateButtonsState()
      return
    end

    if indexEnd == nil or indexEnd < 0 then
      indexEnd = indexBegin
    end

    -- 确保 indexBegin <= indexEnd
    if indexBegin > indexEnd then
      indexBegin, indexEnd = indexEnd, indexBegin
    end

    local hoveredPokecards = table.copy(thisObj.pokeCards, indexBegin, indexEnd)
    local allInPicked = true
    if thisObj.pokeGame.nextPlayerId == thisObj.selfPlayerInfo.userId then
      for i=1, #hoveredPokecards do
        if not hoveredPokecards[i].picked then
          allInPicked = false
          break
        end
      end
    end

    if not allInPicked and 
      thisObj.pokeGame.nextPlayerId == thisObj.selfPlayerInfo.userId and 
      thisObj.pokeGame.lastPlay and 
      thisObj.pokeGame.lastPlay.player.userId ~= thisObj.selfPlayerInfo.userId then
      local pokecards = PokecardPickAI:findValidCard(hoveredPokecards, thisObj.pokeGame.lastPlay.card)
      if pokecards ~= nil then
        for i=1, #thisObj.pokeCards do
          local poke = thisObj.pokeCards[i]
          if table.indexOf(pokecards, poke) < 0 then
            unpickPokecard(poke)
            unhighlightPokecard(poke)
          end
        end
        for i=1, #pokecards do
          local poke = pokecards[i]
          pickPokecard(poke)
          unhighlightPokecard(poke)
        end
        thisObj:updateButtonsState()
        return
      end
    end

    for i = indexBegin, indexEnd do
      local pokeCard = thisObj.pokeCards[i]
      -- 取消牌划过效果
      pokeCard.card_sprite:setTag(ddz.PokecardPickTags.Unpicked)
      pokeCard.card_sprite:setColor(ddz.PokecardPickColors.Normal)
      -- 如果当前牌未被选取，做抽牌处理
      togglePokecard(pokeCard)
      -- if pokeCard.picked ~= true then
      --   pokeCard.picked = true
      --   pokeCard.card_sprite:runAction(cc.MoveBy:create(0.07, cc.p(0, 30)))
      -- else
      --   -- 牌已被选取，做退牌处理
      --   pokeCard.picked = false
      --   pokeCard.card_sprite:runAction(cc.MoveBy:create(0.07, cc.p(0, -30)))
      -- end
    end
    thisObj:updateButtonsState()
  end

  --[[-----------------------------------------------------------
  设置扑克层的触摸事件，做选牌处理
  --]]-----------------------------------------------------------
  function theClass:initPokeCardsLayerTouchHandler()
    thisObj = self

    local listener = cc.EventListenerTouchOneByOne:create()
    self._listener = listener
    listener:setSwallowTouches(true)

    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, thisObj.pokeCardsLayer)
  end

  function theClass:showDrawingCardsAnimation(nextUserId, timing)
    local this = self
    local pokeCards = table.copy(self.selfPlayerInfo.pokeCards)
    local pokeLen = #pokeCards
    local index = 1
    shuffleArray(pokeCards)

    self.pokeCards = {}
    if not self.selfDrawingCard then
      self.selfDrawingCard = cc.Sprite:create('images/game168.png')
      self.selfDrawingCard:setVisible(false)
      self.pokeCardsLayer:addChild(self.selfDrawingCard, -100)    
    end

    self:runAction(
      cc.Sequence:create(
        cc.Repeat:create( 
          cc.Sequence:create(
            cc.CallFunc:create(function() 
              this.selfDrawingCard:setPosition(400, 300)
              this.selfDrawingCard:setVisible(true)
            end),
            cc.TargetedAction:create(
              this.selfDrawingCard,
              cc.MoveTo:create(2/17, cc.p(400, 60))
            ),
            cc.CallFunc:create(function() 
              this.selfDrawingCard:setVisible(false)
              table.insert(this.pokeCards, pokeCards[index])
              table.sort(this.pokeCards, sortDescBy('index'))
              this:showCards(this.pokeCards, true)
              index = index + 1
            end)
            --,cc.DelayTime:create(2 / 17)
          ), 
          pokeLen
        ),
        cc.CallFunc:create(function()
          this.pokeCards = this.selfPlayerInfo.pokeCards
          table.sort(this.pokeCards, sortDescBy('index'))
          this:showGrabLordButtonsPanel(nextUserId == this.selfUserId, this.pokeGame.grabbingLord.lordValue)
          print('[UIPokecardsPlugin:showDrawingCardsAnimation] timing: ', timing)
          this:showPlaycardClock(nil, timing, true)
        end)
      )
    )
  end
  
  --------------------------------------------------------------
  -- 显示牌:
  -------------------------------------------------------------
  function theClass:showCards(pokeCards, noAnimate)
    local p = cc.p(20, (self.visibleSize.height - self.cardContentSize.height)/2)
    p.y = 0
    --local pokeCards = self.selfPlayerInfo.pokeCards
    for index, pokeCard in pairs(pokeCards) do
      local cardSprite = pokeCard.card_sprite
      local cardValue = pokeCard.index
  
      cardSprite:setTag(0)
      if not noAnimate then
        cardSprite:setPosition( cc.p((self.visibleSize.width - self.cardContentSize.width)/2, p.y) )
      end
      cardSprite:setScale(GlobalSetting.content_scale_factor)
      cardSprite:setVisible(true)
      cardSprite:getParent():reorderChild(cardSprite, index)
    end
    self:alignCards(pokeCards, noAnimate)
  end
  
  --[[---------------------------------------------------
  -- 根据牌的数量重新排列展示
  --]]----------------------------------------------------
  function theClass:alignCards(pokeCards, noAnimate) 
    --local pokeCards = self.selfPlayerInfo.pokeCards
     -- 无牌？返回
    if #pokeCards < 1 then
      return
    end
    
    local p = cc.p(0, 0) 
    local cardWidth = self.cardContentSize.width --* GlobalSetting.content_scale_factor
    --print("cardWidth", cardWidth)
    -- 计算牌之间的覆盖位置，最少遮盖30% 即显示面积最多为70%
    local step = (self.visibleSize.width - 40) / (#pokeCards + 1)
    if step > cardWidth * 0.6 then
      step = cardWidth * 0.6
    end
  
    -- 计算中心点
    local poke_size = cardWidth / 2
    local center_point = cc.p(self.visibleSize.width/2, 0)
    
    -- 第一张牌的起始位置，必须大于等于0
    local start_x = center_point.x - (step * #pokeCards/2 + poke_size / 2)
    if start_x < 0 then
      start_x = 0
    end
    
    p.x = start_x
    
    -- 排列并产生移动效果
    for index, pokeCard in pairs(pokeCards) do 
      if pokeCard.card_sprite:getParent() then
        pokeCard.card_sprite:setLocalZOrder(index)
        --pokeCard.card_sprite:getParent():reorderChild(pokeCard.card_sprite, index)
      end
      pokeCard.picked = false
      if not noAnimate then
        pokeCard.card_sprite:runAction( cc.MoveTo:create(0.3, p ) )
      else
        pokeCard.card_sprite:setPosition(p)
      end
      p.x = p.x + step
    end   
  end
  
  --[[
  提取选中的牌
  --]]
  function theClass:getPickedPokecards()
    local picked = {}
    if not self.selfPlayerInfo then
      return picked
    end

    for _, pokeCard in pairs(self.selfPlayerInfo.pokeCards) do
      if pokeCard.picked then
        table.insert(picked, pokeCard)
      end
    end
    
    table.sort(picked, sortAscBy('index'))
    return picked
  end

  --[[
  取消选中的牌
  --]]
  function theClass:resetPickedPokecards()
    local pokeCards = self.selfPlayerInfo.pokeCards
    for _, pokeCard in pairs(pokeCards) do
      if pokeCard.picked then
        -- 牌已被选取，做退牌处理
        pokeCard.picked = false
        pokeCard.card_sprite:runAction(cc.MoveBy:create(0.07, cc.p(0, -30)))
      end
    end
  end

  function theClass:pickupPokecards(pokeCards)
    self:resetPickedPokecards()
    for _, pokeCard in pairs(pokeCards) do
      pokeCard.picked = true
      pokeCard.card_sprite:runAction(cc.MoveBy:create(0.07, cc.p(0, 30)))
    end
  end

  --[[-----------------------------------------------------------
  显示自己出牌动画效果
  --]]-----------------------------------------------------------
  function theClass:selfPlayCardEffect(card)
    local pokeCards = card.pokeCards
    if pokeCards == nil or #pokeCards == 0 then
      return
    end

    -- if self.selfLastCard and #self.selfLastCard.pokeCards > 0 then
    --   for _, pokeCard in pairs(self.selfLastCard.pokeCards) do
    --     pokeCard.card_sprite:setPosition(-150, 0)
    --     pokeCard.card_sprite:setVisible(false)
    --   end 
    -- end

    -- self.selfLastCard = {pokeCards = pokeCards}

    local centerPoint = cc.p(self.visibleSize.width/2, self.visibleSize.height/2 - 80)
    local step = 35 * 0.7
    local pokeSize = self.cardContentSize.width/2
    local startX = centerPoint.x - (step * #pokeCards / 2 + pokeSize) * 0.7
    for index = #pokeCards, 1, -1 do
      local pokeSprite = pokeCards[index].card_sprite
      pokeSprite:runAction(cc.Spawn:create(
        cc.MoveTo:create(0.2, cc.p(startX, centerPoint.y)),
        cc.ScaleTo:create(0.1, 0.5)
      ))
      startX = startX + 35 * 0.7
      pokeSprite:getParent():reorderChild(pokeSprite, -100 - index)
    end
    --table.removeItems(self.selfPlayerInfo.pokeCards, pokeCards)
    self:alignCards(self.selfPlayerInfo.pokeCards)
  end

  --[[-----------------------------------------------------------
  显示上家出牌动画效果
  --]]-----------------------------------------------------------
  function theClass:prevPlayCardEffect(card)
    local pokeCards = card.pokeCards
    local startPoint = cc.p(-100, self.visibleSize.height + 100)
    local pokeSize = self.cardContentSize.width/2
    local step = 35 * 0.7
    local endPoint = cc.p(165, 270)

    for index = #pokeCards, 1, -1 do
      local pokeSprite = pokeCards[index].card_sprite
      pokeSprite:setPosition(startPoint)
      --pokeSprite:setLocalZOrder(100 - index)
      pokeSprite:getParent():reorderChild(pokeSprite, -100 - index);
      pokeSprite:setVisible(true)

      pokeSprite:runAction(cc.Spawn:create(
        cc.MoveTo:create(0.2, endPoint),
        cc.ScaleTo:create(0.1, 0.5)
      ))
      endPoint.x = endPoint.x + 35 * 0.7
    end
  end

  --[[-----------------------------------------------------------
  显示下家出牌动画效果
  --]]-----------------------------------------------------------
  function theClass:nextPlayCardEffect(card)
    local pokeCards = card.pokeCards
    local startPoint = cc.p(self.visibleSize.width + 100, self.visibleSize.height + 100)
    local pokeSize = self.cardContentSize.width/2
    local step = 35 * 0.7
    local endPoint = cc.p(585, 270)

    for index = 1, #pokeCards do
      local pokeSprite = pokeCards[index].card_sprite
      pokeSprite:setPosition(startPoint)
      --pokeSprite:setLocalZOrder(100 - index)
      pokeSprite:getParent():reorderChild(pokeSprite, -100 - index);
      pokeSprite:setVisible(true)

      pokeSprite:runAction(cc.Spawn:create(
        cc.MoveTo:create(0.2, endPoint),
        cc.ScaleTo:create(0.1, 0.5)
      ))
      endPoint.x = endPoint.x - 35 * 0.7
    end
  end

  function theClass:showPrevPlayerRestPokecards(pokeCards)
    pokeCards = pokeCards or self.prevPlayerInfo.pokeCards
    if #pokeCards == 0 then
      return
    end
    self:hideCard(self.prevPlayerInfo.lastCard)
    local startPoint = cc.p(-100, 280)
    local pokeSize = self.cardContentSize.width/2
    local step = 35 * 0.7
    local endPoint = cc.p(125, 280)

    -- for index = #pokeCards, 1, -1 do
    --   local pokeSprite = pokeCards[index].card_sprite
    --   pokeSprite:setPosition(endPoint)
    --   --pokeSprite:setLocalZOrder(100 - index)
    --   pokeSprite:getParent():reorderChild(pokeSprite, -100 - index)
    --   pokeSprite:setVisible(true)
    --   pokeSprite:setScale(0.6)

    --   endPoint.x = endPoint.x + 35 * 0.7
    -- end

    local count = 1
    local index = #pokeCards
    while index > 0 do
      local pokeSprite = pokeCards[index].card_sprite
      pokeSprite:setPosition(endPoint)
      --pokeSprite:setLocalZOrder(100 - index)
      pokeSprite:getParent():reorderChild(pokeSprite, -100 - index)
      pokeSprite:setVisible(true)
      pokeSprite:setScale(0.6)

      if count == 10 then 
        endPoint = cc.p(125, 240)
      else
        endPoint.x = endPoint.x + 35 * 0.7
      end

      count = count + 1
      index = index - 1
    end

  end

  function theClass:showNextPlayerRestPokecards(pokeCards)
    pokeCards = pokeCards or self.nextPlayerInfo.pokeCards
    if #pokeCards == 0 then
      return
    end
    
    self:hideCard(self.nextPlayerInfo.lastCard)
    local startPoint = cc.p(self.visibleSize.width + 100, 280)
    local pokeSize = self.cardContentSize.width/2
    local step = 35 * 0.7
    local endPoint = cc.p(625, 280)

    -- for index = 1, #pokeCards do
    --   local pokeSprite = pokeCards[index].card_sprite
    --   pokeSprite:setPosition(endPoint)
    --   --pokeSprite:setLocalZOrder(100 - index)
    --   pokeSprite:getParent():reorderChild(pokeSprite, -100 - index)
    --   pokeSprite:setScale(0.6)
    --   pokeSprite:setVisible(true)

    --   -- pokeSprite:runAction(cc.Spawn:create(
    --   --   cc.MoveTo:create(0.2, endPoint),
    --   --   cc.ScaleTo:create(0.1, 0.7)
    --   -- ))
    --   endPoint.x = endPoint.x - 35 * 0.7
    -- end

    local count = 1
    local index = #pokeCards
    local startX = 630 - #pokeCards * 35 * 0.7
    if #pokeCards > 10 then
      startX = 630 - 10 * 35 * 0.7
    end 
    endPoint = cc.p(startX, 280)

    while index > 0 do
      local pokeSprite = pokeCards[index].card_sprite
      pokeSprite:setPosition(endPoint)
      --pokeSprite:setLocalZOrder(100 - index)
      pokeSprite:getParent():reorderChild(pokeSprite, -100 - index)
      pokeSprite:setVisible(true)
      pokeSprite:setScale(0.6)

      if count == 10 then 
        endPoint = cc.p(startX, 240)
      else
        endPoint.x = endPoint.x + 35 * 0.7
      end

      count = count + 1
      index = index - 1
    end

  --end
  
  end

  --[[-----------------------------------------------------------
  隐藏出过的牌
  --]]-----------------------------------------------------------
  function theClass:hideCard(theCard)
    theCard = theCard or {}
    theCard.pokeCards = theCard.pokeCards or {}
    for _, pokeCard in pairs(theCard.pokeCards) do
      local cardSprite = pokeCard.card_sprite
      cardSprite:setVisible(false)
      cardSprite:setScale(1)
      cardSprite:setPosition(-150, -150)
    end
  end

  function theClass:hideSelfPokecards()
    self:hideCard({pokeCards = self.selfPlayerInfo.pokeCards})
  end

end

return UIPokecardsPlugin