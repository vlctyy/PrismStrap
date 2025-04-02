local configapi = setmetatable({
    updateTick = 0
}, {}):: table
local httpservice = cloneref(game:GetService('HttpService')) :: HttpService
function configapi:getdata(args, json)
    local body = {
        result = {}
    } :: table
    for i: string, v: table in args.library.modules do
        if not json then
            if v.toggled or v.value then
                body.result[i] = v
            end
        end
    end
    return body
end
function configapi:loadconfig(lib)
    xpcall(function()
        print('debug a')
        for i: string, v: table in lib.modules do
            local module = lib.configs[i]
            if module and not module.ignore then
                if module.toggled == true then
                    v:setstate(true)
                elseif module.value ~= nil then
                    v:setvalue(module.value)
                end
            end
        end
        print('debug b')
    end, warn)
    task.spawn(function()
        task.wait(4)
        repeat
            if tick() > configapi.updateTick then
                writefile('bloxstrap/logs/profile.json', httpservice:JSONEncode(lib.modules))
                configapi.updateTick = tick() + 5
            end
            task.wait()
        until shared.loaded == nil
    end)
end
return configapi
