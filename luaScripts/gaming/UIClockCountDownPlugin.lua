local UIClockCountDownPlugin = {}

function UIClockCountDownPlugin.bind(theClass)
  local function doTickCount(_self, timeoutCallback)
    return function()
      _self._countDownTimes = _self._countDownTimes - 1
      _self.CountDownLabel:setText(tostring(_self._countDownTimes))
      if _self._countDownTimes < 0 then
        _self._clockAction = nil
        _self.CountDownClock:setVisible(false)
        timeoutCallback()
      elseif _self._countDownTimes == 9 then
        _self.CountDownLabel:setColor(cc.c3b(255,0,0))
      end

    end
  end

  function theClass:startCountdown(pos, timeoutCallback, times)
    local this = self
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

end

return UIClockCountDownPlugin