local cloneref = (table.find({'Xeno', 'Fluxus'}, identifyexecutor(), 1) or not cloneref) and function(ref)
    return ref
end or cloneref :: (any)
getgenv().error = function(msg, lvl)
    appendfile('bloxstrap/logs/error.txt', `{msg}\n`)
    if getgenv().developer then
        --getrenv().error(msg, lvl)
    end
end
getgenv().assert = function(a, b)
    if not a then
        error(b)
    end
end
if not isfolder('bloxstrap') or not isfolder('bloxstrap/logs') then
    makefolder('bloxstrap')
    for i: number, v: string in {'audios', 'core', 'images', 'logs', 'logs/cache'} do
        makefolder(`bloxstrap/{v}`)
    end
    writefile('bloxstrap/main.lua', `loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/refs/heads/main/main.lua', true))()`)
end
assert(setfflag and getfflag, `Your executor ({identifyexecutor()}) doesn't have the required functions for this to work.`)
writefile('bloxstrap/logs/error.txt', '')
return loadfile('bloxstrap/main.lua')()
