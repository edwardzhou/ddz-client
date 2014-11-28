local UIClockCountDownPlugin = {}
local utils = require('utils.utils')

function UIClockCountDownPlugin.bind(theClass)
  local function doTickCount(_self, timeoutCallback)
    return function()
      _self._countDownTimes = _self._countDownTimes - 1
      _self.CountDownLabel:setString(tostring(_self._countDownTimes))
      if _self._countDownTimes < 1 then
        _self:stopCountdown()
        _self._clockAction = nil
        -- _self.CountDownClock:setVisible(false)
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

  function theClass:startCountdown(pos, timeoutCallback, times, directShow)
    local this = self
    times = times or 30
    self:stopCountdown()
    if not directShow then
      self.CountDownClock:runAction(cc.MoveTo:create(0.3, pos))
    else
      self.CountDownClock:setPosition(pos)
    end

    self.CountDownLabel:setString(tostring(times))
    self.CountDownLabel:setColor(cc.c3b(0,0,0))
    --self.CountDownClock:setPosition(pos)
    self.CountDownClock:setVisible(true)
    self._countDownTimes = times
    self._clockAction = self.CountDownClock:runAction(cc.Repeat:create(cc.Sequence:create(
      cc.DelayTime:create(1),
      cc.CallFunc:create(doTickCount(this, timeoutCallback))
    ), times))
  end

  function theClass:stopCountdown(hideIt)
    if self._clockAction ~= nil then
      self.CountDownClock:stopAction(self._clockAction)
      self._clockAction = nil
    end

    if hideIt then
      self.CountDownClock:setVisible(false)
    end
  end


  function theClass:startSelfPlayerCountdown(timeoutCallback, times, directShow)
    local pos = cc.p(420, 260)
    self:startCountdown(pos, timeoutCallback, times, directShow)
  end

  function theClass:startNextPlayerCountdown(timeoutCallback, times, directShow)
    local pos = cc.p(670, 325)
    local this = self
    self:startCountdown(pos, function() 
        print('[startNextPlayerCountdown] clock times up.')
        this:showNextPlayTips('对方网络不给力, 请稍候...')
        utils.invokeCallback(timeoutCallback)
      end, times, directShow)
  end

  function theClass:startPrevPlayerCountdown(timeoutCallback, times, directShow)
    local pos = cc.p(130, 350)
    local this = self
    self:startCountdown(pos, function() 
        print('[startPrevPlayerCountdown] clock times up.')
        this:showPrevPlayTips('对方网络不给力, 请稍候...')
        utils.invokeCallback(timeoutCallback)
      end, times, directShow)
  end

  function theClass:showPlaycardClock(fn, timeout, directShow)
    if self.pokeGame.nextPlayerId == self.selfPlayerInfo.userId then
      self:startSelfPlayerCountdown(fn, timeout, directShow)
    elseif self.pokeGame.nextPlayerId == self.prevPlayerInfo.userId then
      self:startPrevPlayerCountdown(fn, timeout, directShow)
    elseif self.pokeGame.nextPlayerId == self.nextPlayerInfo.userId then
      self:startNextPlayerCountdown(fn, timeout, directShow)
    end
  end
end

return UIClockCountDownPlugin