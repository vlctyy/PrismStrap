
local cloneref = (table.find({'Xeno', 'Fluxus'}, identifyexecutor(), 1) or not cloneref) and function(ref)
    return ref
end or cloneref
local players = cloneref(game:FindService('Players')) :: Players
local httpservice = cloneref(game:FindService('HttpService')) :: HttpService
local replicatedstorage = cloneref(game:FindService('ReplicatedStorage')) :: ReplicatedStorage
local lighting = cloneref(game:FindService('Lighting')) :: Lighting
local textchat = cloneref(game:FindService('TextChatService')) :: TextChatService
local startergui = cloneref(game:FindService('StarterGui')) :: StarterGui
local coregui = cloneref(game:FindService('CoreGui')) :: CoreGui
local virtualInputManager = cloneref(game:GetService('VirtualInputManager')) :: VirtualInputManager
local inputservice = cloneref(game:FindService('UserInputService')) :: UserInputService
local lplr = players.LocalPlayer :: Player
local request = identifyexecutor() == 'Delta' and http.request or syn and syn.request or request

local loadfile = function(file, errpath)
    if getgenv().developer then
        errpath = errpath or file:gsub('bloxstrap/', '')
        return getgenv().loadfile(file, errpath)
    else
        local result = request({
            Url = `https://raw.githubusercontent.com/new-qwertyui/Bloxstrap/main/{file:gsub('bloxstrap/', '')}`,
            Method = 'GET'
        })
        if result.StatusCode ~= 404 then
            writefile(file, result.Body)
            return loadstring(result.Body)
        else
            error('Invalid file')
        end
    end
end

local realgui = Instance.new('ScreenGui', gethui())
  
local macroui = Instance.new('Frame', realgui)
macroui.BackgroundTransparency = 1
macroui.Size = UDim2.fromScale(1, 1)
macroui.Visible = false
macroui.AnchorPoint = Vector2.new(0.5, 0.5)
macroui.Position = UDim2.fromScale(0.5, 0.5)

local recordlabel = Instance.new('TextLabel', macroui)
recordlabel.Size = UDim2.fromOffset(50, 50)
recordlabel.AnchorPoint = Vector2.new(0.5, 0.1)
recordlabel.Position = UDim2.fromScale(0.5, 0.1)
recordlabel.BackgroundTransparency = 1
recordlabel.TextSize = 15
recordlabel.Font = Enum.Font.Arial
recordlabel.RichText = true
recordlabel.TextColor3 = Color3.new(1, 1, 1)
recordlabel.Text = 'Select macro\'s click position'

local getcustomasset = function(path: string)
    if not isfile(path) then
        writefile(path, game:HttpGet(`https://raw.githubusercontent.com/new-qwertyui/Bloxstrap/main/{path:gsub('bloxstrap/', '')}`))
    end
    return getgenv().getcustomasset(path)
end

print(getcustomasset('bloxstrap/images/bloxstrap.png')) --> auto installs image

local getfflag = loadfile('bloxstrap/core/getfflag.lua')()
local setfflag = loadfile('bloxstrap/core/setfflag.lua')()
local gui = loadfile(`bloxstrap/core/hook.lua`)() :: table

local run = function(func: (() -> ()))
    xpcall(func, warn)
end

local displaymessage = function(msg, color, font)
    if textchat.ChatVersion == Enum.ChatVersion.TextChatService then
        textchat.TextChannels.RBXGeneral:DisplaySystemMessage(`<font color='rgb({table.concat(color, ', ')})'>{msg}</font>`)
    else
        startergui:SetCore('ChatMakeSystemMessage', {
            Text = msg,
            Color = Color3.fromRGB(unpack(color)),
            Font = font
        })
    end
end

local bloxstrapbutton = gui:addbutton(realgui)

--> inter
run(function()
    local activity = nil
    local logjoin = nil
    activity = gui.windows.intergrations:addmodule({
        name = 'Activity',
        show = false,
        callback = function(call)
            if not call and logjoin and logjoin.toggled then
                gui:clean(logjoin.cons)
            end
        end
    })
    logjoin = activity:addtoggle({
        name = 'Log Joins',
        callback = function(call)
            activity:retoggle()
            if call then
                table.insert(logjoin.cons, players.PlayerAdded:Connect(function(v)
                    local user = v.DisplayName == v.Name and `@{v.Name}` or `{v.DisplayName} (@{v.Name})` :: string
                    displaymessage(`{user} has joined the experience.`, {255, 255, 0}, Enum.Font.BuilderSansMedium)
                end))
                table.insert(logjoin.cons, players.PlayerRemoving:Connect(function(v)
                    local user = v.DisplayName == v.Name and `@{v.Name}` or `{v.DisplayName} (@{v.Name})` :: string
                    displaymessage(`{user} has joined the experience.`, {255, 255, 0}, Enum.Font.BuilderSansMedium)
                end))
            end
        end
    })
end)

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
end)

run(function()
    local streamermode = nil
    streamermode = gui.windows.mods:addmodule({
        name = 'Streamer Mode',
        desc = 'Hides every person in-game\'s username (only works with new chat).',
        callback = function(call)
            if call then
                table.insert(streamermode.cons, coregui.ExperienceChat.appLayout.chatWindow.scrollingView.bottomLockedScrollView.RCTScrollView.RCTScrollContentView.ChildAdded:Connect(function(frame)
                    if frame:FindFirstChild('TextMessage') then
                        local text = #tostring(frame.TextMessage.PrefixText)
                        frame.TextMessage.PrefixText = tostring(math.random(2, text))
                    end
                end))
                for i, frame in coregui.ExperienceChat.appLayout.chatWindow.scrollingView.bottomLockedScrollView.RCTScrollView.RCTScrollContentView:GetChildren() do
                    if frame:FindFirstChild('TextMessage') then
                        local text = #tostring(frame.TextMessage.PrefixText)
                        frame.TextMessage.PrefixText = tostring(math.random(2, text))
                    end
                end
                table.insert(coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame.ChildAdded:Connect(function(v)
                    v.Visible = false
                end))
                for i,v in coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame:GetChildren() do
                    v.Visible = false
                end
            end
        end
    })
end)

run(function()
    local macro = nil
    local macromode = nil
    local macroshowpos = nil
    local macroname = nil
    local macrocps = nil
    
    local macroapis = {}
    
    local function addMacro(name, vec2, togglevec2)
        local toggled = false
        local togglebutton = gui:addbutton(realgui, true, UDim2.fromOffset(55, 55))
        togglebutton.Position = UDim2.fromOffset(togglevec2.X, togglevec2.Y)
        togglebutton.Text = name
        togglebutton.TextSize = 14.5
        togglebutton.TextWrapped = true
        togglebutton.MouseButton1Click:Connect(function()
            toggled = not toggled
            togglebutton.BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.new()
            if toggled then
                repeat
                    virtualInputManager:SendMouseButtonEvent(vec2.X, vec2.Y, Enum.UserInputType.MouseButton1.Value, true, lplr.PlayerGui, 1)
                    virtualInputManager:SendMouseButtonEvent(vec2.X, vec2.Y, Enum.UserInputType.MouseButton1.Value, false, lplr.PlayerGui, 1)
                    task.wait(1 / (macrocps.value or 7))
                until not toggled or not togglebutton.Parent
            end
        end)
        
        gui:setdraggable(togglebutton, gui.gui.Enabled)
        
        table.insert(macroapis, {
            toggle = togglebutton,
            button = {Destroy = function() end}
        })
    end
    macro = gui.windows.mods:addmodule({
        name = 'Macro',
        show = false
    })
    local attempted = 0
    macro:addbutton({
        name = 'Add Macro',
        callback = function()
            if macroname.value == nil then 
                gui:notify({
                    desc = 'Please make a macro name first.'
                })
                return 
            end
            macroui.Visible = true
            gui:toggle(false)
            bloxstrapbutton.Visible = false
            attempted = 1
        end
    })
    macro:addbutton({
        name = 'Reset All Macros',
        callback = function()
            for i,v in macroapis do 
                v.toggle:Destroy()
                v.button:Destroy()
            end
            table.clear(macroapis)
        end
    })
    macroshowpos = macro:addtoggle({
        name = 'Show Macro positions',
        default = true
    })
    macrocps = macro:addtextbox({
        name = 'CPS (Clicks per second)',
        number = true,
        default = 7
    })
    macroname = macro:addtextbox({
        name = 'Macro Name',
    })
    macromode = macro:adddropdown({
        name = 'Macro Mode',
        list = {'Input'},
        default = 1
    })
  
    gui.gui:GetPropertyChangedSignal('Enabled'):Connect(function()
        for i,v in macroapis do
            gui:setdraggable(v.toggle, gui.gui.Enabled)
        end
    end)
    
    local clickpos = nil
    inputservice.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if attempted == 1 then
                attempted += 1
                clickpos = input.Position
                recordlabel.Text = 'Select macro\'s click position'
            elseif attempted >= 2 then
                macroui.Visible = false
                recordlabel.Text = 'Select macro\'s toggle position'
                addMacro(macroname.value, input.Position, clickpos)
                clickpos = nil
                attempted = 0
                gui:toggle()
                bloxstrapbutton.Visible = true
            end
        end
    end)
end)

run(function()
    local crosshair = nil
    local crosshairimage = nil
    crosshair = gui.windows.mods:addmodule({
        name = 'Cross hair',
        icon = getcustomasset('bloxstrap/images/plus.png'),
        callback = function(call)
            if call then
                local imagelabel = Instance.new('ImageLabel', gui.gui)
                imagelabel.Size = UDim2.new(0, 25, 0, 25)
                imagelabel.AnchorPoint = Vector2.new(0.5, 0.5)
                imagelabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                imagelabel.BackgroundTransparency = 1
                imagelabel.Image = getcustomasset('bloxstrap/images/'..crosshairimage.value) or ''
                Instance.new('UIScale', imagelabel).Scale = gui.scale
                table.insert(crosshair.cons, imagelabel)
            end
        end
    })
    local list = {}
    for i,v in listfiles('bloxstrap/images') do
        local new = v:split('/')
        local real = new[#new]:gsub('images\\', '')
        table.insert(list, real)
    end
    crosshairimage = crosshair:adddropdown({
        name = 'Image',
        list = list,
        callback = function()
            crosshair:retoggle()
        end
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
        show = false,
        icon = getcustomasset('bloxstrap/images/camera.png'),
        callback = function(call)
            if not call and cameramodule then
                cameramodule.getRotation = old
            end
            workspace.CurrentCamera.FieldOfView = oldfov
        end
    })
    workspace.CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(function()
        workspace.CurrentCamera.FieldOfView = camerasettings.toggled and fov.value or oldfov
    end)
    fov = camerasettings:addtextbox({
        name = 'Field Of View',
        number = true,
        default = oldfov,
        callback = function(val, lost)
            --print(camerasettings.toggled, lost)
            if val and lost then
                workspace.CurrentCamera.FieldOfView = val
            end
        end
    })
    cameramodule = require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput) :: table
    old = cameramodule.getRotation
    camerasettings:addtextbox({
        name = 'Sensitivity',
        number = true,
        default = 1,
        callback = function(val, lost)
            if val and tonumber(val) and lost and camerasettings.toggled then
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
    local fontweight = nil
    local originalfonts = {}
    gamefont = gui.windows.mods:addmodule({
        name = 'Game Font',
        show = false,
        icon = getcustomasset('bloxstrap/images/fontico.png'),
        callback = function(call)
            if call and font.value ~= 'None' then
                if not font then return end
                local val = `bloxstrap/fonts/{font.value}`
                writefile(val:gsub('.ttf', '.json'):gsub('.otf', '.json'), httpservice:JSONEncode({
                    name = 'fontface',
                    faces = {
                        {
                            name = 'Regular',
                            weight = fontweight.value,
                            style = 'normal',
                            assetId = getcustomasset(val)
                        }
                    }
                }))
                local fontface = Font.new(getcustomasset(val:gsub('.ttf', '.json'):gsub('.otf', '.json')), Enum.FontWeight.Regular)
                for i: number, v: any in game:GetDescendants() do
                    if ({pcall(function() return v.Font end)})[1] then
                        table.insert(originalfonts, {Font = v.Font, UI = v})
                        v.FontFace = fontface
                        table.insert(gamefont.cons, v:GetPropertyChangedSignal('Font'):Connect(function()
                            v.FontFace = fontface
                        end))
                    end
                end
                table.insert(gamefont.cons, game.DescendantAdded:Connect(function(v)
                    if ({pcall(function() return v.Font end)})[1] then
                        table.insert(originalfonts, {Font = v.Font, UI = v})
                        v.FontFace = fontface
                        table.insert(gamefont.cons, v:GetPropertyChangedSignal('Font'):Connect(function()
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
    local list = {'None'}
    for i,v in listfiles('bloxstrap/fonts') do
        local new = v:gsub('bloxstrap/fonts/', ''):gsub('./', '')
        table.insert(list, new)
    end
    font = gamefont:adddropdown({
        name = 'Custom Font',
        list = list,
        callback = function()
            gamefont:retoggle()
        end
    })
    fontweight = gamefont:addtextbox({
        name = 'Font Weight',
        number = true,
        default = 5,
        callback = function(val)
            if not fontweight.value then
                fontweight.value = 5
            end
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
        show = false,
        icon = getcustomasset('bloxstrap/images/lighting.png'),
        callback = function(call)
            if nofog and nofog.toggled then
                lighting.FogEnd = call and 9e9 or old
            end
            if nowind and nowind.toggled then
                setfflag('FFlagGlobalWindRendering', call and not nowind.toggled or true)
                setfflag('FFlagGlobalWindActivated', call and not nowind.toggled or true)
            end
            setfflag('FFlagDebugSkyGray', call and graysky.toggled)
            if quality and quality.value then
                setfflag('FIntDebugForceMSAASamples', (call and quality.value:find('x')) and quality.value:gsub('x', '') or '0') 
            end
            local lightingmode = technology and call and technology.value:gsub(' ', '') or 'Chosen by game' :: string
            if call and lightingmode:find('Phase') then
                lightingmode = lightingmode:split('(')[1]
            end
            sethiddenproperty(lighting, 'Technology', (lightingmode == 'Chosen by game' or not call) and 'Future' or lightingmode)
            if not call then
                return
            end
            if call and inputservice.KeyboardEnabled then
                setfflag('DFFlagDebugRenderForceTechnologyVoxel', lightingmode == 'Voxel' and true or false)
                setfflag('DFFlagDebugRenderForceFutureIsBrightPhase2', lightingmode == 'ShadowMap' and true or false)
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
            gamelighting:retoggle()
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
    local noterraintextures = nil
    local texturequality = nil
    local oldlights = {}

    local oldplayertexture = getfflag('DFIntTextureCompositorActiveJobs')
    local oldterrain = getfflag('FIntTerrainArraySliceSize')
    gamegraphic = gui.windows.enginesettings:addmodule({
        name = 'Graphic',
        show = false,
        icon = getcustomasset('bloxstrap/images/graphic.png'),
        callback = function(call)
            if texturequality == nil then return end
            if call then
                if framebuffer and framebuffer.value then
                    local newval = framebuffer.value:gsub('x', '')
                    setfflag('DFIntMaxFrameBufferSize', newval)
                end
                if framerate and framerate.value and tonumber(framerate.value) then
                    framerate.value = tonumber(framerate.value)
                    setfpscap(framerate.value)
                    setfflag('DFIntTaskSchedulerTargetFps', tostring(framerate.value))
                    setfflag('FFlagDebugDisplayFPS', framerate.value >= 90 and 'true' or 'false')
                end
            end
            local lvl = texturequality.value == 'Medium' and 1 or texturequality.value == 'High' and 2 or 0 
            setfflag('DFFlagTextureQualityOverrideEnabled', (texturequality.value == 'Automatic' or not call) and false or true)
            setfflag('DFIntTextureQualityOverride', lvl)
            setfflag('FIntTerrainArraySliceSize', noterraintextures.toggled and call and 0 or oldterrain)
            setfflag('FIntDebugTextureManagerSkipMips', call and texturequality.value == 'Lowest' and 2 or 0)
            if betterlighting then
                if not call or not betterlighting.toggled then
                    for i,v in oldlights do
                        pcall(function()
                            if typeof(v) == 'Instance' then
                                v.Parent = lighting
                            else
                                lighting[i] = v
                            end
                        end)
                    end
                    table.clear(oldlights)
                    if betterlighting.toggled then
                        gui:clean(betterlighting.cons)
                    end
                else
                    for i,v in lighting:GetChildren() do
                        table.insert(oldlights, v)
                        v.Parent = replicatedstorage
                    end
                    local bloom = Instance.new('BloomEffect', lighting) :: BloomEffect
                    bloom.Intensity = 0.2
                    bloom.Size = 9e9
                    bloom.Threshold = 0.035

                    local depthoffield = Instance.new('DepthOfFieldEffect', lighting) :: DepthOfFieldEffect
                    depthoffield.FarIntensity = 7
                    depthoffield.FocusDistance = 90
                    depthoffield.InFocusRadius = 0
                    depthoffield.NearIntensity = 0
                    depthoffield.Enabled = true

                    local sunrays = Instance.new('SunRaysEffect', lighting) :: SunRaysEffect
                    sunrays.Intensity = 0.1
                    sunrays.Spread = 0.8

                    local colorcorrection = Instance.new('ColorCorrectionEffect', lighting) :: ColorCorrectionEffect
                    colorcorrection.Brightness = 0.01
                    colorcorrection.Contrast = 0.16
                    colorcorrection.Saturation = 0.15

                    table.insert(betterlighting.cons, bloom)
                    table.insert(betterlighting.cons, depthoffield)
                    table.insert(betterlighting.cons, sunrays)
                    table.insert(betterlighting.cons, colorcorrection)

                    for i,v in {'GlobalShadows', 'ExposureCompmensation', 'OutdoorAmbient', 'Technology'} do
                        pcall(function()
                            oldlights[v] = lighting[v]
                        end)
                    end

                    pcall(function() lighting.GlobalShadows = true end)
                    pcall(function() lighting.ExposureCompmensation = -0.85 end)
                    lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 45)
                    pcall(function()
                        lighting.Technology = Enum.Technology.Future
                    end)
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
    noterraintextures = gamegraphic:addtoggle({
        name = 'Disable terrain textures',
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
    texturequality = gamegraphic:adddropdown({
        name = 'Texture Quality',
        list = {'Automatic', 'Lowest', 'Low', 'Medium', 'High'},
        default = 'Automatic',
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

run(function()
    local customtopbar = nil
    local interface = nil
    local robloxmenu = ({pcall(function() return coregui.TopBarApp.UnibarLeftFrame.UnibarMenu['2']['3'] end)})[2]
    local function creategradient(parent)
        local grad = Instance.new('UIGradient', parent)
        grad.Rotation = -60
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
        })
        table.insert(customtopbar.cons, grad)
    end
    local stretchresolution = nil
    local uiscales = {}
    interface = gui.windows.enginesettings:addmodule({
        name = 'Interface Settings',
        show = false,
        icon = getcustomasset('bloxstrap/images/interface.png'),
        callback = function(call)
            if call then
                if stretchresolution.toggled then
                    for i, v in lplr.PlayerGui:GetChildren() do
                        local uiscale = Instance.new('UIScale', v)
                        uiscale.Scale = 0.74
                        table.insert(stretchresolution.cons, uiscale)
                    end
                    for i, v in coregui:GetChildren() do
                        if v.Parent ~= gui.gui then
                            local uiscale = Instance.new('UIScale', v)
                            uiscale.Scale = 0.74
                            table.insert(stretchresolution.cons, uiscale)
                        end
                    end
                end
                if customtopbar.toggled then
                    if robloxmenu.chat['5']:FindFirstChild('Badge') then
                        creategradient(robloxmenu.chat['5'].Badge)
                        robloxmenu.chat['5'].Badge.Text.TextTruncate = 'None'
                    end
                    robloxmenu.chat['5'].ChildAdded:Connect(function(v)
                        creategradient(v)
                        v.Text.TextTruncate = 'None'
                    end)
                    creategradient(robloxmenu.chat.IntegrationIconFrame.IntegrationIcon)
                    creategradient(robloxmenu.nine_dot.IntegrationIconFrame.IntegrationIcon.Close)
                    creategradient(robloxmenu.nine_dot.IntegrationIconFrame.IntegrationIcon.Overflow)
                    creategradient(coregui.TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon)
                    local topbar = lplr.PlayerGui:FindFirstChild('TopbarStandard') or lplr.PlayerGui:FindFirstChild('TopbarPlus')
                    if topbar then
                        for i,v in topbar:GetDescendants() do
                            if v.ClassName == 'ImageLabel' then
                                creategradient(v)
                            end
                        end
                    end
                end
            else
                if customtopbar == nil then return end
                gui:clean(customtopbar.cons)
                gui:clean(stretchresolution.cons)
            end
        end
    })
    customtopbar = interface:addtoggle({
        name = 'Custom Topbar',
        callback = function()
            interface:retoggle()
        end
    })
    stretchresolution = interface:addtoggle({
        name = 'Stretch resolution',
        callback = function()
            interface:retoggle()
        end
    })
end)

run(function()
    local rendering = nil
    local renderingmode = nil
    local dpiscale = nil
    local renderinggraphic = nil
    rendering = gui.windows.enginesettings:addmodule({
        name = 'Rendering',
        icon = getcustomasset('bloxstrap/images/rendering.png'),
        show = false,
        callback = function(call)
            if call and tonumber(renderinggraphic.value) then
                if tonumber(renderinggraphic.value) > 21 then
                    renderinggraphic.value = '21'
                end
                setfflag('FFlagCommitToGraphicsQualityFix', true)
                setfflag('FFlagFixGraphicsQuality', true)
                setfflag('DFIntDebugRestrictGCDistance', renderinggraphic.value)
                setfflag('DFIntDebugFRMQualityLevelOverride', renderinggraphic.value)
            end
            setfflag('DFFlagDisableDPIScale', call and dpiscale.toggled or false)
        end
    })
    renderinggraphic = rendering:addtextbox({
        name = 'Graphic quality (1 - 21)',
        callback = function()
            rendering:retoggle()
        end
    })
    dpiscale = rendering:addtoggle({
        name = 'Disable Scale Optimization', 
        callback = function()
            rendering:retoggle()
        end
    })
    renderingmode = rendering:adddropdown({
        name = 'Rendering Mode',
        list = {'Automatic'}
    })
end)

run(function()
    local general = nil
    local generalvolume = nil
    local generalingameadvertisement = nil
    local generalenablevolume = nil
    general = gui.windows.enginesettings:addmodule({
        name = 'General',
        icon = getcustomasset('bloxstrap/images/general.png'),
        show = false,
        callback = function(call)
            if call then
                if generalvolume.value ~= nil then
                    UserSettings():GetService('UserGameSettings').MasterVolume = tonumber(generalvolume.value)
                end
                setfflag('FFlagAdServiceEnabled', generalingameadvertisement.toggled)
                setfflag('FFlagDebugRomarkMockingAudioDevices', generalenablevolume.toggled)
            end
        end
    })
    generalvolume = general:addtextbox({
        name = 'Volume',
        number = true,
        callback = function(val, ca)
            if ca then
                general:retoggle()
            end
        end
    })
    generalenablevolume = general:addtoggle({
        name = 'Enable In-game volume',
        default = true,
        callback = function()
            general:retoggle()
        end
    })
    generalingameadvertisement = general:addtoggle({
        name = 'Enable In-game advertisements',
        callback = function()
            general:retoggle()
        end
    })
end)

run(function()
    local fastflageditor = nil
    local fastflags = nil
    local oldfastflagsvalues = {}
    fastflageditor = gui.windows.enginesettings:addmodule({
        name = 'FastFlag Editor',
        icon = getcustomasset('bloxstrap/images/flag.png'),
        show = false,
        callback = function()
            
        end
    })
    fastflags = fastflageditor:addtextbox({
        name = 'FastFlags',
        callback = function(a, b)
            if b then
                local suc, oldfflag = pcall(function()
                    return httpservice:JSONDecode(readfile('bloxstrap/logs/fastflags.json'))
                end)
                if not suc then
                    oldfflag = {}
                end
                for i,v in httpservice:JSONDecode(a) do
                    oldfflag[i] = v
                end
                for i,v in oldfflag do
                    setfflag(i,v)
                    fastflageditor:addtextbox({
                        name = tostring(i),
                        default = tostring(v),
                        callback = function(val, lost)
                            if lost then
                                setfflag(i, val)
                            end
                        end
                    })
                end
                writefile('bloxstrap/logs/fastflags.json', httpservice:JSONEncode(oldfflag))
                if not getgenv().noshow then
                    gui:notify({
                        desc = 'Loaded fflags'
                    })
                end
            end
        end
    })
end)

run(function()
    local button = bloxstrapbutton

    local imagelabel = Instance.new('ImageLabel', button) :: ImageLabel
    imagelabel.Size = UDim2.new(0, 22, 0, 22)
    imagelabel.Position = UDim2.new(0.25, 0, 0.25, 0)
    imagelabel.BackgroundTransparency = 1
    imagelabel.Image = getcustomasset('bloxstrap/images/bloxstrap.png')
    imagelabel.ImageColor3 = Color3.new(1, 1, 1)
    imagelabel.ZIndex = 2000

    gui.button = button

    button.MouseButton1Click:Connect(function()
        gui:toggle()
    end)

    local buttontransparency = nil
    local buttonvisibility = nil
    local buttondraggable = nil
    local legitmode = gui.windows.behaviour:addmodule({
        name = 'Legit Mode',
        show = false,
        callback = function(call)
            if call then
                if tonumber(buttontransparency.value) then
                    button.BackgroundTransparency = buttontransparency.value
                    imagelabel.ImageTransparency = buttontransparency.value
                end
            end
        end
    })
    buttontransparency = legitmode:addtextbox({
        name = 'Transparency',
        number = true,
        default = inputservice.TouchEnabled and 0 or 1,
        callback = function(val)
            if legitmode.toggled then
                button.BackgroundTransparency = val
                imagelabel.ImageTransparency = val
            end
        end
    })
    gui.windows.appearence:addmodule({
        name = 'GUI Appearence',
        default = true,
        show = false
    }):adddropdown({
        name = 'Theme',
        list = {'Fluent'},
        callback = function(val)
            if val and val:lower() ~= readfile('bloxstrap/selected.txt'):lower() then
                writefile('bloxstrap/selected.txt', val:lower())
                loadfile('bloxstrap/loader.lua')()
            end
        end
    })
end)

run(function()
    local fastflags = 0 :: number
    for i,v in httpservice:JSONDecode(readfile('bloxstrap/logs/fastflags.json')) do
        setfflag(i, v)
        fastflags += 1
    end
    if not getgenv().noshow then
        gui:notify({
            Title = 'Bloxstrap',
            Description = `Successfully loaded a total of {fastflags} fastflags.`,
            Duration = 10
        })
    end
end)

run(function()
    if not getgenv().noshow then
        gui:notify({
            Title = 'Bloxstrap',
            Description = `{inputservice.KeyboardEnabled and 'Press RShift to open the ui' or 'Press the button at the middle right to open the ui'}.`,
            Duration = 10
        })
    end   
end)

run(function()
    if coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame:FindFirstChild('p_7670822523') then
        coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame.p_7670822523.ChildrenFrame.NameFrame.BGFrame.OverlayFrame.PlayerIcon.Image = getcustomasset('bloxstrap/images/bloxstrap.png')
    end
end)

task.delay(3, function() 
    gui.configlib:loadconfig(gui) 
end)
