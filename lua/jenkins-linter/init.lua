local Path = require("plenary.path")
local parser = require("jenkins-linter.env_parse")
local jv = require("jenkins-linter.validate_jenkinsfile")
local bc = require("jenkins-linter.bread_crumb")

local M = {}


M.setup = function (opts)
  M.conf = {
    env_path = Path:new(os.getenv('HOME') .. "/.config/nvim/"),
    env_name = ".jenkins_env"
  }
end

local jenkins_info = {}
local namespace_id = vim.api.nvim_create_namespace("jenkinsfile-linter")
local VALIDATED_MSG = "Jenkinsfile successfully validated."


local validate_job =  vim.schedule_wrap(function (crumb)
--  local args = vim.fn.json_decode(crumb)
  local buf_contents = vim.api.nvim_buf_get_lines(0,0, -1, false)
  local body = jv.validate(jenkins_info, buf_contents, crumb)
  if body == VALIDATED_MSG then
    vim.diagnostic.reset(namespace_id, 0)
    vim.notify(VALIDATED_MSG, vim.log.levels.INFO)
  else
    local msg, line_str, col_str = body:match("WorkflowScript.+%d+: (.+) @ line (%d+), column (%d+).")
    if line_str and col_str then
      local line = tonumber(line_str) - 1
      local col = tonumber(col_str) - 1

      local diag = {
        bufnr = vim.api.nvim_get_current_buf(),
        lnum = line,
        end_lnum = line,
        col = col,
        end_col = col,
        severity = vim.diagnostic.severity.ERROR,
        message = msg,
        source = "jenkinsfile linter",
      }

      vim.diagnostic.set(namespace_id, vim.api.nvim_get_current_buf(), { diag })
    end
  end
end)

local function check_creds()
  if jenkins_info.user == nil then
    return false, "JENKINS_USER is not set"
  elseif jenkins_info.password == nil and jenkins_info.token == nil then
    return false, "JENKINS_PASSWORD or JENKINS_API_TOKEN is not set"
  elseif jenkins_info.jenkins_url == nil then
    return false, "JENKINS_URL is not set"
  else
    return true, ""
  end
end


local function get_env_vars()
  local file_name = M.conf.env_path .. M.conf.env_name

  if not Path:new(file_name):is_file() then
    vim.notify("env file not opened using environment variables", vim.log.levels.WARN)
    jenkins_info.user = os.getenv("JENKINS_USER")
    jenkins_info.password = os.getenv("JENKINS_PASSWORD")
    jenkins_info.token = os.getenv("JENKINS_API_TOKEN")
    jenkins_info.jenkins_url = os.getenv("JENKINS_URL")
    jenkins_info.insecure = os.getenv("JENKINS_INSECURE") and "--insecure" or ""
  else
    local env = parser.parse_env(file_name)
    jenkins_info.user = env["JENKINS_USER"]
    jenkins_info.password = env["JENKINS_PASSWORD"]
    jenkins_info.token = env["JENKINS_API_TOKEN"]
    jenkins_info.jenkins_url = env["JENKINS_URL"]
    jenkins_info.insecure = env["JENKINS_INSECURE"] and "--insecure" or ""
  end
end

local function validate()
  get_env_vars()
  local ok, msg = check_creds()
  if ok then
    local crumb = bc.get_crumb(
      jenkins_info
    )
    validate_job(crumb)
  else
    vim.notify(msg, vim.log.levels.ERROR)
  end
end


M.validate = validate
M.check_creds = check_creds

return M
