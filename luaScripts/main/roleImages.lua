--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

require 'consts'

local RoleImages = {}
RoleImages[ddz.PlayerRoles.Farmer] = {}
RoleImages[ddz.PlayerRoles.Farmer][ddz.Gender.Male] = { 
  win = 'NewRes/paint/paint_farmer_v.png', 
  lose = 'NewRes/paint/paint_farmer_f.png',
  left = 'NewRes/paint/paint_farmer_default_left.png',
  right = 'NewRes/paint/paint_farmer_default_right.png'
}
RoleImages[ddz.PlayerRoles.Farmer][ddz.Gender.Female] = { 
  win = 'NewRes/paint/paint_farmeress_v.png', 
  lose = 'NewRes/paint/paint_farmeress_f.png',
  left = 'NewRes/paint/paint_farmeress_default_left.png',
  right = 'NewRes/paint/paint_farmeress_default_right.png'
}

RoleImages[ddz.PlayerRoles.Lord] = {}
RoleImages[ddz.PlayerRoles.Lord][ddz.Gender.Male] = { 
  win = 'NewRes/paint/paint_lord_v.png', 
  lose = 'NewRes/paint/paint_lord_f.png' ,
  left = 'NewRes/paint/paint_lord_default_left.png',
  right = 'NewRes/paint/paint_lord_default_right.png'
}

RoleImages[ddz.PlayerRoles.Lord][ddz.Gender.Female] = { 
  win = 'NewRes/paint/paint_lordress_v.png', 
  lose = 'NewRes/paint/paint_lordress_f.png' ,
  left = 'NewRes/paint/paint_lordress_default_left.png',
  right = 'NewRes/paint/paint_lordress_default_right.png' 
}

return RoleImages