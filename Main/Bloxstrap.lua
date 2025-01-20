if not isfile("Bloxstrap/FFlags.json") then writefile("Bloxstrap/FFlags.json", "[]") end
local function loadFunction(func: string) --> Automate the process of loading our functions
return loadstring(game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/refs/heads/main/Main/Functions/"..func..".lua"))()
end
local loadFunc = loadFunction
local cloneref = cloneref or function(...) return ... end
local players = cloneref(game.Players)
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
    CustomFont = ''
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
local GUI: table = loadFunc("GuiLibrary") --> Loading the library
local main: table? = GUI:MakeWindow({ --> Create our main wibdo2
    Title = "Bloxstrap",
    SubTitle = "Executor Edition",
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

local guisets = {}
local guiscale = Appearance:AddToggle({
    Name = 'GUIScaler',
    Description = 'Decrease the roblox gui scales',
    Default = Bloxstrap.Config.GUIScale,
    Callback = function(call)
        Bloxstrap.UpdateConfig('GUIScale', call)
        if call then
            for i,v in lplr.PlayerGui:GetChildren() do
                if v.Name == 'TouchGui' then continue end
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

Appearance:AddSection('Customizations')
local gradients = {}
local customtopbar = Appearance:AddToggle({
    Name = 'Bloxstrap Topbars',
    Description = 'Gives you a cool unique topbar.',
    Default = Bloxstrap.Config.customtopbar,
    Callback = function(call)
        Bloxstrap.UpdateConfig('customtopbar', call)
        local topbarinstances = {game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat.IntegrationIconFrame.IntegrationIcon, game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].nine_dot.IntegrationIconFrame.IntegrationIcon.Overflow, game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].nine_dot.IntegrationIconFrame.IntegrationIcon.Close, game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon}
       pcall(function() game:GetService("CoreGui").TopBarApp.UnibarLeftFrame.UnibarMenu["2"]["3"].chat["5"].Badge.Visible = not call end)
        if call then
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
            for i,v in gradients do v:Destroy() end
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
                game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon.Rotation += 1
                task.wait(0)
            until not Bloxstrap.Config.RotatingHotbar
        else
            game:GetService("CoreGui").TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon.Rotation = 0
        end
    end
})

--> Integrations
local ActivityTracking: section = Integrations:AddSection("Activity Tracking")

--> FastFlags
local FFlagEditor: section = FastFlags:AddSection("Fast Flag Editor")
local FFETextbox: textbox = FastFlags:AddTextBox({
    Name = "Paste Fast Flags (json)",
    Description = "Use with caution. Misusing this can lead to instability or unexpected things happening.",
    Default = '',
    Callback = function(call: string)
        --writefile("Bloxstrap/FFlags.json", call)
        --local fflags = HttpService:JSONDecode(call:gsub('"True"', "true"):gsub('"False"', "false"))
        local flags
        local suc, res = pcall(function()
            return HttpService:JSONDecode(readfile('Bloxstrap/FFlags.json'));
        end)
        if not suc then
            Bloxstrap.error('Failed to insert fast flags -> '..res, 10);
            return;
        end;
        local oldflags = res
        local flags = res
        local flag = HttpService:JSONDecode(call:gsub('"True"', "true"):gsub('"False"', "false"))
        if flag ~= '' then
            table.insert(flags, flag)
        end
        for i, v in flags do
            Bloxstrap.ToggleFFlag(i, v)
        end
        writefile('Bloxstrap/FFlags.json', HttpService:JSONEncode(flags));
        if oldflags:lower() ~= HttpService:JSONEncode(flags):lower() then Bloxstrap.success('Sucessfully inserted a fastflag!', 7) end
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
local filecud
local usecustomfont: toggle
local fontchanger: toggle = FastFlags:AddToggle({
    Name = 'Change Game Fonts',
    Description = 'Changes The Game font to the one you chose',
    Default = Bloxstrap.Config.customfonttoggle or false,
    Callback = function(call: boolean): () -> ()
    uriekfqjkfjqekf = call
    Bloxstrap.UpdateConfig('customfonttoggle', call);
    if call then
        game.DescendantAdded:Connect(function(v)
            if v.ClassName and (v.ClassName == 'TextLabel' or v.ClassName == 'TextButton') and uriekfqjkfjqekf and font ~= nil then
                local currfont = font
                table.insert(updatedfonts, {inst = v, font = tostring(v.Font):split('.')[3], connection = v:GetPropertyChangedSignal('Font'):Connect(function()
                v.Font = Enum.Font[currfont]
                end)})
                v.Font = Enum.Font[currfont]
            end
        end)
        for i,v in game:GetDescendants() do
            if v.ClassName and (v.ClassName == 'TextLabel' or v.ClassName == 'TextButton') and font ~= nil then
                local currfont = font
                pcall(function() table.insert(updatedfonts, {inst = v, font = tostring(v.Font):split('.')[3], connection = v:GetPropertyChangedSignal('Font'):Connect(function()
                v.Font = Enum.Font[currfont]
                end)}) end)
                v.Font = Enum.Font[currfont]
            end;
        end
    else
        for i,v in updatedfonts do
            v.connection:Disconnect()
            v.connection = nil
            task.wait();
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
usecustomfont = FastFlags:AddDropdown({
    Name = 'Custom Fonts',
    Options = listfiles('Bloxstrap/Main/Fonts'),
    Description = 'All fonts that are inside "Bloxstrap/Main/Fonts" folder.',
    Default = Bloxstrap.Config.CustomFont,
    Callback = function(val)
      
    end
})



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
            sound.SoundId =  isfile('Bloxstrap/oofsound.mp3') and getcustomasset('Bloxstrap/oofsound.mp3')
            sound.PlayOnRemove = true 
            sound.Volume = 0.5
            sound:Destroy()
        end
    end)
end
local olddeathsound: toggle = EngineSettings:AddToggle({
Name = 'Use old death sound',
Description = "Bring back the classic 'oof' death sound.",
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
        repeat task.wait() until lplr.Character:FindFirstChild('Humanoid')
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
        Bloxstrap.ToggleFFlag('FFlagDebugDisplayFPS', fps >= 70);
        if fps > 0 then
            setfpscap(fps);
            Bloxstrap.ToggleFFlag("DFIntTaskSchedulerTargetFps", fps);
        else
            setfpscap(9e9);
            Bloxstrap.ToggleFFlag("DFIntTaskSchedulerTargetFps", origValue);
        end;
    end;
});

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
local button = Instance.new('TextButton', game:GetService('CoreGui').TopBarApp.UnibarLeftFrame)
button.BorderSizePixel = 0
button.BackgroundTransparency = 0.07
button.Text = ''
button.BackgroundColor3 = Color3.new()
button.Size = UDim2.new(0, 44, 0, 44)
button.Position = UDim2.new(0, 110, 0, 0)

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
end)
end
return Bloxstrap