--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

EmojiChat = {}

EmojiChat.onUserEmoji = function(userHead, index, isSelf)
	local counts = {2,4,3,8,12,11,11,4,2,6,7,11}
	local count = counts[index]
	local repeatTime = 1
	if count < 4 then
		repeatTime = 3
	elseif count < 8 then
		repeatTime = 2
	end
	local nameFunc = function(mindex)
		return string.format("%02d/emo%02d_%02d.png",index,index,mindex)
	end
	local animate = EmojiChat.getAnimate("emoji_"..tostring(index), count, 0.2, "emo.plist", nameFunc)
	local sprite = cc.Sprite:createWithSpriteFrameName(nameFunc(1))
	
	if isSelf then
		local winSize = cc.Director:getInstance():getWinSize()
		sprite:setPosition(winSize.width/2, winSize.height/2)
		cc.Director:getInstance():getRunningScene():addChild(sprite)
	else
		sprite:setScale(1/userHead:getScale()*0.8)
		userHead:addChild(sprite)
	end
	local seq = cc.Sequence:create(cc.Repeat:create(animate, repeatTime), cc.RemoveSelf:create())
	sprite:runAction(seq)
	sprite:setAnchorPoint(0,0)
end

EmojiChat.getAnimate = function(name, count, interval, plist, nameFunc)
	local animCache = cc.AnimationCache:getInstance()
  local animation = animCache:getAnimation(name)
  if animation == nil then
    local frameCache = cc.SpriteFrameCache:getInstance()
    frameCache:addSpriteFrames(plist)
    local frames = {}
    for i=1, count do
      local frame = frameCache:getSpriteFrame(nameFunc(i))
      table.insert(frames, frame)
    end
    animation = cc.Animation:createWithSpriteFrames(frames, interval)
    animCache:addAnimation(animation, name)
  end
  return cc.Animate:create(animation)
end

return EmojiChat