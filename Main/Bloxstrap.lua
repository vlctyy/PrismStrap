local function loadFunction(func: string) --> Automate the process of loading our functions
	return loadfile("Bloxstrap/Main/Functions/"..func..".lua")()
end
local loadFunc = loadFunction
local cloneref = cloneref or function(...) return ... end
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
	--> Engine Settings
	FPS = 120,
	LightingTechnology = "Chosen by game",
	TextureQuality = "Automatic",
	DisablePlayerShadows = false,
	DisablePostFX = false,
	DisableTerrainTextures = false,
	--> Fast Flags: Unbannable
	GraySky = false
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

Bloxstrap.ToggleFFlag = loadFunc("ToggleFFlag") --> Toggle FFlag function
Bloxstrap.GetFFlag = loadFunc("GetFFlag")
Bloxstrap.start = function(vis: boolean) --> Start the script
	vis = vis or true
	
	local GUI: table = loadFunc("GuiLibrary") --> Loading the library
	local main: table? = GUI:MakeWindow({ --> Create our main wibdo2
		Title = "Bloxstrap",
		SubTitle = "Mobile Edition",
		SaveFolder = "Bloxstrap/Main/Configs"
	})
	main:Visible(vis)

	local Integrations: tab = main:MakeTab({"Integrations", "cross"}) --> Create our tab that will allow buttons and toggles
	local FastFlags: tab = main:MakeTab({"FastFlags", "wrench"})
	local EngineSettings: tab = main:MakeTab({"Engine Settings", "flag"})
	local Appearance: tab = main:MakeTab({"Appearance", "paintbrush-2"})
	
	--> Integrations
	local ActivityTracking: section = Integrations:AddSection("Activity Tracking")
	
	--[[local QueryServerLocation: toggle = Integrations:AddToggle({
		Name = "Query server location",
		Description = "When in-game, you'll be able to see where your server is located via ip-api.com.",
		Default = Bloxstrap.Config.QueryServerLocation,
		Callback = function(callback)
			Bloxstrap.UpdateConfig("QueryServerLocation", callback)
		end
	})
    print(Bloxstrap.Config.QueryServerLocation)
	QueryServerLocation:Set(Bloxstrap.Config.QueryServerLocation)]]
	
	--> FastFlags
	local FFlagEditor: section = FastFlags:AddSection("Fast Flag Editor")
	local FFETextbox: textbox = FastFlags:AddTextBox({
		Name = "Paste Fast Flags (json)",
		Description = "Use with caution. Misusing this can lead to instability or unexpected things happening.",
		Default = readfile("Bloxstrap/FFlags.json"),
		Callback = function(call: string)
			writefile("Bloxstrap/FFlags.json", call)
			local fflags = HttpService:JSONDecode(call:gsub('"True"', "true"):gsub('"False"', "false"))
			for i, v in fflags do
				Bloxstrap.ToggleFFlag(i, v)
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

	local Presets: section = FastFlags:AddSection("⚠️Presets: Bannable⚠️")
	
	local Desync: toggle = FastFlags:AddToggle({
		Name = "Desync",
		Description = "Lags your character behind on other screens.",
		Default = Bloxstrap.Config.Desync,
		callback = function(callback: boolean)
			Bloxstrap.UpdateConfig("Desync", callback)
			Bloxstrap.ToggleFFlag("DFIntS2PhysicsSenderRate", callback and 38000 or 15)
		end
	})
	
	--> Engine Settings
	local Presets: section = EngineSettings:AddSection("Presets: Rendering and Graphics")
	
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
			if type(fps) == "string" then fps = tonumber(fps) end
			Bloxstrap.UpdateConfig("FPS", fps)
			if fps > 0 then
				setfpscap(fps)
				Bloxstrap.ToggleFFlag("DFIntTaskSchedulerTargetFps", fps)
			else
				setfpscap(9e9)
				Bloxstrap.ToggleFFlag("DFIntTaskSchedulerTargetFps", origValue)
			end
		end
	})
	
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
			changeLighting(light)
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
