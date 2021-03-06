--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

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
  TextField = 'ccui.TextField',
  Slider = 'ccui.Slider'
}

TypeMapping['cc.Sprite'] = 'cc.Sprite'

function UIVaribleBinding.bind(uiWidget, varContainer, eventContainer, showDebug)
  --[[
    variable pattern v_VarName , it will set varHolder[VarName] = widget
  --]]
  local function bindVariables(uiWidget, varHodler)
    local widgetName = uiWidget:getName()
    local vtype, vname, wtype = string.gmatch(widgetName, '(%w*)_(.*)')()
    -- wtype = uiWidget:getDescription()
    wtype = tolua.type(uiWidget)
    local tmpParent = varHodler
    local widget = nil
    if vtype ~= nil and vname ~= nil and wtype ~= nil then
      if not not showDebug then
        --print('bind variable:' , vtype, vname, wtype, TypeMapping[wtype])
        print('bind variable:' , vtype, vname, wtype)
      end
      
      if vtype == 'v' then
        widget = tolua.cast(uiWidget, wtype)
        varHodler[vname] = widget
        --print(string.format('varHolder["%s"] => ', vname), widget)
      elseif vtype =='gv' then
        widget = tolua.cast(uiWidget, wtype)
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
        if not not showDebug then
          print('[bind event]', vname, eventHandlerName, 
            ' eventHandler: ', eventHandler , 
            ' , eventTouchHandlerName: ', eventTouchHandler , 
            ' , onclickHandler: ', onclickHandler)
        end
        if widget.addTouchEventListener ~= nil 
          and (type(eventTouchHandler) == 'function' or type(onclickHandler) == 'function') then
            widget:addTouchEventListener(function(sender, event)
              if eventTouchHandler then
                eventTouchHandler(eventContainer, sender, event)
              end
              if event == ccui.TouchEventType.ended and onclickHandler then
                onclickHandler(eventContainer, sender, event)
              end
            end)
        end

        if not not showDebug then
          print(string.format('widget: %s , type(eventHandler) =>', vname), type(eventHandler))
          print(widget, widget.addEventListener )
        end

        if type(eventHandler) == 'function' and widget.addEventListener ~= nil then
          if not not showDebug then
            print(string.format('widget: %s bind onEvent', vname))
          end

          widget:addEventListener(function(sender, event)
              if not not showDebug then
                print(string.format('[widget:EventListener] [%s] onEvent: event => %d, sender =>',vname, event), sender)
              end
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