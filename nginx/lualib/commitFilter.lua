local _M = {}

function _M.apply(pattern)
   
    ngx.req.read_body()

    local req = ngx.var.request_body
    if req == nil then
        return
    end

    local commentPattern = [[<crs:comment>(.*)</crs:comment>]]
    local message
    if req:match([[DevDepot_commitObjects]]) ~= nil then
        message = req:match(commentPattern) -- комментарий хранилища
    elseif req:match([[DevDepot_changeVersion]]) ~= nil then
        local newVersion = req:match([[<crs:newVersion>(.*)</crs:newVersion>]])
        if newVersion == nil then
            return
        end
        message = newVersion:match(commentPattern)
    else
        return
    end

    -- проверка на пустой комментарий
    if message == nil then
        ngx.status = ngx.OK
        local b64 = require("base64")
        answer = b64.encode("{{3ccb2518-9616-4445-aaa7-20048fead174,\"При помещении в хранилище комментарий должен быть заполнен\",{9f06d311-1431-4a54-bd6f-fa93c4d4c471,{9f06d311-1431-4a54-bd6f-fa93c4d4c471,\"\",{00000000-0000-0000-0000-000000000000},\"\"}},\"\",\"0000000000000000000\",00000000-0000-0000-0000-000000000000},17,{\"file:///var/opt/1C/repo/\",0},\"\"}")

        ngx.var.commitfiltered = "true"
        ngx.header["Content-Type"] = "application/xml"
        ngx.say(string.format("<?xml version=\"1.0\" encoding=\"UTF-8\"?><crs:call_exception xmlns:crs=\"http://v8.1c.ru/8.2/crs\" clsid=\"3ccb2518-9616-4445-aaa7-20048fead174\">77u/%s</crs:call_exception>", answer))
        ngx.exit(ngx.status)
    end

    -- вот здесь можно написать свои проверки
    if pattern ~= nil then
        local matches = message:match(pattern)
        if matches ~= nil then
            return
        else
            ngx.var.commitfiltered = "true"
            ngx.status = ngx.HTTP_BAD_REQUEST
            ngx.say("Comment is not matched our team standards")
            ngx.exit(ngx.HTTP_BAD_REQUEST)
        end
    end
end

return _M