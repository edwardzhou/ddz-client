local UIVaribleBdinding = {}

local TypeMapping = {
  Panel = 'ccui.Layout',
  Image = 'ccui.ImageView',
  ImageView = 'ccui.ImageView',
  Label = 'ccui.Text',
  Button = 'ccui.Button'
}

function UIVaribleBdinding.bind(uiWidget, parent, root)
  local function bindVariables(uiWidget, varParent, varRoot)
    local widgetName = uiWidget:getName()
    local vtype, vname, wtype = string.gmatch(widgetName, '(%l*)(.*)_(.*)')()
    local tmpParent = varParent
    local widget
    if vtype ~= nil and vname ~= nil and wtype ~= nil then
      print('bind varaible:' , vtype, vname, TypeMapping[wtype])
      if vtype == 'v' then
        widget = tolua.cast(uiWidget, TypeMapping[wtype])
        varParent[vname] = widget
      elseif vtype =='gv' then
        widget = tolua.cast(uiWidget, TypeMapping[wtype])
        varRoot[vname] = widget
      end
    end
    
    for _, childWidget in pairs(uiWidget:getChildren()) do
      bindVariables(childWidget, tmpParent, varRoot)
    end
  end
	
	bindVariables(uiWidget, parent, root)
end

return UIVaribleBdinding