      Headers = {
        ["Authorization"] = "Bearer " .. tostring(self.key),
        ["Content-Type"] = "application/json",
      },
      Body = HttpService:JSONEncode({
        model = MODEL,
        messages = {
          {
            role = "system",
            content = "You are an AI assistant connected to a self-hosted Roblox source bridge. The Python backend manages project source retrieval."
          },
          {
            role = "user",
            content = msg
          }
        },
        temperature = 1,
        top_p = 0.95,
        max_tokens = 32768,
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

local nv = {}
nv.__index = nv

function nv:init(ins)
  local self = setmetatable({}, nv)
  self.req = request:new({
    apikey = ins.apikey,
    localEndpoint = ins.localEndpoint
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

return require("Providers.nvidia.init"):init({
  apikey = getgenv().apikey, -- replace please
  localEndpoint = "http://127.0.0.1:8000"
})