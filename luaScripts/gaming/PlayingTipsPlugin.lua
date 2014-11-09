local PlayingTipsPlugin = {}

function PlayingTipsPlugin.bind(theClass)
  local selfPlayTipsAction
  local prevPlayTipsAction
  local nextPlayTipsAction

  local function showPlayTips(uiLabel, tipText, hidingDelay)
    self:hidePlayTips(uiLabel)

    uiLabel:setOpacity(0)
    uiLabel:setString(tipText)
    local actions = {
      cc.Show:create(),
      cc.FadeIn:create(0.8)
    }

    if hidingDelay then
      table.insert(actions, cc.DelayTime:create(hidingDelay))
      table.insert(actions, cc.Hide:create())
      table.insert(actions, cc.CallFunc:create(function() uiLabel.actionId = nil end))
    end

    uiLabel.actionId = uiLabel:runAction(unpack(actions))
  end

  local function hidePlayTips(uiLabel)
    if uiLabel.actionId ~= nil then
      uiLabel:stopAction(uiLabel.actionId)
      uiLabel.actionId = nil
    end

    uiLabel:setVisible(false)
  end


  function theClass:showSelfPlayTips(tipText, hidingDelay)
    showPlayTips(self.PlayTipsLabel, tipText, hidingDelay)
  end

  function theClass:hideSelfPlayTips()
    hidePlayTips(self.PlayTipsLabel)
  end

  function theClass:showPrevPlayTips(tipText, hidingDelay)
    showPlayTips(self.PrevPlayTipsLabel)
  end

  function theClass:hidePrevPlayTips()
    hidePlayTips(self.PrevPlayTipsLabel)
  end

  function theClass:showNextPlayTips(tipText, hidingDelay)
    showPlayTips(self.NextPlayTipsLabel)
  end

  function theClass:hidePrevPlayTips()
    hidePlayTips(self.NextPlayTipsLabel)
  end

end

return PlayingTipsPlugin