--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]


local TaskScene = class('TaskScene')
local gameConnection = require('network.GameConnection')
local AccountInfo = require('AccountInfo')

local showToastBox = require('UICommon.ToastBox').showToastBox
local showMessageBox = require('UICommon.MessageBox').showMessageBox

function TaskScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, TaskScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end
  
  return target
end

function TaskScene:ctor(...)
  local this = self
  self:registerScriptHandler(function(event)
    print('[TaskScene] event => ', event)
    local on_event = 'on_' .. event
    if type(this[on_event]) == 'function' then
      this[on_event](this)
    end
  end)

  this._onButtonBuyClicked = __bind(this.ButtonBuy_onClicked, this)

  self:init()

end

function TaskScene:init()
  local this = self
  local rootLayer = cc.Layer:create()

  this.gameConnection = require('network.GameConnection')

  self.rootLayer = rootLayer
  self:addChild(rootLayer)

  local guiReader = ccs.GUIReader:getInstance()
  -- local uiRoot = guiReader:widgetFromBinaryFile('gameUI/Shop.csb')
  local uiRoot = cc.CSLoader:createNode('TaskScene.csb')
  self.uiRoot = guiReader
  rootLayer:addChild(uiRoot)

  this._onButtonApplyClicked = __bind(this.ButtonApply_onClicked, this)
  this._onButtonTakeBonusClicked = __bind(this.ButtonTakeBonus_onClicked, this)

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()
  self.TaskItemModel:setVisible(false)
end


function TaskScene:on_enterTransitionFinish()
  local this = self

  self:loadTaskItems()
end

function TaskScene:on_exit()
end

function TaskScene:playDropCoins()
  if self.drop_coins == nil then
    local drop_coins = cc.ParticleSystemQuad:create('drop_coins.plist')
    drop_coins:setPosition(400, 480)
    self:addChild(drop_coins)
    self.drop_coins = drop_coins
  else
    self.drop_coins:resetSystem()
  end
end

function TaskScene:loadTaskItems()
  local this = self
  local listView

  if not self.listHasItemModel then
    local item_model = self.TaskItemModel:clone()
    item_model:setVisible(true)
    self.TaskItemList:setItemModel(item_model)
    self.listHasItemModel = true
  end
  
  this.gameConnection:request('ddz.taskHandler.getTasks', {}, function (data)
    dump(data, '[ddz.taskHandler.getTasks] data => ')
    this.TaskItemList:removeAllItems()
    for i=1, #data.tasks do
      local task = data.tasks[i]
      this.TaskItemList:pushBackDefaultItem()
      local taskItem = this.TaskItemList:getItem(i-1)
      this:setTaskItemInfo(taskItem, task)
    end
  end)
end

function TaskScene:setTaskItemInfo(taskItem, task)
  local this = self
  local label, buttonApply, buttonApply
  taskItem.taskId = task.taskId
  label = tolua.cast(ccui.Helper:seekWidgetByName(taskItem, 'TaskName'), 'ccui.Text')
  label:setString(task.taskName)
  label = tolua.cast(ccui.Helper:seekWidgetByName(taskItem, 'TaskProgress'), 'ccui.Text')
  label:setString(task.progressDesc)
  label = tolua.cast(ccui.Helper:seekWidgetByName(taskItem, 'TaskBonus'), 'ccui.Text')
  label:setString(task.taskBonusDesc)
  label = tolua.cast(ccui.Helper:seekWidgetByName(taskItem, 'TaskStatus'), 'ccui.Text')

  local arr = string.split(task.progressDesc, "/")
  local progress = tonumber(arr[1])/tonumber(arr[2]) * 100
  local progressBar = tolua.cast(ccui.Helper:seekWidgetByName(taskItem, 'ProgressBar'), 'ccui.LoadingBar') 
  progressBar:setPercent(progress) 

  buttonTakeBonus = tolua.cast(ccui.Helper:seekWidgetByName(taskItem, 'ButtonTakeBonus'), 'ccui.Button')
  buttonTakeBonus.task = task
  buttonTakeBonus:addTouchEventListener(this._onButtonTakeBonusClicked)
  if task.taskFinished == 1 then
  	if task.bonusDelivered then
  		buttonTakeBonus:setTitleText('已领奖')
  		buttonTakeBonus:setEnabled(false)
  	else
    	buttonTakeBonus:setTitleText('领取奖励')
  	end
  else
  	buttonTakeBonus:setTitleText('去做任务')
  end
end

function TaskScene:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      event:stopPropagation()
      this:close()
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function TaskScene:ButtonTakeBonus_onClicked(sender, eventType)
  local task = sender.task
  if eventType == ccui.TouchEventType.ended then
  	if task.taskFinished == 1 then
    	self:takeTaskBonus(sender, task)
  	else
  		self:close()
  	end
  end
end

function TaskScene:ButtonBack_onClicked(sender, eventType)
  self:close()
end

function TaskScene:getTaskItem(taskId)
  local this = self
  local taskItem = nil
  local taskItems = this.TaskItemList:getItems()
  for i=1, #taskItems do
    taskItem = taskItems[i]
    if taskItem.taskId == taskId then
      return taskItem
    end
  end
  return nil
end

function TaskScene:takeTaskBonus(sender, task)
  dump(task, '[TaskScene:takeTaskBonus] task => ')
  local this = self

  this.gameConnection:request('ddz.taskHandler.takeTaskBonus', {taskId = task.taskId, userId = AccountInfo.getCurrentUser().userId}, function (data)
    dump(data, '[ddz.taskHandler.takeTaskBonus] data =>')
    this:playDropCoins()
    task.bonusDelivered = true
    local taskItem = sender:getParent():getParent()
    this:setTaskItemInfo(taskItem, task)
  end)
end


function TaskScene:close()
  cc.Director:getInstance():popScene()
end


local function createScene()
  local scene = cc.Scene:create()
  return TaskScene.extend(scene)
end

require('network.ConnectionStatusPlugin').bind(TaskScene)

return createScene