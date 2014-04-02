local UIClockCountDownPlugin = {}

function UIClockCountDownPlugin.bind(theClass)
  local function doTickCount(_self, timeoutCallback)
    return function()
      _self._countDownTimes = _self._countDownTimes - 1
      _self.CountDownLabel:setText(tostring(_self._countDownTimes))
      if _self._countDownTimes < 0 then
        _self._clockAction = nil
        _self.CountDownClock:setVisible(false)
        if type(timeoutCallback) == 'function' then
          timeoutCallback()
        else
          print('[UIClockCountDownPlugin] WARNING: timeoutCallback is not a function')
        end
      elseif _self._countDownTimes == 9 then
        _self.CountDownLabel:setColor(cc.c3b(255,0,0))
      end

    end
  end

  function theClass:startCountdown(pos, timeoutCallback, times)
    local this = self
    times = times or 30
    self:stopCountdown()
    self.CountDownLabel:setText(tostring(times))
    self.CountDownLabel:setColor(cc.c3b(0,0,0))
    self.CountDownClock:setPosition(pos)
    self.CountDownClock:setVisible(true)
    self._countDownTimes = times
    self._clockAction = self.CountDownClock:runAction(cc.Repeat:create(cc.Sequence:create(
      cc.DelayTime:create(1),
      cc.CallFunc:create(doTickCount(this, timeoutCallback))
    ), times+1))
  end

  function theClass:stopCountdown()
    if self._clockAction ~= nil then
      self.CountDownClock:stopAction(self._clockAction)
      self._clockAction = nil
    end
    self.CountDownClock:setVisible(false)
  end

  function theClass:startSelfPlayerCountdown(timeoutCallback, times)
    local pos = cc.p(130, 180)
    self:startCountdown(pos, timeoutCallback, times)
  end

  function theClass:startNextPlayerCountdown(timeoutCallback, times)
    local pos = cc.p(670, 325)
    self:startCountdown(pos, timeoutCallback, times)
  end

  function theClass:startPrevPlayerCountdown(timeoutCallback, times)
    local pos = cc.p(130, 350)
    self:startCountdown(pos, timeoutCallback, times)
  end

  function theClass:showPlaycardClock()
    if self.pokeGame.currentPlayer == self.selfPlayerInfo then
      self:startSelfPlayerCountdown()
    elseif self.pokeGame.currentPlayer == self.prevPlayerInfo then
      self:startPrevPlayerCountdown()
    elseif self.pokeGame.currentPlayer == self.nextPlayerInfo then
      self:startNextPlayerCountdown()
    end
  end
end

return UIClockCountDownPlugin