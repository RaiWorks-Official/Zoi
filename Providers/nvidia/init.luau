-- this file is responsible for connecting to nvidia and its ai
local request = require("request")

local nv = {}
nv.__index = nv

function nv:init(ins)
  local self = setmetatable({}, nv)
  self.req = request:new({
    apikey = ins.apikey
  })
  return self
end

function nv:getstatus()
  return self.req:getstatus()
end

function nv:chat(msg)
  return self.req:chat(msg)
end

return nv
