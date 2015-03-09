local utils = require('utils.utils')
require('PokeCard')
local PokeCardTexture = class('PokeCardTexture')

function PokeCardTexture:loadPokeCardTextures(node, callback)
  local this = self
  print('[PokeCardTexture:loadPokeCardTextures] start')
  PokeCard.sharedPokeCard()
  print('[PokeCardTexture:loadPokeCardTextures] PokeCard.sharedPokeCard done')
  
  print('[PokeCardTexture:loadPokeCardTextures] cc.SpriteFrameCache:getInstance():addSpriteFrames(\'raw_lord_pokecards.plist\') done')
  local pokefile = 'pc.png'
  local filepath = cc.FileUtils:getInstance():fullPathForFilename(pokefile)
  print('filepath =>' , filepath)
  if not cc.FileUtils:getInstance():isFileExist(pokefile) then
    print('pokecards generating')
    cc.SpriteFrameCache:getInstance():addSpriteFrames('pokecards.plist')
    this:generatePokecards(node, callback)
    --this:generateLordPokecards()
    print('pokecards generated')
  else
    print('pokecards loading')
    local tex = cc.Director:getInstance():getTextureCache():addImage(pokefile)
    local lord_tex = cc.Director:getInstance():getTextureCache():addImage('lord_pc.png')
    PokeCard.createPokecardsFrames(tex)
    PokeCard.createLordPokecardsFrames(lord_tex)
    PokeCard.createPokecardsWithFrames(tex)
    print('pokecards loaded')
    utils.invokeCallback(callback)
  end
end

function PokeCardTexture:generatePokecards(node, callback)
  local this = self
  local function screenCap()
      local batchNode = PokeCard.createRawPokecardTextures()
      local renderTexture = cc.RenderTexture:create(1024, 1024, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
      this.renderTexture = renderTexture

      batchNode:retain()
      renderTexture:retain()

      renderTexture:begin()

      for row=0, 5 do
        for col=1, 10 do
          if row == 5 and col >4 then
            break
          end

          local index = row * 10 + col
          local poke = g_shared_cards[index]
          local sprite = poke.card_sprite
          sprite:setVisible(true)
          sprite:setPosition((col-1) * 100, row * 140)
        end
      end

      batchNode:visit()

      renderTexture:endToLua()

      --local this = self
      node:runAction(cc.Sequence:create(
          cc.DelayTime:create(0.01),
          cc.CallFunc:create(function() 
             local pImage = renderTexture:newImage()
            pImage:saveToFile(ddz.getDataStorePath() .. '/pc.png', false);

            local tex = cc.Director:getInstance():getTextureCache():addImage(pImage, 'pc.png')

            pImage:release()

            renderTexture:release()
            batchNode:release()
            PokeCard.createPokecardsFrames(tex)
            PokeCard.createPokecardsWithFrames(tex)

            node:runAction(cc.CallFunc:create(function() 
                this:generateLordPokecards(node, callback)
              end))
           end)
        ))
  end

  screenCap()

end

function PokeCardTexture:generateLordPokecards(node, callback)
  local this = self

  local function createLordPokeSprite(poke)
    local cardSprite = nil

    cardSprite = cc.Sprite:createWithSpriteFrameName('lord_pb.png')
    
    if poke.value == PokeCardValue.BIG_JOKER then
      local sprite = cc.Sprite:createWithSpriteFrameName('plf_BIG_JOKER.png')
      sprite:setAnchorPoint(cc.p(0, 0))
      sprite:setPosition(cc.p(0,0))
      cardSprite:addChild(sprite)
    elseif poke.value == PokeCardValue.SMALL_JOKER then
      local sprite = cc.Sprite:createWithSpriteFrameName('plf_SMALL_JOKER.png')
      sprite:setAnchorPoint(cc.p(0, 0))
      sprite:setPosition(cc.p(0,0))
      cardSprite:addChild(sprite)
    else

      local valueSprite, typeSprite
      local valueFrameName, typeFrameName
      if poke.pokeType == PokeCardType.DIAMOND or poke.pokeType == PokeCardType.HEART then
        valueFrameName = 'l_r_' .. poke.valueChar .. '.png'
      else
        valueFrameName = 'l_b_' .. poke.valueChar .. '.png'
      end
      typeFrameName = 'plf_' .. poke.pokeType .. '.png'

      valueSprite = cc.Sprite:createWithSpriteFrameName(valueFrameName)
      valueSprite:setAnchorPoint(cc.p(0, 0))
      valueSprite:setPosition(cc.p(0, 17))
      cardSprite:addChild(valueSprite)

      typeSprite = cc.Sprite:createWithSpriteFrameName(typeFrameName)
      typeSprite:setAnchorPoint(cc.p(0, 0))
      typeSprite:setPosition(cc.p(13, 1))
      cardSprite:addChild(typeSprite)
    end

    cardSprite:setAnchorPoint(cc.p(0, 0))
    return cardSprite
  end

  local function screenCap()
      local batchNode = cc.SpriteBatchNode:createWithTexture(
          cc.Director:getInstance():getTextureCache():getTextureForKey('raw_lord_pokecards.png'))
      local renderTexture = cc.RenderTexture:create(512, 256, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
      this.lord_renderTexture = renderTexture

      batchNode:retain()
      renderTexture:retain()

      renderTexture:begin()

      for row=0, 5 do
        for col=1, 10 do
          if row == 5 and col >4 then
            break
          end

          local index = row * 10 + col
          local poke = g_shared_cards[index]
          local sprite = createLordPokeSprite(poke)
          batchNode:addChild(sprite)
          sprite:setVisible(true)
          sprite:setPosition((col-1) * 31, row * 43)
        end
      end

      batchNode:visit()

      renderTexture:endToLua()

      --local this = self
      node:runAction(cc.Sequence:create(
          cc.DelayTime:create(0.01),
          cc.CallFunc:create(function() 
            local pImage = renderTexture:newImage()
            pImage:saveToFile(ddz.getDataStorePath() .. '/lord_pc.png', false);

            local tex = cc.Director:getInstance():getTextureCache():addImage(pImage, 'lord_pc.png')

            pImage:release()

            renderTexture:release()
            batchNode:release()
            PokeCard.createLordPokecardsFrames(tex)

            utils.invokeCallback(callback)
           end)
        ))
  end

  screenCap()

end


return PokeCardTexture