local AddFriendEventPlugin = {}
local AccountInfo = require('AccountInfo')
local showMessageBox = require('UICommon.MsgBox').showMessageBox
local showToastBox = require('UICommon.ToastBox2').showToastBox
local display = require('cocos.framework.display')
local utils = require('utils.utils')

function AddFriendEventPlugin.bind (theClass)

  function theClass:confirmAddFriend(friend_userId, accept)
    local this = self

    local params = {
      friend_userId = friend_userId,
      accept = accept
    }

    this:request('ddz.friendshipHandler.confirmAddFriend', params, function(data)
        dump(data, '[ddz.friendshipHandler.confirmAddFriend] response => ')
      end)
  end

  function theClass:onAddFriend(data)
    local this = self
    dump(data, '[AddFriendEventPlugin:onAddFriend]')
    local runningScene = display.getRunningScene()

    if runningScene.noPops or runningScene.noAddFriendRequest then
      return
    end

    local userInfo = data.userInfo;

    local params = {
      msg = string.format('%s (%s) 加您为好友, 是否同意?', 
        userInfo.nickName, 
        userInfo.userId) , 
      title = '好友申请',
      buttonType = 'ok | cancel',
      grayBackground = true,
      onOk = function()
          this:confirmAddFriend(userInfo.userId, true)
        end,
      onCancel = function()
          this:confirmAddFriend(userInfo.userId, false)
        end,
    }

    showMessageBox(runningScene, params)
  end

  function theClass:onReplyFriend(data)
    local runningScene = display.getRunningScene()

    local userInfo = data.userInfo;

    local msgFormat
    local msgTitle
    if data.accept == 0 then
      msgFormat = '%s (%s) 拒绝加好为友.'
      msgTitle = '好友申请不通过'
    else
      msgFormat = '%s (%s) 同意加为好友.'
      msgTitle = '好友申请通过'
    end


    local params = {
      msg = string.format(msgFormat, 
        userInfo.nickName, 
        userInfo.userId) , 
      title = msgTitle,
      buttonType = 'ok | close',
      grayBackground = true
    }

    showMessageBox(runningScene, params)

    utils.invokeCallback(runningScene.onReplyFriend, runningScene, data)
  end

  function theClass:hookAddFriendEvent()
    local this = self
    if this._onAddFriend == nil then
      this._onAddFriend = __bind(this.onAddFriend, this)
    end

    if this._onReplyFriend == nil then
      this._onReplyFriend = __bind(this.onReplyFriend, this)
    end

    if this.pomeloClient and not this._onAddFriendHooked then
      this.pomeloClient:on('addFriendRequest', this._onAddFriend)
      this.pomeloClient:on('replyFriendRequest', this._onReplyFriend)
      this._onAddFriendHooked = true
    end
  end

  function theClass:unhookAddFriendEvent()
    local this = self
    if this._onAddFriendHooked and this.pomeloClient then
      this.pomeloClient:off('addFriendRequest', this._onAddFriend)
      this.pomeloClient:off('replyFriendRequest', this._onReplyFriend)
      this._onAddFriendHooked = false
    end
  end
end

return AddFriendEventPlugin