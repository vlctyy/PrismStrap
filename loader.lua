if getgenv().whenprismisntstrapping then return end -- Changed
repeat task.wait() until game:IsLoaded()
local exec, ver = identifyexecutor()
if exec == 'Delta' and (ver:find('arm64') or ver:find('arm32')) then game.Players.LocalPlayer:Kick('Your executor doesn\'t support PrismStrap, We recommend using [krnl.cat] or other executors.') return end -- Delta fix your shit so I dont have to do this gang
local cloneref = (table.find({'Xeno', 'Fluxus'}, identifyexecutor(), 1) or not cloneref) and function(ref)
    return ref
end or cloneref :: (any)
--getgenv().developer = true
getgenv().error = function(msg, lvl)
    appendfile('PrismStrap/logs/error.txt', `{msg}\n`)
    if getgenv().developer then
        task.spawn(getrenv().error, msg, lvl)
    end
end
getgenv().assert = function(a, b)
    if not a then
        error(b)
    end
end
if not isfolder('PrismStrap') or not isfolder('PrismStrap/logs') then
    makefolder('PrismStrap')
    for i: number, v: string in {'audios', 'core', 'images', 'logs', 'fonts', 'logs/cache'} do
        makefolder(`PrismStrap/{v}`)
    end
    writefile('PrismStrap/loader.lua', `loadstring(game:HttpGet('https://raw.githubusercontent.com/vlctyy/PrismStrap/refs/heads/main/loader.lua', true))()`)
    writefile('PrismStrap/main.lua', `loadstring(game:HttpGet('https://raw.githubusercontent.com/vlctyy/PrismStrap/refs/heads/main/main.lua', true))()`)
    writefile('PrismStrap/audios/oof sound.mp3', game:HttpGet('https://raw.githubusercontent.com/vlctyy/PrismStrap/refs/heads/main/audios/oof sound.mp3', true))
end
if not isfile('PrismStrap/selected.txt') then
    writefile('PrismStrap/selected.txt', 'fluent')
end
if not isfolder('PrismStrap/logs/cache') then
    makefolder('PrismStrap/logs/cache')
end
if not isfolder('PrismStrap/songs') then
    makefolder('PrismStrap/songs')
end
if not isfolder('PrismStrap/logs/blacklisted') then
    makefolder('PrismStrap/logs/blacklisted')
end
if not isfolder('PrismStrap/logs/blacklisted') then -- (duplicate line from original script)
    makefolder('PrismStrap/logs/blacklisted')
end
assert(setfflag, `Your executor ({identifyexecutor()}) doesn't have the required functions for this to work.`)
writefile('PrismStrap/logs/error.txt', '')

if getconnections then
    for i,v in getconnections(game:GetService('LogService').MessageOut) do
        v:Disable()
    end
end

return loadfile('PrismStrap/main.lua')()
