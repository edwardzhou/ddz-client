local UIVaribleBdinding = {}

local TypeMapping = {
  Panel = 'ccui.Layout',
  Image = 'ccui.ImageView',
  ImageView = 'ccui.ImageView',
  Label = 'ccui.Text',
  Button = 'ccui.Button'
}

function UIVaribleBdinding.bind(uiWidget, varContainer, eventContainer)

--  local function onButtonEvent(sender, event)
--    --local buttonName = sender:getName()
--    local buttonName, vtype, wtype = string.gmatch(sender:getName(), '(.*)_(%l*)(.*)')()
--    local eventHandlerName = string.format('%s_onClicked', buttonName)
--    local onClickHandler = eventContainer[eventHandlerName]
--    print('[onButtonEvent]', event, buttonName, eventHandlerName, onClickHandler)
--    if event == ccui.TouchEventType.ended and type(onClickHandler) == 'function' then
--      onClickHandler(eventContainer, sender, event)
--    end
--  end
--
  local function bindVariables(uiWidget, varHodler)
    local widgetName = uiWidget:getName()
    local vname, vtype, wtype = string.gmatch(widgetName, '(.*)_(%l*)(.*)')()
    local tmpParent = varHodler
    local widget = nil
    if vtype ~= nil and vname ~= nil and wtype ~= nil then
      print('bind variable:' , vtype, vname, TypeMapping[wtype])
      if vtype == 'v' then
        widget = tolua.cast(uiWidget, TypeMapping[wtype])
        varHodler[vname] = widget
      elseif vtype =='gv' then
        widget = tolua.cast(uiWidget, TypeMapping[wtype])
        varHodler[vname] = widget
      end
      if widget and eventContainer and wtype == 'Button' then
        local eventHandlerName = vname .. '_onClicked'
        local eventHandler = eventContainer[eventHandlerName]
        print('[bind event]', vname, eventHandlerName, eventHandler)
        
        if type(eventHandler) == 'function' then
          widget:addTouchEventListener(function(sender, event)
            eventHandler(eventContainer, sender, event)
          end)
        end
      end
    end
    
    for _, childWidget in pairs(uiWidget:getChildren()) do
      bindVariables(childWidget, tmpParent)
    end
  end
	
	bindVariables(uiWidget, varContainer)
end

return UIVaribleBdinding