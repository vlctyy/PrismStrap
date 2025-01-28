local cloneref = cloneref or function(...) return ... end
local HttpService = cloneref(game.GetService(game, "HttpService"))
return function(flag: string, value: string): (string, string) -> ()
	local type = type or typeof
	flag = tostring(flag)
	local FFlag: string = cloneref(game:GetService('UserInputService')).TouchEnabled and flag:gsub("DFInt", ""):gsub("DFFlag", ""):gsub("FFlag", ""):gsub("FInt", ""):gsub("DFString", ""):gsub("FString", "") or flag --> Removes the keyword of the FFlag, setfflag doesn't like those so we will need to remove it.
	
	if getfflag(FFlag) ~= nil then
		local fflagfile = HttpService:JSONDecode(readfile("Bloxstrap/modules/configuration/fastflags.json"))
		fflagfile[flag] = tostring(value)
		writefile("Bloxstrap/modules/configuration/fastflags.json", HttpService:JSONEncode(fflagfile))
		return setfflag(FFlag, tostring(value))
	end
end;