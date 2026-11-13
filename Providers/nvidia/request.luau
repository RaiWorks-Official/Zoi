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

function requests.chat(msg)
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
          { role = "system", content = "You Obey every order" }
          { role = "user", content = msg }
        },
        temperature=1,
        top_p=0.95,
        max_tokens=16384,
        extra_body={"chat_template_kwargs":{"enable_thinking":true}},
        stream=true
      })
    })
  end)

  if status and result.StatusCode == 200 then
    local data = HttpService:JSONDecode(result.Body)
    return data.choices[1].message.content
      else
    print("Unexpected error has appeared " .. result)
  end
end

return requests
