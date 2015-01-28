local Resources = {}

local imgPath = 'images/'

Resources.Images = {
  HeadIcons = {
    ['head1'] = imgPath .. 'head0.png',
    ['head2'] = imgPath .. 'head1.png',
    ['head3'] = imgPath .. 'head2.png',
    ['head4'] = imgPath .. 'head3.png',
    ['head5'] = imgPath .. 'head4.png',
    ['head6'] = imgPath .. 'head5.png',
    ['head7'] = imgPath .. 'head6.png',
    ['head8'] = imgPath .. 'head7.png'
  },
  PlayerRoles = {
    Farmer = imgPath .. 'role_farmer.png',
    Lord = imgPath .. 'role_lord.png'
  },
  PlayerStatus = {
    None = nil,
    Ready = imgPath .. 'game19.png',
    NoGrabLord = imgPath .. 'game21.png',       -- 不叫
    GrabLord = imgPath .. 'game22.png',         -- 叫地主
    PassGrabLord = imgPath .. 'game23.png',     -- 不抢
    ReGrabLord = imgPath .. 'game24.png',       -- 抢地主
    PassPlay = imgPath .. 'game11.png',     -- 不抢
  }
}

function Resources.getHeadIconPath(headIcon)
  return 'images/' .. headIcon .. '.png'
end

return Resources