local inputservice = cloneref(game:GetService('UserInputService')) :: UserInputService
return function(flag)
    if not getfflag then return '' end
    local fflag = flag:gsub('DFInt', ''):gsub('DFFlag', ''):gsub('FFlag', ''):gsub('FInt', ''):gsub('DFString', ''):gsub('FString', '') :: string
    if isfile(`bloxstrap/logs/cache/{fflag}.txt`) then
        local value = readfile(`bloxstrap/logs/cache/{fflag}.txt`) :: string
        return value
    end
    local suc, res = pcall(function() 
        return getfflag(fflag) 
    end)
    print(suc, res)
    if not suc then
        error(`"{flag}" is not a valid fastflag`)
        return 'nil'
    else
        writefile(`bloxstrap/logs/cache/{fflag}.txt`, tostring(res))
    end
    return res
end