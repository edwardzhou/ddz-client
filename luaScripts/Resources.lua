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
    Farmer = imgPath .. 'game0.png',
    Lord = imgPath .. 'game1.png'
  },
  PlayerStatus = {
    None = nil,
    Ready = imgPath .. 'game19.png'
  }
}

return Resources