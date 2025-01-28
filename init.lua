local cloneref = cloneref or function(instance) return instance end
local settings = getgenv().presets or {
    visible = true,
    developer = false,
    config = 'default'
} :: {visible: boolean, developer: boolean, config: string}
getgenv().presets = settings

for i: number, v: string in {'cache', 'modules', 'images', 'sounds', 'modules/configuration', 'modules/fonts'} do
    makefolder(`Bloxstrap/{v}`)
end

if #listfiles('Bloxstrap/modules/libraries') <= 3 then
    writefile('Bloxstrap/modules/configuration/default.json', '{}')
    writefile('Bloxstrap/modules/configuration/fastflags.json', '{}')
    writefile('Bloxstrap/modules/main.lua', `loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/modules/main.lua'))()`)
    print('installed')
end

loadfile('Bloxstrap/modules/main.lua')()(settings)