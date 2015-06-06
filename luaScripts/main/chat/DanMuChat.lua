--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

DanMuChat = {}

DanMuChat.sendDanmu = function(fromHead, toHead, danmuId)
	local names = {
		boom = {17,18,19,20,21,22,23,24,25,26,27,28},
		diamond = {0,5,10,15,17,24,27,29,32,33,34},
		flower = {0,3,8,10,12,15,17},
		rottenegg = {0,7,14,16,19,21}
	}
	cc.SpriteFrameCache:getInstance():addSpriteFrames('itr_emo.plist')
  local sprite = cc.Sprite:createWithSpriteFrameName('biaoqing_' .. danmuId .. 'xy_0.png')
  local getPos = function(sp)
  	local pos = cc.p(sp:convertToWorldSpace(cc.p(0,0)))
  	local size = sp:getContentSize()
  	local scale = sp:getScale()
  	return cc.pAdd(pos, cc.p(size.width/2 * scale, size.height/2 * scale))
	end
  local from = getPos(fromHead)
  local to = getPos(toHead)
  local scene = cc.Director:getInstance():getRunningScene()
  sprite:setPosition(from)
  scene:addChild(sprite)
  local dis = cc.pGetDistance(from, to)
  local mvSpeed = 400
  local rotateSpeed = 720
  local time = dis/mvSpeed
  local delay = cc.DelayTime:create(0.2)
  local move = cc.MoveTo:create(time, to)
  local rotation = time*rotateSpeed + (360 - (time*rotateSpeed % 360))
  local rotate = cc.RotateBy:create(time, rotation)
  local spawn = cc.Spawn:create(move, rotate)
  local anim = DanMuChat.getAnimate(danmuId, names[danmuId])
  local seq = cc.Sequence:create(delay, spawn, anim, delay:clone(), cc.RemoveSelf:create())
  sprite:runAction(seq)
end

DanMuChat.getAnimate = function(name, names)
	local animCache = cc.AnimationCache:getInstance()
  local animation = animCache:getAnimation(name)

  if animation == nil then

    local frameCache = cc.SpriteFrameCache:getInstance()
    local frames = {}
    for k,v in pairs(names) do
      local frame = frameCache:getSpriteFrame(string.format('biaoqing_%sz_%d.png', name, v))
      table.insert(frames, frame)
    end

    animation = cc.Animation:createWithSpriteFrames(frames, 0.1)
    animCache:addAnimation(animation, name)
  end
  return cc.Animate:create(animation)
end

return DanMuChat