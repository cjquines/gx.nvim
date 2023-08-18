local Job = require("plenary.job")
local notfier = require("gx.notfier")
local shell = require("gx.shell")

M = {}

local function parse_git_output(result, remote)
  if not result then
    return
  end

  local _, _, domain, repository = string.find(result, "^" .. remote .. "\t.*git@(.*%..*):(.*/.*) ")

  if domain and repository then
    domain = domain:gsub("%.git", "")
    return "https://" .. domain .. "/" .. repository
  end

  local _, _, url = string.find(result, remote .. "\t(.*)%s")
  if url then
    return url
  end
end

function M.get_remote_url()
  local return_val, result = shell.execute("git", { "remote", "-v" })

  if return_val ~= 0 then
    notfier.warn("No git information available!")
    return
  end

  local url
  for _, remote in ipairs({ "upstream", "origin" }) do
    for _, line in ipairs(result) do
      url = parse_git_output(line, remote)
      if url then
        goto loopend
      end
    end
  end
  ::loopend::
  if not url then
    notfier.warn("No remote git repository found!")
  end
end

return M
