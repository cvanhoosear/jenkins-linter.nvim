local curl = require "plenary.curl"
local log = require "plenary.log".new({plugin = "jenkins-linter.bread_crumb", level = "info"})

local bread_crumb = {}

bread_crumb.get_crumb = function (args)
  log.debug(vim.inspect(args))
  local auth_token = args.user .. ":" .. (args.token or args.password)
  local response = curl.get {
    url = args.jenkins_url .. "/crumbIssuer/api/json",
    auth = auth_token,
    raw = {args.insecure}
  }
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

return bread_crumb

