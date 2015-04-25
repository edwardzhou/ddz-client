local UIChatMsgPlugin = {}

function UIChatMsgPlugin.bind(theClass)

  function theClass:showChatMsg(panel, label, data)
    label:setString(data.message)
    local labelSize = label:getContentSize()
    panel:setContentSize(cc.size(labelSize.width + 80, 40))
    panel:setScale(0.001)
    panel:setVisible(true)
    panel:runAction(
      cc.Sequence:create(
          cc.EaseElasticInOut:create(cc.ScaleTo:create(0.5, 1.0), 0.5),
          cc.DelayTime:create(1.5),
          cc.FadeOut:create(0.2),
          cc.CallFunc:create(function() 
              panel:setVisible(false)
              panel:setOpacity(255)
            end)
        )
      )

  end

  function theClass:showPrevPlayerChatMsg(data)
    self:showChatMsg(self.PrevChatPanel, self.PrevChatText, data)
  end

  function theClass:showNextPlayerChatMsg(data)
    self:showChatMsg(self.NextChatPanel, self.NextChatText, data)
  end

  function theClass:showSelfPlayerChatMsg(data)
    self:showChatMsg(self.SelfChatPanel, self.SelfChatText, data)
  end

end

return UIChatMsgPlugin