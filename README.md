# Bloxstrap
A script that attempts to recreate Bloxstrap, so you can use FFlags without installing a program.

## Script
```lua
getgenv().presets = {
    developer = false,
    visible = true, -- ur choice
    config = 'default'
}
loadstring(game.HttpGet(game, 'https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/init.lua', true))()
```
