#!/usr/bin/lua

local _M = {}

function _M.stringify(values)
    local result = values
    if type(values) == "table" then result = table.concat(values, ";") end
    return result
end
return _M
