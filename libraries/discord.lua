--[[
local lib = {
    spotify = {},
    rp = {}
} :: table

local request = http and http.request or request

-->>> spotify library <<<--

local function convertMs(ms)
    local z =   tonumber(string.format('%.2f', (ms / 1000)))
    local m = math.floor(z / 60)
    z = math.floor(z - (m * 60))
    if #tostring(z) < 2 then
        z = string.format("0%d", z)
    end
    return string.format("%s:%s", m, z)
end

function lib.spotify:play()
    
end

function lib.spotify:getdata(arguments)
    
end

return lib]] --> later