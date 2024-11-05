local function ToggleFFlag(flag: string, value: any)
	local type = type or typeof
	if type(flag) ~= "string" then return task.spawn(error, "string expected, got "..type(flag)) end
	local FFlag: string = Bloxstrap.TouchEnabled and flag:gsub("DFInt", ""):gsub("DFFlag", ""):gsub("FFlag", ""):gsub("FInt", ""):gsub("DFString", ""):gsub("FString", "") or flag --> Removes the keyword of the FFlag, setfflag doesn't like those so we will need to remove it.
	
	if getfflag(FFlag) ~= nil then
		return setfflag(FFlag, tostring(value))
	else
		return task.spawn(error, "FFlag expected, got "..FFlag)
	end
end
return ToggleFFlag
