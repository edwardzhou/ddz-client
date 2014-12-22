local Res = require('Resources')
local AccountInfo = require('AccountInfo')
local UIPlayerUpdatePlugin = {}

function UIPlayerUpdatePlugin.bind(theClass)

  function theClass:updateUserInfo()
    local coins = AccountInfo.getCurrentUser().ddzProfile.coins or 0
    self.SelfCoins:setString(coins)
  end

  function theClass:updateSelfPlayerUI(userInfo)
    local userUI = {
      Panel = self.SelfUser,
      Name = self.SelfUserName,
      Head = self.SelfUserHead,
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
      Head = self.PrevUserHead,
      Status = self.PrevUserStatus,
      PokeCount = self.PrevUserPokeCount,
      Role = self.PrevUserRole
    }
    
    self:updatePlayerUI(userUI, userInfo)
  end

  function theClass:updateNextPlayerUI(userInfo)
    local userUI = {
      Panel = self.NextUser,
      Name = self.NextUserName,
      Head = self.NextUserHead,
      Status = self.NextUserStatus,
      PokeCount = self.NextUserPokeCount,
      Role = self.NextUserRole
    }
    
    self:updatePlayerUI(userUI, userInfo)
  end

  function theClass:updatePlayerUI(userUI, userInfo, updateStatus)

    userUI.Panel:setVisible(userInfo ~= nil)
    if userInfo == nil then
      return
    end

    if updateStatus == nil then
      updateStatus = true
    end

    userInfo =  userInfo or {}
    userUI.Name:setString(userInfo.nickName or '')
    userUI.Name:setVisible(userInfo.nickName and userInfo.nickName ~= '')
    if userInfo.headIcon then
      --userUI.Head:loadTexture(Res.Images.HeadIcons[userInfo.headIcon], ccui.TextureResType.localType)
      userUI.Head:loadTexture(Res.getHeadIconPath(userInfo.headIcon), ccui.TextureResType.localType)
    end
    userUI.Head:setVisible(userInfo.headIcon ~= nil)

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

    if userInfo.role == ddz.PlayerRoles.Farmer then
      userUI.Role:loadTexture(Res.Images.PlayerRoles.Farmer, ccui.TextureResType.localType)
    elseif userInfo.role == ddz.PlayerRoles.Lord then
      userUI.Role:loadTexture(Res.Images.PlayerRoles.Lord, ccui.TextureResType.localType)
    end
    userUI.Role:setVisible(userInfo.role and userInfo.role ~= ddz.PlayerRoles.None)

    userUI.PokeCount:setString(userInfo.pokeCount)

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