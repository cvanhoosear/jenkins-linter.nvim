
local log = require("plenary.log").new({plugin = "jenkins-linter.validate-file", level = "info"})
local curl = require"plenary.curl"

local validate_file = {}

local function urlencode(text)
  text = text:gsub("([^A-Za-z0-9%-_.!~*'())])", function (c)
    return string.format("%%%02X", string.byte(c))
  end)
  return text
end

validate_file.validate = function(jenkins_info, buf_contents, crumb)
  local auth_token = jenkins_info.user .. ":" .. (jenkins_info.token or jenkins_info.password)
  local response = curl.post(jenkins_info.jenkins_url .. "/pipeline-model-converter/validate", {
    auth = auth_token,
    raw = {
      jenkins_info.insecure,
      "-H" .. "Jenkins-Crumb:" .. crumb,
      "-d" .. "jenkinsfile=" .. urlencode(table.concat(buf_contents, "\n")),
    },
    on_stderror = function (err, _)
      if err then
        vim.notify("Something went wrong when trying to validate your file, check the logs.", vim.log.levels.ERROR)
        log.error(err)
      end
    end,
  })
  local status = response.status
  if status == 401 then
    log.error("Unable to authorize to get breadcrumb. Please check your creds")
  elseif status == 404 then
    log.error("Unable to hit your crumb provider. Please check your host")
  elseif response.status ~= 200 then
    log.error("Getting bread_crumb failed")
  end
  log.debug(response.body)
  return response.body
end

return validate_file
