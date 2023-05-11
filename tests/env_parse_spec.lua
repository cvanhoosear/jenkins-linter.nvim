--JENKINS_USER = test.user
--
--JENKINS_PASSWORD = p@ssword1
--JENKINS_API_TOKEN = 22930ebd340c
--JENKINS_URL = https://jenkins.wa.spectranetix.com:8443/

local parse = require ("jenkins-linter.env_parse")
local eq = assert.are.same

describe("parsing env file", function()

  local ENV_FILE = "/home/cvanhoosear/plugins/jenkins-linter.nvim/tests/.test_env"
--  before_each(function()
--    file  = io.open(".test_env")
--  end)
    it("parse_env should return the env key", function ()
      local expected = "JENKINS_USER"
      local test_line = 'JENKINS_USER=test.user'
      eq(expected, parse._find_env_key(test_line))
    end)

    it("parse_env should return the env key of JENKINS_PASSWORD", function ()
      local expected = "JENKINS_PASSWORD"
      local test_line = 'JENKINS_PASSWORD=test.user'
      eq(expected, parse._find_env_key(test_line))
    end)

    it("parse_env should return the env key with spaces b/w =", function ()
      local expected = "JENKINS_USER"
      local test_line = 'JENKINS_USER = test.user'
      eq(expected, parse._find_env_key(test_line))
    end)

    it("parse_env should return the env key of JENKINS_PASSWORD with spaces b/w =", function ()
      local expected = "JENKINS_PASSWORD"
      local test_line = 'JENKINS_PASSWORD = test.user'
      eq(expected, parse._find_env_key(test_line))
    end)

    it("parse the value of from the key value string JENKINS_USER=test.user", function ()
      local expected = "test.user"
      local test_line = 'JENKINS_USER=test.user'
      eq(expected, parse._find_env_value(test_line))
    end)

    it("parse the value of from the key value string JENKINS_PASSWORD=hunter21", function ()
      local expected = "hunter21"
      local test_line = 'JENKINS_PASSWORD=hunter21'
      eq(expected, parse._find_env_value(test_line))
    end)
--
    it("parse the value of from the key value string JENKINS_USER=test.user with spaces b/w =", function ()
      local expected = "test.user"
      local test_line = 'JENKINS_USER = test.user'
      eq(expected, parse._find_env_value(test_line))
    end)

    it("parse the value of from the key value string JENKINS_PASSWORD=hunter21 with spaces b/w =", function ()
      local expected = "hunter21"
      local test_line = 'JENKINS_PASSWORD = hunter21'
      eq(expected, parse._find_env_value(test_line))
    end)

    it("should parse the test env file", function ()
      local expected = {
        JENKINS_USER = "test.user",
        JENKINS_PASSWORD = "p@ssword1",
        JENKINS_API_TOKEN = "22930ebd340c",
        JENKINS_URL = "https://jenkins.wa.spectranetix.com:8443/",
      }
      local results = parse.parse_env(ENV_FILE)
      for k, v in pairs(expected) do
        assert(results[k] ~= nil)
        eq(v, results[k])
      end
    end)
end)
