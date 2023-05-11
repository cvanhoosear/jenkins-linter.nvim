local env_parser = {}

local function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

env_parser._find_env_key = function (line)
  local i = string.find(line, "=")
  local result = line:sub(0, i-1)
  return trim(result)
end

env_parser._find_env_value = function (line)
  local i = string.find(line, "=")
  if (string.find(line, '=', i+1) ~= nil) then
    error("Something is wrong with key value pair in env file", vim.log.levels.ERROR)
  end
  local result = line:sub(i+1,-1)
  return trim(result)
end

env_parser.parse_env = function (file_path)
  local envs = {}
  local file = io.open(file_path, 'r')
  if file == nil then
    vim.notify("Unable to open env file", vim.log.levels.ERROR)
    return {}
  end

  for line in file:lines() do
    local key = env_parser._find_env_key(line)
    local value = env_parser._find_env_value(line)
    envs[key] = value
  end
  file:close()
  return envs
end

return env_parser
