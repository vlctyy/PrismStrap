if getgenv().whenbloxisntstrapping then return end -- Assuming "whenbloxisntstrapping" is a specific flag name and not a directory
repeat task.wait() until game:IsLoaded()
local exec, ver = identifyexecutor()
if exec == 'Delta' and (ver:find('arm64') or ver:find('arm32')) then game.Players.LocalPlayer:Kick('Your executor doesn\'t support PrismStrap, We recommend using [krnl.cat] or other executors.') return end -- Changed user-facing message
local cloneref = (table.find({'Xeno', 'Fluxus'}, identifyexecutor(), 1) or not cloneref) and function(ref)
    return ref
end or cloneref :: (any)
--getgenv().developer = true
getgenv().error = function(msg, lvl)
    appendfile('PrismStrap/logs/error.txt', `{msg}\n`) -- Changed
    if getgenv().developer then
        task.spawn(getrenv().error, msg, lvl)
    end
end
getgenv().assert = function(a, b)
    if not a then
        error(b)
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
if not isfolder('PrismStrap/logs/blacklisted') then -- Changed (duplicate line from original script, changed as well)
    makefolder('PrismStrap/logs/blacklisted') -- Changed
end
assert(setfflag, `Your executor ({identifyexecutor()}) doesn't have the required functions for this to work.`)
writefile('PrismStrap/logs/error.txt', '') -- Changed

if getconnections then
    for i,v in getconnections(game:GetService('LogService').MessageOut) do
        v:Disable()
    end
end

return loadfile('PrismStrap/main.lua')() -- Changed
