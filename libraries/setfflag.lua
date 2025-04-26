local k = cloneref(game:GetService('UserInputService')).KeyboardEnabled
local getfflag = getfflag or function() return '' end
return function(flag, value)
    local fflag = k and flag or flag:gsub('DFInt', ''):gsub('DFFlag', ''):gsub('FFlag', ''):gsub('FInt', ''):gsub('DFString', ''):gsub('FString', '') :: string
    if value and tostring(value) then
        value = tostring(value):gsub('"True"', 'true'):gsub('"False"', 'false'):gsub('True', 'true'):gsub('False', 'false')
    end
    if getfflag(fflag) ~= nil then
        setfflag(fflag, tostring(value))
    end
end