local cloneref = (table.find({'Xeno', 'Fluxus'}, identifyexecutor(), 1) or not cloneref) and function(ref)
    return ref
end or cloneref
local players = cloneref(game:FindService('Players')) :: Players
local httpservice = cloneref(game:FindService('HttpService')) :: HttpService
local replicatedstorage = cloneref(game:FindService('ReplicatedStorage')) :: ReplicatedStorage
local lighting = cloneref(game:FindService('Lighting')) :: Lighting
local inputservice = cloneref(game:FindService('UserInputService')) :: UserInputService
local lplr = players.LocalPlayer :: Player
local request = fluxus and fluxus.request or identifyexecutor() == 'Delta' and http.request or syn and syn.request or request

local loadfile = function(file, errpath)
    if getgenv().developer then
        errpath = errpath or file:gsub('bloxstrap/', '')
        return getgenv().loadfile(file, errpath)
    else
        local result = request({
            Url = `https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/{file:gsub('bloxstrap/', '')}`,
            Method = 'GET'
        })
        if result.StatusCode ~= 404 then
            loadstring(result.Body)
        else
            error('Invalid file')
        end
    end
end

local getfflag = loadfile('bloxstrap/core/getfflag.lua')()
local setfflag = loadfile('bloxstrap/core/setfflag.lua')()
local gui = loadfile('bloxstrap/core/gui.lua')() :: table

local run = function(func: (() -> ()))
    xpcall(func, function(err)
        error(err)
    end)
end

local ipinfo = game:HttpGet('http://ip-api.com/json')
if httpservice:JSONDecode(ipinfo).country:lower() == 'ukraine' or isfile('ukraine.txt') then
    writefile('ukraine.txt', 'real')
    lplr:Kick('You are currently blacklisted from using bloxstrap')
end

local getcustomasset = function(path: string)
    if not isfile(path) then
        writefile(path, game:HttpGet(`https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/{path:gsub('bloxstrap/', '')}`))
    end
    return getgenv().getcustomasset(path)
end

--> mods

run(function()
    local deathsound = nil
    local sounds = nil
    deathsound = gui.windows.mods:addmodule({
        name = 'Death Sound',
        icon = getcustomasset('bloxstrap/images/sound.png'),
        callback = function(call)
            if call then
                pcall(function()
                    table.insert(deathsound.cons, lplr.Character.Humanoid.HealthChanged:Connect(function()
                        if lplr.Character.Humanoid.Health <= 0 then
                            lplr.PlayerScripts.RbxCharacterSounds.Enabled = false
                            local sound = Instance.new('Sound', workspace)
                            sound.PlayOnRemove = true
                            sound.Volume = 0.6
                            sound.SoundId = getcustomasset(`bloxstrap/audios/{sounds.value}`)
                            sound:Remove()
                        end
                    end))
                end)
                table.insert(deathsound.cons, lplr.CharacterAdded:Connect(function()
                    lplr.PlayerScripts.RbxCharacterSounds.Enabled = true
                    task.delay(0.6, function()
                        deathsound:retoggle()
                    end)
                end))
            end
        end
    })
    local list = {}
    for i,v in listfiles('bloxstrap/audios') do
        local new = v:gsub('bloxstrap/audios/', ''):gsub('./', '')
        table.insert(list, new)
    end
    sounds = deathsound:adddropdown({
        name = 'Sound',
        list = list
    })
    deathsound:retoggle()
end)

run(function()
    local crosshair = nil
    local crosshairimage = nil
    crosshair = gui.windows.mods:addmodule({
        name = 'Cross hair',
        icon = getcustomasset('bloxstrap/images/plus.png'),
        callback = function(call)
            if call then
                repeat task.wait() until crosshairimage
                local imagelabel = Instance.new('ImageLabel', gui.gui)
                imagelabel.Size = UDim2.new(0, 19, 0, 19)
                imagelabel.AnchorPoint = Vector2.new(0.5, 0.5)
                imagelabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                imagelabel.BackgroundTransparency = 1
                imagelabel.Image = getcustomasset('bloxstrap/images/'..crosshairimage.value) or ''
                Instance.new('UICorner', imagelabel).Scale = gui.scale
                table.insert(crosshair.cons, imagelabel)
            end
        end
    })
    local list = {}
    for i,v in listfiles('bloxstrap/images') do
        local new = v:gsub('bloxstrap/images/', ''):gsub('./', '')
        table.insert(list, new)
    end
    crosshairimage = crosshair:adddropdown({
        name = 'Image',
        list = list
    })
end)

run(function()
    local camerasettings = nil
    local cameramodule = nil
    local fov = nil
    local old = nil
    local oldfov = workspace.CurrentCamera.FieldOfView
    camerasettings = gui.windows.mods:addmodule({
        name = 'Camera',
        icon = getcustomasset('bloxstrap/images/camera.png'),
        callback = function(call)
            if not call and cameramodule then
                cameramodule.getRotation = old
            end
        end
    })
    fov = camerasettings:addtextbox({
        name = 'Field Of View',
        number = true,
        callback = function(val, lost)
            if val and lost and camerasettings.enabled then
                workspace.CurrentCamera.FieldOfView = val
            end
        end
    })
    workspace.CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(function()
        workspace.CurrentCamera.FieldOfView = camerasettings.enabled and fov.value or oldfov
    end)
    cameramodule = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput) :: table
    old = cameramodule.getRotation
    camerasettings:addtextbox({
        name = 'Sensitivity',
        number = true,
        callback = function(val, lost)
            if val and lost and camerasettings.enabled then
                cameramodule.getRotation = function(...)
                    return old(...) * val
                end
            end
        end
    })
end)

run(function()
    local gamefont = nil
    local font = nil
    local originalfonts = {}
    gamefont = gui.windows.mods:addmodule({
        name = 'Game Font',
        icon = getcustomasset('bloxstrap/images/fontico.png'),
        callback = function(call)
            if call then
                if not font then return end
                local val = `bloxstrap/fonts/{font.value}`
                print(val)
                writefile(val:gsub('.ttf', '.json'), httpservice:JSONEncode({
                    name = 'fontface',
                    faces = {
                        {
                            name = 'Regular',
                            weight = 50,
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
                        table.insert(gamefont.cons, v:GetPropertyChangedSignal('FontFace'):Connect(function()
                            v.FontFace = fontface
                        end))
                    end
                end
                table.insert(gamefont.cons, game.DescendantAdded:Connect(function(v)
                    if v.ClassName and v.ClassName:find('Text') and ({pcall(function() return v.Font end)})[1] then
                        table.insert(originalfonts, {Font = v.Font, UI = v})
                        v.FontFace = fontface
                        table.insert(gamefont.cons, v:GetPropertyChangedSignal('FontFace'):Connect(function()
                            v.FontFace = fontface
                        end))
                    end
                end))
            else
                for i,v in originalfonts do
                    pcall(function()
                        v.UI.Font = v.Font
                    end)
                end
                table.clear(originalfonts)
            end
        end
    })
    local list = {}
    for i,v in listfiles('bloxstrap/fonts') do
        local new = v:gsub('bloxstrap/fonts/', ''):gsub('./', '')
        table.insert(list, new)
    end
    font = gamefont:adddropdown({
        name = 'Font',
        list = list,
        callback = function()
            gamefont:retoggle()
        end
    })
end)

run(function()
    local gamelighting = nil
    local nofog = nil
    local nowind = nil
    local graysky = nil
    local quality = nil
    local technology = nil
    local old = lighting.FogEnd
    gamelighting = gui.windows.mods:addmodule({
        name = 'Lighting',
        icon = getcustomasset('bloxstrap/images/lighting.png'),
        callback = function(call)
            if nofog and nofog.toggled then
                lighting.FogEnd = call and 9e9 or old
            end
            if nowind and nowind.toggled then
                setfflag('FFlagGlobalWindRendering', call and not nowind.toggled)
                setfflag('FFlagGlobalWindActivated', call and not nowind.toggled)
            end
            if graysky and graysky.toggled then
                setfflag('FFlagDebugSkyGray', call)
            end
            if quality and quality.value then
                setfflag('FIntDebugForceMSAASamples', (call and quality.value:find('x')) and quality.value:gsub('x', '') or '0') 
            end
            local lightingmode = technology and call and technology.value:gsub(' ', '') or 'Chosen by game' :: string
            if call and lightingmode:find('Phase') then
                print('wow')
                lightingmode = lightingmode:split('(')[1]
            end
            sethiddenproperty(lighting, 'Technology', (lightingmode == 'Chosen by game' or not call) and 'Future' or lightingmode)
            if not call then
                return
            end
            if call and inputservice.KeyboardEnabled then
                setfflag('DFFlagDebugRenderForceTechnologyVoxel', lightingmode == 'Voxel' and true or false)
                setfflag('DFFlagDebugRenderForceFutureIsBrightPhase2', lightingmode == 'Shadow Map' and true or false)
                setfflag('DFFlagDebugRenderForceFutureIsBrightPhase3', lightingmode == 'Future' and true or false)
            end
        end
    })
    nofog = gamelighting:addtoggle({
        name = 'No Fog',
        callback = function()
            gamelighting:retoggle()
        end
    })
    nowind = gamelighting:addtoggle({
        name = 'No Wind',
        callback = function()
            gamelighting:addtoggle()
        end
    })
    graysky = gamelighting:addtoggle({
        name = 'Gray sky',
        callback = function()
            gamelighting:retoggle()
        end
    })
    technology = gamelighting:adddropdown({
        name = 'Lighting Technology',
        list = {'Chosen by game', 'Voxel (Phase 1)', 'Shadow Map (Phase 2)', 'Future (Phase 3)'},
        callback = function()
            gamelighting:retoggle()
        end
    })
    quality = gamelighting:adddropdown({  
        name = 'Anti-aliasing quality (MSAA)',
        list = {'Automatic', '1x', '2x', '4x'},
        callback = function()
            gamelighting:retoggle()
        end
    })
end)

run(function()
    local gamegraphic = nil
    local noplrshadow = nil
    local nopostingeffects = nil
    local noplrtexture = nil
    local framebuffer = nil
    local framerate = nil
    local betterlighting = nil
    local oldlights = {}

    local oldplayertexture = getfflag('DFIntTextureCompositorActiveJobs')
    gamegraphic = gui.windows.enginesettings:addmodule({
        name = 'Graphic',
        icon = getcustomasset('bloxstrap/images/graphic.png'),
        callback = function(call)
            if call then
                if framebuffer and framebuffer.value then
                    local newval = framebuffer.value:gsub('x', '')
                    setfflag('DFIntMaxFrameBufferSize', newval)
                end
                if framerate and framerate.value then
                    framerate.value = tonumber(framerate.value)
                    setfpscap(framerate.value)
                    setfflag('DFIntTaskSchedulerTargetFps', tostring(framerate.value))
                    setfflag('FFlagDebugDisplayFPS', framerate.value >= 90 and 'true' or 'false')
                end
            end
            if betterlighting then
                if not call or not betterlighting.toggled then
                    for i,v in oldlights do
                        if typeof(v) == 'Instance' then
                            v.Parent = lighting
                        else
                            lighting[i] = v
                        end
                    end
                    table.clear(oldlights)
                else
                    for i,v in lighting:GetChildren() do
                        table.insert(oldlights, v)
                        v.Parent = replicatedstorage
                    end
                    local Bloom = Instance.new('BloomEffect', lighting)
                    Bloom.Intensity = 0.2
                    Bloom.Size = 9e9
                    Bloom.Threshold = 0.035

                    local DepthOfField = Instance.new('DepthOfFieldEffect', lighting)  
                    DepthOfField.FarIntensity = 7
                    DepthOfField.FocusDistance = 90
                    DepthOfField.InFocusRadius = 0
                    DepthOfField.NearIntensity = 0
                    DepthOfField.Enabled = true

                    local SunRays = Instance.new('SunRaysEffect', lighting)
                    SunRays.Intensity = 0.1
                    SunRays.Spread = 0.8

                    local ColorCorrection = Instance.new('ColorCorrectionEffect', lighting)
                    ColorCorrection.Brightness = 0.01
                    ColorCorrection.Contrast = 0.16
                    ColorCorrection.Saturation = 0.15

                    table.insert(betterlighting.cons, Bloom)
                    table.insert(betterlighting.cons, DepthOfField)
                    table.insert(betterlighting.cons, SunRays)
                    table.insert(betterlighting.cons, ColorCorrection)

                    for i,v in {'GlobalShadows', 'ExposureCompmensation', 'OutdoorAmbient', 'Technology'} do
                        pcall(function()
                            oldlights[v] = lighting[v]
                        end)
                    end

                    pcall(function() lighting.GlobalShadows = true end)
                    pcall(function() lighting.ExposureCompmensation = -0.85 end)
                    lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 45)
                    lighting.Technology = Enum.Technology.Future
                end
            end
            if noplrtexture then
                setfflag('DFIntTextureCompositorActiveJobs', call and noplrtexture and noplrtexture.toggled and 0 or oldplayertexture)
            end
            if nopostingeffects then
                setfflag('FFlagDisablePostFx', call and nopostingeffects.toggled and true or false)
            end
            if noplrshadow then
                setfflag('FIntRenderShadowIntensity', call and noplrshadow.toggled and 0 or 1)
            end
        end
    })
    betterlighting = gamegraphic:addtoggle({
        name = 'Better Lighting',
        callback = function()
            gamegraphic:retoggle()
        end
    })
    noplrtexture = gamegraphic:addtoggle({
        name = 'Disable player textures',
        callback = function()
            gamegraphic:retoggle()
        end
    })
    nopostingeffects = gamegraphic:addtoggle({
        name = 'Disable post-processing effects',
        callback = function()
            gamegraphic:retoggle()
        end
    })
    noplrshadow = gamegraphic:addtoggle({
        name = 'Disable player shadows',
        callback = function()
            gamegraphic:retoggle()
        end
    })
    framebuffer = gamegraphic:adddropdown({
        name = 'Frame Buffer',
        list = {'1x', '2x', '3x', '4x', '10x'},
        default = '4x',
        callback = function()
            gamegraphic:retoggle()
        end
    })
    framerate = gamegraphic:addtextbox({
        name = 'Framerate limit',
        number = true,
        default = 240,
        callback = function(val, lost)
            if lost then
                gamegraphic:retoggle()
            end
        end
    })
end)