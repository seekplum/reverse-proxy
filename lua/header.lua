#!/usr/bin/lua

local common = require("common")

local my_cache = ngx.shared.my_cache

local uri = ngx.var.request_uri
local cookies = ngx.header.set_cookie
if cookies then
    if type(cookies) == "string" then
        cookies = ngx.re.gsub(cookies, " Secure;", " SameSite=lax;")
    end
end
if uri ~= nil then
    local my_cookies = my_cache:get("my_cookies")
    if my_cookies == nil and cookies ~= nil then
        my_cache:set("my_cookies", cookies)
    end
    if ngx.re.match(uri, "^/login") and my_cookies ~= nil then
        ngx.header.set_cookie = my_cache:get("my_cookies")
        my_cache:delete("my_cookies")
    end
end
if not cookies then return end
ngx.log(ngx.WARN, "path:", uri, ", cookies: [", common.stringify(cookies), "].")
return
