local function loadFunction(func: string) --> Automate the process of loading our functions
	return loadfile("Bloxstrap/Main/Functions/"..func..".lua")()
end
local loadFunc = loadFunction
local cloneref = cloneref or function(...) return ... end
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

getgenv().Bloxstrap = {}
Bloxstrap.TouchEnabled = UserInputService.TouchEnabled
Bloxstrap.Config = {
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
	HitregFix = false
}
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
--> pasted from gui2lua :WHAT:
local notifisholder = Instance.new("Frame", game.Players.LocalPlayer.PlayerGui:FindFirstChildWhichIsA('ScreenGui'));
notifisholder.BackgroundTransparency = 1
notifisholder.BorderSizePixel = 0
notifisholder.Position = UDim2.new(0.463240534, 0, 0.021327015, 0)
notifisholder.Size = UDim2.new(0, 100, 0, 100)

local UIListLayout = Instance.new("UIListLayout", notifisholder)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

Bloxstrap.error = function(desc: string, duration: number): (string, number) -> ()
	local alert = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local ImageLabel = Instance.new("ImageLabel")
	local TextLabel = Instance.new("TextLabel")
	alert.Name = "alert"
	alert.Parent = notifisholder
	alert.BackgroundColor3 = Color3.new(0.976471, 0.34902, 0.34902)
	alert.BorderColor3 = Color3.new(0, 0, 0)
	alert.BorderSizePixel = 0
	alert.Position = UDim2.new(-0.75, 0, 0.0399999991, 0)
	alert.Size = UDim2.new(0, 273, 0, 43)

	UICorner.Parent = alert
	UICorner.CornerRadius = UDim.new(0, 13)

	ImageLabel.Parent = alert
	ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.BorderColor3 = Color3.new(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.0480000004, 0, 0.209302321, 0)
	ImageLabel.Size = UDim2.new(0, 25, 0, 25)
	ImageLabel.Image = "rbxassetid://76328231059742"

	TextLabel.Parent = ImageLabel
	TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	TextLabel.BackgroundTransparency = 1
	TextLabel.BorderColor3 = Color3.new(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Size = UDim2.new(0, 176, 0, 25)
	TextLabel.Position = UDim2.new(1.55, 0, 0.04, 0)
	TextLabel.Font = Enum.Font.GothamMedium
	TextLabel.Text = desc
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.TextSize = 14
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	local textsize = game:GetService('TextService'):GetTextSize(desc, 14, Enum.Font.GothamMedium, Vector2.new(1000000, 1000000));
	alert.Size = UDim2.new(0, textsize.X + 80, 0, 43)


	task.delay(duration or 5, function()
		alert:Destroy();
	end)
end

Bloxstrap.success = function(desc, duration)
	local alert = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local ImageLabel = Instance.new("ImageLabel")
	local TextLabel = Instance.new("TextLabel")
	alert.Name = "alert"
	alert.Parent = notifisholder
	alert.BackgroundColor3 = Color3.new(0.254902, 0.8, 0.309804)
	alert.BorderColor3 = Color3.new(0, 0, 0)
	alert.BorderSizePixel = 0
	alert.Position = UDim2.new(-0.75, 0, 0.0399999991, 0)
	alert.Size = UDim2.new(0, 273, 0, 43)

	UICorner.Parent = alert
	UICorner.CornerRadius = UDim.new(0, 13)

	ImageLabel.Parent = alert
	ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.BorderColor3 = Color3.new(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.0480000004, 0, 0.209302321, 0)
	ImageLabel.Size = UDim2.new(0, 25, 0, 25)
	ImageLabel.Image = "rbxassetid://18954559468"

	TextLabel.Parent = ImageLabel
	TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	TextLabel.BackgroundTransparency = 1
	TextLabel.BorderColor3 = Color3.new(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Size = UDim2.new(0, 176, 0, 25)
	TextLabel.Position = UDim2.new(1.55, 0, 0.04, 0)
	TextLabel.Font = Enum.Font.GothamMedium
	TextLabel.Text = desc
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.TextSize = 14
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	local textsize = game:GetService('TextService'):GetTextSize(desc, 14, Enum.Font.GothamMedium, Vector2.new(1000000, 1000000));
	alert.Size = UDim2.new(0, textsize.X + 80, 0, 43)


	task.delay(duration or 5, function()
		alert:Destroy();
	end)
end

Bloxstrap.info = function(desc: string, duration: number): (string, number) -> ()
	local alert = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local ImageLabel = Instance.new("ImageLabel")
	local TextLabel = Instance.new("TextLabel")
	alert.Name = "alert"
	alert.Parent = notifisholder
	alert.BackgroundColor3 = Color3.new(0.215686, 0.521569, 0.87451)
	alert.BorderColor3 = Color3.new(0, 0, 0)
	alert.BorderSizePixel = 0
	alert.Position = UDim2.new(-0.75, 0, 0.0399999991, 0)
	alert.Size = UDim2.new(0, 273, 0, 43)

	UICorner.Parent = alert
	UICorner.CornerRadius = UDim.new(0, 13)

	ImageLabel.Parent = alert
	ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.BorderColor3 = Color3.new(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.0480000004, 0, 0.209302321, 0)
	ImageLabel.Size = UDim2.new(0, 25, 0, 25)
	ImageLabel.Image = "rbxassetid://18954541090"

	TextLabel.Parent = ImageLabel
	TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
	TextLabel.BackgroundTransparency = 1
	TextLabel.BorderColor3 = Color3.new(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Size = UDim2.new(0, 176, 0, 25)
	TextLabel.Position = UDim2.new(1.55, 0, 0.04, 0)
	TextLabel.Font = Enum.Font.GothamMedium
	TextLabel.Text = desc
	TextLabel.TextColor3 = Color3.new(1, 1, 1)
	TextLabel.TextSize = 14
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left

	local textsize = game:GetService('TextService'):GetTextSize(desc, 14, Enum.Font.GothamMedium, Vector2.new(1000000, 1000000));
	alert.Size = UDim2.new(0, textsize.X + 80, 0, 43)


	task.delay(duration or 5, function()
		alert:Destroy();
	end)
end;

if getgenv().showlocation then
	local json = game:GetService("HttpService"):JSONDecode(game:HttpGet('https://ipinfo.io/json'));
	Bloxstrap.info(`Server Located at {json.region}, {json.city}, {json.country}`, 7)
	getgenv().showlocation = nil;
end;

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
	
	--> Integrations
	local ActivityTracking: section = Integrations:AddSection("Activity Tracking")
	local teleportConnection: RBXScriptConnection;
	local queueteleport = queueonteleport or queue_on_teleport or syn and syn.queue_on_teleport or nil
	local QueryServerLocation: toggle = Integrations:AddToggle({
		Name = "Query server location",
		Description = "When in-game, you'll be able to see where your server is located via ip-api.com,\n it would not be 100% accurate tho.",
		Default = Bloxstrap.Config.QueryServerLocation,
		Callback = function(callback)
			Bloxstrap.UpdateConfig("QueryServerLocation", callback)
			if callback then
				local json = game:GetService("HttpService"):JSONDecode(game:HttpGet('https://ipinfo.io/json'));
				Bloxstrap.info(`Server Location: {json.region}, {json.country}`, 7)
				getgenv().showlocation = nil;
			end
		end
	})
    
	QueryServerLocation:Set(Bloxstrap.Config.QueryServerLocation)
	
	--> FastFlags
	local FFlagEditor: section = FastFlags:AddSection("Fast Flag Editor")
	local FFETextbox: textbox = FastFlags:AddTextBox({
		Name = "Paste Fast Flags (json)",
		Description = "Use with caution. Misusing this can lead to instability or unexpected things happening.",
		Default = '[]',
		Callback = function(call: string)
			--writefile("Bloxstrap/FFlags.json", call)
			--local fflags = HttpService:JSONDecode(call:gsub('"True"', "true"):gsub('"False"', "false"))
			local flags
			local suc, res = pcall(function()
				return HttpService:JSONDecode(readfile('Bloxstrap/FFlags.json'));
			end)
			if not suc then
				Bloxstrap.error(res);
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
	local usecustomfont: toggle
	local fontchanger: toggle = FastFlags:AddToggle({
		Name = 'Use custom font',
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
						table.insert(updatedfonts, {inst = v, font = tostring(v.Font):split('.')[3], connection = v:GetPropertyChangedSignal('Font'):Connect(function()
							v.Font = Enum.Font[currfont]
						end)})
						v.Font = Enum.Font[currfont]
					end;
				end
			else
				for i,v in updatedfonts do
					v.connection:Disconnect()
					v.connection = nil
					v.inst.Font = Enum.Font[v.font]
				end
				table.clear(updatedfonts)
			end
		end
	})
	local list: table = {}
	for i,v in Enum.Font:GetEnumItems() do
		table.insert(list, tostring(v):split('.')[3]);
	end
	fonttdropdown = FastFlags:AddDropdown({
		Name = "Fonts",
		Description = "",
		Options = list,
		Default = Bloxstrap.Config.customfontroblox or '',
		Callback = function(qweqweq: string)
			Bloxstrap.UpdateConfig('customfontroblox', qweqweq);
			font = qweqweq
			if uriekfqjkfjqekf then
				for i,v in updatedfonts do
					v.inst.Font = Enum.Font.Arial
				end
			end
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
		if getcustomasset == nil and not notified then
			notified = true
			return Bloxstrap.error('Missing getcustomasset function', 7);
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
		print('real')
		deathsoundConnection = humanoid.HealthChanged:Connect(function()
			if humanoid.Health <= 0 then
				print('died')
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
	
	local usingVoxel = Bloxstrap.GetFFlag("DFFlagDebugRenderForceTechnologyVoxel")
	local usingShadowMap = Bloxstrap.GetFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2")
	local usingFuture = Bloxstrap.GetFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3")
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
				Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceTechnologyVoxel", usingVoxel)
				Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase2", usingShadowMap)
				Bloxstrap.ToggleFFlag("DFFlagDebugRenderForceFutureIsBrightPhase3", usingFuture)
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
end
return Bloxstrap --> Returns a table with all our functions. Feel free to add your own!
--> suck my dick nigger