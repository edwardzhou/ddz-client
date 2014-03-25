local UIVaribleBdinding = {}

local TypeMapping = {
  Panel = 'ccui.Layout',
  Layout = 'ccui.Layout',
  CheckBox = 'ccui.CheckBox',
  ListView = 'ccui.ListView',
  LoadingBar = 'ccui.LoadingBar',
  PageView = 'ccui.PageView',
  ScrollView = 'ccui.ScrollView',
  Image = 'ccui.ImageView',
  ImageView = 'ccui.ImageView',
  Label = 'ccui.Text',
  Text = 'ccui.Text',
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
  --[[
    variable pattern v_VarName , it will set varHolder[VarName] = widget
  --]]
  local function bindVariables(uiWidget, varHodler)
    local widgetName = uiWidget:getName()
    local vtype, vname, wtype = string.gmatch(widgetName, '(%w*)_(.*)')()
    wtype = uiWidget:getDescription()
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
        local eventHandlerName = vname .. '_onEvent'
        local eventHandler = eventContainer[eventHandlerName]
        local onclickName = vname .. '_onClicked'
        local onclickHandler = eventContainer[onclickName]
        print('[bind event]', vname, eventHandlerName, ' eventHandler:', eventHandler , ' onclickHandler: ', onclickHandler)
        
        if type(eventHandler) == 'function' or type(onclickHandler) == 'function' then
          widget:addTouchEventListener(function(sender, event)
            if eventHandler then
              eventHandler(eventContainer, sender, event)
            end
            if event == ccui.TouchEventType.ended and onclickHandler then
              onclickHandler(eventContainer, sender, event)
            end
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