local inputservice = cloneref(game:GetService('UserInputService')) :: UserInputService
local loadfile = function(file, errpath)
    if getgenv().developer then
        errpath = errpath or file:gsub('bloxstrap/', '')
        return getgenv().loadfile(file, errpath)
    else
        local result = request({
            Url = `https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/{file:gsub('bloxstrap/', '')}`,
            Method = 'GET'
        })
        if result.StatusCode == 200 then
            return loadstring(result.Body)
        else
            error('Invalid file')
        end
    end
end
local getfflag = loadfile('bloxstrap/core/getfflag.lua')()
return function(flag, value)
    local fflag = inputservice.KeyboardEnabled and flag or flag:gsub('DFInt', ''):gsub('DFFlag', ''):gsub('FFlag', ''):gsub('FInt', ''):gsub('DFString', ''):gsub('FString', '') :: string
    if value and tostring(value) then
        value = tostring(value):gsub('"True"', 'true'):gsub('"False"', 'false')
    end
    if getfflag(fflag) ~= nil then
        local suc, res = pcall(function()
            return setfflag(fflag, tostring(value))
        end)
        if not suc then
            return error(res)
        end
        return res
    end
end