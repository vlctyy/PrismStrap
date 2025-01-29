local cloneref = cloneref or function(...) return ... end
local HttpService = cloneref(game.GetService(game, 'HttpService'))

return function(fastflag, value)
    local fastflagnew = cloneref(game:GetService('UserInputService')).TouchEnabled and fastflag:gsub('DFInt', ''):gsub('DFaFlag', ''):gsub('FFlag', ''):gsub('FInt', ''):gsub('DFString', ''):gsub('FString', '') or fastflag :: string
    if ({pcall(function() return getfflag(fastflagnew) end)})[1] and value ~= nil then
        local newvalue = {} :: table
        for i,v in HttpService:JSONDecode(readfile('Bloxstrap/modules/configuration/fastflags.json')) do
            newvalue[i] = v
        end
        print(value, tostring(value))
        newvalue[fastflag] = tostring(value)
        writefile('Bloxstrap/modules/configuration/fastflags.json', HttpService:JSONEncode(newvalue))
        return setfflag(fastflagnew, tostring(value))
    elseif value ~= nil and not ({pcall(function() return getfflag(fastflagnew) end)})[1] then
        if not isfile('Bloxstrap/cache/logs.txt') then
            writefile('Bloxstrap/cache/logs.txt', '')
        end
        appendfile('Bloxstrap/cache/logs.txt', `Attempted to use an unsupported fastflag ({fastflag}), Value: {value}.\n`)
    end
end
