local UIButtonsPlugin = {}

function UIButtonsPlugin.bind( theClass )
  function theClass:showButtonsPanel(show)
    self.ButtonsPanel:setVisible(show)
  end

  function theClass:enableButtonPass(enabled)
    self.ButtonPass:setEnabled(enabled)
    local imgPath = 'images/game11.png'
    if not enabled then
      imgPath = 'images/game15.png'
    end
    self.ImagePass:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonReset(enabled)
    self.ButtonReset:setEnabled(enabled)
    local imgPath = 'images/game12.png'
    if not enabled then
      imgPath = 'images/game16.png'
    end
    self.ImagePass:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonTip(enabled)
    self.ButtonTip:setEnabled(enabled)
    local imgPath = 'images/game13.png'
    if not enabled then
      imgPath = 'images/game17.png'
    end
    self.ImageTip:loadTexture(imgPath, ccui.TextureResType.localType)
  end

  function theClass:enableButtonPlay(enabled)
    self.ButtonPlay:setEnabled(enabled)
    local imgPath = 'images/game14.png'
    if not enabled then
      imgPath = 'images/game18.png'
    end
    self.ImagePlay:loadTexture(imgPath, ccui.TextureResType.localType)
  end

end

return UIButtonsPlugin