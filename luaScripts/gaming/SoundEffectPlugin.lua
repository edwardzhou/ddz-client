require('AudioEngine')
require('PokeCard')
local Res = require('Resources')
local SoundEffectPlugin = {}


function SoundEffectPlugin.bind( theClass )

  local function getCardSoundFile(card, female)
    local filename = 'Man_'
    if female then
      filename = 'Woman_'
    end

    if card.cardType == CardType.SINGLE then
      filename = filename .. card.maxPokeValue 
    elseif card.cardType == CardType.PAIRS then
      filename = filename .. 'dui' .. card.maxPokeValue
    elseif card.cardType == CardType.THREE then
      filename = filename .. 'tuple' .. card.maxPokeValue
    elseif card.cardType == CardType.STRAIGHT then
      filename = filename .. 'shunzi'
    elseif card.cardType == CardType.THREE_WITH_ONE then
      filename = filename .. 'sandaiyi'
    elseif card.cardType == CardType.THREE_WITH_PAIRS then
      filename = filename .. 'sandaiyidui'
    elseif card.cardType == CardType.PAIRS_STRAIGHT then
      filename = filename .. 'liandui'
    elseif card.cardType == CardType.THREE_STRAIGHT
        or card.cardType == CardType.PLANE
        or card.cardType == CardType.PLANE_WITH_WING then
      filename = filename .. 'feiji'
    elseif card.cardType == CardType.FOUR_WITH_TWO then
      filename = filename .. 'sidaier'
    elseif card.cardType == CardType.FOUR_WITH_TWO_PAIRS then
      filename = filename .. 'sidailiangdui'
    elseif card.cardType == CardType.BOMB then
      filename = filename .. 'zhadan'
    elseif card.cardType == CardType.ROCKET then
      filename = filename .. 'wangzha'
    else
      filename = filename .. 'buyao' .. (math.random(1000) % 4 + 1)
    end

    return filename .. '.mp3'
  end

 
  local function playCardSound(card, female)
    local filename = 'sounds/' .. getCardSoundFile(card, female)
    AudioEngine.playEffect(filename)
  end

  function theClass:playRocketEffect()
    self.RocketImage:setPosition(cc.p(400, -20))
    --self.RocketImage:setVisible(true)
    self.RocketImage:runAction(
      cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function ()
          AudioEngine.playEffect('sounds/Missile.mp3')
        end),
        cc.Show:create(),
        cc.MoveBy:create(1.2, cc.p(0, 550)),
        cc.Hide:create()
      )
    )
  end

  function theClass:playBombEffect()
    --self.RocketImage:setVisible(true)
    local animationCache = cc.AnimationCache:getInstance()
    local bombAnamination = animationCache:getAnimation('bomb')

    if bombAnamination == nil then
      bombAnamination = cc.Animation:create()
      local frames = {}
      for i=4, 10 do
        local frameName = string.format('images/bomb%d.png', i)
        --local frame = cc.SpriteFrame:create(frameName)
        --table.insert(frames, frame)
        bombAnamination:addSpriteFrameWithFile(frameName)
      end
      bombAnamination:setDelayPerUnit(0.125)
      --bombAnamination:setRestoreOriginalFrame(true)
      animationCache:addAnimation(bombAnamination, 'bomb')
    end

    if self.bombSprite == nil then
      self.bombSprite = cc.Sprite:create('images/bomb4.png')
      self.bombSprite:setAnchorPoint(cc.p(0.5, 0.5))
      self.bombSprite:setPosition(cc.p(400, 300))
      self:addChild(self.bombSprite, 20)
    end

    self.bombSprite:setVisible(false)
    self.bombSprite:setDisplayFrameWithAnimationName('bomb', 0)
    self.bombSprite:setOpacity(255)

    self.bombSprite:runAction(
      cc.Sequence:create(
        cc.DelayTime:create(0.3),
        cc.Show:create(),
        cc.Blink:create(0.2, 3),
        cc.CallFunc:create(function ()
          AudioEngine.playEffect('sounds/Bomb.mp3')
        end),
        cc.Animate:create(bombAnamination),
        cc.FadeOut:create(0.2),
        cc.Hide:create()
      )
    )
  end

  function theClass:playCardEffect(playerInfo, card)
    playCardSound(card, playerInfo.gender ~= '男')
    if card.cardType == CardType.ROCKET then
      self:playRocketEffect()
    elseif card.cardType == CardType.BOMB then
      self:playBombEffect()
    end
  end

  function theClass:playGrabLordEffect(playerInfo, grabState)
    local filename = 'Man_'
    if playerInfo.gender ~= '男' then
      filename = 'Woman_'
    end

    if grabState == ddz.PlayerStatus.NoGrabLord then
      filename = filename .. 'NoOrder'
    elseif grabState == ddz.PlayerStatus.GrabLord then
      filename = filename .. 'Order'
    elseif grabState == ddz.PlayerStatus.PassGrabLord then
      filename = filename .. 'NoRob'
    elseif grabState == ddz.PlayerStatus.ReGrabLord then
      filename = filename .. 'Rob1'
    end

    filename = filename .. '.mp3'

    filename = 'sounds/' .. filename
    AudioEngine.playEffect(filename)
  end

  function theClass:playWinEffect()
    local filename = 'sounds/game_win.mp3'
    AudioEngine.playEffect(filename)
  end

  function theClass:playLoseEffect()
    local filename = 'sounds/game_lose.mp3'
    AudioEngine.playEffect(filename)
  end

end

return SoundEffectPlugin