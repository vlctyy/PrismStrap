if getgenv().whenbloxisntstrapping then return end
repeat task.wait() until game:IsLoaded()
local exec, ver = identifyexecutor()
if exec == 'Delta' and (ver:find('arm64') or ver:find('arm32')) then game.Players.LocalPlayer:Kick('Your executor doesn\'t support bloxstrap, We recommend using [krnl.cat] or other executors.') return end
local cloneref = (table.find({'Xeno', 'Fluxus'}, identifyexecutor(), 1) or not cloneref) and function(ref)
    return ref
end or cloneref :: (any)
--getgenv().developer = true
getgenv().error = function(msg, lvl)
    appendfile('bloxstrap/logs/error.txt', `{msg}\n`)
    if getgenv().developer then
        task.spawn(getrenv().error, msg, lvl)
    end
end
getgenv().developer = true
getgenv().assert = function(a, b)
    if not a then
        error(b)
    end
end
if not isfolder('bloxstrap') or not isfolder('bloxstrap/logs') then
    makefolder('bloxstrap')
    for i: number, v: string in {'audios', 'core', 'images', 'logs', 'fonts', 'logs/cache'} do
        makefolder(`bloxstrap/{v}`)
    end
    writefile('bloxstrap/loader.lua', `loadstring(game:HttpGet('https://raw.githubusercontent.com/new-qwertyui/Bloxstrap/refs/heads/main/loader.lua', true))()`)
    writefile('bloxstrap/main.lua', `loadstring(game:HttpGet('https://raw.githubusercontent.com/new-qwertyui/Bloxstrap/refs/heads/main/main.lua', true))()`)
    writefile('bloxstrap/audios/oof sound.mp3', game:HttpGet('https://raw.githubusercontent.com/new-qwertyui/Bloxstrap/refs/heads/main/audios/oof sound.mp3', true))
end
if not isfile('bloxstrap/selected.txt') then
    writefile('bloxstrap/selected.txt', 'fluent')
end
if not isfolder('bloxstrap/logs/cache') then
    makefolder('bloxstrap/logs/cache')
end
if not isfolder('bloxstrap/songs') then
    makefolder('bloxstrap/songs')
end
if not isfolder('bloxstrap/logs/blacklisted') then
    makefolder('bloxstrap/logs/blacklisted')
end
if not isfolder('bloxstrap/logs/blacklisted') then
    makefolder('bloxstrap/logs/blacklisted')
end
assert(setfflag, `Your executor ({identifyexecutor()}) doesn't have the required functions for this to work.`)
writefile('bloxstrap/logs/error.txt', '')

if getconnections then
    for i,v in getconnections(game:GetService('LogService').MessageOut) do
        v:Disconnect()
    end
end

return loadfile('bloxstrap/main.lua')()
