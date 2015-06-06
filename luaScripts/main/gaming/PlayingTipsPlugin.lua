--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

local PlayingTipsPlugin = {}

function PlayingTipsPlugin.bind(theClass)
  local selfPlayTipsAction
  local prevPlayTipsAction
  local nextPlayTipsAction
  local hidePlayTips

  local function showPlayTips(uiLabel, tipText, hidingDelay)
    hidePlayTips(uiLabel)

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

    uiLabel.actionId = uiLabel:runAction(cc.Sequence:create(unpack(actions)))
  end

  hidePlayTips = function (uiLabel)
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
    showPlayTips(self.PrevPlayTipsLabel, tipText, hidingDelay)
  end

  function theClass:hidePrevPlayTips()
    hidePlayTips(self.PrevPlayTipsLabel)
  end

  function theClass:showNextPlayTips(tipText, hidingDelay)
    showPlayTips(self.NextPlayTipsLabel, tipText, hidingDelay)
  end

  function theClass:hideNextPlayTips()
    hidePlayTips(self.NextPlayTipsLabel)
  end

end

return PlayingTipsPlugin