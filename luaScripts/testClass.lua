require('bootstrap.framework.functions')
require('bootstrap.framework.debug')
require('bootstrap.extern')

cjson = require('cjson.safe')

ClassA = class('ClassA')

local _classId = 1

function ClassA:ctor()
  self.classId = _classId
  _classId = _classId + 1
end

function ClassA:foo()
  print(string.format('ClassA #%d: foo', self.classId))
end