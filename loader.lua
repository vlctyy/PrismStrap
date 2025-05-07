repeat task.wait() until game:IsLoaded()
if getgenv().whenprismisntstrapping then return end -- Changed (was whenbloxisntstrapping)
local exec, ver = identifyexecutor()
local cloneref = cloneref or function(ref)
    return ref
end
--getgenv().developer = true
getgenv().error = function(msg, lvl)
    appendfile('PrismStrap/logs/error.txt', `{msg}\n`) -- Changed
    if getgenv().developer then
        task.spawn(getrenv().error, msg, lvl)
    end
end
getgenv().assert = function(statement, err)
    if not statement then
        error(err)
    end
end
if not isfolder('PrismStrap') or not isfolder('PrismStrap/logs') then -- Changed
    makefolder('PrismStrap') -- Changed
    for i: number, v: string in {'audios', 'core', 'images', 'logs', 'fonts', 'logs/cache'} do
        makefolder(`PrismStrap/{v}`) -- Changed
    end
    writefile('PrismStrap/loader.lua', `loadstring(game:HttpGet('https://raw.githubusercontent.com/vlctyy/PrismStrap/refs/heads/main/loader.lua', true))()`) -- Changed
    writefile('PrismStrap/main.lua', `loadstring(game:HttpGet('https://raw.githubusercontent.com/vlctyy/PrismStrap/refs/heads/main/main.lua', true))()`) -- Changed
    writefile('PrismStrap/audios/oof sound.mp3', game:HttpGet('https://raw.githubusercontent.com/vlctyy/PrismStrap/refs/heads/main/audios/oof sound.mp3', true)) -- Changed
end
if not isfile('PrismStrap/selected.txt') then -- Changed
    writefile('PrismStrap/selected.txt', 'fluent') -- Changed
end
if not isfolder('PrismStrap/logs/cache') then -- Changed
    makefolder('PrismStrap/logs/cache') -- Changed
end
if not isfolder('PrismStrap/songs') then -- Changed
    makefolder('PrismStrap/songs') -- Changed
end
if not isfolder('PrismStrap/logs/blacklisted') then -- Changed
    makefolder('PrismStrap/logs/blacklisted') -- Changed
end
if not isfolder('PrismStrap/logs/blacklisted') then -- Changed (duplicate line from original script)
    makefolder('PrismStrap/logs/blacklisted') -- Changed
end
assert(setfflag, `Your executor ({identifyexecutor()}) doesn't have the required functions for this to work.`)
writefile('PrismStrap/logs/error.txt', '') -- Changed

if getconnections then
    for i,v in getconnections(cloneref(game:GetService('LogService')).MessageOut) do
        v:Disable()
    end
    for i,v in getconnections(cloneref(game:GetService('ScriptContext')).Error) do
        v:Disable()
    end
end

return loadfile('PrismStrap/main.lua')() -- Changed
