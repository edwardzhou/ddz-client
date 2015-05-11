local Res = require('Resources')
local AccountInfo = require('AccountInfo')
local UIPlayerUpdatePlugin = {}

function UIPlayerUpdatePlugin.bind(theClass)

  local function updatePlayerPokecards(this, userUI, playerPokeCount)

    if userUI.pc_prefix ~= nil then
      local pokeCount = playerPokeCount or 0
      local pokeDiv = math.floor(pokeCount / 2)
      local pokeRem = pokeCount % 2
      local pc_name
      local pokeIndex
      for i=1, 10 do
        pokeIndex = 10 - i
        if pokeIndex > 0 then
          pc_name = string.format('%s%02d', userUI.pc_prefix, pokeIndex)
          local visible = pokeIndex > (10 - pokeDiv - pokeRem)
          this[pc_name]:setVisible(visible)
          local v = 0
          if visible then
            v=1
          end
          -- cclog('pokeCount: %d, pokeDiv: %d, pokeRem: %d, pc_name: %s, visible: %d', pokeCount, pokeDiv, pokeRem, pc_name, v)
        end

        pokeIndex = 10 + i
        if pokeIndex <= 20 then
          pc_name = string.format('%s%02d', userUI.pc_prefix, pokeIndex)
          local visible = pokeIndex <= (10 + pokeDiv)
          this[pc_name]:setVisible(visible)
          local v = 0
          if visible then
            v=1
          end
          -- cclog('pokeCount: %d, pokeDiv: %d, pokeRem: %d, pc_name: %s, visible: %d', pokeCount, pokeDiv, pokeRem, pc_name, v)
        end
      end

      this[userUI.pc_prefix .. '10']:setVisible(pokeCount > 0)
    end
  end

  function theClass:updateUserInfo()
    local coins = AccountInfo.getCurrentUser().ddzProfile.coins or 0
    self.SelfCoins:setString(coins)
  end

  function theClass:updateSelfPlayerUI(userInfo)
    local userUI = {
      Panel = self.SelfUserHead,
      Name = self.SelfUserName,
      Head = self.SelfUserHeadIcon,
      Status = self.SelfUserStatus,
      PokeCount = self.SelfUserPokeCount,
      Role = self.SelfUserRole
    }
    
    self:updatePlayerUI(userUI, userInfo)
  end

  function theClass:updatePrevPlayerUI(userInfo)
    local userUI = {
      Panel = self.PrevUser,
      Name = self.PrevUserName,
      Head = self.PrevUserHeadIcon,
      Status = self.PrevUserStatus,
      PokeCount = self.PrevUserPokeCount,
      pc_prefix = 'prev_pc_',
      Role = self.PrevUserRole
    }
    
    self:updatePlayerUI(userUI, userInfo)
  end

  function theClass:updateNextPlayerUI(userInfo)
    local userUI = {
      Panel = self.NextUser,
      Name = self.NextUserName,
      Head = self.NextUserHeadIcon,
      Status = self.NextUserStatus,
      PokeCount = self.NextUserPokeCount,
      pc_prefix = 'next_pc_',
      Role = self.NextUserRole
    }
    
    self:updatePlayerUI(userUI, userInfo)
  end

  function theClass:updatePlayerUI(userUI, userInfo, updateStatus)
    local this = self

    userUI.Panel:setVisible(userInfo ~= nil)
    if userInfo == nil then
      userUI.Name:setString('')
      userUI.PokeCount:setString('0')
      updatePlayerPokecards(this, userUI, 0)
      
      return
    end

    if updateStatus == nil then
      updateStatus = true
    end

    --userInfo =  userInfo or {}
    userUI.Name:setString(userInfo.nickName or '')
    userUI.Name:setVisible(userInfo.nickName and userInfo.nickName ~= '')
    userUI.PokeCount:setString(userInfo.pokeCount)

    updatePlayerPokecards(this, userUI, userInfo.pokeCount)

    -- if userUI.pc_prefix ~= nil then
    --   local pokeCount = userInfo.pokeCount or 0
    --   local pokeDiv = math.floor(pokeCount / 2)
    --   local pokeRem = pokeCount % 2
    --   local pc_name
    --   local pokeIndex
    --   for i=1, 10 do
    --     pokeIndex = 10 - i
    --     if pokeIndex > 0 then
    --       pc_name = string.format('%s%02d', userUI.pc_prefix, pokeIndex)
    --       local visible = pokeIndex > (10 - pokeDiv - pokeRem)
    --       self[pc_name]:setVisible(visible)
    --       local v = 0
    --       if visible then
    --         v=1
    --       end
    --       -- cclog('pokeCount: %d, pokeDiv: %d, pokeRem: %d, pc_name: %s, visible: %d', pokeCount, pokeDiv, pokeRem, pc_name, v)
    --     end

    --     pokeIndex = 10 + i
    --     if pokeIndex <= 20 then
    --       pc_name = string.format('%s%02d', userUI.pc_prefix, pokeIndex)
    --       local visible = pokeIndex <= (10 + pokeDiv)
    --       self[pc_name]:setVisible(visible)
    --       local v = 0
    --       if visible then
    --         v=1
    --       end
    --       -- cclog('pokeCount: %d, pokeDiv: %d, pokeRem: %d, pc_name: %s, visible: %d', pokeCount, pokeDiv, pokeRem, pc_name, v)
    --     end
    --   end

    --   self[userUI.pc_prefix .. '10']:setVisible(pokeCount > 0)
    -- end

    -- do return end

    local iconIndex = tonumber(userInfo.headIcon)
    if iconIndex == nil or iconIndex == 0 then
      userInfo.headIcon = math.floor(math.random() * 10000000) % 8 + 1
      iconIndex = userInfo.headIcon
    end

    if userInfo.role == 0 and not userUI.Head:isVisible() then
      userUI.Head:setVisible(true)
    end

    userUI.Head:loadTexture(string.format('NewRes/idImg/idImg_head_%02d.jpg', iconIndex), ccui.TextureResType.localType)
    -- userUI.Head:setVisible(true)

    -- if userInfo.headIcon then
    --   --userUI.Head:loadTexture(Res.Images.HeadIcons[userInfo.headIcon], ccui.TextureResType.localType)
    --   --userUI.Head:loadTexture(Res.getHeadIconPath(userInfo.headIcon), ccui.TextureResType.localType)
    --   userUI.Head:loadTextureNormal(Res.getHeadIconPath(userInfo.headIcon))
    -- end
    -- userUI.Head:setVisible(userInfo.headIcon ~= nil)

    -- if userInfo.state ~= ddz.PlayerStatus.Playing then
    --   if userInfo.state == ddz.PlayerStatus.Ready then
    --     userUI.Status:loadTexture(Res.Images.PlayerStatus.Ready, ccui.TextureResType.localType)
    --   elseif userInfo.state == ddz.PlayerStatus.NoGrabLord then
    --     userUI.Status:loadTexture(Res.Images.PlayerStatus.NoGrabLord, ccui.TextureResType.localType)
    --   elseif userInfo.state == ddz.PlayerStatus.GrabLord then
    --     userUI.Status:loadTexture(Res.Images.PlayerStatus.GrabLord, ccui.TextureResType.localType)
    --   elseif userInfo.state == ddz.PlayerStatus.PassGrabLord then
    --     userUI.Status:loadTexture(Res.Images.PlayerStatus.PassGrabLord, ccui.TextureResType.localType)
    --   elseif userInfo.state == ddz.PlayerStatus.ReGrabLord then
    --     userUI.Status:loadTexture(Res.Images.PlayerStatus.ReGrabLord, ccui.TextureResType.localType)
    --   end
    --   userUI.Status:setVisible(userInfo.state and userInfo.state ~= ddz.PlayerStatus.None and userInfo.state ~= ddz.PlayerStatus.Playing)
    -- end

    -- userUI.Status:setVisible(false)

    -- if userInfo.role == ddz.PlayerRoles.Farmer then
    --   userUI.Role:loadTexture(Res.Images.PlayerRoles.Farmer, ccui.TextureResType.localType)
    -- elseif userInfo.role == ddz.PlayerRoles.Lord then
    --   userUI.Role:loadTexture(Res.Images.PlayerRoles.Lord, ccui.TextureResType.localType)
    -- end
    -- userUI.Role:setVisible(userInfo.role and userInfo.role ~= ddz.PlayerRoles.None)

    -- userUI.PokeCount:setString(userInfo.pokeCount)

  end

  function theClass:animateStatus(statusUI)
    --print('show Player Pass')
    local parentSize = statusUI:getParent():getContentSize()
    local statusUISize = statusUI:getContentSize()
    local pos = cc.p(statusUI:getPosition())
    statusUI:setVisible(false)
--    statusUI:loadTexture(Res.Images.PlayerStatus.PassPlay, ccui.TextureResType.localType)

    statusUI:setVisible(true)
    statusUI:setOpacity(0);

    statusUI:setPosition(cc.p(pos.x, parentSize.height))
    statusUI:runAction(cc.Sequence:create(
        cc.Spawn:create(
          cc.FadeIn:create(0.5),
          cc.MoveTo:create(0.5, cc.p(pos.x, parentSize.height / 2.0))
        ),
        cc.DelayTime:create(1.5),
        cc.CallFunc:create(function()
            statusUI:setVisible(false)
            statusUI:setOpacity(255)
          end)
      ))

    -- statusUI:runAction(cc.Sequence:create(
    --     cc.FadeIn:create(0.5),
    --     cc.DelayTime:create(1.0),
    --     cc.FadeOut:create(0.5),
    --     cc.CallFunc:create(function()
    --         statusUI:setVisible(false)
    --         statusUI:setOpacity(255)
    --       end)
    --   ))
  end

end

return UIPlayerUpdatePlugin