--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local GamePlayer = require('GamePlayer')

local SPlayerJoinPlugin = {}

function SPlayerJoinPlugin.bind(theClass)
  function theClass:onServerPlayerJoin( playersInfo )
    self:doPlayerJoin(playersInfo)
  end

  function theClass:doPlayerJoin(playersInfo)
    local this = self
    this.players = playersInfo
    if playersInfo[1].userId == this.selfUserId then
      this.selfPlayerInfo = GamePlayer.new(playersInfo[1])
      if playersInfo[2] ~= nil then
        this.nextPlayerInfo = GamePlayer.new(playersInfo[2])
      else
        this.nextPlayerInfo = nil
      end
      if playersInfo[3] ~= nil then
        this.prevPlayerInfo = GamePlayer.new(playersInfo[3])
      else
        this.prevPlayerInfo = nil
      end
    elseif playersInfo[2].userId == this.selfUserId then
      this.prevPlayerInfo = GamePlayer.new(playersInfo[1])
      this.selfPlayerInfo = GamePlayer.new(playersInfo[2])
      if playersInfo[3] ~= nil then
        this.nextPlayerInfo = GamePlayer.new(playersInfo[3])
      else
        this.nextPlayerInfo = nil
      end
    elseif playersInfo[3].userId == this.selfUserId then
      this.prevPlayerInfo = GamePlayer.new(playersInfo[2])
      this.nextPlayerInfo = GamePlayer.new(playersInfo[1])
      this.selfPlayerInfo = GamePlayer.new(playersInfo[3])
    end

    dump(playersInfo, 'playersInfo => ', 5);
    dump(this.selfPlayerInfo, 'this.selfPlayerInfo => ', 5);
    dump(this.nextPlayerInfo, 'this.nextPlayerInfo => ', 5);
    dump(this.prevPlayerInfo, 'this.prevPlayerInfo => ', 5);

    this.PanelNextHead:setVisible(this.nextPlayerInfo ~= nil)
    this.PanelPrevHead:setVisible(this.prevPlayerInfo ~= nil)

    this:doUpdatePlayersUI()
  end

  function theClass:doUpdatePlayersUI()
    local this = self
    if this.updatePlayerUI then
      this:updateSelfPlayerUI(this.selfPlayerInfo)
      this:updatePrevPlayerUI(this.prevPlayerInfo)
      this:updateNextPlayerUI(this.nextPlayerInfo)
    end
  end
end

return SPlayerJoinPlugin