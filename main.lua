
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
        errpath = errpath or file:gsub('bloxstrap/', '')
        if not isfile(file) then
            error(`{file} not found in the workspace`)
        end
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
        writefile(path, game:HttpGet(`https://raw.githubusercontent.com/new-qwertyui/Bloxstrap/main/{path:gsub('bloxstrap/', '')}`))
    end
    return getgenv().getcustomasset(path)
end

print(getcustomasset('bloxstrap/images/bloxstrap.png')) --> auto installs image

local getfflag = loadfile('bloxstrap/libraries/getfflag.lua')()
local setfflag = loadfile('bloxstrap/libraries/setfflag.lua')()
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

local bloxstrapbutton = gui:addbutton(realgui, nil, nil, 'bloxstrapbutton')
bloxstrapbutton.Visible = pcdebug or not inputservice.KeyboardEnabled
bloxstrapbutton:GetPropertyChangedSignal('Visible'):Connect(function()
    if bloxstrapbutton.Visible and inputservice.KeyboardEnabled and not pcdebug then
        bloxstrapbutton.Visible = false
    end
end)

getgenv().whenbloxisntstrapping = true

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
                            sound.SoundId = getgenv().getcustomasset(`bloxstrap/audios/{sounds.value}`)
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
                for i,v in coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame:GetChildren() do
                    if v.Name:sub(1, 2) == 'p_' then
                        v.Visible = false
                    end
                end
                coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame.ChildAdded:Connect(function(v)
                    if v.Name:sub(1, 2) == 'p_' then
                        v.Visible = false
                    end
                end)
            else 
                for i,v in coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame:GetChildren() do
                    if v.Name:sub(1, 2) == 'p_' then
                        v.Visible = true
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


    local greenframe: TextLabel = Instance.new('Frame', macroelements.stopframe);
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
        image.Image = 'rbxassetid://75356581151796'
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

    local function getMS(ms)
        return ms > 999 and tonumber(`1.{ms}`) or ms > 9999 and tonumber(`1{ms:split('')[1]}.{ms}`) or (ms > 99 and tonumber(`0.{ms}`) or ms > 9 and tonumber(`0.0{ms}`)) or tonumber(`0.00{ms}`)
    end
    
    local function addMacro(name, positions, togglevec2)
        for i,v in positions do
            if v.frame and v.frame.Parent then
                v.frame:Destroy()
            end
        end
        local toggled = false
        local togglebutton = gui:addbutton(realgui, true, UDim2.fromOffset(55, 55))
        togglebutton.Position = UDim2.fromOffset(togglevec2.X, togglevec2.Y)
        togglebutton.Text = name
        togglebutton.TextSize = 14.5
        togglebutton.TextWrapped = true
        togglebutton.MouseButton1Click:Connect(function()
            toggled = not toggled
            if macromode.value == 'Toggle' then
                togglebutton.BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.new()
                if toggled then
                    repeat
                        for i,v in positions do
                            virtualInputManager:SendMouseButtonEvent(v.clickpos.X, v.clickpos.Y, Enum.UserInputType.MouseButton1.Value, true, lplr.PlayerGui, 1)
                            virtualInputManager:SendMouseButtonEvent(v.clickpos.X, v.clickpos.Y, Enum.UserInputType.MouseButton1.Value, false, lplr.PlayerGui, 1)
                            task.wait(macrocps.value / (macrocps.value or 7))
                        end
                        task.wait(1 / (macrocps.value or 7))
                    until not toggled or not togglebutton.Parent or macromode.value ~= 'Toggle'
                end
            elseif macromode.value == 'No Repeat' then
                togglebutton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                for i,v in positions do
                    virtualInputManager:SendMouseButtonEvent(v.clickpos.X, v.clickpos.Y, Enum.UserInputType.MouseButton1.Value, true, lplr.PlayerGui, 1)
                    virtualInputManager:SendMouseButtonEvent(v.clickpos.X, v.clickpos.Y, Enum.UserInputType.MouseButton1.Value, false, lplr.PlayerGui, 1)
                    task.wait(macrocps.value / (macrocps.value or 7))
                end
                togglebutton.BackgroundColor3 = Color3.new()
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
                if mouseenter and macromode.value == 'Repeat While Holding' then
                    togglebutton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    for i,v in positions do
                        virtualInputManager:SendMouseButtonEvent(v.clickpos.X, v.clickpos.Y, Enum.UserInputType.MouseButton1.Value, true, lplr.PlayerGui, 1)
                        virtualInputManager:SendMouseButtonEvent(v.clickpos.X, v.clickpos.Y, Enum.UserInputType.MouseButton1.Value, false, lplr.PlayerGui, 1)
                        task.wait(1 / (macrocps.value or 7))
                    end
                elseif macromode.value == 'Repeat While Holding' then
                    togglebutton.BackgroundColor3 = Color3.new()
                end
                task.wait(1 / (macrocps.value or 7))
            until not togglebutton.Parent
        end)

        gui:setdraggable(togglebutton, gui.gui.Enabled)
        
        table.insert(macroapis, {
            toggle = togglebutton,
            button = {Destroy = function() end}
        })
        table.clear(macros)
    end
    macro = gui.windows.mods:addmodule({
        name = 'Macro',
        show = false
    })
    local attempted = 0
    macro:addbutton({
        name = 'Add Macro',
        callback = function()
            if macroname.value == nil or macroname.value == '' then 
                gui:notify({
                    desc = 'Please enter a macro name first.'
                })
                return 
            end
            settingms = true
            macroelements.background.Visible = true
            gui:toggle(false)
            bloxstrapbutton.Visible = false
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
                            for i,v in listfiles('bloxstrap/logs/macros') do
                                delfile(v)
                            end
                            for i,v in macroapis do 
                                v.toggle:Destroy()
                                v.button:Destroy()
                            end
                            table.clear(macroapis)
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
        name = 'Default MS (Miliseconds)',
        number = true,
        default = 50
    })
    macroname = macro:addtextbox({
        name = 'Macro Name',
    })
    macromode = macro:adddropdown({
        name = 'Macro Types',
        list = {'No Repeat', 'Repeat While Holding', 'Toggle'},
        default = 1
    })
  
    gui.gui:GetPropertyChangedSignal('Enabled'):Connect(function()
        for i,v in macroapis do
            gui:setdraggable(v.toggle, gui.gui.Enabled)
        end
    end)
    
    inputservice.InputBegan:Connect(function(input, gp)
        if gp then return end
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            if settingms then
                table.insert(macros, {
                    frame = macroelements:new(UDim2.fromOffset(input.Position.X, input.Position.Y)),
                    clickpos = input.Position
                })
            elseif settingms == false then
                local jsonmacros = {}
                for i,v in macros do
                    table.insert(jsonmacros, {
                        clickpos = {X = v.clickpos.X, Y = v.clickpos.Y}
                    })
                end
                writefile(`bloxstrap/logs/macros/{macroname.value}.json`, httpservice:JSONEncode({
                    second = jsonmacros,
                    third = {X = input.Position.X, Y = input.Position.Y}
                }))
                settingms = nil
                macrolab.Visible = false
                bloxstrapbutton.Visible = true
                gui:toggle(true)
                addMacro(macroname.value, table.clone(macros), input.Position)
            end
        end
    end)

    for i,v in listfiles('bloxstrap/logs/macros') do
        local res = httpservice:JSONDecode(readfile(v))
        addMacro(v:gsub('bloxstrap/logs/macros/', ''):gsub('.json', ''), res.second, res.third)
    end
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
                imagelabel.Image = getgenv().getcustomasset('bloxstrap/images/'..crosshairimage.value) or ''
                Instance.new('UIScale', imagelabel).Scale = gui.scale
                table.insert(crosshair.cons, imagelabel)
            end
        end
    })
    local list = {}
    for i,v in listfiles('bloxstrap/images') do
        local new = v:split((identifyexecutor() == 'Swift' and '\\') or '/')
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
            if call and font and font.value ~= 'None' then
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
                local fontface = Font.new(getgenv().getcustomasset(val:gsub('.ttf', '.json'):gsub('.otf', '.json')), Enum.FontWeight.Regular)
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
            sethiddenproperty(lighting, 'Technology', (technology.value == 'Chosen by game' or not call) and 'Future' or lightingmode)
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
    local showfpscounter = nil
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
                end
                setfflag('FFlagDebugDisplayFPS', showfpscounter.toggled and 'true' or 'false')
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
    showfpscounter = gamegraphic:addtoggle({
        name = 'Show FPS Counter',
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
                    if robloxmenu.chat:FindFirstChild('5') then
                        if robloxmenu.chat['5']:FindFirstChild('Badge') then
                            creategradient(robloxmenu.chat['5'].Badge)
                            robloxmenu.chat['5'].Badge.Text.TextTruncate = 'None'
                        end
                        robloxmenu.chat['5'].ChildAdded:Connect(function(v)
                            creategradient(v)
                            v.Text.TextTruncate = 'None'
                        end)
                    end
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
            end
        end
    })
    generalvolume = general:addtextbox({
        name = 'Game Volume',
        number = true,
        default = .2,
        callback = function(val, ca)
            if ca then
                general:retoggle()
            end
        end
    })
    generalingameadvertisement = general:addtoggle({
        name = 'Enable In-game advertisements',
        callback = function()
            general:retoggle()
        end
    })
end)

if isfile('setting.bs') then
    writefile('bloxstrap/logs/blacklisted/'.. readfile('setting.bs').. '.txt', 'zoom')
    gui:notify({
        desc = `Attempted to use a fastflag that can\ncrash ur game ({readfile('setting.bs')})`
    })
    delfile('setting.bs')
end

local fastflageditor = nil
run(function()
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
        name = 'Parse Fast Flags (json)',
        ignore = true,
        callback = function(a, b)
            if b then
                local suc, oldfflag = pcall(function()
                    return httpservice:JSONDecode(readfile('bloxstrap/logs/fastflags.json'))
                end)
                if not suc then
                    oldfflag = {}
                end
                for i,v in httpservice:JSONDecode(a) do
                    if not isfile('bloxstrap/logs/blacklisted/'.. i.. '.txt') then
                        oldfflag[i] = v
                    end
                end
                for i,v in oldfflag do
                    if not isfile('bloxstrap/logs/blacklisted/'.. i.. '.txt') then
                        fastflageditor:addtextbox({
                            name = tostring(i),
                            ignore = true,
                            default = tostring(v),
                            callback = function(val, lost)
                                if val and lost then
                                    local suc, oldfflag = pcall(function()
                                        return httpservice:JSONDecode(readfile('bloxstrap/logs/fastflags.json'))
                                    end)
                                    if not suc then
                                        oldfflag = {}
                                    end
                                    oldfflag[i] = val
                                    writefile('bloxstrap/logs/fastflags.json', httpservice:JSONEncode(oldfflag))
                                    setfflag(i, val)
                                end
                            end
                        })
                    end
                end
                writefile('bloxstrap/logs/fastflags.json', httpservice:JSONEncode(oldfflag))
                if not getgenv().noshow then
                    gui:notify({
                        desc = 'Successfully entered fastflags.'
                    })
                end
            end
        end
    })
    fastflageditor:addbutton({
        name = 'Reset Fastflags',
        callback = function()
            gui.win:Dialog({
                Title = 'FastFlags Editor',
                Content = 'Are you sure you want to reset ur fastflags\n(this will restart ur roblox).',
                Buttons = {
                    {
                        Title = 'Confirm',
                        Callback = function()
                            writefile('bloxstrap/logs/fastflags.json', '{}')
                            task.delay(1, function()
                                game:Shutdown()
                            end)
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
end)

run(function()
    if not inputservice.KeyboardEnabled or pcdebug then
        local button = bloxstrapbutton

        gui.gui:GetPropertyChangedSignal('Enabled'):Connect(function()
            gui:setdraggable(button, gui.gui.Enabled)
        end)
        
        gui:setdraggable(button, gui.gui.Enabled)

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
            name = 'Button Transparency',
            number = true,
            default = 0,
            callback = function(val)
                if legitmode.toggled then
                    button.BackgroundTransparency = val
                    imagelabel.ImageTransparency = val
                    button.UIStroke.Transparency = val 
                end
            end
        })
        legitmode:addbutton({
            name = 'Reset Button Position',
            callback = function()
                button.Position = UDim2.fromScale(0.99, 0.5)
            end
        })
    end
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
        if not isfile('bloxstrap/logs/blacklisted/'.. i.. '.txt') then
            fastflags += 1
            fastflageditor:addtextbox({
                name = tostring(i),
                default = tostring(v),
                ignore = true,
                callback = function(val, lost)
                    if val and lost then
                        local suc, oldfflag = pcall(function()
                            return httpservice:JSONDecode(readfile('bloxstrap/logs/fastflags.json'))
                        end)
                        if not suc then
                            oldfflag = {}
                        end
                        oldfflag[i] = val
                        writefile('bloxstrap/logs/fastflags.json', httpservice:JSONEncode(oldfflag))
                        setfflag(i, val)
                    end
                end
            })
        end
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
    local songmodule = nil
    local songmode = {value =  'Storage'} --> spotify soon
    local songloop = {toggled = false}
    local songautoselect = {toggled = false}
    local songvolume = {value = 0.5}

    local songselected = {value = ''}

    local soundinstance = nil

    local songlist = listfiles('bloxstrap/songs')

    for i,v in songlist do
        songlist[i] = v:gsub('bloxstrap/songs/', '')
    end

    songmodule = gui.windows.music:addmodule({
        name = 'Play Selected Song',
        callback = function(call)
            if call then
                if soundinstance and soundinstance.Parent then
                    soundinstance:Destroy()
                end 
                if songselected.value == '' then
                    return gui:notify({
                        title = 'Music Player',
                        desc = 'Please select a song first!'
                    })
                end
                soundinstance = Instance.new('Sound', workspace)
                soundinstance.Volume = songvolume.value
                soundinstance.Looped = songloop.toggled
                soundinstance.SoundId = getgenv().getcustomasset(`bloxstrap/songs/{songselected.value}`)
                table.insert(songmodule.cons, soundinstance.Ended:Connect(function()
                    if not songloop.toggled and songautoselect.toggled then
                        if soundinstance and soundinstance.Parent then
                            soundinstance:Destroy()
                        end 
                        soundinstance = Instance.new('Sound', workspace)
                        soundinstance.Volume = songvolume.value
                        soundinstance.Looped = songloop.toggled
                        soundinstance.SoundId = getcustomasset(`bloxstrap/songs/{songlist[math.random(1, #songlist)]}`),
                        soundinstance:Play()
                    end
                end))
                soundinstance:Play()
            else
                if soundinstance and soundinstance.Parent then
                    soundinstance:Destroy()
                end 
            end
        end
    })
    songloop = songmodule:addtoggle({
        name = 'Loop Song',
        callback = function()
            songmodule:retoggle()
        end
    })
    songautoselect = songmodule:addtoggle({
        name = 'Auto Select Song On End',
        tooltip = 'Plays a random song when the current song ur playing ends.'
    })
    songmode = songmodule:adddropdown({
        name = 'Type',
        list = {'Storage'},
        default = 1
    })
    songselected = songmodule:adddropdown({
        name = 'Select Song',
        list = songlist,
        callback = function()
            songmodule:retoggle()
        end
    })
    songvolume = songmodule:addtextbox({
        name = 'Volume',
        number = true,
        default = 0.5,
        callback = function(val, rea)
            if rea and soundinstance and soundinstance.Parent then
                soundinstance.Volume = val
            end
        end
    })
end)

run(function()
    if coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame:FindFirstChild('p_7670822523') then
        coregui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame.p_7670822523.ChildrenFrame.NameFrame.BGFrame.OverlayFrame.PlayerIcon.Image = getcustomasset('bloxstrap/images/bloxstrap.png')
    end
end)

task.delay(3, function() 
    gui.configlib:loadconfig(gui) 
    gui:notify({
        Title = 'Bloxstrap',
        Description = `{inputservice.KeyboardEnabled and 'Press The RShift Key to open & close the ui' or 'Press the button at the middle right\n to open & close the ui'}.`,
        Duration = 10
    })
end)
