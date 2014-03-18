local SPlayerJoinPlugin = {}

function SPlayerJoinPlugin.bind(theClass)
  function theClass:onServerPlayerJoin( playersInfo )
    self:doPlayerJoin(playersInfo)
  end

  function theClass:doPlayerJoin(playersInfo)
    local this = self
    this.players = playersInfo
    if playersInfo[1].userId == this.selfUserId then
      this.selfPlayerInfo = playersInfo[1]
      this.nextPlayerInfo = playersInfo[2]
      this.prevPlayerInfo = playersInfo[3]
    elseif playersInfo[2].userId == this.selfUserId then
      this.selfPlayerInfo = playersInfo[2]
      this.nextPlayerInfo = playersInfo[3]
      this.prevPlayerInfo = playersInfo[1]
    elseif playersInfo[3].userId == this.selfUserId then
      this.selfPlayerInfo = playersInfo[3]
      this.nextPlayerInfo = playersInfo[1]
      this.prevPlayerInfo = playersInfo[2]
    end

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