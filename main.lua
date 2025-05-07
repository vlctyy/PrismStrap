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

local pcdebug = true

local loadfile = function(file, errpath)
    if getgenv().developer then
        errpath = errpath or file:gsub('PrismStrap/', '')
        if not isfile(file) then
            error(`{file} not found in the workspace`)
        end
        return getgenv().loadfile(file, errpath)
    else
        local result = request({
            Url = `https://raw.githubusercontent.com/vlctyy/PrismStrap/main/{file:gsub('PrismStrap/', '')}`,
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

local listfiles = identifyexecutor() ~= 'AWP' and listfiles or function(folder)
    if not listfiles then return {} end
    local rah = listfiles(folder)
    for i,v in rah do
        rah[i] = v:gsub('\\', '/')
    end
    return rah
end

local gethui = gethui or function()
    return coregui.RobloxGui
end
    
local realgui = Instance.new('ScreenGui', gethui())
realgui.IgnoreGuiInset = true

local macrolab = Instance.new('TextLabel', realgui)
macrolab.BackgroundTransparency = 1
macrolab.Text = 'Choose ur macro toggle position.'
macrolab.TextColor3 = Color3.new(1, 1, 1)
macrolab.ZIndex = 300
macrolab.Visible = false
macrolab.TextScaled = true
macrolab.AnchorPoint = Vector2.new(0.5, 0.05)
macrolab.Position = UDim2.fromScale(0.5, 0.05)
macrolab.Size = UDim2.fromOffset(200, 40)
macrolab.Font = Enum.Font.GothamMedium

local getcustomasset = function(path: string)
    if not isfile(path) then
        writefile(path, game:HttpGet(`https://raw.githubusercontent.com/vlctyy/PrismStrap/main/{path:gsub('PrismStrap/', '')}`))
    end
    return getgenv().getcustomasset(path)
end

print(getcustomasset('PrismStrap/images/PrismStrap.png')) --> auto installs image

local getfflag = loadfile('PrismStrap/libraries/getfflag.lua')()
local setfflag = loadfile('PrismStrap/libraries/setfflag.lua')()
local gui = loadfile(`PrismStrap/core/hook.lua`)() :: table

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

local prismstrapbutton = gui:addbutton(realgui, nil, nil, 'prismstrapbutton')
prismstrapbutton.Visible = pcdebug or not inputservice.KeyboardEnabled
prismstrapbutton:GetPropertyChangedSignal('Visible'):Connect(function()
    if prismstrapbutton.Visible and inputservice.KeyboardEnabled and not pcdebug then
        prismstrapbutton.Visible = false
    end
end)

getgenv().whenprismisntstrapping = true

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
                    displaymessage(`{user} has left the experience.`, {255, 255, 0}, Enum.Font.BuilderSansMedium) -- Changed "joined" to "left"
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
        icon = getcustomasset('PrismStrap/images/sound.png'),
        callback = function(call)
            if call then
                pcall(function()
                    table.insert(deathsound.cons, lplr.Character.Humanoid.HealthChanged:Connect(function()
                        if lplr.Character.Humanoid.Health <= 0 then
                            lplr.PlayerScripts.RbxCharacterSounds.Enabled = false
                            local sound = Instance.new('Sound', workspace)
                            sound.PlayOnRemove = true
                            sound.Volume = 0.6
                            sound.SoundId = getgenv().getcustomasset(`PrismStrap/audios/{sounds.value}`)
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
    for i,v in listfiles('PrismStrap/audios') do
        local new = v:gsub('PrismStrap/audios/', ''):gsub('./', '')
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
        desc = 'Hides every person in-game\'s username.',
        callback = function(call)
            if call then
                table.insert(streamermode.cons, coregui.ExperienceChat.appLayout.chatWindow.scrollingView.bottomLockedScrollView.RCTScrollView.RCTScrollContentView.ChildAdded:Connect(function(frame)
                    if frame:FindFirstChild('TextMessage') and frame.TextMessage:FindFirstChild('PrefixText') then
                        local text = tostring(frame.TextMessage.PrefixText.ContentText)
                        frame.TextMessage.PrefixText.Text = frame.TextMessage.PrefixText.Text:gsub(text, 'None')
                    end
                end))
                for i, frame in coregui.ExperienceChat.appLayout.chatWindow.scrollingView.bottomLockedScrollView.RCTScrollView.RCTScrollContentView:GetChildren() do
                    if frame:FindFirstChild('TextMessage') and frame.TextMessage:FindFirstChild('PrefixText') then
                        local text = tostring(frame.TextMessage.PrefixText.ContentText)
                        frame.TextMessage.PrefixText.Text = frame.TextMessage.PrefixText.Text:gsub(text, 'None')
                    end
                end
                for i,v_playerlist in pairs(coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame:GetChildren()) do
                    if v_playerlist.Name:sub(1, 2) == 'p_' then
                        v_playerlist.Visible = false
                    end
                end
                table.insert(streamermode.cons, coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame.ChildAdded:Connect(function(v_playerlist_added)
                    if v_playerlist_added.Name:sub(1, 2) == 'p_' then
                        v_playerlist_added.Visible = false
                    end
                end))
            else 
                for i,v_playerlist in pairs(coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame:GetChildren()) do
                    if v_playerlist.Name:sub(1, 2) == 'p_' then
                        v_playerlist.Visible = true
                    end
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

    local settingms = nil

    local macroelements = {
        background = Instance.new('Frame', realgui)
    }

    macroelements.background.AnchorPoint = Vector2.new(0.5, 0.5)
    macroelements.background.BackgroundColor3 = Color3.new()
    macroelements.background.Position = UDim2.fromScale(0.5, 0.5)
    macroelements.background.Size = UDim2.fromScale(1, 1)
    macroelements.background.BackgroundTransparency = 0.5
    macroelements.background.Visible = false

    macroelements.stopframe = Instance.new('Frame', macroelements.background);
    macroelements.stopframe.AnchorPoint = Vector2.new(0.99000001, 0.5);
    macroelements.stopframe.Name = 'stopframe';
    macroelements.stopframe.Position = UDim2.new(0.99000001, 0, 0.5, 0);
    macroelements.stopframe.BorderColor3 = Color3.fromRGB(0, 0, 0);
    macroelements.stopframe.Size = UDim2.new(0, 50, 0, 50);
    macroelements.stopframe.BorderSizePixel = 0;
    macroelements.stopframe.BackgroundColor3 = Color3.fromRGB(35, 35, 35);


    local greenframe: Frame = Instance.new('Frame', macroelements.stopframe); -- Changed TextLabel to Frame for this element
    greenframe.BorderColor3 = Color3.fromRGB(0, 0, 0);
    greenframe.AnchorPoint = Vector2.new(0.5, 0.5);
    greenframe.Name = 'greenframe';
    greenframe.Position = UDim2.new(0.5, 0, 0.5, 0);
    greenframe.Size = UDim2.new(0, 20, 0, 20);
    greenframe.BorderSizePixel = 0;
    greenframe.BackgroundColor3 = Color3.fromRGB(209, 0, 3);


    local UIStroke: UIStroke = Instance.new('UIStroke', greenframe);
    UIStroke.Thickness = 2;
    UIStroke.LineJoinMode = Enum.LineJoinMode.Miter;
    UIStroke.Color = Color3.fromRGB(255, 255, 255);
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;


    local stopbutton: TextButton = Instance.new('TextButton', macroelements.stopframe);
    stopbutton.FontFace = Font.new('rbxasset://fonts/families/SourceSansPro.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    stopbutton.TextColor3 = Color3.fromRGB(0, 0, 0);
    stopbutton.BorderColor3 = Color3.fromRGB(0, 0, 0);
    stopbutton.Text = '';
    stopbutton.Name = 'stopbutton';
    stopbutton.BackgroundTransparency = 1;
    stopbutton.BorderSizePixel = 0;
    stopbutton.Size = UDim2.new(0, 50, 0, 50);
    stopbutton.ZIndex = 1000;
    stopbutton.TextSize = 14;
    stopbutton.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    stopbutton.MouseButton1Click:Connect(function()
        settingms = false
        macroelements.background.Visible = false
        macrolab.Visible = true
    end)

    local label: TextLabel = Instance.new('TextLabel', macroelements.stopframe);
    label.TextWrapped = true;
    label.TextColor3 = Color3.fromRGB(255, 255, 255);
    label.BorderColor3 = Color3.fromRGB(0, 0, 0);
    label.Text = 'Stop Recording';
    label.Name = 'label';
    label.Size = UDim2.new(0, 200, 0, 17);
    label.Position = UDim2.new(-4.28000021, 0, 0.3, 0);
    label.BorderSizePixel = 0;
    label.BackgroundTransparency = 1;
    label.TextXAlignment = Enum.TextXAlignment.Right;
    label.TextSize = 14;
    label.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal);
    label.TextScaled = true;
    label.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    
    local macroapis = {}

    local macros = {}

    function macroelements:new(udim2)
        local macroframe = Instance.new('Frame', self.background)
        macroframe.Position = udim2
        macroframe.BackgroundTransparency = 0.5
        macroframe.BackgroundColor3 = Color3.new()
        macroframe.Size = UDim2.fromOffset(50, 50)
        macroframe.ZIndex = 50


        local image = Instance.new('ImageLabel', macroframe)
        image.BackgroundTransparency = 1
        image.ImageColor3 = Color3.new(1, 1, 1)
        image.AnchorPoint = Vector2.new(0.5, 0.5)
        image.Size = UDim2.fromOffset(35, 35)
        image.ZIndex = 100
        image.Image = 'rbxassetid://75356581151796' -- Consider changing this asset ID if it's Bloxstrap specific
        image.Position = UDim2.fromScale(0.5, 0.5)

        local msholder = Instance.new('Frame', macroframe)
        msholder.Size = UDim2.fromOffset(42, 2)
        msholder.Name = 'MsHolder'
        msholder.BorderSizePixel = 0
        msholder.Position = UDim2.fromScale(1.16, 0.52)
        msholder.BackgroundColor3 = Color3.new(1, 1, 1)

        local msbox = Instance.new('TextBox', msholder)
        msbox.BackgroundTransparency = 1
        msbox.Position = UDim2.fromScale(0.095, -10)
        msbox.Size = UDim2.fromOffset(34, 19)
        msbox.Font = Enum.Font.GothamBold
        msbox.TextColor3 = Color3.new(1, 1, 1)
        msbox.Text = tostring(macrocps.value)
        msbox.TextScaled = true
        
        local mstext = Instance.new('TextLabel', msholder)
        mstext.BackgroundTransparency = 1
        mstext.Position = UDim2.fromScale(0.095, 1)
        mstext.Size = UDim2.fromOffset(34, 19)
        mstext.Font = Enum.Font.GothamBold
        mstext.TextColor3 = Color3.new(1, 1, 1)
        mstext.Text = 'ms'
        mstext.TextScaled = true

        Instance.new('UICorner', macroframe).CornerRadius = UDim.new(1, 0)

        return macroframe
    end

    local function getMS(ms_val) -- Renamed ms to ms_val to avoid conflict with mstext
        return ms_val > 999 and tonumber(`1.{ms_val}`) or ms_val > 9999 and tonumber(`1{ms_val:split('')[1]}.{ms_val}`) or (ms_val > 99 and tonumber(`0.{ms_val}`) or ms_val > 9 and tonumber(`0.0{ms_val}`)) or tonumber(`0.00{ms_val}`)
    end
    
    local function addMacro(name_param, positions, togglevec2) -- Renamed name to name_param
        for i,v_pos in pairs(positions) do
            if v_pos.frame and v_pos.frame.Parent then
                v_pos.frame:Destroy()
            end
        end
        local toggled = false
        local togglebutton = gui:addbutton(realgui, true, UDim2.fromOffset(55, 55))
        togglebutton.Position = UDim2.fromOffset(togglevec2.X, togglevec2.Y)
        togglebutton.Text = name_param
        togglebutton.TextSize = 14.5
        togglebutton.TextWrapped = true
        togglebutton.MouseButton1Click:Connect(function()
            toggled = not toggled
            if macromode.value == 'Toggle' then
                togglebutton.BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.new()
                if toggled then
                    task.spawn(function() -- Run in a new thread to not block
                        repeat
                            for i,v_click in pairs(positions) do
                                virtualInputManager:SendMouseButtonEvent(v_click.clickpos.X, v_click.clickpos.Y, Enum.UserInputType.MouseButton1.Value, true, lplr.PlayerGui, 1)
                                virtualInputManager:SendMouseButtonEvent(v_click.clickpos.X, v_click.clickpos.Y, Enum.UserInputType.MouseButton1.Value, false, lplr.PlayerGui, 1)
                                task.wait(tonumber(macrocps.value or 70) / 1000) -- ms to seconds
                            end
                            task.wait(1 / (tonumber(macrocps.value or 70) / 1000)) -- Repeats per second approx based on cps
                        until not toggled or not togglebutton.Parent or macromode.value ~= 'Toggle'
                    end)
                end
            elseif macromode.value == 'No Repeat' then
                togglebutton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                task.spawn(function()
                    for i,v_click in pairs(positions) do
                        virtualInputManager:SendMouseButtonEvent(v_click.clickpos.X, v_click.clickpos.Y, Enum.UserInputType.MouseButton1.Value, true, lplr.PlayerGui, 1)
                        virtualInputManager:SendMouseButtonEvent(v_click.clickpos.X, v_click.clickpos.Y, Enum.UserInputType.MouseButton1.Value, false, lplr.PlayerGui, 1)
                        task.wait(tonumber(macrocps.value or 70) / 1000)
                    end
                    togglebutton.BackgroundColor3 = Color3.new()
                end)
            end
        end)
        local mouseenter = false
        togglebutton.MouseEnter:Connect(function()
            mouseenter = true
        end)
        togglebutton.MouseLeave:Connect(function()
            mouseenter = false
        end)
        
        task.spawn(function()
            repeat
                if mouseenter and inputservice:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and macromode.value == 'Repeat While Holding' then -- Check mouse button press
                    togglebutton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    for i,v_click in pairs(positions) do
                        virtualInputManager:SendMouseButtonEvent(v_click.clickpos.X, v_click.clickpos.Y, Enum.UserInputType.MouseButton1.Value, true, lplr.PlayerGui, 1)
                        virtualInputManager:SendMouseButtonEvent(v_click.clickpos.X, v_click.clickpos.Y, Enum.UserInputType.MouseButton1.Value, false, lplr.PlayerGui, 1)
                        task.wait(tonumber(macrocps.value or 70) / 1000)
                    end
                elseif macromode.value == 'Repeat While Holding' then
                    togglebutton.BackgroundColor3 = Color3.new()
                end
                task.wait(1 / (tonumber(macrocps.value or 70) * 10)) -- Adjusted wait time
            until not togglebutton.Parent
        end)

        gui:setdraggable(togglebutton, gui.gui.Enabled)
        
        table.insert(macroapis, {
            toggle = togglebutton,
            button = {Destroy = function() if togglebutton.Parent then togglebutton:Destroy() end end} -- Ensure button is actually destroyed
        })
        table.clear(macros) -- Clear current recording points after saving a macro
    end
    macro = gui.windows.mods:addmodule({
        name = 'Macro',
        show = false
    })
    macro:addbutton({
        name = 'Add Macro',
        callback = function()
            if macroname.value == nil or macroname.value == '' then 
                gui:notify({
                    desc = 'Please enter a macro name first.'
                })
                return 
            end
            macros = {} -- Clear previous recording points before starting a new one
            settingms = true
            macroelements.background.Visible = true
            gui:toggle(false)
            prismstrapbutton.Visible = false
        end
    })
    macro:addbutton({
        name = 'Reset All Macros',
        callback = function()
            gui.win:Dialog({
                Title = 'Macro',
                Content = 'Are you sure you want to reset ur macros? (this will reset all ur macro settings)',
                Buttons = {
                    {
                        Title = 'Confirm',
                        Callback = function()
                            for i,v_file in listfiles('PrismStrap/logs/macros') do
                                delfile(v_file)
                            end
                            for i,v_api in pairs(macroapis) do 
                                if v_api.toggle and v_api.toggle.Parent then v_api.toggle:Destroy() end
                                if v_api.button and v_api.button.Destroy then v_api.button:Destroy() end
                            end
                            table.clear(macroapis)
                            table.clear(macros) -- Also clear any temp macros
                        end
                    },
                    {
                        Title = 'Cancel',
                        Callback = function() end
                    }
                }
            })
        end
    })
    macrocps = macro:addtextbox({
        name = 'Clicks Per Second (CPS)', -- Changed from MS to CPS for clarity
        number = true,
        default = 10 -- Default to 10 CPS (approx 100ms)
    })
    macroname = macro:addtextbox({
        name = 'Macro Name',
    })
    macromode = macro:adddropdown({
        name = 'Macro Types',
        list = {'No Repeat', 'Repeat While Holding', 'Toggle'},
        default = 'No Repeat' -- Default to first item in list
    })
  
    gui.gui:GetPropertyChangedSignal('Enabled'):Connect(function()
        for i,v_api in pairs(macroapis) do
            if v_api.toggle then gui:setdraggable(v_api.toggle, gui.gui.Enabled) end
        end
    end)
    
    inputservice.InputBegan:Connect(function(input, gp)
        if gp then return end
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            if settingms == true then -- Explicitly check true for recording clicks
                table.insert(macros, {
                    frame = macroelements:new(UDim2.fromOffset(input.Position.X, input.Position.Y)),
                    clickpos = input.Position
                })
            elseif settingms == false then -- Explicitly check false for setting toggle position
                local jsonmacros = {}
                for i,v_macro in pairs(macros) do
                    table.insert(jsonmacros, {
                        clickpos = {X = v_macro.clickpos.X, Y = v_macro.clickpos.Y}
                    })
                end
                if #jsonmacros > 0 then -- Only save if there are recorded clicks
                    writefile(`PrismStrap/logs/macros/{macroname.value}.json`, httpservice:JSONEncode({
                        macro_clicks = jsonmacros, -- Renamed for clarity
                        toggle_position = {X = input.Position.X, Y = input.Position.Y} -- Renamed for clarity
                    }))
                    addMacro(macroname.value, table.clone(macros), input.Position) -- Use table.clone to prevent issues
                else
                    gui:notify({desc = "No clicks recorded for macro."})
                end
                settingms = nil -- Reset state
                macrolab.Visible = false
                prismstrapbutton.Visible = true
                gui:toggle(true)
            end
        end
    end)

    if not isfolder('PrismStrap/logs/macros') then makefolder('PrismStrap/logs/macros') end
    for i,v_file in listfiles('PrismStrap/logs/macros') do
        local suc, res = pcall(function() return httpservice:JSONDecode(readfile(v_file)) end)
        if suc and res and res.macro_clicks and res.toggle_position then
            addMacro(v_file:gsub('PrismStrap/logs/macros/', ''):gsub('.json', ''), res.macro_clicks, res.toggle_position)
        else
            warn("PrismStrap Macro: Failed to load or invalid format for", v_file)
        end
    end
end)

run(function()
    local crosshair = nil
    local crosshairimage = nil
    crosshair = gui.windows.mods:addmodule({
        name = 'Cross hair',
        icon = getcustomasset('PrismStrap/images/plus.png'),
        callback = function(call)
            if call then
                local imagelabel = Instance.new('ImageLabel', gui.gui)
                imagelabel.Name = "PrismStrap_Crosshair" -- Give it a unique name for easy identification/cleanup
                imagelabel.Size = UDim2.new(0, 25, 0, 25)
                imagelabel.AnchorPoint = Vector2.new(0.5, 0.5)
                imagelabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                imagelabel.BackgroundTransparency = 1
                imagelabel.Image = getgenv().getcustomasset('PrismStrap/images/'..crosshairimage.value) or ''
                Instance.new('UIScale', imagelabel).Scale = gui.scale
                table.insert(crosshair.cons, imagelabel)
            end
        end
    })
    local list = {}
    for i,v_img in listfiles('PrismStrap/images') do
        local new_img_name = v_img:split((identifyexecutor() == 'Swift' and '\\') or '/')[#v_img:split((identifyexecutor() == 'Swift' and '\\') or '/')]:gsub('images\\', '')
        table.insert(list, new_img_name)
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
    local old_camera_input_rotation_func = nil -- Renamed 'old' to be more specific
    local oldfov = workspace.CurrentCamera.FieldOfView
    camerasettings = gui.windows.mods:addmodule({
        name = 'Camera',
        show = false,
        icon = getcustomasset('PrismStrap/images/camera.png'),
        callback = function(call)
            if not call and cameramodule and old_camera_input_rotation_func then
                cameramodule.getRotation = old_camera_input_rotation_func
            end
            workspace.CurrentCamera.FieldOfView = oldfov -- Revert FOV if module disabled
        end
    })
    workspace.CurrentCamera:GetPropertyChangedSignal('FieldOfView'):Connect(function()
        if camerasettings.toggled and fov and tonumber(fov.value) then -- Check if it's a number too
             workspace.CurrentCamera.FieldOfView = tonumber(fov.value)
        else
             workspace.CurrentCamera.FieldOfView = oldfov
        end
    end)
    fov = camerasettings:addtextbox({
        name = 'Field Of View',
        number = true,
        default = oldfov,
        callback = function(val, lost)
            if tonumber(val) and lost and camerasettings.toggled then -- Make sure it's a number
                workspace.CurrentCamera.FieldOfView = tonumber(val)
            elseif not camerasettings.toggled then
                workspace.CurrentCamera.FieldOfView = oldfov
            end
        end
    })
    pcall(function() -- Wrap in pcall as CameraModule path can change or not exist
        cameramodule = require(lplr.PlayerScripts.PlayerModule:WaitForChild("CameraModule"):WaitForChild("CameraInput")) :: table
        if cameramodule then old_camera_input_rotation_func = cameramodule.getRotation end
    end)

    camerasettings:addtextbox({
        name = 'Sensitivity',
        number = true,
        default = 1,
        callback = function(val, lost)
            if tonumber(val) and lost and camerasettings.toggled and cameramodule and old_camera_input_rotation_func then
                cameramodule.getRotation = function(...)
                    return old_camera_input_rotation_func(...) * tonumber(val)
                end
            elseif cameramodule and old_camera_input_rotation_func then -- Revert if not toggled or invalid
                cameramodule.getRotation = old_camera_input_rotation_func
            end
        end
    })
end)

run(function()
    local gamefont = nil
    local font_dropdown = nil -- Renamed 'font' to avoid conflict with Enum.Font
    local fontweight_textbox = nil -- Renamed 'fontweight'
    local originalfonts = {}
    gamefont = gui.windows.mods:addmodule({
        name = 'Game Font',
        show = false,
        icon = getcustomasset('PrismStrap/images/fontico.png'),
        callback = function(call)
            if call and font_dropdown and font_dropdown.value ~= 'None' and fontweight_textbox then
                local font_path = `PrismStrap/fonts/{font_dropdown.value}`
                local font_json_path = font_path:gsub('%.ttf$', '.json'):gsub('%.otf$', '.json')
                
                writefile(font_json_path, httpservice:JSONEncode({
                    name = 'fontface',
                    faces = {
                        {
                            name = 'Regular',
                            weight = tonumber(fontweight_textbox.value) or 400, -- Use Enum or number (400=Regular)
                            style = 'normal',
                            assetId = getcustomasset(font_path) -- Get asset for .ttf/.otf
                        }
                    }
                }))
                local fontface_asset = getcustomasset(font_json_path) -- Get asset for .json
                local fontface = Font.new(fontface_asset, Enum.FontWeight.Regular, Enum.FontStyle.Normal) -- Ensure Font.new usage is correct
                
                for i_desc, v_desc in pairs(game:GetDescendants()) do
                    local success, hasFontProp = pcall(function() return v_desc.Font end)
                    if success and hasFontProp then
                        table.insert(originalfonts, {Font = v_desc.Font, UI = v_desc, FontFace = v_desc.FontFace}) -- Store original FontFace too
                        v_desc.FontFace = fontface
                        local fontChangeConn = v_desc:GetPropertyChangedSignal('Font'):Connect(function()
                            v_desc.FontFace = fontface -- Re-apply if Font enum changes
                        end)
                        table.insert(gamefont.cons, fontChangeConn)
                    end
                end
                local descendantAddedConn = game.DescendantAdded:Connect(function(v_new_desc)
                     local success_new, hasFontProp_new = pcall(function() return v_new_desc.Font end)
                    if success_new and hasFontProp_new then
                        table.insert(originalfonts, {Font = v_new_desc.Font, UI = v_new_desc, FontFace = v_new_desc.FontFace})
                        v_new_desc.FontFace = fontface
                         local fontChangeConnNew = v_new_desc:GetPropertyChangedSignal('Font'):Connect(function()
                            v_new_desc.FontFace = fontface
                        end)
                        table.insert(gamefont.cons, fontChangeConnNew)
                    end
                end)
                table.insert(gamefont.cons, descendantAddedConn)
            else
                for i_orig, v_orig in pairs(originalfonts) do
                    pcall(function()
                        if v_orig.UI and v_orig.UI.Parent then -- Check if UI still exists
                            v_orig.UI.FontFace = v_orig.FontFace -- Restore original FontFace
                        end
                    end)
                end
                table.clear(originalfonts)
            end
        end
    })
    local list_fonts = {'None'}
    if not isfolder('PrismStrap/fonts') then makefolder('PrismStrap/fonts') end
    for i,v_fontfile in listfiles('PrismStrap/fonts') do
        local new_fontname = v_fontfile:gsub('PrismStrap/fonts/', ''):gsub('./', '')
        if new_fontname:match('%.ttf$') or new_fontname:match('%.otf$') then -- Only list actual font files
             table.insert(list_fonts, new_fontname)
        end
    end
    font_dropdown = gamefont:adddropdown({
        name = 'Custom Font',
        list = list_fonts,
        callback = function()
            gamefont:retoggle()
        end
    })
    fontweight_textbox = gamefont:addtextbox({
        name = 'Font Weight (100-900)', -- More descriptive
        number = true,
        default = 400, -- Corresponds to Enum.FontWeight.Regular
        callback = function(val)
            local numVal = tonumber(val)
            if numVal and numVal >= 100 and numVal <= 900 then
                 fontweight_textbox.value = numVal
            else
                 fontweight_textbox.value = 400 -- Reset to default if invalid
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
    local quality_msaa = nil -- Renamed quality
    local technology_lighting = nil -- Renamed technology
    local original_fog_end = lighting.FogEnd
    gamelighting = gui.windows.mods:addmodule({
        name = 'Lighting',
        show = false,
        icon = getcustomasset('PrismStrap/images/lighting.png'),
        callback = function(call)
            if nofog and nofog.toggled then
                lighting.FogEnd = call and 9e9 or original_fog_end
            end
            if nowind and nowind.toggled then
                setfflag('FFlagRenderGlobalWind', call and false or true) -- Changed flag name based on common use
                setfflag('FFlagGlobalWind', call and false or true)       -- Changed flag name
            end
            if graysky then setfflag('FFlagDebugSkyGray', call and graysky.toggled or false) end

            if quality_msaa and quality_msaa.value then
                setfflag('DFIntMSAASamplesOverride', (call and quality_msaa.value:find('x')) and quality_msaa.value:gsub('x', '') or '0') 
            end
            
            local lightingmode = technology_lighting and call and technology_lighting.value:gsub(' ', '') or 'Future' -- Default to Future or game choice
            if call and lightingmode:find('Phase') then
                lightingmode = lightingmode:match("(.+) %((Phase %d)%)") -- Extract base name like "Voxel"
            end
            
            local currentTechnology = lighting.Technology
            local targetTechnology = (technology_lighting.value == 'Chosen by game' or not call) and Enum.Technology.Future or Enum.Technology[lightingmode] or Enum.Technology.Future
            
            if sethiddenproperty then
                sethiddenproperty(lighting, 'Technology', targetTechnology)
            else
                lighting.Technology = targetTechnology -- Fallback if sethiddenproperty isn't available
            end

            if not call then -- Revert FFlags if module is disabled
                setfflag('DFFlagDebugRenderForceTechnologyVoxel', false)
                setfflag('DFFlagDebugRenderForceFutureIsBrightPhase2', false)
                setfflag('DFFlagDebugRenderForceFutureIsBrightPhase3', false)
                lighting.Technology = currentTechnology -- Revert to original before module was enabled
                return
            end

            if call and inputservice.KeyboardEnabled then -- FFlags usually for PC more than mobile
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
    technology_lighting = gamelighting:adddropdown({
        name = 'Lighting Technology',
        list = {'Chosen by game', 'Voxel', 'ShadowMap', 'Future', 'Compatibility'}, -- Removed (Phase X) for clarity, matches Enum better
        default = 'Chosen by game',
        callback = function()
            gamelighting:retoggle()
        end
    })
    quality_msaa = gamelighting:adddropdown({  
        name = 'Anti-aliasing quality (MSAA)',
        list = {'Automatic', '1x', '2x', '4x', '8x'}, -- Added 8x
        default = 'Automatic',
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
    local showfpscounter = nil
    local betterlighting = nil
    local noterraintextures = nil
    local texturequality = nil
    local oldlights = {}

    local original_texture_compositor_jobs = getfflag('DFIntTextureCompositorActiveJobs')
    local original_terrain_array_slice_size = getfflag('FIntTerrainArraySliceSize')
    gamegraphic = gui.windows.enginesettings:addmodule({
        name = 'Graphic',
        show = false,
        icon = getcustomasset('PrismStrap/images/graphic.png'),
        callback = function(call)
            if texturequality == nil then return end
            if call then
                if framebuffer and framebuffer.value then
                    local newval_fb = framebuffer.value:gsub('x', '')
                    setfflag('DFIntRenderShadowIntensity', newval_fb) -- Example for a different flag usage
                    setfflag('DFIntFBSizeMultiplier', newval_fb) -- This is more likely for framebuffer size
                end
                if framerate and framerate.value and tonumber(framerate.value) then
                    local fps_val = tonumber(framerate.value)
                    if setfpscap then setfpscap(fps_val) else settings():GetService("RunService"):Set3dRenderingEnabled(false) task.wait() settings():GetService("RunService"):Set3dRenderingEnabled(true) end -- Basic unlock/re-lock if no setfpscap
                    setfflag('DFIntTaskSchedulerTargetFps', tostring(fps_val))
                end
                if showfpscounter then setfflag('FFlagDebugDisplayFPSWithValue', showfpscounter.toggled and 'true' or 'false') end -- More specific flag
            end
            local lvl_tex = texturequality.value == 'Medium' and 1 or texturequality.value == 'High' and 2 or (texturequality.value == 'Low' and 0 or (texturequality.value == 'Lowest' and -1 or -2)) -- Adjusted mapping
            setfflag('DFFlagUseTextureQualityLevel', (texturequality.value == 'Automatic' or not call) and false or true) -- Renamed flag
            setfflag('DFIntTextureQualityLevel', lvl_tex) -- Renamed flag
            
            if noterraintextures then setfflag('FIntTerrainArraySliceSize', noterraintextures.toggled and call and 0 or original_terrain_array_slice_size) end
            if texturequality then setfflag('FIntTextureManagerMipBias', call and texturequality.value == 'Lowest' and 2 or 0) end -- Different flag, more direct

            if betterlighting then
                if not call or not betterlighting.toggled then
                    for i_light, v_light in pairs(oldlights) do
                        pcall(function()
                            if typeof(v_light) == 'Instance' and v_light.Parent == replicatedstorage then
                                v_light.Parent = lighting
                            elseif type(i_light) == "string" then -- Properties stored by name
                                lighting[i_light] = v_light
                            end
                        end)
                    end
                    table.clear(oldlights)
                    if betterlighting.cons and #betterlighting.cons > 0 then
                        gui:clean(betterlighting.cons) -- Clean up instances created for better lighting
                    end
                else
                    -- Backup existing children and key properties
                    for i_light, v_light in ipairs(lighting:GetChildren()) do table.insert(oldlights, v_light) v_light.Parent = replicatedstorage end
                    for _,propName in ipairs({'GlobalShadows', 'ExposureCompensation', 'OutdoorAmbient', 'Technology', 'Ambient', 'Brightness', 'ColorShift_Bottom', 'ColorShift_Top', 'FogColor', 'FogEnd', 'FogStart'}) do oldlights[propName] = lighting[propName] end
                    
                    local bloom = Instance.new('BloomEffect', lighting)
                    bloom.Intensity = 0.15; bloom.Size = 56; bloom.Threshold = 0.85; table.insert(betterlighting.cons, bloom)
                    
                    local sunrays = Instance.new('SunRaysEffect', lighting)
                    sunrays.Intensity = 0.05; sunrays.Spread = 0.2; table.insert(betterlighting.cons, sunrays)

                    local colorcorrection = Instance.new('ColorCorrectionEffect', lighting)
                    colorcorrection.Brightness = 0.05; colorcorrection.Contrast = 0.1; colorcorrection.Saturation = 0.05; colorcorrection.TintColor = Color3.fromRGB(255, 250, 245); table.insert(betterlighting.cons, colorcorrection)
                    
                    lighting.GlobalShadows = true
                    lighting.Ambient = Color3.fromRGB(128, 128, 128)
                    lighting.OutdoorAmbient = Color3.fromRGB(160, 160, 170)
                    lighting.Brightness = 2
                    lighting.Technology = Enum.Technology.Future
                    lighting.ExposureCompensation = 0.05
                end
            end
            if noplrtexture then setfflag('DFIntTextureCompositorMaxJobs', noplrtexture.toggled and call and 0 or original_texture_compositor_jobs) end -- Renamed flag
            if nopostingeffects then setfflag('DFFlagPostFXEnabled', not (nopostingeffects.toggled and call)) end -- Inverted logic based on common flag name
            if noplrshadow then setfflag('FIntRenderShadowIntensityLocalPlayer', noplrshadow.toggled and call and 0 or 1) end -- More specific player shadow flag
            
            if not call then -- Revert all FFlags to their "assumed default" or pre-module state when module is off
                setfflag('DFIntFBSizeMultiplier', '1')
                if setfpscap then setfpscap(60) else settings():GetService("RunService"):Set3dRenderingEnabled(false) task.wait() settings():GetService("RunService"):Set3dRenderingEnabled(true) end
                setfflag('DFIntTaskSchedulerTargetFps', '60')
                setfflag('FFlagDebugDisplayFPSWithValue', 'false')
                setfflag('DFFlagUseTextureQualityLevel', false)
                setfflag('DFIntTextureQualityLevel', -2) -- Often default is automatic/low
                setfflag('FIntTerrainArraySliceSize', original_terrain_array_slice_size)
                setfflag('FIntTextureManagerMipBias', 0)
                setfflag('DFIntTextureCompositorMaxJobs', original_texture_compositor_jobs)
                setfflag('DFFlagPostFXEnabled', true)
                setfflag('FIntRenderShadowIntensityLocalPlayer', 1)
            end
        end
    })
    betterlighting = gamegraphic:addtoggle({
        name = 'Enhanced Lighting', -- Renamed for clarity
        callback = function() gamegraphic:retoggle() end
    })
    noplrtexture = gamegraphic:addtoggle({
        name = 'Disable Player Textures',
        callback = function() gamegraphic:retoggle() end
    })
    noterraintextures = gamegraphic:addtoggle({
        name = 'Disable Terrain Textures',
        callback = function() gamegraphic:retoggle() end
    })
    nopostingeffects = gamegraphic:addtoggle({
        name = 'Disable Post-Processing FX',
        callback = function() gamegraphic:retoggle() end
    })
    noplrshadow = gamegraphic:addtoggle({
        name = 'Disable Own Player Shadow',
        callback = function() gamegraphic:retoggle() end
    })
    framebuffer = gamegraphic:adddropdown({
        name = 'Render Scale Multiplier', -- Renamed, more common term
        list = {'0.5x','1x', '1.25x', '1.5x', '2x'}, -- Added 0.5x, changed options
        default = '1x',
        callback = function() gamegraphic:retoggle() end
    })
    showfpscounter = gamegraphic:addtoggle({
        name = 'Show FPS Counter (In-Engine)',
        callback = function() gamegraphic:retoggle() end
    })
    texturequality = gamegraphic:adddropdown({
        name = 'Texture Quality Override',
        list = {'Automatic', 'Lowest', 'Low', 'Medium', 'High'},
        default = 'Automatic',
        callback = function() gamegraphic:retoggle() end
    })
    framerate = gamegraphic:addtextbox({
        name = 'FPS Cap Target',
        number = true,
        default = cloneref(game:GetService("RunService")):GetRobloxVersion().Hash == "0.610.0.6100523" and 240 or 60, -- Dynamic default
        callback = function(val, lost) if lost then gamegraphic:retoggle() end end
    })
end)

run(function()
    local customtopbar = nil
    local interface_settings_module = nil -- Renamed interface to be more specific
    local robloxmenu_internal
    pcall(function() robloxmenu_internal = coregui.TopBarApp.UnibarLeftFrame.UnibarMenu['2']['3'] end) -- Wrapped in pcall

    local function creategradient(parent_ui)
        if not parent_ui then return end
        local grad = Instance.new('UIGradient', parent_ui)
        grad.Name = "PrismStrap_TopbarGradient"
        grad.Rotation = -60
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(219, 89, 171)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(61, 56, 192))
        })
        table.insert(customtopbar.cons, grad)
    end
    local stretchresolution = nil
    
    interface_settings_module = gui.windows.enginesettings:addmodule({
        name = 'Interface Settings',
        show = false,
        icon = getcustomasset('PrismStrap/images/interface.png'),
        callback = function(call)
            -- Cleanup for stretch resolution first
            if stretchresolution and stretchresolution.cons then gui:clean(stretchresolution.cons) end
            
            if call then
                if stretchresolution and stretchresolution.toggled then
                    local uiscale_value = 0.74 -- Default stretch factor
                    -- Iterate PlayerGui
                    for _, child_pgui in pairs(lplr.PlayerGui:GetChildren()) do
                        if not child_pgui:IsA("ScreenGui") or child_pgui == realgui or child_pgui == elements.gui then continue end -- Skip our own PrismStrap GUIs
                        local uiscale = Instance.new('UIScale', child_pgui)
                        uiscale.Name = "PrismStrap_StretchScale"
                        uiscale.Scale = uiscale_value
                        table.insert(stretchresolution.cons, uiscale)
                    end
                    -- Iterate CoreGui (carefully)
                    for _, child_cgui in pairs(coregui:GetChildren()) do
                        if child_cgui == realgui or child_cgui == elements.gui or not child_cgui:IsA("ScreenGui") then continue end -- Skip PrismStrap GUIs and non-ScreenGuis
                        local uiscale = Instance.new('UIScale', child_cgui)
                        uiscale.Name = "PrismStrap_StretchScale_Core"
                        uiscale.Scale = uiscale_value
                        table.insert(stretchresolution.cons, uiscale)
                    end
                end
                
                -- Custom Topbar Logic
                if customtopbar and customtopbar.toggled and robloxmenu_internal then
                    if robloxmenu_internal.chat and robloxmenu_internal.chat:FindFirstChild('5') then
                        if robloxmenu_internal.chat['5']:FindFirstChild('Badge') then
                            creategradient(robloxmenu_internal.chat['5'].Badge)
                            robloxmenu_internal.chat['5'].Badge.Text.TextTruncate = Enum.TextTruncate.None -- Allow full text
                        end
                        local chatBadgeAddedConn = robloxmenu_internal.chat['5'].ChildAdded:Connect(function(v_badge_added)
                            if v_badge_added.Name == "Badge" then -- Be more specific
                                creategradient(v_badge_added)
                                if v_badge_added:IsA("TextLabel") or v_badge_added:FindFirstChildOfClass("TextLabel") then
                                    (v_badge_added:IsA("TextLabel") and v_badge_added or v_badge_added:FindFirstChildOfClass("TextLabel")).TextTruncate = Enum.TextTruncate.None
                                end
                            end
                        end)
                        table.insert(customtopbar.cons, chatBadgeAddedConn)
                    end
                    if robloxmenu_internal.chat and robloxmenu_internal.chat:FindFirstChild("IntegrationIconFrame") then creategradient(robloxmenu_internal.chat.IntegrationIconFrame:FindFirstChildWhichIsA("ImageLabel") or robloxmenu_internal.chat.IntegrationIconFrame) end
                    if robloxmenu_internal.nine_dot and robloxmenu_internal.nine_dot:FindFirstChild("IntegrationIconFrame") then
                        creategradient(robloxmenu_internal.nine_dot.IntegrationIconFrame:FindFirstChild("Close") or robloxmenu_internal.nine_dot.IntegrationIconFrame:FindFirstChildWhichIsA("ImageLabel"))
                        creategradient(robloxmenu_internal.nine_dot.IntegrationIconFrame:FindFirstChild("Overflow") or robloxmenu_internal.nine_dot.IntegrationIconFrame:FindFirstChildWhichIsA("ImageButton"))
                    end
                    if coregui.TopBarApp and coregui.TopBarApp:FindFirstChild("MenuIconHolder") then creategradient(coregui.TopBarApp.MenuIconHolder.TriggerPoint.Background.ScalingIcon) end
                    
                    local topbarStandard = lplr.PlayerGui:FindFirstChild('TopbarStandard') or lplr.PlayerGui:FindFirstChild('TopbarPlus')
                    if topbarStandard then
                        for _,v_topbar_desc in pairs(topbarStandard:GetDescendants()) do
                            if v_topbar_desc:IsA('ImageLabel') and not v_topbar_desc:FindFirstChild("PrismStrap_TopbarGradient") then -- Avoid duplicate gradients
                                creategradient(v_topbar_desc)
                            end
                        end
                    end
                end
            else -- When module is turned off
                if customtopbar and customtopbar.cons then gui:clean(customtopbar.cons) end
                -- Stretch resolution cleanup already handled at the start of the 'if call' block for consistency
            end
        end
    })
    customtopbar = interface_settings_module:addtoggle({
        name = 'Custom Topbar Colors',
        callback = function() interface_settings_module:retoggle() end
    })
    stretchresolution = interface_settings_module:addtoggle({
        name = 'Stretch Resolution (0.74x)',
        callback = function() interface_settings_module:retoggle() end
    })
end)

run(function()
    local rendering_module = nil -- Renamed rendering
    -- local renderingmode_dropdown = nil -- Renamed renderingmode, seems unused for FFlags directly
    local dpiscale_toggle = nil
    local renderinggraphic_textbox = nil

    local original_FRM_quality_level = getfflag('DFIntDebugFRMQualityLevelOverride') -- Backup original

    rendering_module = gui.windows.enginesettings:addmodule({
        name = 'Rendering Tuning', -- Renamed
        icon = getcustomasset('PrismStrap/images/rendering.png'),
        show = false,
        callback = function(call)
            local quality_level_val = renderinggraphic_textbox and tonumber(renderinggraphic_textbox.value)
            if call and quality_level_val then
                quality_level_val = math.clamp(quality_level_val, 1, 21) -- Ensure it's within Roblox's typical range
                renderinggraphic_textbox.value = tostring(quality_level_val) -- Update textbox if clamped
                
                setfflag('FFlagFixGraphicsQuality', true) -- Often used with quality overrides
                setfflag('DFIntDebugFRMQualityLevelOverride', tostring(quality_level_val))
                setfflag('DFIntDebugQualityLevel', tostring(quality_level_val)) -- Another common quality FFlag
            else
                -- Revert to original or a known safe default when module is off
                setfflag('FFlagFixGraphicsQuality', false)
                setfflag('DFIntDebugFRMQualityLevelOverride', original_FRM_quality_level or "0") -- Revert or use 0 for automatic
                setfflag('DFIntDebugQualityLevel', original_FRM_quality_level or "0")
            end
            if dpiscale_toggle then setfflag('DFFlagEnableDPIScale', not (call and dpiscale_toggle.toggled)) end -- Inverted logic is common for 'disable' toggles
            
            if not call then
                 -- Also reset the rendering mode/pipeline if specific ones were forced
                 setfflag("FFlagDebugGraphicsPreferVulkan", false)
                 setfflag("FFlagDebugGraphicsPreferMetal", false)
                 setfflag("FFlagDebugGraphicsPreferD3D11", false)
            end
        end
    })
    renderinggraphic_textbox = rendering_module:addtextbox({
        name = 'Graphics Quality Level (1-21)', -- Clarified range
        number = true,
        default = getfflag('DFIntDebugFRMQualityLevelOverride') or "10", -- Use current or a mid-range default
        callback = function(val, lostFocus) if lostFocus then rendering_module:retoggle() end end
    })
    dpiscale_toggle = rendering_module:addtoggle({
        name = 'Enable DPI Scaling (Native Res)', -- Clarified "Disable optimization" means enable native DPI
        callback = function() rendering_module:retoggle() end
    })
    
    local renderingModeDropdown = rendering_module:adddropdown({ -- Define and use
        name = 'Graphics API Preference (PC)',
        list = {'Automatic', 'Force Vulkan', 'Force Metal (MacOS)', 'Force D3D11'},
        default = 'Automatic',
        callback = function(val)
            if rendering_module.toggled then -- Only apply if main module is on
                setfflag("FFlagDebugGraphicsPreferVulkan", val == 'Force Vulkan')
                setfflag("FFlagDebugGraphicsPreferMetal", val == 'Force Metal (MacOS)')
                setfflag("FFlagDebugGraphicsPreferD3D11", val == 'Force D3D11')
            end
            -- Retoggle main module to re-apply other settings like quality if needed
            rendering_module:retoggle() 
            task.wait(0.1) -- short delay
            rendering_module:retoggle()
        end
    })
end)

run(function()
    local general_settings_module = nil -- Renamed general
    local generalvolume_textbox = nil
    local generalingameadvertisement_toggle = nil
    -- local generalenablevolume -- Unused variable

    general_settings_module = gui.windows.enginesettings:addmodule({
        name = 'General Client Settings', -- Renamed
        icon = getcustomasset('PrismStrap/images/general.png'),
        show = false,
        callback = function(call)
            local userGameSettings = UserSettings():GetService('UserGameSettings')
            if call then
                if generalvolume_textbox and tonumber(generalvolume_textbox.value) ~= nil then
                    userGameSettings.MasterVolume = math.clamp(tonumber(generalvolume_textbox.value), 0, 1) -- Clamp between 0 and 1
                end
                if generalingameadvertisement_toggle then
                     setfflag('FFlagInGameAdvertisingEnabled', generalingameadvertisement_toggle.toggled) -- More common flag name
                end
            else
                -- Revert FFlags or settings if module is turned off
                -- UserGameSettings.MasterVolume could be reverted to a stored original value if desired
                setfflag('FFlagInGameAdvertisingEnabled', true) -- Assuming true is the default
            end
        end
    })
    generalvolume_textbox = general_settings_module:addtextbox({
        name = 'Master Game Volume (0.0-1.0)',
        number = true,
        default = UserSettings():GetService('UserGameSettings').MasterVolume,
        callback = function(val, lostFocus)
            if lostFocus and general_settings_module.toggled then
                local numVal = tonumber(val)
                if numVal ~= nil then
                     UserSettings():GetService('UserGameSettings').MasterVolume = math.clamp(numVal, 0, 1)
                end
            end
        end
    })
    generalingameadvertisement_toggle = general_settings_module:addtoggle({
        name = 'Enable In-Game Advertisements',
        default = getfflag('FFlagInGameAdvertisingEnabled') == "true", -- Set default based on current FFlag state
        callback = function()
            general_settings_module:retoggle()
        end
    })
end)

if isfile('setting.bs') then -- This file seems related to FFlag settings, ensure path matches PrismStrap
    local flagToBlacklist = readfile('setting.bs')
    writefile('PrismStrap/logs/blacklisted/'.. flagToBlacklist.. '.txt', 'Potentially unstable FFlag blocked by setting.bs: ' .. flagToBlacklist)
    gui:notify({
        desc = `Blocked potentially unstable FFlag from setting.bs: {flagToBlacklist}`
    })
    delfile('setting.bs')
end

local fastflageditor = nil
run(function()
    local fastflags_textbox = nil -- Renamed 'fastflags'

    fastflageditor = gui.windows.enginesettings:addmodule({
        name = 'FastFlag Editor',
        icon = getcustomasset('PrismStrap/images/flag.png'),
        show = false,
        callback = function() end -- Main callback usually for enable/disable, not needed for just containing elements
    })
    fastflags_textbox = fastflageditor:addtextbox({
        name = 'Parse FastFlags (JSON, e.g., {"FFlagName": true})', -- Added example
        ignore = true, -- This likely means don't save this textbox value itself to config
        callback = function(json_input_str, lostFocus)
            if lostFocus and json_input_str and json_input_str ~= "" then
                local suc_decode_ff, decoded_new_fflags = pcall(function() return httpservice:JSONDecode(json_input_str) end)
                if not suc_decode_ff or typeof(decoded_new_fflags) ~= "table" then
                    gui:notify({desc = "Invalid JSON for FastFlags."})
                    return
                end

                local suc_read_old, old_fflags_data = pcall(function() return httpservice:JSONDecode(readfile('PrismStrap/logs/fastflags.json')) end)
                local current_fflags = (suc_read_old and typeof(old_fflags_data) == "table") and old_fflags_data or {}
                
                local changesMade = false
                for flag_name, flag_value in pairs(decoded_new_fflags) do
                    if not isfile('PrismStrap/logs/blacklisted/'.. flag_name.. '.txt') then
                        current_fflags[flag_name] = flag_value -- Add or update
                        setfflag(flag_name, flag_value) -- Apply immediately
                        changesMade = true
                    else
                        gui:notify({desc = `FFlag {flag_name} is blacklisted.`})
                    end
                end

                if changesMade then
                     -- Re-populate the displayed FFlag textboxes in the UI after parsing
                    for childName, childApi in pairs(fastflageditor.elements or {}) do -- Assuming 'elements' holds the child UI objects map
                        if childName ~= fastflags_textbox.name and childName ~= "Reset Fastflags" then -- Avoid self and buttons
                             if childApi.Destroy then childApi:Destroy() end -- Remove old dynamic FFlag textboxes if UI lib supports it
                        end
                    end
                     for ff_name_curr, ff_val_curr in pairs(current_fflags) do
                        if not isfile('PrismStrap/logs/blacklisted/'.. ff_name_curr.. '.txt') then
                             fastflageditor:addtextbox({
                                name = tostring(ff_name_curr),
                                default = tostring(ff_val_curr),
                                ignore = true, -- Don't save these individual dynamically added boxes to main config
                                callback = function(new_val, innerLostFocus)
                                    if new_val and innerLostFocus then
                                        local suc_read_cb, fflags_cb_data = pcall(function() return httpservice:JSONDecode(readfile('PrismStrap/logs/fastflags.json')) end)
                                        local current_fflags_cb = (suc_read_cb and typeof(fflags_cb_data) == "table") and fflags_cb_data or {}
                                        current_fflags_cb[ff_name_curr] = new_val -- Store new value as string, FFlag system handles type
                                        writefile('PrismStrap/logs/fastflags.json', httpservice:JSONEncode(current_fflags_cb))
                                        setfflag(ff_name_curr, new_val)
                                    end
                                end
                            })
                        end
                     end
                    writefile('PrismStrap/logs/fastflags.json', httpservice:JSONEncode(current_fflags))
                    if not getgenv().noshow then gui:notify({desc = 'FastFlags updated and applied.'}) end
                    fastflags_textbox:setvalue("") -- Clear the input box after parsing
                end
            end
        end
    })
    fastflageditor:addbutton({
        name = 'Reset Fastflags (Restart Required)',
        callback = function()
            gui.win:Dialog({
                Title = 'FastFlags Editor',
                Content = 'Reset all custom FastFlags to default?\nThis will SHUT DOWN Roblox to apply changes.', -- Clarified action
                Buttons = {
                    {
                        Title = 'Confirm & Shutdown',
                        Callback = function()
                            writefile('PrismStrap/logs/fastflags.json', '{}') -- Empty JSON object
                            gui:notify({desc="FastFlags reset. Roblox will now shutdown.", Duration = 5})
                            task.delay(3, function() game:Shutdown() end)
                        end
                    },
                    {
                        Title = 'Cancel', Callback = function() end
                    }
                }
            })
        end
    })
end)

-- Visual Stats Spoofer Module (INTEGRATED)
run(function()
    local visualSpooferModule = nil

    -- grab the services we need, u know the drill
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")

    -- some vars for this spoofer thingy
    local spoofPingLabel = nil
    local spoofMemoryLabel = nil
    local spoofRenderConnection = nil -- gotta keep track of the renderstepped thing

    -- these will hold our textbox things from the UI
    local minPingTextbox, maxPingTextbox, minMemoryTextbox, maxMemoryTextbox

    --------------------------------------------------------------------
    -- FINDING THE UI STUFF - THIS IS WHERE U PUT UR MAGIC (OR PATHS) --
    --------------------------------------------------------------------
    local function findSpooferUiElements()
        -- reset these so we always try to find fresh if called again
        spoofPingLabel = nil
        spoofMemoryLabel = nil

        local robloxGui = CoreGui:FindFirstChild("RobloxGui")
        if not robloxGui then
            print("PrismStrap Spoofer: lol, RobloxGui ain't even there.")
            return false
        end

        -- ==================================================================================
        -- !!! HEY! YEAH, YOU! CHANGE THIS CRAP BELOW TO UR ACTUAL FINDING LOGIC / PATHS !!!
        -- This is just a wild guess and will PROBABLY NOT WORK out of the box.
        -- Use Dex or Studio to find the real TextLabels for Ping and Memory in Perf Stats.
        -- ==================================================================================
        
        -- Maybe the stats stuff is in a frame called "PerformanceStats"? idfk
        local statsContainer = robloxGui:FindFirstChild("PerformanceStats") 
        local searchRoot = statsContainer or robloxGui -- if no container, search all of RobloxGui i guess

        for _, kiddo in ipairs(searchRoot:GetDescendants()) do
            if kiddo:IsA("TextLabel") then
                -- try to find the ping label
                if not spoofPingLabel then
                    if (string.find(kiddo.Name:lower(), "ping") or string.find(kiddo.Name:lower(), "network")) and string.find(kiddo.Text:lower(), "ms") then
                        spoofPingLabel = kiddo
                    elseif string.match(kiddo.Text, "%d+ ms") and not string.find(kiddo.Text:lower(), "gpu") then -- avoid gpu time lol
                        spoofPingLabel = kiddo
                    end
                end

                -- and now the memory label
                if not spoofMemoryLabel then
                    if (string.find(kiddo.Name:lower(), "memory") or string.find(kiddo.Name:lower(), "mem") or string.find(kiddo.Name:lower(), "client")) and (string.find(kiddo.Text:lower(), "mb") or string.find(kiddo.Text:lower(), "gb")) then
                        spoofMemoryLabel = kiddo
                    elseif string.match(kiddo.Text, "%.2f MB") or string.match(kiddo.Text, "%.2f GB") then
                        spoofMemoryLabel = kiddo
                    end
                end
            end
            -- if we got both, bounce
            if spoofPingLabel and spoofMemoryLabel then break end
        end
        -- ==================================================================================
        -- !!! END OF THE STUFF YOU NEED TO CHANGE !!!
        -- ==================================================================================

        if spoofPingLabel then print("PrismStrap Spoofer: Ay, found ping label: " .. spoofPingLabel:GetFullName()) end
        if spoofMemoryLabel then print("PrismStrap Spoofer: Found memory label too: " .. spoofMemoryLabel:GetFullName()) end

        if not spoofPingLabel then gui:notify({Title="PrismStrap", desc="Spoofer: Can't find the ping text, u sure stats are open?"}) end
        if not spoofMemoryLabel then gui:notify({Title="PrismStrap", desc="Spoofer: No memory text found either, my dude."}) end

        return spoofPingLabel ~= nil and spoofMemoryLabel ~= nil
    end

    -------------------------------------------------
    -- THIS IS THE BIT THAT ACTUALLY FAKES THE NUMBERS --
    -------------------------------------------------
    local function doSpoofingLogic()
        -- check if our labels disappeared or something, try to find 'em again
        if not spoofPingLabel or not spoofPingLabel.Parent or not spoofMemoryLabel or not spoofMemoryLabel.Parent then
            if not findSpooferUiElements() then
                -- if we still can't find them, welp, game over for this RenderStep
                return false 
            end
        end

        -- get the min/max from our UI boxes, or use some defaults if they're empty/weird
        local minPing = tonumber(minPingTextbox.value) or 10
        local maxPing = tonumber(maxPingTextbox.value) or 35
        if maxPing < minPing then maxPing = minPing + 5 end -- can't have max lower than min, right?

        local minMem = tonumber(minMemoryTextbox.value) or 180
        local maxMem = tonumber(maxMemoryTextbox.value) or 320
        if maxMem < minMem then maxMem = minMem + 50 end

        -- Fake the Ping!
        if spoofPingLabel and spoofPingLabel.Parent then -- just to be safe
            local randomPing = math.random(minPing, maxPing)
            pcall(function() spoofPingLabel.Text = tostring(randomPing) .. " ms" end) -- pcall in case roblox is a crybaby
        end

        -- And Fake the Memory!
        if spoofMemoryLabel and spoofMemoryLabel.Parent then
            local randomMemory = math.floor(math.random(minMem * 100, maxMem * 100)) / 100 -- for .xx format
            pcall(function() spoofMemoryLabel.Text = string.format("%.2f MB", randomMemory) end)
        end
        return true -- tell the RenderStepped we're good (or at least tried)
    end

    --------------------------------------------------
    -- MAKING THE ACTUAL UI FOR PRISMSTRAP          --
    --------------------------------------------------
    visualSpooferModule = gui.windows.mods:addmodule({
        name = "Visual Stats Spoofer",
        -- no icon for now, u said so
        callback = function(isEnabled) -- this runs when the main 'Enabled' toggle for this mod is clicked
            if isEnabled then
                if findSpooferUiElements() then -- try to find the stuff first
                    -- if we had an old renderstepped connection, kill it
                    if spoofRenderConnection and spoofRenderConnection.Connected then
                        spoofRenderConnection:Disconnect()
                    end

                    -- make a new renderstepped to keep updating the text
                    spoofRenderConnection = RunService.RenderStepped:Connect(function()
                        if not doSpoofingLogic() then -- if this returns false, means elements are lost and couldn't be refound
                            if spoofRenderConnection and spoofRenderConnection.Connected then
                                spoofRenderConnection:Disconnect() -- stop trying
                                gui:notify({Title = "PrismStrap", desc = "Spoofer: UI parts lost, stopping it."})
                                if visualSpooferModule and visualSpooferModule.toggled then
                                    visualSpooferModule:retoggle() -- flip the switch off in the UI
                                end
                            end
                        end
                    end)
                    -- IMPORTANT: add this connection to the .cons table so PrismStrap can clean it up
                    -- if this whole module is disabled via its main toggle
                    table.insert(visualSpooferModule.cons, spoofRenderConnection)
                    gui:notify({Title = "PrismStrap", desc = "Visual Stats Spoofer ON!"})
                else
                    -- couldn't find the UI elements
                    gui:notify({Title = "PrismStrap", desc = "Spoofer: Can't find stats UI. Open Perf Stats (Ctrl+Shift+F2) & try toggling again."})
                    if visualSpooferModule and visualSpooferModule.toggled then
                         visualSpooferModule:retoggle() -- untoggle it in the UI if it was on
                    end
                end
            else
                -- this part runs if the module is being turned OFF
                -- PrismStrap should auto-clean visualSpooferModule.cons when its own toggle is switched off.
                -- but just in case, if our connection is somehow still alive:
                if spoofRenderConnection and spoofRenderConnection.Connected then
                    spoofRenderConnection:Disconnect()
                end
                gui:notify({Title = "PrismStrap", desc = "Visual Stats Spoofer OFF."})
            end
        end
    })

    -- Textboxes for the user to set their fake min/max values
    minPingTextbox = visualSpooferModule:addtextbox({
        name = "Min Fake Ping (ms)",
        number = true,
        default = 10
    })
    maxPingTextbox = visualSpooferModule:addtextbox({
        name = "Max Fake Ping (ms)",
        number = true,
        default = 35
    })
    minMemoryTextbox = visualSpooferModule:addtextbox({
        name = "Min Fake Memory (MB)",
        number = true,
        default = 180
    })
    maxMemoryTextbox = visualSpooferModule:addtextbox({
        name = "Max Fake Memory (MB)",
        number = true,
        default = 320
    })

    -- A button to try and re-find the UI elements if they get lost or stats were opened late
    visualSpooferModule:addbutton({
        name = "Re-Scan for Stats UI",
        callback = function()
            gui:notify({Title = "PrismStrap", desc = "Spoofer: Trying to find stats UI again..."})
            if findSpooferUiElements() then
                gui:notify({Title = "PrismStrap", desc = "Spoofer UI Re-Scan: Found 'em (or refreshed)!"})
                -- If the spoofer should be on but the connection died, try to restart it.
                if visualSpooferModule.toggled and (not spoofRenderConnection or not spoofRenderConnection.Connected) then
                    visualSpooferModule:retoggle() -- calls callback with false
                    visualSpooferModule:retoggle() -- calls callback with true, which should restart it
                end
            else
                gui:notify({Title = "PrismStrap", desc = "Spoofer UI Re-Scan: Still can't find 'em. Stats open?"})
            end
        end
    })
end)


run(function()
    if not inputservice.KeyboardEnabled or pcdebug then
        local button = prismstrapbutton

        gui.gui:GetPropertyChangedSignal('Enabled'):Connect(function()
            gui:setdraggable(button, gui.gui.Enabled)
        end)
        
        gui:setdraggable(button, gui.gui.Enabled)

        local imagelabel = Instance.new('ImageLabel', button) :: ImageLabel
        imagelabel.Size = UDim2.new(0, 22, 0, 22)
        imagelabel.Position = UDim2.new(0.25, 0, 0.25, 0)
        imagelabel.BackgroundTransparency = 1
        imagelabel.Image = getcustomasset('PrismStrap/images/PrismStrap.png')
        imagelabel.ImageColor3 = Color3.new(1, 1, 1)
        imagelabel.ZIndex = 2000
    
        gui.button = button
    
        button.MouseButton1Click:Connect(function()
            gui:toggle()
        end)
    
        local buttontransparency = nil
        local buttonvisibility = nil -- Unused variable
        local buttondraggable = nil -- Unused variable
        local legitmode = gui.windows.behaviour:addmodule({
            name = 'Legit Mode',
            show = false,
            callback = function(call)
                if call then
                    if buttontransparency and tonumber(buttontransparency.value) ~= nil then
                        local transparency_val = math.clamp(tonumber(buttontransparency.value), 0, 1)
                        button.BackgroundTransparency = transparency_val
                        imagelabel.ImageTransparency = transparency_val
                        if button:FindFirstChildOfClass("UIStroke") then button:FindFirstChildOfClass("UIStroke").Transparency = transparency_val end
                    end
                else -- Revert when legit mode is off (if desired, or leave as is)
                    button.BackgroundTransparency = 0.3 -- Or original default
                    imagelabel.ImageTransparency = 0
                    if button:FindFirstChildOfClass("UIStroke") then button:FindFirstChildOfClass("UIStroke").Transparency = 0 end
                end
            end
        })
        buttontransparency = legitmode:addtextbox({
            name = 'Button Transparency (0.0-1.0)',
            number = true,
            default = 0.3, -- Match original default
            callback = function(val)
                if legitmode.toggled then
                     local transparency_val = tonumber(val)
                     if transparency_val ~= nil then
                        transparency_val = math.clamp(transparency_val, 0, 1)
                        button.BackgroundTransparency = transparency_val
                        imagelabel.ImageTransparency = transparency_val
                        if button:FindFirstChildOfClass("UIStroke") then button:FindFirstChildOfClass("UIStroke").Transparency = transparency_val end
                     end
                end
            end
        })
        legitmode:addbutton({
            name = 'Reset Button Position',
            callback = function()
                button.Position = UDim2.fromScale(0.99, 0.5) -- Original default position
            end
        })
    end
    gui.windows.appearence:addmodule({
        name = 'GUI Appearence',
        default = true,
        show = false
    }):adddropdown({
        name = 'Theme',
        list = {'Fluent', 'Old'}, -- Add 'Old' if you support it
        default = readfile('PrismStrap/selected.txt') or 'Fluent',
        callback = function(val)
            if val and val:lower() ~= readfile('PrismStrap/selected.txt'):lower() then
                writefile('PrismStrap/selected.txt', val:lower())
                -- Need a reliable way to reload the entire UI or just the theme.
                -- A full 'loadfile('PrismStrap/loader.lua')()' might be too disruptive if not handled carefully.
                -- For now, notify user to re-run.
                gui:notify({Title="PrismStrap", desc="Theme changed to "..val..". Re-execute script to see full changes.", Duration=7})
                -- Or if 'loadfile('PrismStrap/loader.lua')()' is designed for this:
                -- shared.loaded:destruct() -- If this is the cleanup function
                -- task.wait(0.1)
                -- loadfile('PrismStrap/loader.lua')()
            end
        end
    })
end)

run(function()
    local fflag_load_count = 0 :: number
    if not isfolder('PrismStrap/logs') then makefolder('PrismStrap/logs') end
    if not isfile('PrismStrap/logs/fastflags.json') then writefile('PrismStrap/logs/fastflags.json', '{}') end

    local suc_decode_ff, decoded_existing_fflags = pcall(function() return httpservice:JSONDecode(readfile('PrismStrap/logs/fastflags.json')) end)
    
    if suc_decode_ff and typeof(decoded_existing_fflags) == "table" then
        for ff_name, ff_value in pairs(decoded_existing_fflags) do
            if not isfile('PrismStrap/logs/blacklisted/'.. ff_name.. '.txt') then
                setfflag(ff_name, ff_value) -- Apply FFlags on load
                fflag_load_count += 1
                if fastflageditor then -- Check if fastflageditor UI module exists
                    fastflageditor:addtextbox({
                        name = tostring(ff_name),
                        default = tostring(ff_value),
                        ignore = true,
                        callback = function(new_val_ff, lostFocus_ff)
                            if new_val_ff and lostFocus_ff then
                                local suc_read_cb_ff, fflags_cb_data_ff = pcall(function() return httpservice:JSONDecode(readfile('PrismStrap/logs/fastflags.json')) end)
                                local current_fflags_cb_ff = (suc_read_cb_ff and typeof(fflags_cb_data_ff) == "table") and fflags_cb_data_ff or {}
                                current_fflags_cb_ff[ff_name] = new_val_ff
                                writefile('PrismStrap/logs/fastflags.json', httpservice:JSONEncode(current_fflags_cb_ff))
                                setfflag(ff_name, new_val_ff)
                            end
                        end
                    })
                end
            end
        end
    end
    if not getgenv().noshow then
        gui:notify({
            Title = 'PrismStrap',
            Description = `Loaded {fflag_load_count} custom FastFlags.`,
            Duration = 7
        })
    end
end)

run(function()
    local songmodule = nil
    local songmode_dropdown = {value =  'Storage'} -- Renamed songmode
    local songloop_toggle = {toggled = false} -- Renamed songloop
    local songautoselect_toggle = {toggled = false} -- Renamed songautoselect
    local songvolume_textbox = {value = 0.5} -- Renamed songvolume

    local songselected_dropdown = {value = ''} -- Renamed songselected

    local soundinstance = nil

    if not isfolder('PrismStrap/songs') then makefolder('PrismStrap/songs') end
    local songlist_files = listfiles('PrismStrap/songs')

    local songlist_display = {} -- For the dropdown
    for i,v_songfile in ipairs(songlist_files) do -- Use ipairs for ordered lists
        local song_filename = v_songfile:gsub('PrismStrap/songs/', ''):gsub('./', '')
        if song_filename:match('%.mp3$') or song_filename:match('%.ogg$') then -- Filter for common audio formats
             table.insert(songlist_display, song_filename)
        end
    end

    songmodule = gui.windows.music:addmodule({
        name = 'Play Selected Song',
        callback = function(call)
            if call then
                if soundinstance and soundinstance.Parent then
                    soundinstance:Destroy()
                    soundinstance = nil
                end 
                if songselected_dropdown.value == '' or songselected_dropdown.value == nil then
                    return gui:notify({
                        title = 'Music Player',
                        desc = 'Please select a song first!'
                    })
                end
                local soundIdAsset = getgenv().getcustomasset(`PrismStrap/songs/{songselected_dropdown.value}`)
                if not soundIdAsset or soundIdAsset == "" then
                    return gui:notify({title = 'Music Player', desc = 'Failed to load song asset.'})
                end

                soundinstance = Instance.new('Sound', workspace)
                soundinstance.Name = "PrismStrap_MusicPlayer"
                soundinstance.Volume = tonumber(songvolume_textbox.value) or 0.5
                soundinstance.Looped = songloop_toggle.toggled
                soundinstance.SoundId = soundIdAsset
                
                local soundEndedConn
                soundEndedConn = soundinstance.Ended:Connect(function()
                    if not songloop_toggle.toggled and songautoselect_toggle.toggled then
                        if #songlist_display > 0 then
                            local nextSongIndex = math.random(1, #songlist_display)
                            songselected_dropdown.value = songlist_display[nextSongIndex]
                            -- We need to update the dropdown UI element itself if PrismStrap's API allows
                            -- For now, just set the internal value and retoggle to replay
                            songmodule:retoggle() -- Turn off
                            task.wait(0.1)
                            songmodule:retoggle() -- Turn back on to play next song
                        end
                    elseif not songloop_toggle.toggled and not songautoselect_toggle.toggled then
                        songmodule:retoggle() -- Turn off if not looping and not auto-selecting
                    end
                    if soundEndedConn then soundEndedConn:Disconnect() end -- Disconnect self after firing once
                end)
                table.insert(songmodule.cons, soundEndedConn) -- Add to module's connections for cleanup
                soundinstance:Play()
            else
                if soundinstance and soundinstance.Parent then
                    soundinstance:Stop() -- Use Stop instead of Destroy for potential reuse or state issues
                    soundinstance:Destroy()
                    soundinstance = nil
                end 
            end
        end
    })
    songloop_toggle = songmodule:addtoggle({
        name = 'Loop Song',
        default = false,
        callback = function(isLooping)
            songloop_toggle.toggled = isLooping -- Update internal state
            if soundinstance and soundinstance.Parent then
                soundinstance.Looped = isLooping
            end
        end
    })
    songautoselect_toggle = songmodule:addtoggle({
        name = 'Auto-Play Random On End',
        default = false,
        tooltip = 'Plays a random song from your "songs" folder when the current one ends (if not looping).'
    })
    songmode_dropdown = songmodule:adddropdown({ -- Keep this for future (Spotify etc.) but make it non-functional for now
        name = 'Source',
        list = {'Local Storage'},
        default = 'Local Storage'
        -- callback = function(val) songmode_dropdown.value = val end -- Not needed if only one option
    })
    songselected_dropdown = songmodule:adddropdown({
        name = 'Select Song',
        list = #songlist_display > 0 and songlist_display or {"No songs found in PrismStrap/songs"},
        callback = function(selected_song_name)
            songselected_dropdown.value = selected_song_name
            if songmodule.toggled then -- If player is already "on", restart with new song
                songmodule:retoggle() -- Off
                task.wait(0.1)
                songmodule:retoggle() -- On
            end
        end
    })
    songvolume_textbox = songmodule:addtextbox({
        name = 'Volume (0.0-1.0)',
        number = true,
        default = 0.5,
        callback = function(val, lostFocus)
            if lostFocus then
                local num_vol = tonumber(val)
                if num_vol ~= nil then
                    songvolume_textbox.value = math.clamp(num_vol, 0, 1)
                    if soundinstance and soundinstance.Parent then
                        soundinstance.Volume = songvolume_textbox.value
                    end
                end
            end
        end
    })
end)

run(function()
    pcall(function() -- Wrap in pcall in case PlayerList structure changes
        if coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame:FindFirstChild('p_7670822523') then
            coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame.p_7670822523.ChildrenFrame.NameFrame.BGFrame.OverlayFrame.PlayerIcon.Image = getcustomasset('PrismStrap/images/PrismStrap.png')
        end
    end)
end)

gui.configlib:loadconfig(gui) 
gui:notify({
    Title = 'PrismStrap',
    Description = `{inputservice.KeyboardEnabled and 'Press RightShift to toggle UI' or 'Press the button on the right to toggle UI'}.`, -- Slightly reworded
    Duration = 10
})
