return function(sets: table)
    for i: number, v: string in {'Players', 'ReplicatedStorage', 'HttpService', 'UserInputService', 'CoreGui', 'Lighting'} do
        getfenv()[v:lower()] = cloneref(game:GetService(v))
    end
    local lplr = players.LocalPlayer :: Player
    
    local function loadfile(file, msg)
        local success, file = pcall(function()
            return readfile(file)
        end)
        if not success then
            error('file doesnt exist')
        end
        local loaded, script = pcall(function()
            return loadstring(file, msg or file:gsub('Bloxstrap/', ''))
        end)
        return loaded and script or error(script)
    end
    
    local function loadfunc(name)
        if sets.developer then
            return loadfile(`Bloxstrap/modules/{name}`)
        else
            local result = loadstring(game:HttpGet(`https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/modules/{name}`))
            return result == '404: Not Found' and error(`Bloxstrap | module named '{name}' doesn't exist.`) or result
        end
    end
    
    local gui = loadfunc('libraries/gui.lua')()
    local setfflag = loadfunc('libraries/toggleflag.lua')()
    local getfflag = loadfunc('libraries/getfflag.lua')()
    
    local main: table? = gui:MakeWindow({ 
        Title = 'Bloxstrap',
        SubTitle = 'Made by qwerty and max with love',
        SaveName = sets.config
    })
  
    coregui['redz Library V5'].Hub.Visible = sets.visible
  
    local run = pcall
  
    for i: number, v: string in {'Intergations', 'Mods', 'FastFlags', 'Appearance', 'Behaviour'} do
        getfenv()[v:lower():gsub(' ', '')] = main:MakeTab({
             v,
            '',
            true
        })
    end
    
    mods:AddSection('Presets')
    
    run(function()
        local chosensound = 'oof sound.mp3'
        local deathcon = nil
        local respawncon = nil
        local deathsound = mods:AddToggle({
            Name = 'Use custom death sound',
            Tooltip = 'Uses a custom death sound instead of the current one',
            Callback = function(call: boolean): ()
                if call then
                    deathcon = lplr.Character.Humanoid.HealthChanged:Connect(function()
                        if lplr.Character.Humanoid.Health <= 0 then
                            lplr.PlayerScripts.RbxCharacterSounds.Enabled = false
                            local sound = Instance.new('Sound', workspace)
                            sound.PlayOnRemove = true
                            sound.Volume = 0.6
                            sound.SoundId = getcustomasset(`Bloxstrap/sounds/{chosensound}`)
                            sound:Remove()
                        end
                    end)
                    respawncon = lplr.CharacterAdded:Connect(function(v)
                        lplr.PlayerScripts.RbxCharacterSounds.Enabled = true
                        if deathcon then
                            deathcon:Disconnect(v)
                            deathcon = nil
                        end
                        deathcon = v:WaitForChild('Humanoid').HealthChanged:Connect(function()
                            if v.Humanoid.Health <= 0 then
                                lplr.PlayerScripts.RbxCharacterSounds.Enabled = false
                                local sound = Instance.new('Sound', workspace)
                                sound.PlayOnRemove = true
                                sound.Volume = 0.6
                                sound.SoundId = getcustomasset(`Bloxstrap/sounds/{chosensound}`)
                                sound:Remove()
                            end
                        end)
                    end)
                else
                    if respawncon then
                        respawncon:Disconnect()
                        respawncon = nil
                    end
                    if deathcon then
                        deathcon:Disconnect()
                        deathcon = nil
                    end
                    lplr.PlayerScripts.RbxCharacterSounds.Enabled = true
                end
            end
        })
        local sounds = {} :: table
        for i: number, v: string in listfiles('Bloxstrap/sounds') do
            sounds[i] = v:gsub('Bloxstrap/sounds/', ''):gsub('/', '')
        end
        mods:AddDropdown({
            Name = 'Sound',
            Default = 'oof sound.mp3',
            Options = sounds,
            Callback = function(val: string): ()
                chosensound = val
            end
        })
    end)
    
    local emulatesounds = mods:AddToggle({
        Name = 'Emulate old character sounds',
        Tooltip = 'An attempt to roughly bring back the character sounds used prior to 2014.',
        Callback = function(call: boolean): ()
            -- soon
        end
    })
  
    run(function()
        local chosenimage = nil
        local imagelabel = nil
        local crosshair = mods:AddToggle({
            Name = 'Crosshair',
            Tooltip = 'Creates a crosshair in the middle of your screen.',
            Callback = function(call: boolean): ()
                if call then
                    imagelabel = Instance.new('ImageLabel', coregui['redz Library V5'])
                    imagelabel.Size = UDim2.new(0, 19, 0, 19)
                    imagelabel.AnchorPoint = Vector2.new(0.5, 0.5)
                    imagelabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                    imagelabel.BackgroundTransparency = 1
                    imagelabel.Image = chosenimage or ''
                else
                    if imagelabel and imagelabel.Parent then
                        imagelabel:Destroy()
                    end
                end
            end
        })
        mods:AddDropdown({
            Name = 'Crosshair Image',
            Options = listfiles('Bloxstrap/images'),
            Callback = function(val: string): ()
                if val then
                    chosenimage = getcustomasset(val)
                    crosshair:Retoggle()
                end
            end
        })
    end)
    
    run(function()
        local old;
        mods:AddToggle({
            Name = 'Remove Fogs',
            Callback = function(call: boolean): ()
                old = call and lighting.FogEnd or old
                if old == nil then return end
                lighting.FogEnd = call and 9e9 or old
            end
        })
    end)
    
    run(function()
        local connections = {}
        mods:AddToggle({
            Name = 'Better Resolution',
            Tooltip = 'Changes your screen resolution.',
            Callback = function(call: boolean): ()
              
            end
        })
    end)
    
    run(function()
        local camerascript = require and require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput) or {} :: table
        local old = camerascript.getRotation
        mods:AddTextBox({
            Name = 'Camera Sensitivity',
            Default = '1',
            Tooltip = 'Increases your camera sensitivity (set to 1 for roblox default)',
            Callback = function(val)
                if not val or tonumber(val) == nil then return end
                camerascript.getRotation = function(...)
                    return old(...) * tonumber(val)
                end
            end
        })
    end)
    
    --[[run(function()
        local oldskies = {} :: table
        local customskyid = mods:AddDropdown({
            Name = 'Custom Sky'
            Tooltip = 'Enter sky assetid.',
            Callback = function(val: string): ()
                if not val then return end
                if val == '' then
                    lighting:FindFirstChildWhichOfClass('Sky'):Destroy()
                    for i: number, v: Sky in oldskies do
                        v.Parent = lighting
                    end
                else
                    if not val:find('assetid') then
                        val = `rbxassetid://{val}`
                    end
                    
                end
            end
        })
    end)]]
  
    mods:AddSection('Miscellaneous')
    
    run(function()
        local customfonts = {'none'} :: table
        for i: number, v: string in listfiles('Bloxstrap/modules/fonts') do
            if v:find('.ttf') then
                table.insert(customfonts, v)
            end
        end
        local originalfonts = {}
        local connections = {} :: table
        local applyfont = mods:AddDropdown({
            Name = 'Apply custom font',
            Tooltip = 'Forces every in-game font to be a font you choose',
            Options = customfonts,
            Callback = function(val: string): ()
                if val == 'none' or #connections > 0 then
                    for i: number, v: any in connections do
                        v:Disconnect()
                    end
                    table.clear(connections)
                    for i: number, v: {Font: any, UI: Instance} in originalfonts do
                        v.UI.Font = v.Font
                    end
                    table.clear(originalfonts)
                elseif val then
                    writefile(val:gsub('.ttf', '.json'), httpservice:JSONEncode({
                        name = 'fontface',
                        faces = {
                            {
                                name = 'Regular',
                                weight = 100,
                                style = 'normal',
                                assetId = getcustomasset(val)
                            }
                        }
                    }))
                    local fontface = Font.new(getcustomasset(val:gsub('.ttf', '.json')), Enum.FontWeight.Regular)
                    for i: number, v: any in game:GetDescendants() do
                        if v.ClassName and v.ClassName:find('Text') and ({pcall(function() return v.Font end)})[1] then
                            table.insert(originalfonts, {Font = v.Font, UI = v})
                            v.FontFace = fontface
                            table.insert(connections, v:GetPropertyChangedSignal('FontFace'):Connect(function()
                                v.FontFace = fontface
                            end))
                        end
                    end
                    table.insert(connections, game.DescendantAdded:Connect(function(v)
                        if v.ClassName and v.ClassName:find('Text') and ({pcall(function() return v.Font end)})[1] then
                            table.insert(originalfonts, {Font = v.Font, UI = v})
                            v.FontFace = fontface
                            table.insert(connections, v:GetPropertyChangedSignal('FontFace'):Connect(function()
                                v.FontFace = fontface
                            end))
                        end
                    end))
                end
            end
        })
    end)
    
    run(function()
        mods:AddToggle({
            Name = 'Disable scale quality optimization',
            Callback = function(call: boolean): ()
                setfflag('DFFlagDisableDPIScale', call)
            end
        })
    end)
    
    fastflags:AddSection('Presets')
    fastflags:AddSection({Name = 'Rendering and graphics', lower = true})
    
    run(function()
        fastflags:AddDropdown({  
            Name = 'Anti-aliasing quality (MSAA)',
            Options = {'Automatic', '1x', '2x', '4x'},
            Callback = function(val: string): ()
                if not val or not userinputservice.TouchEnabled then return end
                local newval = val:find('x') and val:gsub('x', '') or 0
                print(newval)
                setfflag('FIntDebugForceMSAASamples', newval)
            end
        })
    end)
    
    run(function()
        fastflags:AddToggle({
            Name = 'Disable player shadows',
            Callback = function(call: boolean): ()
                
                setfflag('FIntRenderShadowIntensity', call and 0 or 1)
            end
        })
        fastflags:AddToggle({
            Name = 'Disable post-processing effects',
            Callback = function(call: boolean): ()
            
                setfflag('FFlagDisablePostFx', call and true or false)
            end
        })
      
        local oldlightingflag = getfflag('FIntRenderLocalLightFadeInMs')
        fastflags:AddToggle({
            Name = 'Disable fade animations',
            Callback = function(call: boolean): ()
                setfflag('FIntRenderLocalLightFadeInMs', call and 0 or oldlightingflag)
            end
        })
      
        local oldplayertexure = getfflag('DFIntTextureCompositorActiveJobs')
        fastflags:AddToggle({
            Name = 'Disable player textures',
            Callback = function(call: boolean): ()
                setfflag('DFIntTextureCompositorActiveJobs', call and 0 or oldplayertexure)
            end
        })
      
        local oldterrain = getfflag('FIntTerrainArraySliceSize')
        fastflags:AddToggle({
            Name = 'Disable terrain textures',
            Callback = function(call: boolean): ()
                setfflag('FIntTerrainArraySliceSize', call and 0 or oldterrain)
            end
        })
    end)
  
    run(function()
        fastflags:AddTextBox({
            Name = 'Framerate limit',
            Tooltip = 'Use a large number 9e9 for no limit. Set as 0 for default.',
            Callback = function(val: string): ()
                val = tonumber(val)
                if val == nil then return end
                setfflag('FFlagTaskSchedulerLimitTargetFpsTo2402', val and val > 60 and true or false)
                setfflag('FFlagDebugDisplayFPS', val > 90)
                if val and val == 0 then
                    setfpscap(240)
                    setfflag('DFIntTaskSchedulerTargetFps', 240)
                    return
                end
                if val then
                    setfpscap(val)
                    setfflag('DFIntTaskSchedulerTargetFps', val)
                end
            end
        })
    end)
    
    run(function()
        local function changelighting(lighting)
            if not lighting then return end
            sethiddenproperty(game.Lighting, 'Technology', lighting:find('Voxel') and 'Voxel' or lighting:find('Shadow Map') and 'ShadowMap' or 'Future')
            if not userinputservice.TouchEnabled then
                str = lighting:lower()
                if str:find('voxel') then
                    setfflag('DFFlagDebugRenderForceTechnologyVoxel', true)
                    setfflag('DFFlagDebugRenderForceFutureIsBrightPhase2', false)
                    setfflag('DFFlagDebugRenderForceFutureIsBrightPhase3', false)
                    return
                elseif str:find('shadow map') then
                    setfflag('DFFlagDebugRenderForceTechnologyVoxel', false)
                    setfflag('DFFlagDebugRenderForceFutureIsBrightPhase2', true)
                    setfflag('DFFlagDebugRenderForceFutureIsBrightPhase3', false)
                    return
                elseif str:find('future') then
                    setfflag('DFFlagDebugRenderForceTechnologyVoxel', false)
                    setfflag('DFFlagDebugRenderForceFutureIsBrightPhase2', false)
                    setfflag('DFFlagDebugRenderForceFutureIsBrightPhase3', true)
                    return
                elseif str:find('chosen') then
                    setfflag('DFFlagDebugRenderForceTechnologyVoxel', false)
                    setfflag('DFFlagDebugRenderForceFutureIsBrightPhase2', false)
                    setfflag('DFFlagDebugRenderForceFutureIsBrightPhase3', false)
                    return
                end
            end
        end
        fastflags:AddDropdown({
            Name = 'Preferred lighting technology',
            Tooltip = 'Choose which lighting should be forced enabled in all games.',
            Callback = changelighting,
            Default = 'Chosen by game',
            Options = {'Chosen by game', 'Voxel (Phase 1)', 'Shadow Map (Phase 2)', 'Future (Phase 3)'}
        })
      
      fastflags:AddDropdown({
          Name = 'Texure quality',
          Options = {'Automatic', 'Lowest (Requires rejoin)', 'Low', 'Medium', 'High', 'Highest'},
          Callback = function(val: string): ()
              if not val then return end
              local str = val:lower() :: string
              if str:find('lowest') then
                  setfflag('DFFlagTextureQualityOverrideEnabled', true)
                  setfflag('DFIntTextureQualityOverride', 0)
                  setfflag('FIntDebugTextureManagerSkipMips', 2)
                  return
              elseif str:find('low') then
                  setfflag('DFFlagTextureQualityOverrideEnabled', true)
                  setfflag('DFIntTextureQualityOverride', 0)
                  setfflag('FIntDebugTextureManagerSkipMips', 0)
                  return
              elseif str:find('medium') then
                  setfflag('DFFlagTextureQualityOverrideEnabled', true)
                  setfflag('DFIntTextureQualityOverride', 1)
                  setfflag('FIntDebugTextureManagerSkipMips', 0)
                  return
              elseif str:find('high') then
                  setfflag('DFFlagTextureQualityOverrideEnabled', true)
                  setfflag('DFIntTextureQualityOverride', 2)
                  setfflag('FIntDebugTextureManagerSkipMips', 0)
                  return
              elseif str:find('highest') then
                  setfflag('DFFlagTextureQualityOverrideEnabled', true)
                  setfflag('DFIntTextureQualityOverride', 3)
                  setfflag('FIntDebugTextureManagerSkipMips', 0)
                  return
              end
              setfflag('DFFlagTextureQualityOverrideEnabled', false)
              setfflag('DFIntTextureQualityOverride', 3)
              setfflag('FIntDebugTextureManagerSkipMips', 0)
          end
      })
    end)
    
    fastflags:AddSection('Fast Flag Editor')
    
    run(function()
        spawn(function()
            task.wait(0.05)
            fastflags:AddTextBox({
                Name = 'Add New',
                Loadable = false,
                Default = isfile('Bloxstrap/cache/enteredflags.json') and readfile('Bloxstrap/cache/enteredflags.json') or nil,
                Callback = function(val)
                    if not val or val == '' then return end
                    writefile('Bloxstrap/cache/enteredflags.json', val)
                    local suc, res = pcall(function()
                        return httpservice:JSONDecode(readfile('Bloxstrap/cache/enteredflags.json'))
                    end)
                    if not suc then
                        writefile('Bloxstrap/cache/enteredflags.json', '{}')
                        error('Invalid json format')
                    end
                    for i: string, v: any in res do
                        fastflags:AddTextBox({
                            Name = i,
                            Default = v,
                            Callback = function(val)
                                if val == nil then return end
                                setfflag(i, val)
                            end
                        })
                    end
                end
            })
        end)
        fastflags:AddSection('Added FastFlags')
        
    end)
  
    run(function()
        local configvalue = 'default' :: string
        local configs = {} :: {string}
        for i: number, v: string in listfiles('Bloxstrap/modules/configuration') do
            local name = v:gsub('Bloxstrap/modules/configuration/', ''):gsub('.json', ''):gsub('/', '')
            if name == 'config.txt' or name == 'fastflags' then continue end
            configs[i] = name
        end
        
        behaviour:AddDropdown({
        
