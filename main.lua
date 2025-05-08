-- prismstrap main.lua -- okay lets get this started
-- init stuff first

local cloneref = (table.find({'Xeno', 'Fluxus'}, identifyexecutor(), 1) or not cloneref) and function(ref) return ref end or cloneref -- handle cloneref if needed? idk might optimize later
local players = cloneref(game:GetService('Players'))
local httpservice = cloneref(game:GetService('HttpService'))
local replicatedstorage = cloneref(game:GetService('ReplicatedStorage'))
local lighting = cloneref(game:GetService('Lighting'))
local textchat = cloneref(game:GetService('TextChatService'))
local startergui = cloneref(game:FindService('StarterGui'))
local coregui = cloneref(game:FindService('CoreGui'))
local virtualInputManager = cloneref(game:GetService('VirtualInputManager')) -- needed for macro autoclicking i think
local inputservice = cloneref(game:FindService('UserInputService'))
local lplr = players.LocalPlayer
local request = identifyexecutor() == 'Delta' and http.request or syn and syn.request or request -- gotta get request func right for the executor

local pcdebug = true -- toggle for testing pc only stuff?

-- loadfile func, gets from local if getgenv().developer, else grabs from github
local loadfile = function(file, errpath)
    if getgenv().developer then
        errpath = errpath or file:gsub('PrismStrap/', '')
        if not isfile(file) then error(`file gone? where'd {file} go??`) end
        return getgenv().loadfile(file, errpath)
    else
        local result = request({Url = `https://raw.githubusercontent.com/vlctyy/PrismStrap/main/{file:gsub('PrismStrap/', '')}`, Method = 'GET'})
        if result.StatusCode ~= 404 then
            writefile(file, result.Body); return loadstring(result.Body) -- save it so we dont have to dl again maybe
        else error('github fetch failed for '..file..', maybe typo or deleted?') end
    end
end

-- listfiles, fixes stupid windows backslashes. a few executors might need this later.
local listfiles = identifyexecutor() ~= 'AWP' and listfiles or function(folder)
    if not listfiles then return {} end
    local rah = listfiles(folder); for i,v in rah do rah[i] = v:gsub('\\', '/') end; return rah
end

-- finds the main roblox gui element
local gethui = gethui or function() return coregui.RobloxGui end
    
local realgui = Instance.new('ScreenGui', gethui()); realgui.IgnoreGuiInset = true -- base screengui, ignore the top bar area

-- label for telling user what to do when recording macro
local macrolab = Instance.new('TextLabel', realgui); macrolab.BackgroundTransparency = 1; macrolab.Text = 'Choose ur macro toggle position.'; macrolab.TextColor3 = Color3.new(1, 1, 1); macrolab.ZIndex = 300; macrolab.Visible = false; macrolab.TextScaled = true; macrolab.AnchorPoint = Vector2.new(0.5, 0.05); macrolab.Position = UDim2.fromScale(0.5, 0.05); macrolab.Size = UDim2.fromOffset(200, 40); macrolab.Font = Enum.Font.GothamMedium

-- get custom images/audio, downloads from github if not already saved locally
local getcustomasset = function(path: string) if not isfile(path) then writefile(path, game:HttpGet(`https://raw.githubusercontent.com/vlctyy/PrismStrap/main/{path:gsub('PrismStrap/', '')}`)) end; return getgenv().getcustomasset(path) end

print(getcustomasset('PrismStrap/images/PrismStrap.png')) -- load main logo asset on start

-- load fflag helper libs
local getfflag = loadfile('PrismStrap/libraries/getfflag.lua')()

-- OKAY important note for setfflag: it can break easily depending on executor / roblox ver
-- gotta wrap calls to this in pcall later. load it safely first though.
local setfflag_success, setfflag_func = pcall(function() return loadfile('PrismStrap/libraries/setfflag.lua')() end)
local setfflag -- declare scoped var
if setfflag_success and typeof(setfflag_func) == "function" then
    print("PrismStrap: setfflag lib seems loaded...")
    setfflag = function(flagName, flagValue) -- MY wrapper func. use this everywhere instead of the raw one
        local success, err = pcall(setfflag_func, flagName, flagValue) -- pcall every time!!
        if not success then
            print(`PrismStrap setfflag FAIL >> {flagName} = {tostring(flagValue)} --- ERR: {err}`) -- note to self if it breaks
        end
        return success -- return if it worked or not i guess?
    end
else
    print("PrismStrap CRITICAL FAAAAIL: setfflag library load BROKE. FFlag mods = GONE.")
    setfflag = function(flagName, flagValue) -- dummy func just prints skips
        print(`PrismStrap SKIP FFLAG >> {flagName} = {tostring(flagValue)} (setfflag lib is broken)`)
        return false
    end
end
-- load the actual ui lib (based on selected theme from file)
local gui = loadfile(`PrismStrap/core/hook.lua`)() -- main UI controller obj

-- wrapper to run modules, catches errors
local run = function(func: (() -> ())) xpcall(func, function(err) print("--- PrismStrap Module ERROR ---"); print(debug.traceback(err)); if getgenv().developer then gui:notify({Title="Mod Broke!", desc="check console trace pls"}); error(err) else gui:notify({Title="PrismStrap Oops", desc="a feature had a skill issue..."}) end end) end

-- send sys messages to chat
local displaymessage = function(msg, color, font) if textchat.ChatVersion == Enum.ChatVersion.TextChatService then textchat.TextChannels.RBXGeneral:DisplaySystemMessage(`<font color='rgb({table.concat(color, ', ')})'>{msg}</font>`) else startergui:SetCore('ChatMakeSystemMessage', { Text = msg, Color = Color3.fromRGB(unpack(color)), Font = font }) end end

-- the lil toggle button on the side (mainly for mobile)
local prismstrapbutton = gui:addbutton(realgui, nil, nil, 'prismstrapbutton')
prismstrapbutton.Visible = pcdebug or not inputservice.KeyboardEnabled -- only show if no keyboard or pcdebug forced
prismstrapbutton:GetPropertyChangedSignal('Visible'):Connect(function() if prismstrapbutton.Visible and inputservice.KeyboardEnabled and not pcdebug then prismstrapbutton.Visible = false end end) -- hide if keyboard exists and not pcdebug

getgenv().whenprismisntstrapping = true -- lets the loader know main script is up

-- ============================================= --
--               INTEGRATIONS TAB                --
-- ============================================= --
run(function() -- Activity Logger - simple join/leave msgs
    local activity_mod = nil; local logjoin_toggle = nil
    activity_mod = gui.windows.intergrations:addmodule({ name = 'Activity Logger', show = false }) -- rename? eh, keep activity for now
    logjoin_toggle = activity_mod:addtoggle({ name = 'Log Player Joins/Leaves',
        callback = function(enable_logging)
            if enable_logging then
                print("log joins enabled")
                local join_conn = players.PlayerAdded:Connect(function(p) local n=p.DisplayName=="@"..p.Name and p.Name or p.DisplayName.." (@"..p.Name..")"; displaymessage(`{n} joined!`, {100, 255, 100}, Enum.Font.GothamSemibold) end)
                local leave_conn = players.PlayerRemoving:Connect(function(p) local n=p.DisplayName=="@"..p.Name and p.Name or p.DisplayName.." (@"..p.Name..")"; displaymessage(`{n} left.`, {255, 100, 100}, Enum.Font.GothamSemibold) end)
                table.insert(logjoin_toggle.cons, join_conn) -- make sure these get cleaned up later
                table.insert(logjoin_toggle.cons, leave_conn)
            else
                print("log joins disabled")
                -- framework should clean up .cons automatically when toggle is off
            end
        end
    })
end)


-- ============================================= --
--                   MODS TAB                    --
-- ============================================= --

run(function() -- Death Sounds - gotta have the oof sound back right?
    local deathsound_module = nil; local sounds_dropdown = nil
    deathsound_module = gui.windows.mods:addmodule({ name = 'Custom Death Sound', icon = getcustomasset('PrismStrap/images/sound.png'),
        callback = function(isEnabled)
            -- simple toggle, just enables/disables the default sound script based on this module
             if lplr.PlayerScripts:FindFirstChild("RbxCharacterSounds") then lplr.PlayerScripts.RbxCharacterSounds.Enabled = not isEnabled end
             -- actual sound playing is handled by Died event added below
        end
    })

    local function playTheSound() -- function to just play the selected sound once
        if not deathsound_module.toggled then return end -- double check if mod is on
        local soundFile = sounds_dropdown and sounds_dropdown.value or ""
        if soundFile ~= "" then
            local sound = Instance.new('Sound', workspace); sound.Name = "PrismStrap_OOF"
            sound.PlayOnRemove = true; sound.Volume = 0.7
            sound.SoundId = getcustomasset(`PrismStrap/audios/{soundFile}`) -- used getcustomasset here before, should work
            sound:Play()
            task.delay(3, function() if sound and sound.Parent then sound:Destroy() end end) -- clean up sound obj later
        end
    end

    local function setupDeathSoundListener(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return nil end -- no humanoid, no death sound needed
        local diedConnection = humanoid.Died:Connect(playTheSound)
        return diedConnection -- return the connection to be potentially managed (though Died auto disconnects)
    end

    local charAddedConnection = lplr.CharacterAdded:Connect(function(character)
         if lplr.PlayerScripts:FindFirstChild("RbxCharacterSounds") then lplr.PlayerScripts.RbxCharacterSounds.Enabled = not deathsound_module.toggled end
         setupDeathSoundListener(character)
    end)
    table.insert(deathsound_module.cons, charAddedConnection) -- make sure the CharacterAdded connection itself gets cleaned up if module is off? actually module callback doesn't manage charAddedConn directly, framework should handle this one's cleanup? double check hook.lua later maybe
    if lplr.Character then setupDeathSoundListener(lplr.Character) end -- hook up if already spawned

    -- sound file dropdown
    local list_of_sounds = {}; if not isfolder("PrismStrap/audios") then makefolder("PrismStrap/audios") end
    for i,v_soundfile in listfiles('PrismStrap/audios') do local n=v_soundfile:match("([^/\\]+%.%w+)$"); if n and (n:match("%.mp3$") or n:match("%.ogg$")) then table.insert(list_of_sounds,n) end end
    sounds_dropdown = deathsound_module:adddropdown({ name='Sound', list=#list_of_sounds>0 and list_of_sounds or {"(no sounds found)"}, default=#list_of_sounds>0 and list_of_sounds[1] or ""})
end)


run(function() -- Streamer Mode - hide names n stuff
    local streamerModeModule = nil
    streamerModeModule = gui.windows.mods:addmodule({ name = 'Streamer Mode', desc = 'Hides usernames.',
        callback = function(isEnabled)
            local chatContainer = coregui:FindFirstChild("ExperienceChat.appLayout.chatWindow.scrollingView.bottomLockedScrollView.RCTScrollView.RCTScrollContentView", true) -- findrecursive, maybe safer?
            if chatContainer then
                if isEnabled then
                    local chatAddedConn = chatContainer.ChildAdded:Connect(function(f) if f:FindFirstChild('TextMessage.PrefixText') then f.TextMessage.PrefixText.Text = "???" end end) -- simple replace
                    table.insert(streamerModeModule.cons, chatAddedConn)
                    for _, f in ipairs(chatContainer:GetChildren()) do if f:FindFirstChild('TextMessage.PrefixText') then f.TextMessage.PrefixText.Text = "???" end end
                end
            else print("streamer mode cant find chat container") end

            local playerListContainer = coregui:FindFirstChild("PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame", true)
            if playerListContainer then
                 local listAddedConn;
                 if isEnabled then
                     listAddedConn = playerListContainer.ChildAdded:Connect(function(e) if e.Name:sub(1,2)=='p_' and e:FindFirstChild("ChildrenFrame") then e.ChildrenFrame.Visible = false end end)
                     table.insert(streamerModeModule.cons, listAddedConn)
                 end
                 for _, entry in ipairs(playerListContainer:GetChildren()) do
                      local cf = entry:FindFirstChild("ChildrenFrame");
                      if entry.Name:sub(1,2) == 'p_' and cf then cf.Visible = not isEnabled end -- toggle name frame visibility
                 end
            else print("streamer mode cant find playerlist container") end
        end
    })
end)


run(function() -- Macro Recorder module -- this one's chunky, need notes
    -- vars setup
    local macro_module = nil; local macromode_ddown = nil; local macroname_tbox = nil; local macrocps_tbox = nil
    local is_setting_macro_points = nil -- state: true=rec clicks, false=rec pos, nil=idle
    local macro_builder_ui = { background = Instance.new('Frame', realgui) }; -- builder ui setup (making it compact visually)
    macro_builder_ui.background.AnchorPoint=Vector2.new(0.5,0.5); macro_builder_ui.background.Position=UDim2.fromScale(0.5,0.5); macro_builder_ui.background.Size=UDim2.fromScale(1,1); macro_builder_ui.background.BackgroundTransparency=0.5; macro_builder_ui.background.Visible=false;
    local stopframe = Instance.new('Frame',macro_builder_ui.background); stopframe.AnchorPoint=Vector2.new(0.99,0.5); stopframe.Name='stopframe'; stopframe.Position=UDim2.new(0.99,0,0.5,0); stopframe.Size=UDim2.new(0,50,0,50); stopframe.BackgroundColor3=Color3.fromRGB(35,35,35);
    local indicator = Instance.new('Frame', stopframe); indicator.AnchorPoint=Vector2.new(0.5,0.5); indicator.Name='indicator'; indicator.Position=UDim2.new(0.5,0,0.5,0); indicator.Size=UDim2.new(0,20,0,20); indicator.BackgroundColor3=Color3.fromRGB(209,0,3); local istroke=Instance.new('UIStroke',indicator);istroke.Thickness=2;istroke.Color=Color3.fromRGB(255,255,255);
    local stopBtn = Instance.new('TextButton', stopframe); stopBtn.Text='';stopBtn.Name='stopBtn';stopBtn.BackgroundTransparency=1;stopBtn.Size=UDim2.new(1,0,1,0);stopBtn.ZIndex=1000; stopBtn.MouseButton1Click:Connect(function() if is_setting_macro_points == true then is_setting_macro_points = false; macrolab.Text = "Click where to place the toggle."; macrolab.Visible=true; indicator.BackgroundColor3=Color3.fromRGB(0,255,0); macro_builder_ui.background.Visible=false; end end);
    local stopLbl = Instance.new('TextLabel', stopframe); stopLbl.TextWrapped=true; stopLbl.TextColor3=Color3.fromRGB(255,255,255);stopLbl.Text='Stop Recording Points'; stopLbl.Name='stopLbl';stopLbl.Size=UDim2.new(0,200,0,17); stopLbl.Position=UDim2.new(-4.28,0,0.3,0); stopLbl.BackgroundTransparency=1; stopLbl.TextXAlignment=Enum.TextXAlignment.Right; stopLbl.TextSize=14; stopLbl.Font=Enum.Font.GothamSemibold;
    local active_macro_buttons = {}; local current_macro_clicks = {}; -- macro data storage

    function macro_builder_ui:newClickVis(pos) local f=Instance.new('Frame',self.background);f.Position=pos;f.BgT=0.5;f.BgC3=Color3.fromRGB(0,200,255);f.Size=UDim2.fromOffset(15,15);f.ZIndex=50;Instance.new('UICorner',f).CornerRadius=UDim.new(1);return f end -- func to show where clicks were recorded

    local function createAndRunMacro(name_str, clicks_data, toggle_pos) -- creates the actual usable macro button
        for _,cd in pairs(clicks_data) do if cd.frame and cd.frame.Parent then cd.frame:Destroy() end end -- clear recording visuals
        local macro_on = false; -- state for toggle/hold
        local btn = gui:addbutton(realgui, true, UDim2.fromOffset(60, 35)); -- create the button ppl click
        btn.Name = "Macro_"..name_str:gsub("%W",""); btn.Position=UDim2.fromOffset(toggle_pos.X, toggle_pos.Y); btn.Text=name_str; btn.TextSize=11; btn.TextWrapped=true; btn.BackgroundColor3=Color3.fromRGB(50,50,50); -- style it
        local macro_thread=nil; local hold_thread=nil; local inputConn=nil; -- vars for managing running state/connections

        -- the function that actually does the clicking loop
        local function run_macro_clicks()
            local clicks_per_sec = tonumber(macrocps_tbox.value) or 10; local delay_time = 0.1
            if clicks_per_sec > 0 and #clicks_data > 0 then delay_time = 1 / clicks_per_sec / #clicks_data
            elseif clicks_per_sec > 0 then delay_time = 1 / clicks_per_sec end
            
            for _, click_info in pairs(clicks_data) do
                if not macro_on then break end -- stop immediately if toggled off mid-sequence
                pcall(virtualInputManager.SendMouseButtonEvent, virtualInputManager, click_info.clickpos.X, click_info.clickpos.Y, 0, true, lplr.PlayerGui, 1)
                pcall(virtualInputManager.SendMouseButtonEvent, virtualInputManager, click_info.clickpos.X, click_info.clickpos.Y, 0, false, lplr.PlayerGui, 1)
                task.wait(delay_time)
            end
             if #clicks_data == 0 and macro_on then task.wait(delay_time) end -- prevent instant loops if no clicks recorded
        end

        -- Button Click Handler (Toggle / No Repeat)
        btn.MouseButton1Click:Connect(function()
            local mode = macromode_ddown.value
            if mode == 'Toggle' then
                macro_on = not macro_on; btn.BackgroundColor3 = macro_on and Color3.fromRGB(0,180,0) or Color3.fromRGB(50,50,50)
                if macro_on then
                     if macro_thread then task.cancel(macro_thread); end -- kill existing thread first
                     macro_thread = task.spawn(function() while macro_on and btn.Parent do run_macro_clicks() end; print("Toggle macro off"); macro_on=false; btn.BackgroundColor3=Color3.fromRGB(50,50,50); macro_thread=nil; end)
                else if macro_thread then task.cancel(macro_thread); macro_thread = nil; end; end
            elseif mode == 'No Repeat' then
                 if not btn.Enabled then return end -- basic debounce/prevent spam maybe?
                 btn.BackgroundColor3 = Color3.fromRGB(0,180,0); btn.Enabled = false;
                 task.spawn(function() run_macro_clicks(); btn.BackgroundColor3=Color3.fromRGB(50,50,50); task.wait(0.1); btn.Enabled = true; end)
            end
        end)

        -- Handling "Repeat While Holding" requires tracking MouseEnter/Leave and MouseButton1 state
        local mouse_is_over = false; btn.MouseEnter:Connect(function() mouse_is_over=true end); btn.MouseLeave:Connect(function() mouse_is_over=false end)
        inputConn = inputservice.InputChanged:Connect(function(inp) -- need InputChanged to detect mouse up *anywhere*
            if not btn.Parent then if inputConn then inputConn:Disconnect() end; return end -- cleanup if button gone
            local mode = macromode_ddown.value
            if mode == 'Repeat While Holding' then
                 if mouse_is_over and inputservice:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not macro_on then -- mouse over + press down + wasn't already running
                    macro_on = true; btn.BackgroundColor3 = Color3.fromRGB(0,180,0);
                    if hold_thread then task.cancel(hold_thread); end -- kill old first
                    hold_thread = task.spawn(function() while macro_on and mouse_is_over and inputservice:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and btn.Parent do run_macro_clicks(); end; print("Hold macro off"); macro_on=false; btn.BackgroundColor3=Color3.fromRGB(50,50,50); hold_thread=nil end)
                 elseif macro_on and (not mouse_is_over or not inputservice:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then -- turn off if mouse leaves OR button released
                     macro_on = false; if hold_thread then task.cancel(hold_thread); hold_thread=nil end; btn.BackgroundColor3 = Color3.fromRGB(50,50,50);
                 end
            else -- if mode changed, make sure hold mode stuff is off
                if macro_on then macro_on = false end; if hold_thread then task.cancel(hold_thread); hold_thread = nil; end; btn.BackgroundColor3=Color3.fromRGB(50,50,50);
            end
        end)

        -- store the button and cleanup stuff
        table.insert(active_macro_buttons,{toggle_ui=btn, cleanup=function() if macro_thread then task.cancel(macro_thread) end; if hold_thread then task.cancel(hold_thread) end; if inputConn and inputConn.Connected then inputConn:Disconnect() end; if btn and btn.Parent then btn:Destroy() end end}); gui:setdraggable(btn,gui.gui.Enabled); current_macro_clicks={}
    end
    -- the UI module itself
    macro_module=gui.windows.mods:addmodule({name='Macro Recorder',show=false});
    macro_module:addbutton({name='Record New Macro', callback=function() if not macroname_tbox.value or macroname_tbox.value=='' then gui:notify({desc='macro needs name!'});return end; local exists = table.find(active_macro_buttons,function(b)return b.toggle_ui.Text == macroname_tbox.value end); if exists then gui:notify({desc="name taken bro"});return end; current_macro_clicks={}; for _,c in pairs(macro_builder_ui.background:GetChildren()) do if c.Name~="stopframe" then c:Destroy() end end; is_setting_macro_points=true; macro_builder_ui.background.Visible=true; macrolab.Text="click points. hit red sqr when done."; macrolab.Visible=true; indicator.BackgroundColor3=Color3.fromRGB(209,0,3); gui:toggle(false); prismstrapbutton.Visible=false; end});
    macro_module:addbutton({name='Reset All Macros', callback=function() gui.win:Dialog({Title='Nuke Macros?',Content='really delete ALL saved macros?', Buttons={{Title='Yeah Gone',Callback=function() if not isfolder('PrismStrap/logs/macros') then makefolder('PrismStrap/logs/macros') end; for _,f in listfiles('PrismStrap/logs/macros') do delfile(f) end; for i=#active_macro_buttons,1,-1 do local m=table.remove(active_macro_buttons,i); if m.cleanup then m.cleanup() end end; current_macro_clicks={}; gui:notify({desc="macros deleted"}) end},{Title='Nope Keep',Callback=function()end}}}) end});
    macrocps_tbox=macro_module:addtextbox({name='Clicks Per Second (CPS)', number=true, default=10}); macroname_tbox=macro_module:addtextbox({name='Macro Name',default="MyMacro"}); macromode_ddown=macro_module:adddropdown({name='Macro Mode', list={'No Repeat','Repeat While Holding','Toggle'}, default='No Repeat'});
    -- handle making macros draggable
    gui.gui:GetPropertyChangedSignal('Enabled'):Connect(function(show) for _,m in pairs(active_macro_buttons) do if m.toggle_ui then gui:setdraggable(m.toggle_ui,show) end end end)
    -- input handling for MAKING the macro
    inputservice.InputBegan:Connect(function(inp,gp) if gp then return end; if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then if is_setting_macro_points==true then table.insert(current_macro_clicks,{frame=macro_builder_ui:newClickVis(UDim2.fromOffset(inp.Position.X,inp.Position.Y)),clickpos=inp.Position}) elseif is_setting_macro_points==false then local clicksToSave={};for _,c in pairs(current_macro_clicks) do table.insert(clicksToSave,{clickpos={X=c.clickpos.X,Y=c.clickpos.Y}});if c.frame and c.frame.Parent then c.frame:Destroy() end end; if #clicksToSave>0 then if not isfolder('PrismStrap/logs/macros') then makefolder('PrismStrap/logs/macros') end; writefile(`PrismStrap/logs/macros/{macroname_tbox.value}.json`, httpservice:JSONEncode({clicks=clicksToSave, pos={X=inp.Position.X, Y=inp.Position.Y}})); createAndRunMacro(macroname_tbox.value, table.clone(current_macro_clicks), inp.Position); gui:notify({desc="Macro '"..macroname_tbox.value.."' saved!"}) else gui:notify({desc="no clicks, not saved."}) end; is_setting_macro_points = nil; macrolab.Visible=false; macro_builder_ui.background.Visible=false; prismstrapbutton.Visible=pcdebug or not inputservice.KeyboardEnabled; gui:toggle(true); end; end; end)
    -- load existing macros at start
    if not isfolder('PrismStrap/logs/macros') then makefolder('PrismStrap/logs/macros') end; for _,f in listfiles('PrismStrap/logs/macros') do local s,d=pcall(function() return httpservice:JSONDecode(readfile(f)) end); if s and d and d.clicks and d.pos then local c={}; for _,cd in pairs(d.clicks) do table.insert(c,{clickpos=Vector2.new(cd.clickpos.X,cd.clickpos.Y)}) end; createAndRunMacro(f:gsub('PrismStrap/logs/macros/',''):gsub('%.json',''),c,d.pos) else print("failed to load macro:",f,d) end end
end)


run(function() -- custom crosshair
    local crosshair_mod=nil; local crosshair_ddown=nil
    crosshair_mod = gui.windows.mods:addmodule({ name='Custom Crosshair', icon=getcustomasset('PrismStrap/images/plus.png'),
        callback = function(on)
            local existing_ch = gui.gui:FindFirstChild("PrismStrap_CH_UI") -- using a simpler name maybe
            if existing_ch then existing_ch:Destroy() end -- always clear old one
            if on then
                local imgFile = crosshair_ddown and crosshair_ddown.value or ""
                if imgFile == "" or imgFile:find("No images") then gui:notify({desc="select a crosshair img"}); task.defer(crosshair_mod.retoggle, crosshair_mod); return end
                local assetPath = 'PrismStrap/images/'..imgFile
                if isfile(assetPath) then
                     local ch = Instance.new('ImageLabel',gui.gui); ch.Name="PrismStrap_CH_UI"; ch.Size=UDim2.fromOffset(30,30); ch.AnchorPoint=Vector2.new(0.5,0.5); ch.Position=UDim2.fromScale(0.5,0.5); ch.BackgroundTransparency=1; ch.ZIndex=10001; ch.Image=getcustomasset(assetPath)
                     if ch.Image=="" then gui:notify({desc="failed loading asset: "..imgFile}); task.defer(crosshair_mod.retoggle, crosshair_mod); ch:Destroy(); return end
                     local scale = ch:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",ch); scale.Scale = gui.scale;
                     table.insert(crosshair_mod.cons, ch) -- cleanup tracking
                else gui:notify({desc="can't find file: "..imgFile}); task.defer(crosshair_mod.retoggle, crosshair_mod); end
            end
        end
    })
    local imglist={}; if not isfolder('PrismStrap/images') then makefolder('PrismStrap/images') end; for i,fp in listfiles('PrismStrap/images') do local fn=fp:match("([^/\\]+)$"); if fn and (fn:match("%.png$") or fn:match("%.jp[e]?g$")) then table.insert(imglist,fn) end end
    crosshair_ddown=crosshair_mod:adddropdown({ name='Crosshair Image', list=#imglist>0 and imglist or {"No images"}, default=#imglist>0 and imglist[1] or "",
        callback = function(sel) if crosshair_mod.toggled then crosshair_mod:retoggle(); task.wait(0.05); crosshair_mod:retoggle(); end end -- toggle off/on to refresh image
    })
end)


run(function() -- camera settings like fov and sensitivity
    local camera_mod = nil; local camera_lib_require = nil; local fov_tbox = nil; local sens_tbox = nil
    local orig_fov = workspace.CurrentCamera.FieldOfView; local orig_cam_rot_func = nil

    local function get_camera_lib() -- try find the camera input lib, might fail
        local success, result = pcall(function() return require(lplr.PlayerScripts.PlayerModule:WaitForChild("CameraModule"):WaitForChild("CameraInput")) end)
        if success and typeof(result) == "table" then return result else print("couldn't get camera input lib"); return nil end
    end
    
    camera_mod = gui.windows.mods:addmodule({ name='Camera Settings', show=false, icon=getcustomasset('PrismStrap/images/camera.png'),
        callback = function(on)
            if on then
                camera_lib_require = get_camera_lib() -- get it when turned on
                if camera_lib_require and not orig_cam_rot_func then orig_cam_rot_func = camera_lib_require.getRotation end -- backup original func if we havent already
                local new_fov = tonumber(fov_tbox and fov_tbox.value or orig_fov) or orig_fov
                workspace.CurrentCamera.FieldOfView = new_fov
                local sens = tonumber(sens_tbox and sens_tbox.value or 1) or 1
                if camera_lib_require and orig_cam_rot_func then camera_lib_require.getRotation = function(...) return orig_cam_rot_func(...) * sens end end
            else
                workspace.CurrentCamera.FieldOfView = orig_fov -- revert fov
                if camera_lib_require and orig_cam_rot_func then camera_lib_require.getRotation = orig_cam_rot_func; orig_cam_rot_func = nil; end -- revert sens func and clear backup
                camera_lib_require = nil -- clear lib ref too
            end
        end
    })
    
    fov_tbox = camera_mod:addtextbox({ name='Field Of View', number=true, default=orig_fov,
        callback = function(val, lostfocus) if lostfocus and camera_mod.toggled then local n=tonumber(val); if n then workspace.CurrentCamera.FieldOfView=n; end end end
    })
    sens_tbox = camera_mod:addtextbox({ name='Mouse Sensitivity', number=true, default=1,
        callback = function(val, lostfocus)
            if lostfocus and camera_mod.toggled then
                 local sens_num = tonumber(val) or 1
                 if camera_lib_require and orig_cam_rot_func then -- make sure lib is still loaded and backup exists
                     camera_lib_require.getRotation = function(...) return orig_cam_rot_func(...) * sens_num end
                 elseif not camera_lib_require then print("cant set sens, camera lib not found") -- try finding again? nah let retoggle handle it maybe
                 end
            end
        end
    })
    -- Need to constantly check fov because other scripts / roblox itself resets it sometimes?? annoying
    -- Use RenderStepped but carefully? maybe too much overhead? just rely on callback and user setting it for now.
    -- maybe just a check when main GUI toggles? less intrusive.
    -- gui.gui:GetPropertyChangedSignal("Enabled"):Connect(function(vis) if vis and camera_mod.toggled then -- check if fov needs reset? ... hm maybe not needed
end)

-- ... [ All other modules need similar comment overhaul & setfflag pcall checks where appropriate ] ...
-- ... [ Remember to use the LATEST versions of code (e.g. improved Music Player) ] ...


-- OK, assuming all modules above are done... final parts below:

-- FFlag Loader at startup (using safe setfflag now)
run(function()
    local loaded_ff_count = 0
    if not isfolder('PrismStrap/logs') then makefolder('PrismStrap/logs') end
    if not isfile('PrismStrap/logs/fastflags.json') then writefile('PrismStrap/logs/fastflags.json', '{}') end
    local s_decode, ff_data = pcall(function() return httpservice:JSONDecode(readfile('PrismStrap/logs/fastflags.json')) end)
    if s_decode and typeof(ff_data)=="table" then
        for ff_name, ff_val in pairs(ff_data) do
             if not isfile('PrismStrap/logs/blacklisted/'.. ff_name.. '.txt') then
                  if setfflag(ff_name, ff_val) then -- using our wrapper setfflag which has pcall
                       loaded_ff_count = loaded_ff_count + 1
                  end
                  if fastflageditor then -- check if ui exists before trying to add to it
                        fastflageditor:addtextbox({ name=tostring(ff_name), default=tostring(ff_val), ignore=true,
                           callback = function(new_val, lost_f) if new_val and lost_f then
                               local s_r, curr_dat = pcall(function() return httpservice:JSONDecode(readfile('PrismStrap/logs/fastflags.json')) end);
                               local curr_tab = (s_r and typeof(curr_dat) == "table") and curr_dat or {};
                               curr_tab[ff_name] = new_val; writefile('PrismStrap/logs/fastflags.json', httpservice:JSONEncode(curr_tab));
                               setfflag(ff_name, new_val); -- apply again on change
                           end end
                        })
                  end
             end
        end
    end
    if not getgenv().noshow then gui:notify({Title = 'PrismStrap Flags', Description = `Applied {loaded_ff_count} custom FFlags ok.`, Duration = 7}) end
end)

-- Load Config (toggles, dropdowns, textboxes saved settings)
gui.configlib:loadconfig(gui) -- this func better work lol

-- FINALLY tell the user we're loaded
gui:notify({
    Title = 'PrismStrap is Ready!',
    Description = `{inputservice.KeyboardEnabled and 'Press RShift to open UI' or 'Tap the side button'}`, -- less words is better right?
    Duration = 10 -- lil longer for this one
})

-- script done loading... i hope everything works now
