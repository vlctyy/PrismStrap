local cloneref = cloneref or function(instance) return instance end
local settings = getgenv().presets or {
    visible = true,
    developer = false,
    config = 'default'
} :: {visible: boolean, developer: boolean, config: string}
getgenv().presets = settings
makefolder('Bloxstrap')
if isfolder('Bloxstrap/Main') then
    delfolder('Bloxstrap')
    makefolder('Bloxstrap')
end
for i: number, v: string in {'cache', 'modules', 'images', 'sounds', 'modules/configuration', 'modules/fonts'} do
    makefolder(`Bloxstrap/{v}`)
end

if not isfile('Bloxstrap/modules/main.lua') then
    writefile('Bloxstrap/modules/configuration/default.json', '{}')
    writefile('Bloxstrap/images/bloxstrap.png', game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/images/bloxstrap.png'))
    writefile('Bloxstrap/sounds/oof sound.mp3', game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/sounds/oof%20sound.mp3'))
    writefile('Bloxstrap/modules/main.lua', `return loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/modules/main.lua', true))()`)
    print('installed')
end

if not ({pcall(function() return cloneref(game:GetService('HttpService')):JSONDecode(readfile('Bloxstrap/modules/configuration/fastflags.json')) end)})[1] then
    print('fflag failure, reinstalling')
    writefile('Bloxstrap/modules/configuration/fastflags.json', '{}')
end


loadfile('Bloxstrap/modules/main.lua')()(settings)
