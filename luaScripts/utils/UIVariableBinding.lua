local UIVaribleBinding = {}

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
  TextBMFont = 'ccui.TextBMFont',
  TextAtlas = 'ccui.TextAtlas',
  Button = 'ccui.Button',
  TextField = 'ccui.TextField'
}

function UIVaribleBinding.bind(uiWidget, varContainer, eventContainer)
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
      --print('bind variable:' , vtype, vname, wtype, TypeMapping[wtype])
      if vtype == 'v' then
        widget = tolua.cast(uiWidget, TypeMapping[wtype])
        varHodler[vname] = widget
      elseif vtype =='gv' then
        widget = tolua.cast(uiWidget, TypeMapping[wtype])
        varHodler[vname] = widget
      end
      --if widget and eventContainer and wtype == 'Button' then
      if widget and eventContainer then
        local eventHandlerName = vname .. '_onEvent'
        local eventHandler = eventContainer[eventHandlerName]
        local eventTouchHandlerName = vname .. '_onTouchEvent'
        local eventTouchHandler = eventContainer[eventTouchHandlerName]
        local onclickName = vname .. '_onClicked'
        local onclickHandler = eventContainer[onclickName]
        -- print('[bind event]', vname, eventHandlerName, ' eventHandler:', eventHandler , ' onclickHandler: ', onclickHandler)
        if type(eventTouchHandler) == 'function' or type(onclickHandler) == 'function' then
          widget:addTouchEventListener(function(sender, event)
              if eventTouchHandler then
                eventTouchHandler(eventContainer, sender, event)
              end
              if event == ccui.TouchEventType.ended and onclickHandler then
                onclickHandler(eventContainer, sender, event)
              end
            end)
        end

        if type(eventHandler) == 'function' and widget.addEventListener ~= nil then
          widget:addEventListener(function(sender, event)
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

return UIVaribleBinding