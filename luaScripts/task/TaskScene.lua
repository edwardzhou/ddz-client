
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

  require('utils.UIVariableBinding').bind(uiRoot, self, self)
  self:initKeypadHandler()
  self.TaskItemModel:setVisible(false)


end


function TaskScene:on_enterTransitionFinish()
  local this = self

  self:loadShopItems()
end

function TaskScene:on_exit()
end

function TaskScene:loadShopItems()
  local this = self
  local listView

  if not self.listHasItemModel then
    local item_model = self.TaskItemModel:clone()
    item_model:setVisible(true)
    self.TaskItemList:setItemModel(item_model)
    self.TaskItemList:pushBackDefaultItem()
    self.TaskItemList:pushBackDefaultItem()
    self.TaskItemList:pushBackDefaultItem()
    self.listHasItemModel = true
  else
    --self.TaskItemList:removeAllItems()
  end
  
  this.gameConnection:request('ddz.taskHandler.getTasks', {}, function (data)
    dump(data, '[ddz.taskHandler.getTasks] data => ')
    this.TaskItemList:removeAllItems()
    local task, taskItem
    local label
    for i=1, #data.tasks do
      task = data.tasks[i]
      this.TaskItemList:pushBackDefaultItem()
      taskItem = this.TaskItemList:getItem(i-1)
      label = tolua.cast(ccui.Helper:seekWidgetByName(taskItem, 'TaskName'), 'ccui.Text')
      label:setString(task.taskName)
      label = tolua.cast(ccui.Helper:seekWidgetByName(taskItem, 'TaskProgress'), 'ccui.Text')
      label:setString(task.progressDesc)
      label = tolua.cast(ccui.Helper:seekWidgetByName(taskItem, 'TaskBonus'), 'ccui.Text')
      label:setString(task.taskBonusDesc)
      label = tolua.cast(ccui.Helper:seekWidgetByName(taskItem, 'TaskDesc'), 'ccui.Text')
      label:setString(task.taskDesc)

    end
  end)

  -- this.gameConnection:request('ddz.hallHandler.getShopItems', {}, function(data) 
  --   dump(data, '[ddz.hallHandler.getShopItems] data =>')
  --   self.TaskItemList:removeAllItems()
  --   for i=1, #data do
  --     local pkg = data[i]
  --     this.TaskItemList:pushBackDefaultItem()
  --     local item = this.TaskItemList:getItem(i-1)
  --     local label, imgIcon, price, button
  --     price = pkg.price or 0.0
  --     label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelPkgName'), 'ccui.Text')
  --     label:setString(pkg.packageName)
  --     label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelPkgDesc'), 'ccui.Text')
  --     label:setString(pkg.packageDesc)
  --     label = tolua.cast(ccui.Helper:seekWidgetByName(item, 'LabelPrice'), 'ccui.Text')
  --     label:setString(string.format('价格 %d 元', price/100))

  --     imgIcon = tolua.cast(ccui.Helper:seekWidgetByName(item, 'ImagePkgIcon'), 'ccui.ImageView')
  --     if pkg.packageIcon then
  --       local imgFilename = 'images/' .. pkg.packageIcon
  --       print('packageIcon => ', imgFilename)
  --       imgIcon:loadTexture(imgFilename, ccui.TextureResType.localType)
  --     end

  --     button = tolua.cast(ccui.Helper:seekWidgetByName(item, 'ButtonBuy'), 'ccui.Button')
  --     button.package = pkg

  --     button:addTouchEventListener(this._onButtonBuyClicked)      
  --   end
  -- end)
end

function TaskScene:initKeypadHandler()
  local this = self
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
--      if type(self.onMainMenu) == 'function' then
--        self.onMainMenu()
--      end
      event:stopPropagation()
      this:close()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
      --label:setString("MENU clicked!")
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function TaskScene:ButtonBuy_onClicked(sender, eventType)
  local this = self
  local pkg = sender.package
  --print('[TaskScene:ButtonBuy_onClicked] eventType => ', eventType)
  if eventType == ccui.TouchEventType.ended then
    print('[TaskScene:ButtonBuy_onClicked] you want to buy : ' , pkg.packageName)
    local msgParams = {
      title = '购买道具',
      msg = string.format('购买 %s\n%s\n价格 %d 元', pkg.packageName, pkg.packageDesc, pkg.price / 100),
      closeOnClickOutside = false,
      buttonType = 'ok|cancel',
      onOk = function() return this:buyPackage(pkg) end
    }
    showMessageBox(this, msgParams)
  end
end

function TaskScene:ButtonBack_onClicked(sender, eventType)
  self:close()
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