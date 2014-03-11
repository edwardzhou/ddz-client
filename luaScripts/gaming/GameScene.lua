require 'GuiConstants'
require 'PokeCard'

local GameScene = class('GameScene', function()
  return cc.Scene:create()
end)

function GameScene.extend(target, ...)
  local t = tolua.getpeer(target)
  if not t then
    t = {}
    tolua.setpeer(target, t)
  end
  setmetatable(t, GameScene)
  if type(target.ctor) == 'function' then
    target:ctor(...)
  end

  return target
end

function GameScene:ctor(...)
  cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile('poke_cards.plist')
  
  self.visibleSize = cc.Director:getInstance():getVisibleSize()
  self.origin = cc.Director:getInstance():getVisibleOrigin()

  self:registerScriptHandler(function(event)
    print('event => ', event)
    if event == "enterTransitionFinish" then
      self:init()
    elseif event == 'exit' then
      self:cleanup()
    end
  end)
end

function GameScene:cleanup()
end

function GameScene:init()
  local this = self
  self:initKeypadHandler()

  local rootLayer = cc.Layer:create()
  self:addChild(rootLayer)

  local ui = ccs.GUIReader:getInstance():widgetFromJsonFile('UI/Gaming/Gaming.json')
  rootLayer:addChild(ui)
  self.uiWidget = ui

  local pokeCardsPanel = ccui.Helper:seekWidgetByName(ui, 'SelfPokeCards_Panel')
  local pokeCardsLayer = cc.Layer:create()
  pokeCardsPanel:addNode(pokeCardsLayer)
  self.pokeCardsLayer = pokeCardsLayer
  
  self:assignControlsVariables()
  self.selfUserId = 1

  local readyButton = ccui.Helper:seekWidgetByName(ui, 'Ready_Button')
  readyButton:addTouchEventListener(function(sender, eventType)
    local buttonName = sender:getName()
    print('button clicked: ', buttonName, eventType)
    if eventType == ccui.TouchEventType.ended then
      --this:updatePlayerUI(this.PrevUserUI, {name= '张无忌'})
      local Heads = {nil, 'head1', 'head2', 'head3', 'head4', 'head5', 'head6', 'head7', 'head8'}
      local Status = {ddz.PlayerStatus.None, ddz.PlayerStatus.Ready}
      local Roles = {ddz.PlayerRoles.None, ddz.PlayerRoles.Farmer, ddz.PlayerRoles.Lord, ddz.PlayerRoles.Farmer}
      table.shuffle(Roles)
      local playersInfo = {
        {userId=1, name='我自己', role=Roles[1]},
 --       {userId=2, name='张无忌', role=Roles[2]},
        {userId=3, name='东方不败', role=Roles[3]}
      }
      for _, playerInfo in pairs(playersInfo) do
        playerInfo.headIcon = Heads[ math.random(#Heads) ]
        playerInfo.status = Status[ math.random(#Status) ]
      end
      table.shuffle(playersInfo)
      this:doPlayerJoin(playersInfo)
    end
  end)

  PokeCard.sharedPokeCard(pokeCardsLayer)
  PokeCard.reloadAllCardSprites(pokeCardsLayer)
  self.cardContentSize = PokeCard.getByPokeChars('A')[1].card_sprite:getContentSize()
  dump(self.visibleSize, 'visibleSize')
--pokeCards = PokeCard.getByPokeChars('AcjmDrBekRuvCVNXp')
  self.pokeCards = PokeCard.getByPokeChars('AcjmDrBekRuvCVNXpWSY')
  table.sort(self.pokeCards, sortDescBy('index'))
  self:showCards()
  
  self:initPokeCardsLayerTouchHandler()
end

function GameScene:initKeypadHandler()
  local function onKeyReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACKSPACE then
      --      if type(self.onMainMenu) == 'function' then
      --        self.onMainMenu()
      --      end
      cc.Director:getInstance():popScene()
    elseif keyCode == cc.KeyCode.KEY_MENU  then
    end
  end

  local listener = cc.EventListenerKeyboard:create()
  listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
  self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function GameScene:assignControlsVariables()
  local uiRoot = self.uiWidget
  
  local function widgetByName(root, name, typeName)
    local widget = ccui.Helper:seekWidgetByName(root, name)
    if widget == nil then
      return nil
    end
    return tolua.cast(widget, typeName) 
  end
  
  local function assignUserPanel(userTag, userUISurffix)
    local userUISurffix = userUISurffix or 'UI'
    local ctrlPrefix = userPrefix
    local userPanel = ccui.Helper:seekWidgetByName(uiRoot, userTag .. '_Panel')
    local userAttr = userPanel
    userAttr.Name = widgetByName(userPanel, userTag .. 'Name_Label', 'ccui.Text')
    userAttr.Role = widgetByName(userPanel, userTag .. 'Role_Image', 'ccui.ImageView')
    userAttr.Head = widgetByName(userPanel, userTag .. 'Head_Image', 'ccui.ImageView')
    userAttr.Status = widgetByName(userPanel, userTag .. 'Status_Image', 'ccui.ImageView')
    self[userTag .. userUISurffix] = userAttr
  end
  
  -- 上家
  assignUserPanel('PrevUser')
  -- 下家
  assignUserPanel('NextUser')
  -- 自己
  assignUserPanel('SelfUser')
  
end

local function createScene()
  --local scene = cc.Scene:create()
  return GameScene.new()
end

require('gaming.UIPlayerUpdatePlugin').bind(GameScene)
require('gaming.SPlayerJoinPlugin').bind(GameScene)
require('gaming.UIPokecardPickPlugin').bind(GameScene)

return createScene