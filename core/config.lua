local configapi = setmetatable({
    updateTick = tick()
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
    for i: string, v: table in lib.modules do
        local module = lib.configs[i]
        if module and not module.exception then
            if module.toggled == true then
                v:setstate(module.toggled)
            elseif module.value ~= nil then
                v:setvalue(module.value)
            end
        end
    end
    task.spawn(function()
        task.wait(4)
        repeat
            if configapi.updateTick <= tick() then
                writefile('bloxstrap/logs/profile.json', httpservice:JSONEncode(lib.modules))
                configapi.updateTick = tick() + 5
            end
            task.wait()
        until shared.loaded == nil
    end)
end
return configapi
