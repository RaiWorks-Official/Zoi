      local HttpService = game:GetService("HttpService")

local requests = {}
requests.__index = requests

local ENDPOINT = "https://integrate.api.nvidia.com/v1/chat/completions"
local MODEL = "nvidia/nemotron-3-ultra-550b-a55b"
local LOCAL_ENDPOINT = "http://127.0.0.1:8000"

function requests:new(build)
  local self = setmetatable({}, requests)
  if type(build.apikey) == "table" then
    self.key = build.apikey[math.random(#build.apikey)]
  else
    self.key = build.apikey
  end
  self.localEndpoint = build.localEndpoint or LOCAL_ENDPOINT
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
  local localstatus, localresult = pcall(function()
    return HttpService:RequestAsync({
      Url = self.localEndpoint .. "/health",
      Method = "GET"
    })
  end)

  if localstatus and localresult.StatusCode == 200 then
    local files = {}

    for _, v in ipairs(game:GetDescendants()) do
      if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
        local success, source = pcall(function()
          return decompile(v)
        end)

        if success and type(source) == "string" then
          table.insert(files,
            "Path - " .. v:GetFullName() ..
            "\nContent\n" .. source
          )
        end
      end
    end

    if #files > 0 then
      local uploadstatus, uploadresult = pcall(function()
        return HttpService:RequestAsync({
          Url = self.localEndpoint .. "/source",
          Method = "POST",
          Headers = {
            ["Content-Type"] = "text/plain"
          },
          Body = table.concat(files, "\n\n")
        })
      end)

      if not uploadstatus then
        warn("Source upload failed: " .. tostring(uploadresult))
      elseif uploadresult.StatusCode < 200 or uploadresult.StatusCode >= 300 then
        warn("Source upload rejected: " .. tostring(uploadresult.StatusCode))
      end
    end
  else
    warn("Local server is unavailable")
  end

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