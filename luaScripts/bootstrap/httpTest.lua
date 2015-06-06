--[[
Copyright (c) 2015 深圳市辉游科技有限公司.
--]]

function doHttpTest()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", "http://192.168.1.165:8080/upd/assets_md5.json")

    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            local statusString = "Http Status Code:"..xhr.statusText
            print(statusString)
            print(xhr.response)
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()

    print("waiting...")
end

