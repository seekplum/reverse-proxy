#!/usr/bin/lua

local my_cache = ngx.shared.my_cache
local my_cookies = my_cache:get("my_cookies")
local cookies = ngx.req.get_headers()["Cookie"]
if cookies ~= nil and my_cookies ~= nil and type(cookies) == "string" and
    string.find(cookies, 'JSESSIONID.') ~= nil then
    ngx.req.set_header("Cookie", my_cookies)
end
