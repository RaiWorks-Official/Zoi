-- the file responsible for user to ai communications
local HttpService = game:GetService("HttpService")

local requests = {}
requests.__index = requests

function requests:new(build)
  local self = setmetatable({}, requests)
  if type(build.apikey) == "table" then
      self.key = build.apikey[math.random(#build.apikey)]
    else
      self.key = build.apikey
  end
  return self
end

function requests.getstatus()
  local url = "https://nvidia.com"

  local status, result = pcall(function()
    return HttpService:RequestAsync({
      Url = url,
      Method = "POST",
      Headers = {
        ["Authorization"] = "Bearer " .. self.key,
        ["Content-Type"] = "application/json",
      },
      Body = HttpService:JSONEncode({
        model = "nvidia/nemotron-3-ultra-550b-a55b",
        messages = {
          { role = "user", content = "ping" }
        },
        max_tokens = 1
      })
    })
  end)

  if status and result.StatusCode == 200 then
    return true
      elseif status
    return result.StatusCode
      else
    return result.StatusCode
  end
end

return requests
