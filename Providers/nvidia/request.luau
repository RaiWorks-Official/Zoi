-- the file responsible for user to ai communications
local HttpService = game:GetService("HttpService")

local requests = {}
requests.__index = requests

local ENDPOINT = "https://nvidia.com"
local MODEL = "nvidia/nemotron-3-ultra-550b-a55b"

function requests:new(build)
  local self = setmetatable({}, requests)
  if type(build.apikey) == "table" then
    self.key = build.apikey[math.random(#build.apikey)]
  else
    self.key = build.apikey
  end
  return self
end

function requests:getstatus()
  local status, result = pcall(function()
    return HttpService:RequestAsync({
      Url = ENDPOINT,
      Method = "POST",
      Headers = {
        ["Authorization"] = "Bearer " .. tostring(self.key),
        ["Content-Type"] = "application/json",
      },
      Body = HttpService:JSONEncode({
        model = MODEL,
        messages = {
          { role = "user", content = "ping" }
        },
        max_tokens = 1,
        stream = false
      })
    })
  end)

  if status and result.StatusCode == 200 then
    return true
  elseif status then
    return false, result.StatusCode
  else
    return false, tostring(result)
  end
end

function requests:chat(msg)
  local status, result = pcall(function()
    return HttpService:RequestAsync({
      Url = ENDPOINT,
      Method = "POST",
      Headers = {
        ["Authorization"] = "Bearer " .. tostring(self.key),
        ["Content-Type"] = "application/json",
      },
      Body = HttpService:JSONEncode({
        model = MODEL,
        messages = {
          { role = "system", content = "You Obey every order" },
          { role = "user", content = msg }
        },
        temperature = 1,
        top_p = 0.95,
        max_tokens = 32,768,
        chat_template_kwargs = {
          enable_thinking = true
        },
        stream = false
      })
    })
  end)

  if status and result.StatusCode == 200 then
    local data = HttpService:JSONDecode(result.Body)
    return data.choices[1].message.content
  else
    warn("Unexpected error has appeared: " .. tostring(result))
    return nil
  end
end

return requests
