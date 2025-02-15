local inputservice = cloneref(game:GetService('UserInputService')) :: UserInputService
return function(flag)
    local fflag = inputservice.KeyboardEnabled and flag or flag:gsub('DFInt', ''):gsub('DFFlag', ''):gsub('FFlag', ''):gsub('FInt', ''):gsub('DFString', ''):gsub('FString', '') :: string
    if isfile(`bloxstrap/logs/cache/{fflag}.txt`) then
        local value = readfile(`bloxstrap/logs/cache/{fflag}.txt`) :: string
        return inputservice.KeyboardEnabled and (value == 'true' and true or value == 'false' and false or tonumber(value) or value) or value
    end
    local res = ({
        pcall(function() return getfflag(fflag) end)
    })
    if not res[1] then
        task.spawn(error, `"{flag}" is not a valid fastflag`)
        return nil
    end
    return res[2]
end