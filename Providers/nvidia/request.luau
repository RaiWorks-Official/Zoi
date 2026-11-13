-- the file responsible for user to ai communications

local requests = {}
requests.__index = requests

function requests.new(build)
  local self = setmetatable({}, requests)
  if type(build.apikey) == "table" then
      self.key = build.apikey[math.random(#build.apikey)]
    else
      self.key = build.apikey
  end
  return self
end

return requests
