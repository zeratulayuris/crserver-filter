-- Прототип коммит-хука при помещении в хранилище
-- вызывает произвольный сервис при коммите.
-- Удобен для запуска gitsync при помещении в хранилище

-- Основан на работе https://github.com/asosnoviy/commitHook

-- TODO 
-- * обеспечить единоразовое чтение request_body всеми плагинами, а не каждым по отдельности

local _M = {}

function sendhook(premature)
    if premature then
        return
    end

    local httpc = require("resty.http").new()
        local res, err = httpc:request_uri(hookurl, {
            method = "POST",
            body = hookbody,
            headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            },
            keepalive_timeout = 30000,
            keepalive_pool = 10
        })

        if not res then
            ngx.log(ngx.WARN, "error calling "..url)
            return
        end
  
end

function _M.call(url, body)

    if ngx.var.commitfiltered == "true" then
        return
    end

    if  ngx.status == ngx.HTTP_BAD_REQUEST then
        return
    end

    hookurl =  url
    hookbody = body
    local req = ngx.var.request_body
    if req == nil then
        return
    end

    if string.find(req, "DevDepot_commitObjects") then
        ngx.timer.at(0, sendhook)
    end
end

return _M