require('GuiConstants')
local Res = require('Resources')

local UIPlayerUpdatePlugin = {}

function UIPlayerUpdatePlugin.bind(theClass)
  function theClass:updatePlayerUI(userUI, userInfo)

    userUI:setVisible(userInfo ~= nil)
    if userInfo == nil then
      return
    end

    userInfo =  userInfo or {}
    userUI.Name:setText(userInfo.name or '')
    userUI.Name:setVisible(userInfo.name and userInfo.name ~= '')
    if userInfo.headIcon then
      userUI.Head:loadTexture(Res.Images.HeadIcons[userInfo.headIcon], ccui.TextureResType.localType)
    end
    userUI.Head:setVisible(userInfo.headIcon ~= nil)

    if userInfo.status == ddz.PlayerStatus.Ready then
      userUI.Status:loadTexture(Res.Images.PlayerStatus.Ready, ccui.TextureResType.localType)
    end
    userUI.Status:setVisible(userInfo.status and userInfo.status ~= ddz.PlayerStatus.None)

    if userInfo.role == ddz.PlayerRoles.Farmer then
      userUI.Role:loadTexture(Res.Images.PlayerRoles.Farmer, ccui.TextureResType.localType)
    elseif userInfo.role == ddz.PlayerRoles.Lord then
      userUI.Role:loadTexture(Res.Images.PlayerRoles.Lord, ccui.TextureResType.localType)
    end
    userUI.Role:setVisible(userInfo.role and userInfo.role ~= ddz.PlayerRoles.None)

  end
end

return UIPlayerUpdatePlugin