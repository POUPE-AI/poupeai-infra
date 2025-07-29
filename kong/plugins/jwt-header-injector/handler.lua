local jwt_parser = require "kong.plugins.jwt.jwt_parser"

local JwtHeaderInjector = {
  PRIORITY = 1000,
  VERSION = "1.0.0",
}

function JwtHeaderInjector:access(conf)
  local authorization = kong.request.get_header("authorization")
  if authorization then
    local _, _, token = authorization:find("Bearer%s+(.+)")
    if token then
      local jwt, err = jwt_parser:new(token)
      if err then
        kong.log.warn("Failed to parse JWT: ", err)
      elseif jwt.claims and jwt.claims.sub then
        kong.service.request.set_header("X-User-Sub", jwt.claims.sub)
      end
    end
  end
end

return JwtHeaderInjector