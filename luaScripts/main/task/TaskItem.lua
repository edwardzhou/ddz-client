local UIVarBinding = require('utils.UIVariableBinding')

local TaskItem = class('TaskItem', function() 
  return cc.Layer:create()
end)

function TaskItem:ctor()
  self:init()
end

function TaskItem:init()
	local uiRoot = cc.CSLoader:createNode('TaskItemLayer.csb')
	self.uiRoot = uiRoot
  self:addChild(uiRoot)
  require('utils.UIVariableBinding').bind(uiRoot, self, self)
end

return TaskItem