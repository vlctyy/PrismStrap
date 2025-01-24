if not isfile("Bloxstrap/FFlags.json") then writefile("Bloxstrap/FFlags.json", "[]") end
local function loadFunction(func: string) --> Automate the process of loading our functions
return loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/refs/heads/main/Main/Functions/"..func..".lua"))()
end
local loadFunc = loadFunction
local cloneref = cloneref or function(...) return ... end
local players = cloneref(game:GetService('Players'))
local lplr = cloneref(game:GetService('Players')).LocalPlayer;
local humanoid = lplr.Character:FindFirstChild('Humanoid');
local HttpService = cloneref(game.GetService(game, "HttpService"))
local UserInputService = cloneref(game.GetService(game, "UserInputService"))
local getgenv = getgenv or _G
local files: table = {};
local writefile = writefile or function(name: string, src: string): (string, string) -> ()
files[name] = src
end
local isfile: () -> () = isfile or function(file: string): (string) -> (boolean)
return readfile(file) ~= nil and true or false;
end;

if hookfunction then
    hookfunction(lplr.Kick, function(...)
        return
    end)
end

getgenv().Bloxstrap = {}
    Bloxstrap.TouchEnabled = UserInputService.TouchEnabled
    Bloxstrap.Config = setmetatable({
    OofSound = false,
    --> Engine Settings
    FPS = 120,
    AntiAliasingQuality = "Automatic",
    LightingTechnology = "Chosen by game",
    TextureQuality = "Automatic",
    DisablePlayerShadows = false,
    DisablePostFX = false,
    DisableTerrainTextures = false,
    --> Fast Flags: Unbannable
    GraySky = false,
    --> Fast Flags: Bannable
    Desync = false,
    HitregFix = false,
    customfonttoggle = false,
    customfontroblox = '',
    customtopbar = false,
    CustomFont = '',
    CameraSensitivity = 1,
    CrosshairImage = '',
    TouchUiSize = 1
}, {
    __index = function(s, i)
        s[i] = false
        return s[i]
    end
})
local conf = Bloxstrap.Config
Bloxstrap.canUpdate = false
Bloxstrap.UpdateConfig = function(obj: string, val: any)
if not Bloxstrap.canUpdate then Bloxstrap.Config = conf return end
Bloxstrap.Config[obj] = val
end
Bloxstrap.SaveConfig = function() --> Saves the config
    return writefile("Bloxstrap/Main/Configs/Default.json", HttpService:JSONEncode(Bloxstrap.Config))
end
if isfile("Bloxstrap/Main/Configs/Default.json") then
    Bloxstrap.Config = HttpService:JSONDecode(readfile("Bloxstrap/Main/Configs/Default.json"))
    conf = Bloxstrap.Config
end

local notif = function(a, b)
    cloneref(game:GetService("StarterGui")):SetCore("SendNotification", {
    	Title = 'Bloxstrap', 
    	Text = a,
    	Duration = b or 6
    })
end

Bloxstrap.error = notif

Bloxstrap.success = notif

Bloxstrap.info = notif

Bloxstrap.ToggleFFlag = loadFunc("ToggleFFlag") --> Toggle FFlag function
Bloxstrap.GetFFlag = loadFunc("GetFFlag")
Bloxstrap.start = function(vis: boolean) --> Start the script
vis = vis or true

if not vis then
    setidentity(8);
    game:GetService('CoreGui')["redz Library V5"].Enabled = false
end

getgenv().errorlog = getgenv().errorlog or "Bloxstrap/Logs/crashlog"..HttpService:GenerateGUID(false)..".txt"
local GUI: table = loadfile('Bloxstrap/Main/Functions/GuiLibrary.lua')() --> Loading the library
local main: table? = GUI:MakeWindow({ --> Create our main wibdo2
    Title = "Bloxstrap",
    SubTitle = "",
    SaveFolder = "Bloxstrap/Main/Configs"
})
main:Visible(vis)

local Integrations: tab = main:MakeTab({"Integrations", "cross"}) --> Create our tab that will allow buttons and toggles
local FastFlags: tab = main:MakeTab({"Mods", "wrench"})
local EngineSettings: tab = main:MakeTab({"Engine Settings", "flag"})
local Appearance: tab = main:MakeTab({"Appearance", "paintbrush-2"})
Appearance:AddSection('Player')
local storeeffects = {}
local isalive = function(v)
      v = v or lplr
      local a, b = pcall(function()
          return v.Character and v.Character.PrimaryPart and v.Character:FindFirstChild('Humanoid') and v.Character.Humanoid.Health > 0
      end)
      return a and b or false
end
local derendering = Appearance:AddToggle({
    Name = 'De Rendering',
    Description = 'Stops effects and player animations from rendering.',
    Default = Bloxstrap.Config.DeRendering,
    Callback = function(call)
        Bloxstrap.UpdateConfig('DeRendering', call)
        Bloxstrap.ToggleFFlag('FFlagDisablePostFx', call)
        if call then
            repeat
                for i,v in players:GetPlayers() do
                    if not isalive(lplr) then break end
                    if v ~= lplr and isalive(v) then
                        local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                        for i,v in v.Character.Humanoid:GetPlayingAnimationTracks() do
                            v:AdjustSpeed(mag <= 100 and 1 or 0)
                        end
                    end
                end
                task.wait()
            until not Bloxstrap.Config.DeRendering
        end
    end
})
pcall(function()
local camerascript = require and require(lplr.PlayerScripts.PlayerModule.CameraModule.CameraInput) or {}
local old = camerascript.getRotation
local camsensitivity = Appearance:AddSlider({
    Name = 'Camera Sensitivity',
    Min = 1,
    Max = 7,
    Increase = 0.1,
    Default = Bloxstrap.Config.CameraSensitivity,
    Callback = function(val)
        Bloxstrap.UpdateConfig('CameraSensitivity', val)
        camerascript.getRotation = function(...)
            return old(...) * val
        end
    end
})  
        end)
local funnycon
local guisets = {}
local guiscale = Appearance:AddToggle({
    Name = 'GUIScaler',
    Description = 'Decrease the roblox gui scales',
    Default = Bloxstrap.Config.GUIScale,
    Callback = function(call)
        Bloxstrap.UpdateConfig('GUIScale', call)
        if call then
            funnycon = lplr.PlayerGui.ChildAdded: Connect(function(v)
                if v.Name == 'TouchGui' then return end
                local oldui = v:FindFirstChildWhichIsA('UIScale', true)
                if oldui then
                    table.insert(guisets, {oldscale = oldui.Scale, scaler = oldui})
                    oldui.Scale = 0.5
                else
                    local uiscale = Instance.new('UIScale', v)
                    uiscale.Scale = 0.7
                    table.insert(guisets, {oldscale = 9e9, scaler = uiscale})
                end
           end)
            for i,v in lplr.PlayerGui:GetChildren() do
                if v.Name == 'TouchGui' then continue end
                local oldui = v:FindFirstChildWhichIsA('UIScale', true)
                if oldui then
                    table.insert(guisets, {oldscale = oldui.Scale, scaler = oldui})
                    oldui.Scale = 0.5
                else
                    local uiscale = Instance.new('UIScale', v)
                    uiscale.Scale = 0.7
                    table.insert(guisets, {oldscale = 9e9, scaler = uiscale})
                end
            end
            for i,v in game.CoreGui:GetChildren() do
          
                local oldui = v:FindFirstChildWhichIsA('UIScale')
                if oldui then
                    table.insert(guisets, {oldscale = oldui.Scale, scaler = oldui})
                    oldui.Scale -= 0.3
                else
                    local uiscale = Instance.new('UIScale', v)
                    uiscale.Scale = 0.7
                    table.insert(guisets, {oldscale = 9e9, scaler = uiscale})
                end
            end
        else
            pcall(function() funnycon:Disconnect() funnycon = nil end)
            for i,v in guisets do
                if v.oldscale == 9e9 then
                    v.scaler:Destroy()
                else
                    v.scaler.Scale = v.oldscale
                end
            end
            table.clear(guisets)
        end
    end
})

local touchuuval = 1.2
local touchuiscale
local touchui = Appearance:AddToggle({
    Name = 'TouchGui Size',
    Description = 'Increases your touchgui size.',
    Default = Bloxstrap.Config.TouchUI,
    Callback = function(call)
        if call then
            touchuiscale = Instance.new('UIScale', lplr.PlayerGui.TouchGui)
            touchuiscale.Scale = touchuuval
        else
            if touchuiscale then
                touchuiscale:Destroy()
                touchuiscale = nil
            end
        end
    end
})
Appearance:AddSlider({
    Name = 'Scale',
    Min = 1,
    Max = 2,
    Increase = 0.1,
    Callback = function(val)
        Bloxstrap.UpdateConfig('TouchUiSize', val)
        touchuuval = val
        if touchuiscale then
            touchuiscale.Scale = val
        end
    end
})

local chosenimage = ''
local imagelabel
local screengui = Instance.new('ScreenGui', game.CoreGui)
screengui.IgnoreGuiInset = true
local crosshaircons = {}
local crosshair = Appearance:AddToggle({
    Name = 'Crosshair',
    Default = Bloxstrap.Config.Crosshair,
    Callback = function(call)
        Bloxstrap.UpdateConfig('Crosshair', call)
        if call then
            imagelabel = Instance.new('ImageLabel', screengui)
            imagelabel.Size = UDim2.new(0, 19, 0, 19)
            imagelabel.AnchorPoint = Vector2.new(0.5, 0.5)
            imagelabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            imagelabel.BackgroundTransparency = 1
            imagelabel.Image = chosenimage
            imagelabel.Visible = true
            repeat
              task.wait()
              if not isalive() then continue end
              local mag = (lplr.Character.Head.Position - workspace.CurrentCamera.CFrame.Position).magnitude
              imagelabel.Visible = (mag <= 3)
            until not Bloxstrap.Config.Crosshair
        else
            for i,v in crosshaircons do
                crosshaircons:Disconnect()
            end
            table.clear(crosshaircons)
            if imagelabel then
                imagelabel:Destroy()
            end
        end
    end
})
Appearance:AddDropdown({
    Name = 'Image',
    Options = listfiles('Bloxstrap/Images'),
    Default = Bloxstrap.Config.CrosshairImage,
    Callback = function(val)
        Bloxstrap.UpdateConfig('CrosshairImage', val)
        chosenimage = getcustomasset(val)
        if imagelabel then
            imagelabel.Image = chosenimage
        end
    end
})
Appearance:AddSection('Customizations')
local gradients = {}
local fakerobloxbutton
pcall(function() fakerobloxbutton = Instance.new('TextButton', game:GetService('CoreGui').TopBarApp.UnibarLeftFrame)
fakerobloxbutton.BorderSizePixel = 0
fakerobloxbutton.BackgroundTransparency = 0.07
fakerobloxbutton.Text = ''
fakerobloxbutton.Name = 'funni'
fakerobloxbutton.ZIndex = 999
fakerobloxbutton.BackgroundColor3 = Color3.new()
fakerobloxbutton.Size = UDim2.new(0, 44, 0, 44)
fakerobloxbutton.Position = UDim2.new(0, -52, 0, 0)
fakerobloxbutton.Visible = false
fakerobloxbutton.MouseButton1Click:Connect(function()
    firesignal(game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.Activated)
end)

local imagelabel = Instance.new('ImageLabel', fakerobloxbutton)
imagelabel.Size = UDim2.new(0, 22, 0, 22)
imagelabel.Position = UDim2.new(0.25, 0, 0.25, 0)
imagelabel.BackgroundTransparency = 1
imagelabel.Image = getcustomasset('Bloxstrap/icon.png')
imagelabel.ImageColor3 = Color3.new(1, 1, 1)

Instance.new('UICorner', fakerobloxbutton).CornerRadius = UDim.new(1, 0) end)


local customtopbar = Appearance:AddToggle({
    Name = 'Bloxstrap Topbars',
    Description = 'Gives you a cool unique topbar.',
    Default = Bloxstrap.Config.customtopbar,
    Callback = function(call)
        game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Visible = not call
        fakerobloxbutton.Visible = call 
        Bloxstrap.UpdateConfig('customtopbar', call)
        local topbarinstances = {game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat.IntegrationIconFrame.IntegrationIcon, game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].nine_dot.IntegrationIconFrame.IntegrationIcon.Overflow, game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].nine_dot.IntegrationIconFrame.IntegrationIcon.Close, imagelabel}
        if call then
            woahwoah = game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"].ChildAdded:Connect(function(v)
                grad = Instance.new('UIGradient', v)
                grad.Rotation = -60
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
                })
                v.Text.TextColor3 = Color3.new()
                v.Text.TextTruncate = 'None'
                table.insert(gradients, grad)
            end)
            if game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"]:FindFirstChild('Badge') then
                grad = Instance.new('UIGradient', game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"]:FindFirstChild('Badge'))
                game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"]:FindFirstChild('Badge').Text.TextTruncate = 'None'
                game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"]:FindFirstChild('Badge').Text.TextColor3 = Color3.new()
                grad.Rotation = -60
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
                })
                table.insert(gradients, grad)
            end
            for i,v in topbarinstances do
                grad = Instance.new('UIGradient', v)
                grad.Rotation = 60
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
                })
                table.insert(gradients, grad)
            end
        else
            --imagelabel.Image = game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon.Image
            pcall(function() woahwoah:Disconnect() end)
            for i,v in gradients do pcall(function() v:Destroy() end) end
        end
    end
})

local rotatinghotbar = Appearance:AddToggle({
    Name = 'Spin Hotbar',
    Description = 'Spins the roblox logo around for whatever reason.',
    Default = Bloxstrap.Config.RotatingHotbar,
    Callback = function(call)
        Bloxstrap.UpdateConfig('RotatingHotbar', call)
        if call then
            repeat
                game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon.Rotation += 1.5
                imagelabel.Rotation += 1.5
                task.wait(0)
            until not Bloxstrap.Config.RotatingHotbar
        else
            game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon.Rotation = 0
            imagelabel.Rotation = 0
        end
    end
})

--> Integrations
local ActivityTracking: section = Integrations:AddSection("Activity Tracking")

--> FastFlags
local FFlagEditor: section = FastFlags:AddSection("Fast Flag Editor")
local usefilepath = false
local FFETextbox: textbox = FastFlags:AddTextBox({
    Name = "Paste Fast Flags (json)",
    Description = "Use with caution. Misusing this can lead to instability or unexpected things happening.",
    Default = readfile('Bloxstrap/FFlags.json'),
    Callback = function(call: string)
        writefile("Bloxstrap/FFlags.json", call)
        local fflags = HttpService:JSONDecode(call:gsub('"True"', "true"):gsub('"False"', "false"))
        for i,v in fflags do
            Bloxstrap.ToggleFFlag(i,v)
        end
    end
})

local Presets: section = FastFlags:AddSection("Presets: Unbannable")

local GraySky: toggle = FastFlags:AddToggle({
Name = "Gray sky",
Description = "Turns the sky gray. (Requires rejoin)",
Default = Bloxstrap.Config.GraySky,
Callback = function(callback: boolean)
    Bloxstrap.UpdateConfig("GraySky", callback)
    Bloxstrap.ToggleFFlag("FFlagDebugSkyGray", callback)
end
})

local updatedfonts: table = {};
local font: string = 'Arimo'
local fonttdropdown: dropdown
local uriekfqjkfjqekf = false
local currentcustomfont = nil
local funnycon84
local usecustomfont: toggle
local fontchanger: toggle = FastFlags:AddToggle({
    Name = 'Change Game Fonts',
    Description = 'Changes The Game font to the one you chose',
    Callback = function(call: boolean): () -> ()
    uriekfqjkfjqekf = call
    Bloxstrap.UpdateConfig('customfonttoggle', call);
    if call then
        print(currentcustomfont)
        funnycon84 = game.DescendantAdded:Connect(function(v)
            if v.ClassName and (v.ClassName == 'TextLabel' or v.ClassName == 'TextButton' or v.ClassName == 'TextBox') and uriekfqjkfjqekf and font ~= nil then
                local currfont = font
                table.insert(updatedfonts, {inst = v, font = tostring(v.Font):split('.')[3], connection = v:GetPropertyChangedSignal('Font'):Connect(function()
                if currentcustomfont then
                    v.FontFace = currentcustomfont
                else
                    v.Font = Enum.Font[currfont]
                end
                end)})
                if currentcustomfont then
                    v.FontFace = currentcustomfont
                else
                    v.Font = Enum.Font[currfont]
                end
            end
        end)
        for i,v in game:GetDescendants() do
            if v.ClassName and (v.ClassName == 'TextLabel' or v.ClassName == 'TextButton' or v.ClassName == 'TextBox') and font ~= nil then
                local currfont = font
                pcall(function() table.insert(updatedfonts, {inst = v, font = tostring(v.Font):split('.')[3], connection = v:GetPropertyChangedSignal('Font'):Connect(function()
                    if currentcustomfont then
                        v.FontFace = currentcustomfont
                    else
                        v.Font = Enum.Font[currfont]
                    end
                end)}) end)
                if currentcustomfont then
                    v.FontFace = currentcustomfont
                else
                    v.Font = Enum.Font[currfont]
                end
            end;
        end
    else
            pcall(function() funnycon84:Disconnect() end)
            for i,v in updatedfonts do
                v.connection:Disconnect()
                v.connection = nil
                v.inst.Font = Enum.Font[v.font]
            end;
            table.clear(updatedfonts);
        end
    end
})
local list: table = {}
for i,v in Enum.Font:GetEnumItems() do
    table.insert(list, tostring(v):split('.')[3]);
end
fonttdropdown = FastFlags:AddDropdown({
    Name = "Preset-Fonts",
    Description = "",
    Options = list,
    Default = Bloxstrap.Config.customfontroblox or '',
    Callback = function(qweqweq: string)
        Bloxstrap.UpdateConfig('customfontroblox', qweqweq);
    font = qweqweq
    end
})
local fontlists = {'none'}
for i,v in listfiles('Bloxstrap/Main/Fonts') do
    if v:find('.ttf') then
        table.insert(fontlists, v)
    end
end
usecustomfont = FastFlags:AddDropdown({
    Name = 'Custom Fonts',
    Options = fontlists,
    Description = 'All fonts that are inside "Bloxstrap/Main/Fonts" folder.',
    Default = Bloxstrap.Config.CustomFont,
    Callback = function(val)
        local json = val:gsub('.ttf', '.json')
        if val == 'none' then
            --pcall(delfile, json)
            currentcustomfont = nil
            return Bloxstrap.UpdateConfig('CustomFont', '')
        end
        Bloxstrap.UpdateConfig('CustomFont', val)
        --if not isfile(json) then
            writefile(json, HttpService:JSONEncode({name = 'font', faces = {
                {
                    name = 'Regular',
                    weight = 600,
                    style = 'normal',
                    assetId = getcustomasset(val)
                }
            }}))
        --end
          currentcustomfont = Font.new(getcustomasset(json), Enum.FontWeight.Regular)
          if Bloxstrap.Config.customfonttoggle then
            fontchanger:Toggle(false)
            fontchanger:Toggle(true)
          end
    end
})

fontchanger:Toggle(Bloxstrap.Config.customfonttoggle)

local Presets: section = FastFlags:AddSection("Presets: Bannable")

local Desync: toggle = FastFlags:AddToggle({
    Name = "Desync",
    Description = "Lags your character behind on other screens.",
    Default = Bloxstrap.Config.Desync,
    Callback = function(callback: boolean)
        Bloxstrap.UpdateConfig("Desync", callback)
        Bloxstrap.ToggleFFlag("DFIntS2PhysicsSenderRate", callback and 38000 or 15)
    end
})

local HitregFix: toggle = FastFlags:AddToggle({
    Name = "Hitreg Fix",
    Description = "Makes your hitreg in most games better. (reset fflags to remove)",
    Default = Bloxstrap.Config.HitregFix,
    Callback = function(callback: boolean)
        Bloxstrap.UpdateConfig("HitregFix", callback)
        local FFlags = [[
        { 
          "DFIntCodecMaxIncomingPackets": "100",
          "DFIntCodecMaxOutgoingFrames": "10000",
          "DFIntLargePacketQueueSizeCutoffMB": "1000",
          "DFIntMaxProcessPacketsJobScaling": "10000",
          "DFIntMaxProcessPacketsStepsAccumulated": "0",
          "DFIntMaxProcessPacketsStepsPerCyclic": "5000",
          "DFIntMegaReplicatorNetworkQualityProcessorUnit": "10",
          "DFIntNetworkLatencyTolerance": "1",
          "DFIntNetworkPrediction": "120",
          "DFIntOptimizePingThreshold": "50",
          "DFIntPlayerNetworkUpdateQueueSize": "20",
          "DFIntPlayerNetworkUpdateRate": "60",
          "DFIntRaknetBandwidthInfluxHundredthsPercentageV2": "10000",
          "DFIntRaknetBandwidthPingSendEveryXSeconds": "1",
          "DFIntRakNetLoopMs": "1",
          "DFIntRakNetResendRttMultiple": "1",
          "DFIntServerPhysicsUpdateRate": "60",
          "DFIntServerTickRate": "60",
          "DFIntWaitOnRecvFromLoopEndedMS": "100",
          "DFIntWaitOnUpdateNetworkLoopEndedMS": "100",
          "FFlagOptimizeNetwork": "true",
          "FFlagOptimizeNetworkRouting": "true",
          "FFlagOptimizeNetworkTransport": "true",
          "FFlagOptimizeServerTickRate": "true",
          "FIntRakNetResendBufferArrayLength": "128"
        }]]
        FFlags = HttpService:JSONDecode(FFlags:gsub('"True"', "true"):gsub('"False"', "false"))
        for i, v in FFlags do
        Bloxstrap.ToggleFFlag(i, v)
        end
    end
})

--> Engine Settings
local Presets: section = EngineSettings:AddSection("Presets")

local deathsoundConnection;
local enabled
local notified = false
local addcon = function()
    if getcustomasset == nil  then
        return
    end
    if deathsoundConnection then
        deathsoundConnection:Disconnect()
        deathsoundConnection = nil
    end
    if not lplr.Character then
        repeat task.wait() until lplr.Character
    end
    if not lplr.Character:FindFirstChild('Humanoid') then
        repeat task.wait() until lplr.Character:FindFirstChild('Humanoid')
    end
    repeat task.wait() until humanoid.Parent ~= nil
    deathsoundConnection = humanoid.HealthChanged:Connect(function()
        if humanoid.Health <= 0 then
            game:GetService("Players").LocalPlayer.PlayerScripts.RbxCharacterSounds.Enabled = false
            local sound = Instance.new("Sound", workspace)
            sound.SoundId = isfile('Bloxstrap/deathsound.mp3') and getcustomasset('Bloxstrap/deathsound.mp3') or isfile('Bloxstrap/oofsound.mp3') and getcustomasset('Bloxstrap/oofsound.mp3')
            sound.PlayOnRemove = true 
            sound.Volume = 0.5
            sound:Destroy()
        end
    end)
end
local olddeathsound: toggle = EngineSettings:AddToggle({
    Name = isfile('Bloxstrap/deathsound.mp3') and 'Use custom death sound' or 'Use old death sound',
    Description = isfile('Bloxstrap/deathsound.mp3') and 'Gives you a custom death sound.' or "Bring back the classic 'oof' death sound.",
    Default = Bloxstrap.Config.OofSound,
    Callback = function(call)
    Bloxstrap.UpdateConfig("OofSound", call)
        if call then
            addcon()
            lplr.CharacterAdded:Connect(addcon)
        else
            deathsoundConnection:Disconnect()
            deathsoundConnection = nil
        end
    end
})

lplr.CharacterAdded:Connect(function()
    if not lplr.Character then
        repeat task.wait() until lplr.Character
    end
    if not lplr.Character:FindFirstChild('Humanoid') then
        repeat task.wait() until isalive()
    end
    humanoid = lplr.Character:FindFirstChild('Humanoid')
    game:GetService("Players").LocalPlayer.PlayerScripts.RbxCharacterSounds.Enabled = true
end)

local defaultMSAA = 0
local AntiAliasingQuality: dropdown = EngineSettings:AddDropdown({
    Name = "Anti-aliasing quality (MSAA)",
    Description = "",
    Options = {"Automatic", "1x", "2x", "4x"},
    Default = Bloxstrap.Config.AntiAliasingQuality,
    Callback = function(msaa: string)
        if not UserInputService.TouchEnabled then return end
        Bloxstrap.UpdateConfig("AntiAliasingQuality", msaa)
        Bloxstrap.ToggleFFlag("FIntDebugForceMSAASamples", msaa:find("x") and msaa:gsub("x", "") or defaultMSAA)
    end
})

local shadowIntense = 1
local DisablePlayerShadows: toggle = EngineSettings:AddToggle({
    Name = "Disable player shadows",
    Description = "",
    Default = Bloxstrap.Config.DisablePlayerShadows,
    Callback = function(callback)
        Bloxstrap.UpdateConfig("DisablePlayerShadows", callback)
        Bloxstrap.ToggleFFlag("FIntRenderShadowIntensity", callback and 0 or shadowIntense)
    end
})

local disableppfx = false
local DisablePostFX: toggle = EngineSettings:AddToggle({
    Name = "Disable post-processing effects",
    Description = "",
    Default = Bloxstrap.Config.DisablePostFX,
    Callback = function(callback)
        Bloxstrap.UpdateConfig("DisablePostFX", callback)
        Bloxstrap.ToggleFFlag("FFlagDisablePostFx", callback and true or disableppfx)
    end
})

local disableterraintex = Bloxstrap.GetFFlag("FIntTerrainArraySliceSize")
local DisableTerrainTextures: toggle = EngineSettings:AddToggle({
    Name = "Disable terrain textures",
    Description = "",
    Default = Bloxstrap.Config.DisableTerrainTextures,
    Callback = function(callback)
        Bloxstrap.UpdateConfig("DisableTerrainTextures", callback)
        Bloxstrap.ToggleFFlag("FIntTerrainArraySliceSize", callback and 0 or disableterraintex)
    end
})

local origValue = Bloxstrap.GetFFlag("DFIntTaskSchedulerTargetFps")
local FramerateLimit: textbox = EngineSettings:AddTextBox({
    Name = "Framerate limit",
    Description = "Set to 0 if you want to use Roblox's native framerate unlocker.",
    Default = Bloxstrap.Config.FPS,
    Callback = function(fps: number)
        if fps == nil then return end;
        if type(fps) == "string" then fps = tonumber(fps) end;
        Bloxstrap.UpdateConfig("FPS", fps);
        Bloxstrap.ToggleFFlag('FFlagTaskSchedulerLimitTargetFpsTo2402', fps and fps >= 70)
        if fps > 0 then
            setfpscap(fps);
            Bloxstrap.ToggleFFlag("DFIntTaskSchedulerTargetFps", fps);
        else
            setfpscap(9e9);
            Bloxstrap.ToggleFFlag("DFIntTaskSchedulerTargetFps", origValue);
        end;
    end;
});
EngineSettings:AddToggle({
    Name = 'Display FPS',
    Default = Bloxstrap.Config.DisplayFPS,
    Callback = function(call)
        Bloxstrap.UpdateConfig('DisplayFPS', call)
        Bloxstrap.ToggleFFlag('FFlagDebugDisplayFPS', call);
    end
})

--local usingVoxel = Bloxstrap.GetFFlag("DFFlagDebugRenderForceTechnologyVoxel")
--local usingShadowMap = Bloxstrap.GetFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2")
--local usingFuture = Bloxstrap.GetFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3")
local function changeLighting(lighting: string)
    sethiddenproperty(game.Lighting, "Technology", lighting:find("Voxel") and "Voxel" or lighting:find("Shadow Map") and "ShadowMap" or "Future")
    if not UserInputService.TouchEnabled then
        str = lighting:lower()
        if str:find("voxel") then
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", true)
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", false)
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", false)
        return
        elseif str:find("shadow map") then
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", false)
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", true)
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", false)
        return
        elseif str:find("future") then
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", false)
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", false)
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", true)
        return
        elseif str:find("chosen") then
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", false)
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", false)
        Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", false)
        return
        end
    end
end

local PreferredLightingTechnology: dropdown = EngineSettings:AddDropdown({
    Name = "Preferred lighting technology",
    Description = "Chosen one will be force enabled in all games.",
    Options = {"Chosen by game", "Voxel (Phase 1)", "Shadow Map (Phase 2)", "Future (Phase 3)"},
    Default = Bloxstrap.Config.LightingTechnology,
    Callback = function(light: string)
        Bloxstrap.UpdateConfig("LightingTechnology", light)
        pcall(changeLighting, light)
    end
})

local textureQual = 3
local function changeTextureQuality(level: string)
    str = level:lower()
    if str:find("lowest") then
        Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
        Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 0)
        Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 2)
        return
    elseif str:find("low") then
        Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
        Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 0)
        Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
        return
    elseif str:find("medium") then
        Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
        Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 1)
        Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
        return
    elseif str:find("high") then
        Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
        Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 2)
        Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
        return
    elseif str:find("highest") then
        Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", true)
        Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", 3)
        Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
        return
    end
    Bloxstrap.ToggleFFlag("DFFlagTextureQualityOverrideEnabled", false)
    Bloxstrap.ToggleFFlag("DFIntTextureQualityOverride", textureQual)
    Bloxstrap.ToggleFFlag("FIntDebugTextureManagerSkipMips", 0)
    return
end

local TextureQuality: dropdown = EngineSettings:AddDropdown({
    Name = "Texture quality",
    Description = "",
    Options = {"Automatic", "Lowest (Requires rejoin)", "Low", "Medium", "High", "Highest"},
    Default = Bloxstrap.Config.TextureQuality,
    Callback = function(level: string)
        Bloxstrap.UpdateConfig("TextureQuality", level)
        changeTextureQuality(level)
    end
})

--> End
Bloxstrap.canUpdate = true
pcall(function()
local button = Instance.new('TextButton', game:GetService('CoreGui').TopBarApp.UnibarLeftFrame)
button.BorderSizePixel = 0
button.BackgroundTransparency = 0.07
button.Text = ''
button.BackgroundColor3 = Color3.new()
button.Size = UDim2.new(0, 44, 0, 44)
button.Position = UDim2.new(0, 103, 0, 0)

local imagelabel = Instance.new('ImageLabel', button)
imagelabel.Size = UDim2.new(0, 22, 0, 22)
imagelabel.Position = UDim2.new(0.25, 0, 0.25, 0)
imagelabel.BackgroundTransparency = 1
imagelabel.Image = getcustomasset('Bloxstrap/icon.png')
imagelabel.ImageColor3 = Color3.new(1, 1, 1)

local grad = Instance.new('UIGradient', imagelabel)
grad.Rotation = 60
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
})
grad.Enabled = game:GetService('CoreGui')["redz Library V5"].Enabled

Instance.new('UICorner', button).CornerRadius = UDim.new(1, 0)
Bloxstrap.Visible = function(callback)
    game:GetService('CoreGui')["redz Library V5"].Enabled = callback
    grad.Enabled = callback
end
button.MouseButton1Click:Connect(function()
    Bloxstrap.Visible(not grad.Enabled)
end) end)
end
return Bloxstrap
