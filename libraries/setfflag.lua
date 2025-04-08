local inputservice = cloneref(game:GetService('UserInputService')) :: UserInputService
local loadfile = function(file, errpath)
    if getgenv().developer then
        errpath = errpath or file:gsub('bloxstrap/', '')
        return getgenv().loadfile(file, errpath)
    else
        local result = request({
            Url = `https://raw.githubusercontent.com/new-qwertyui/Bloxstrap/main/{file:gsub('bloxstrap/', '')}`,
            Method = 'GET'
        })
        if result.StatusCode == 200 then
            return loadstring(result.Body)
        else
            error('Invalid file')
        end
    end
end
local getfflag = getfflag or function()
    return 'nil'
end
local crashTick = tick()
return function(flag, value)
    repeat task.wait() until tick() > crashTick
    if isfile('bloxstrap/logs/blacklisted/'.. flag.. '.txt') then
        return shared.loaded.gui:notify({
            desc = `Attempted to use a fastflag that can\ncrash ur game ({flag})`
        })
    end
    crashTick = tick() + 0.1
    local fflag = inputservice.KeyboardEnabled and flag or flag:gsub('DFInt', ''):gsub('DFFlag', ''):gsub('FFlag', ''):gsub('FInt', ''):gsub('DFString', ''):gsub('FString', '') :: string
    if value and tostring(value) then
        value = tostring(value):gsub('"True"', 'true'):gsub('"False"', 'false')
    end
    if identifyexecutor() == 'Delta' then
        value = tostring(value) == '' and 'nil' or value
    end
    if getfflag(fflag) ~= nil then
        writefile('setting.bs', flag)
        setfflag(fflag, tostring(value))
        if isfile('setting.bs') then
            delfile('setting.bs')
        end
    end
end
