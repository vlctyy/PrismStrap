
if shared.loaded then
    shared.loaded:destruct()
end
if readfile('bloxstrap/selected.txt') == 'new' then
    return loadfile('bloxstrap/core/guis/new.lua')()
end
local httpservice = cloneref(game:GetService('HttpService')) :: HttpService
local tweenservice = cloneref(game:GetService('TweenService')) :: TweenService
local inputservice = cloneref(game:GetService('UserInputService')) :: UserInputService
local loadfile = function(file, errpath)
    if getgenv().developer then
        errpath = errpath or file:gsub('bloxstrap/', '')
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

local elements = {
    windows = {},
    assets = {
        intergrations = 'rbxassetid://94186399020089',
        ['engine settings'] = 'rbxassetid://94903440484497',
        mods = 'rbxassetid://126821269590599',
        appearence = 'rbxassetid://98935832640924',
        behaviour = 'rbxassetid://137701271745658',
        exit = 'rbxassetid://98193757882443'
    },
    configs = isfile('bloxstrap/logs/profile.json') and table.clone(httpservice:JSONDecode(readfile('bloxstrap/logs/profile.json'))) or {},
    tweenspeed = 0.2,
    saving = false,
    drags = {},
    enabled = true,
    modules = {},
    actualwins = {},
    configlib = loadfile('bloxstrap/core/config.lua')(),
    gui = nil,
    scale = 1,
    aprilfool = false--os.date('%m%d') == '0401'
} :: table

elements.randomStr = function(...)
    local lol = {...}
    if elements.aprilfool or lol[2] then
        if lol[2] then
            local str = ''
            for i = 1, lol[3] do
                str ..= string.char(math.random(32, 126))
            end
            return str
        else
            return string.reverse(lol[1])
        end
    end
    return ...
end

local guitype = readfile('bloxstrap/selected.txt')
local oldgui = loadfile(`bloxstrap/core/guis/{guitype}.lua`)()
elements.gui = oldgui.GUI
elements.gui.IgnoreGuiInset = true

local getString = elements.randomStr

local ScreenGui = Instance.new('ScreenGui', gethui and gethui() or cloneref(game:GetService('CoreGui'))) 
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new('Frame', ScreenGui) 
Frame.AnchorPoint = Vector2.new(1, 1)
Frame.BackgroundColor3 = Color3.new(1, 1, 1)
Frame.BackgroundTransparency = 1
Frame.ClipsDescendants = false
Frame.Active = false
Frame.Position = UDim2.new(1, -30, 1, -30)
Frame.BorderSizePixel = 0
Frame.Size = UDim2.new(0, 310, 1, -30)

local UIListLayout = Instance.new('UIListLayout', Frame) 
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout.Padding = UDim.new(0, 20)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

if elements.aprilfool then
    for i,v in game:GetDescendants() do
        if v.ClassName == 'Part' or v.ClassName == 'MeshPart' then
            v.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        elseif v.ClassName == 'Frame' then
            v.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        elseif v.ClassName == 'TextLabel' or v.ClassName == 'TextButton' or v.ClassName == 'TextBox' then
            v.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
            v.TextColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
            v:GetPropertyChangedSignal('Text'):Connect(function()
                v.Text = v.Text:gsub(v.ContentText, string.reverse(v.ContentText))
            end)
            v.Text = v.Text:gsub(v.ContentText, string.reverse(v.ContentText))
        end
    end
    
    game.DescendantAdded:Connect(function(v)
         if v.ClassName == 'Part' or v.ClassName == 'MeshPart' then
            v.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        elseif v.ClassName == 'Frame' then
            v.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        elseif v.ClassName == 'TextLabel' or v.ClassName == 'TextButton' or v.ClassName == 'TextBox' then
            v.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
            v.TextColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
            v:GetPropertyChangedSignal('Text'):Connect(function()
                v.Text = v.Text:gsub(v.ContentText, string.reverse(v.ContentText))
            end)
            v.Text = v.Text:gsub(v.ContentText, string.reverse(v.ContentText))
        end
    end)
end

function elements.callback(api, ...)
    local suc, res = pcall(api, ...)
    if not suc then
        --error(res)
    end
end

function elements:setdraggable(gui, bool)
    if self.drags[gui] == nil then
        local dragging
        local dragInput
        local dragStart
        local startPos
        
        gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        inputservice.InputChanged:Connect(function(input)
            if self.drags[gui] and input == dragInput and dragging then
                local delta = input.Position - dragStart
                tweenservice:Create(gui, TweenInfo.new(0.04, Enum.EasingStyle.Quad), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
            end
        end)
    end
    self.drags[gui] = bool
end

local window 
if guitype == 'old' then
    window = oldgui:MakeWindow({
        Title = getString('Bloxstrap'),
        SubTitle = ''
    })
else
    --loadstring(game:HttpGet('https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua'))():SetLibrary(oldgui)
    window = oldgui:CreateWindow({
        Title = getString('Bloxstrap'),
        SubTitle = '',
        TabWidth = 160,
        Size = UDim2.fromOffset(600, 450),
        Acrylic = false,
        Theme = 'Darker',
        MinimizeKey = Enum.KeyCode.RightShift
    })
    elements.win = window
    --savemanager:SetLibrary(oldgui)
end
local winframe
if guitype == 'fluent' then
    for i,v in oldgui.GUI:GetChildren() do
        if v:FindFirstChild('UIListLayout') then
            v.Visible = false
            break
        end
    end
    table.foreach(oldgui.GUI:GetChildren(), function(a,b)
        if b:GetChildren()[1].Name ~= 'UIListLayout' then
            winframe = b
            b.Active = true
            elements:setdraggable(b, true)
        end
    end)
end
elements.uiscaler = oldgui.GUI:FindFirstChildOfClass('UIScale') or Instance.new('UIScale', oldgui.GUI)

if elements.uiscaler then
    local scalecon = workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
        --elements.uiscaler.Scale = workspace.CurrentCamera.ViewportSize.Y / 700
        elements.scale = elements.uiscaler.Scale
    end)
    --elements.uiscaler.Scale = workspace.CurrentCamera.ViewportSize.Y / 700
    elements.scale = elements.uiscaler.Scale
end

function elements:clean(cons)
    for _, v in cons do
        if typeof(v) == 'Instance' then
            pcall(function()
                v:Destroy()
            end)
        elseif type(v) == 'thread' then
            pcall(task.cancel, v)
        else
            v:Disconnect() 
        end
    end
    table.clear(cons)
end


for i,v in {'Intergrations', 'Mods', 'Engine Settings', 'Appearence', 'Behaviour'} do
    local tabname = v:lower():gsub(' ', '')
    local args = {
        Title = getString(v),
        Icon = elements.assets[v:lower()]
    }
    elements.actualwins[tabname] = guitype == 'old' and window:MakeTab(args) or window:AddTab(args)
    elements.windows[tabname] = {}
end

if guitype == 'old' then
    for i,v in elements.windows do
        function v:addmodule(args)
            local api = {
                toggled = false,
                cons = {}
            }
            local actualapi = elements.actualwins[i]:AddSection(args.name)
            function api:addtoggle(args)
                local fakeapi = {toggled = false, cons = {}}
                elements.modules[args.name] = fakeapi
                local togglename = args.name
                local toggledef = args.default
                local togglecallback = args.callback or function() end
                local toggle = elements.actualwins[i]:AddToggle({
                    Title = togglename,
                    Callback = function(call)
                        api.toggled = call
                        if not api.toggled then
                            elements:clean(fakeapi.cons)
                        end
                        task.spawn(togglecallback, api.toggled)
                    end,
                    Default = toggledef
                })
                function fakeapi:setstate(bool)
                    toggle:Toggle(bool or not fakeapi.toggled)
                end
                function fakeapi:retoggle()
                    if fakeapi.toggled then
                        toggle:Toggle(false)
                        toggle:Toggle(true)
                    end
                end
                return fakeapi
            end

            local modtoggle = api:addtoggle({
                name = 'Enabled',
                callback = function(call: boolean)
                    api.toggled = call
                    if args.callback then
                        task.spawn(args.callback, api.toggled)
                    end
                end,
                exception = true
            })
            
            function api:retoggle(...)
                modtoggle:retoggle(...)
            end

            api.cons = modtoggle.cons

            function api:adddropdown(args)
                local fakeapi = {value = ''}
                elements.modules[args.name] = fakeapi
                local textbox = elements.actualwins[i]:AddDropdown({
                    Title = args.name,
                    Options = args.list,
                    Callback = function(val)
                        fakeapi.value = val
                        if args.callback then
                            task.spawn(elements.callback, args.callback, val, true)
                        end
                    end,
                    Default = args.default
                })
                function fakeapi:setvalue(...)
                    textbox:Set(...)
                end
                return fakeapi
            end
            function api:addtextbox(args)
                local fakeapi = {value = args.default or ''}
                elements.modules[args.name] = fakeapi
                
                local textbox = elements.actualwins[i]:AddTextBox({
                    Title = args.name,
                    Callback = function(val)
                        fakeapi.value = val
                        if args.callback then
                            task.spawn(elements.callback, args.callback, val, true)
                        end
                    end,
                    Default = args.default
                })
                function fakeapi:setvalue(...)
                    textbox:Set(...)
                end
                return fakeapi
            end
            return api
        end
    end
else
    for i,v in elements.windows do
        function v:addmodule(arguments)
            local moduleapi = {
                toggled = false,
                cons = {}
            }
            function moduleapi:addbutton(args)
                local api = {
                    callback = args.callback or function() end
                }
                elements.actualwins[i]:AddButton({
                    Title = getString(args.name), 
                    Description = args.subtext,
                    Callback = api.callback
                })
                return api
            end
            function moduleapi:addtoggle(args)
                if oldgui.Options[args.name] then
                    warn('sorted mod'.. elements.modules[args.name])
                    elements.modules[args.name].callback = args.callback
                    return elements.modules[args.name]
                end
                local api = {
                    toggled = (args.default or false), 
                    cons = {},
                    callback = args.callback or function() end,
                    ignore = args.ignore
                }
                elements.modules[args.name] = api
                local moduletoggle
                local notshow = (args.show == false and true) or nil
                if notshow then
                    api.toggled = true
                end
                if not notshow then 
                    moduletoggle = elements.actualwins[i]:AddToggle(args.name, {
                        Title = getString(args.name), 
                        Description = args.subtext 
                    })
                end
                function api:setstate(bool)
                    bool = bool or not api.toggled
                    if moduletoggle then
                        moduletoggle:SetValue(bool)
                    else
                        task.spawn(api.callback, bool)
                    end
                end
                if moduletoggle then
                    moduletoggle:OnChanged(function()
                        api.toggled = oldgui.Options[args.name].Value
                        if not api.toggled then
                            elements:clean(api.cons)
                        end
                        task.spawn(elements.callback, api.callback, api.toggled)
                    end)
                end
                function api:retoggle()
                    if api.toggled and api.callback then
                        api:setstate(false)
                        api:setstate(true)
                    end
                end
                if args.default then
                    if moduletoggle then
                        moduletoggle:SetValue(args.default)
                    else
                        api:setstate(args.default)
                    end
                end
                return api
            end
              
            moduleapi.toggled = (arguments.show == false and true) or arguments.default
            
            local modtoggle = moduleapi:addtoggle({
                name = arguments.name,
                show = arguments.show,
                callback = function(call: boolean)
                    moduleapi.toggled = call
                    if arguments.callback then
                        task.spawn(arguments.callback, moduleapi.toggled)
                    end
                end,
                exception = true
            })
            
            function moduleapi:retoggle(...)
                modtoggle:retoggle(...)
            end

            moduleapi.cons = modtoggle.cons

            function moduleapi:adddropdown(args)
                local api = {
                    array = args.list or {},
                    value = args.default or args.list[1],
                    ignore = args.ignore
                }
                elements.modules[args.name] = api
                local dropdown = elements.actualwins[i]:AddDropdown(args.name, {
                    Title = getString(args.name),
                    Values = api.array,
                    Multi = false
                })

                if api.value then
                    dropdown:SetValue(api.value)
                end

                dropdown:OnChanged(function(val)
                    api.value = val
                    if args.callback then
                        task.spawn(elements.callback, args.callback, val)
                    end
                end)

                function api:setvalue(val)
                    dropdown:SetValue(val)
                end
                return api
            end

            function moduleapi:addtextbox(args)
                local api = {
                    ignore = args.ignore,
                    value = args.default or ''
                }
                elements.modules[args.name] = api
                
                local box = elements.actualwins[i]:AddInput(args.name, {
                    Title = getString(args.name),
                    Default = args.default,
                    Numeric = args.number,
                    Finished = true,
                    Callback = function(val)
                        api.value = val
                        if args.callback then
                            task.spawn(elements.callback, args.callback, api.value, true)
                        end
                    end
                })         
                function api:setvalue(val)
                    box:SetValue(val)
                end 
                return api
            end

            return moduleapi
        end
    end
end

shared.loaded = {}

function shared.loaded:destruct()
    elements.gui:Destroy()
    shared.loaded = nil
end

local customelements = {}

function elements:toggle(bool)
    bool = bool or not self.enabled
    if winframe then
        winframe.Visible = bool
    else
        self.gui.Enabled = bool
    end
    for i,v in customelements do
        if v and v.Parent then
            v.Enabled = bool
        end
    end
    self.enabled = bool
end

function elements:addbutton(parent, pos, size)
    size = size or UDim2.fromOffset(44, 44)

    local button = Instance.new('TextButton', parent)
    button.BorderSizePixel = 0
    button.BackgroundTransparency = 0.3
    button.Text = ''
    button:GetPropertyChangedSignal('Text'):Connect(function()
        button.Text = getString(button.Text)
    end)
    if not pos then
        button.AnchorPoint = Vector2.new(1, 0.5)
    end
    button.BackgroundColor3 = Color3.new()
    button.Size = size
    button.Position = UDim2.fromScale(1, 0.5)
    button.ZIndex = 2000
    button.TextColor3 = Color3.new(1, 1, 1)
    
    Instance.new('UICorner', button).CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new('UIStroke', button)
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(1, 1, 1)
    
    table.insert(customelements, stroke)
    
    return button
end

function elements:notify(args)
    local title = args.Title or args.title or 'Bloxstrap'
    local description = args.Description or args.Desc or args.desc or args.subtext
    local duration = args.duration or args.Duration or 7

    title = getString(title)
    description = getString(description)

    local notif = Instance.new('Frame', Frame) 
    notif.Name = 'notif'
    notif.BackgroundTransparency = 1
    notif.Active = false
    notif.BackgroundColor3 = Color3.new(1, 1, 1)
    notif.ClipsDescendants = false
    notif.BorderSizePixel = 0
    notif.Size = UDim2.new(1, 0, 0, 72)

    local Frame_1 = Instance.new('Frame', notif) 
    Frame_1.BackgroundTransparency = 1
    Frame_1.Active = false
    Frame_1.BackgroundColor3 = Color3.new(1, 1, 1)
    Frame_1.ClipsDescendants = false
    Frame_1.BorderSizePixel = 0
    Frame_1.Position = UDim2.fromScale(1.1, 0)
    Frame_1.Size = UDim2.fromScale(1, 1)

    tweenservice:Create(Frame_1, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = UDim2.fromScale()}):Play()

    local Frame_2 = Instance.new('Frame', Frame_1) 
    Frame_2.BackgroundTransparency = 0.9
    Frame_2.Active = false
    Frame_2.BackgroundColor3 = Color3.new(1, 1, 1)
    Frame_2.ClipsDescendants = false
    Frame_2.BorderSizePixel = 0
    Frame_2.Size = UDim2.fromScale(1, 1)

    local ImageLabel = Instance.new('ImageLabel', Frame_2) 
    ImageLabel.ImageColor3 = Color3.new(0, 0, 0)
    ImageLabel.ScaleType = Enum.ScaleType.Slice
    ImageLabel.ClipsDescendants = false
    ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
    ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel.Image = 'rbxassetid://8992230677'
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Position = UDim2.fromScale(0.5, 0.5)
    ImageLabel.ImageTransparency = 0.7
    ImageLabel.Active = false
    ImageLabel.BorderSizePixel = 0
    ImageLabel.Size = UDim2.new(1, 120, 1, 116)

    Instance.new('UICorner', Frame_2)

    local Background = Instance.new('Frame', Frame_2) 
    Background.Name = 'Background'
    Background.BackgroundTransparency = 0.3
    Background.Active = false
    Background.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Background.ClipsDescendants = false
    Background.BorderSizePixel = 0
    Background.Size = UDim2.fromScale(1, 1)

    Instance.new('UICorner', Background)

    local Frame_3 = Instance.new('Frame', Frame_2) 
    Frame_3.BackgroundTransparency = 0.4000000059604645
    Frame_3.Active = false
    Frame_3.BackgroundColor3 = Color3.new(1, 1, 1)
    Frame_3.ClipsDescendants = false
    Frame_3.BorderSizePixel = 0
    Frame_3.Size = UDim2.fromScale(1, 1)

    Instance.new('UICorner', Frame_3)

    local UIGradient = Instance.new('UIGradient', Frame_3) 
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(0.156863, 0.156863, 0.156863)),
        ColorSequenceKeypoint.new(1, Color3.new(0.156863, 0.156863, 0.156863)),
    })
    UIGradient.Rotation = 90

    local ImageLabel_1 = Instance.new('ImageLabel', Frame_2) 
    ImageLabel_1.ScaleType = Enum.ScaleType.Tile
    ImageLabel_1.Active = false
    ImageLabel_1.Image = 'rbxassetid://9968344105'
    ImageLabel_1.BackgroundTransparency = 1
    ImageLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
    ImageLabel_1.ImageTransparency = 0.98
    ImageLabel_1.TileSize = UDim2.new(0, 128, 0, 128);
    ImageLabel_1.ClipsDescendants = false
    ImageLabel_1.BorderSizePixel = 0
    ImageLabel_1.Size = UDim2.fromScale(1, 1)

    Instance.new('UICorner', ImageLabel_1)

    local ImageLabel_2 = Instance.new('ImageLabel', Frame_2) 
    ImageLabel_2.ScaleType = Enum.ScaleType.Tile
    ImageLabel_2.Active = false
    ImageLabel_2.Image = 'rbxassetid://9968344227'
    ImageLabel_2.TileSize = UDim2.new(0, 128, 0, 128);
    ImageLabel_2.BackgroundTransparency = 1
    ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
    ImageLabel_2.ImageTransparency = 0.8999999761581421
    ImageLabel_2.ClipsDescendants = false
    ImageLabel_2.BorderSizePixel = 0
    ImageLabel_2.Size = UDim2.fromScale(1, 1)

    Instance.new('UICorner', ImageLabel_2)

    local Frame_4 = Instance.new('Frame', Frame_2) 
    Frame_4.BackgroundColor3 = Color3.new(1, 1, 1)
    Frame_4.BackgroundTransparency = 1
    Frame_4.Active = false
    Frame_4.ClipsDescendants = false
    Frame_4.ZIndex = 2
    Frame_4.BorderSizePixel = 0
    Frame_4.Size = UDim2.fromScale(1, 1)

    Instance.new('UICorner', Frame_4)

    local UIStroke = Instance.new('UIStroke', Frame_4) 
    UIStroke.Color = Color3.new(0.352941, 0.352941, 0.352941)
    UIStroke.Transparency = 0.5

    local Frame_5 = Instance.new('Frame', Frame_2) 
    Frame_5.BackgroundTransparency = 1
    Frame_5.Active = false
    Frame_5.BackgroundColor3 = Color3.new(1, 1, 1)
    Frame_5.ClipsDescendants = false
    Frame_5.BorderSizePixel = 0
    Frame_5.Size = UDim2.fromScale(1, 1)

    local TextLabel = Instance.new('TextLabel', Frame_1) 
    TextLabel.TextWrapped = true
    TextLabel.TextColor3 = Color3.new(0.941176, 0.941176, 0.941176)
    TextLabel.Text = title
    TextLabel.ClipsDescendants = false
    TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.fromOffset(14, 17)
    TextLabel.RichText = true
    TextLabel.Active = false
    TextLabel.TextSize = 13
    TextLabel.Size = UDim2.new(1, -12, 0, 12)

    local TextButton = Instance.new('TextButton', Frame_1) 
    TextButton.TextColor3 = Color3.new(0, 0, 0)
    TextButton.Text = ''
    TextButton.AutoButtonColor = false
    TextButton.AnchorPoint = Vector2.new(1, 0)
    TextButton.Font = Enum.Font.SourceSans
    TextButton.BackgroundTransparency = 1
    TextButton.Position = UDim2.new(1, -14, 0, 13)
    TextButton.BackgroundColor3 = Color3.new(1, 1, 1)
    TextButton.ClipsDescendants = false
    TextButton.TextSize = 14
    TextButton.Size = UDim2.fromOffset(20, 20)
    TextButton.MouseButton1Click:Connect(function()
        tweenservice:Create(Frame_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = UDim2.fromScale(1.1, 0)}):Play()
        task.wait(0.2)
        notif:Destroy()
    end)

    local ImageLabel_3 = Instance.new('ImageLabel', TextButton) 
    ImageLabel_3.ImageColor3 = Color3.new(0.941176, 0.941176, 0.941176)
    ImageLabel_3.ClipsDescendants = false
    ImageLabel_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_3.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel_3.Image = 'rbxassetid://9886659671'
    ImageLabel_3.BackgroundTransparency = 1
    ImageLabel_3.Position = UDim2.fromScale(0.5, 0.5)
    ImageLabel_3.BackgroundColor3 = Color3.new(1, 1, 1)
    ImageLabel_3.Active = false
    ImageLabel_3.BorderSizePixel = 0
    ImageLabel_3.Size = UDim2.fromOffset(16, 16)

    local Frame_6 = Instance.new('Frame', Frame_1) 
    Frame_6.BackgroundColor3 = Color3.new(1, 1, 1)
    Frame_6.BackgroundTransparency = 1
    Frame_6.Active = false
    Frame_6.ClipsDescendants = false
    Frame_6.Position = UDim2.fromOffset(14, 40)
    Frame_6.BorderSizePixel = 0
    Frame_6.AutomaticSize = Enum.AutomaticSize.Y
    Frame_6.Size = UDim2.new(1, -28, 0, 0)

    local UIListLayout_1 = Instance.new('UIListLayout', Frame_6) 
    UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center
    UIListLayout_1.Padding = UDim.new(0, 3)
    UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

    local TextLabel_1 = Instance.new('TextLabel', Frame_6) 
    TextLabel_1.TextWrapped = true
    TextLabel_1.TextColor3 = Color3.new(0.941176, 0.941176, 0.941176)
    TextLabel_1.Text = description
    TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
    TextLabel_1.Font = Enum.Font.Gotham
    TextLabel_1.BackgroundTransparency = 1
    TextLabel_1.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel_1.ClipsDescendants = false
    TextLabel_1.Active = false
    TextLabel_1.AutomaticSize = Enum.AutomaticSize.Y
    TextLabel_1.TextSize = 14
    TextLabel_1.Size = UDim2.new(1, 0, 0, 14)
    
    local TextLabel_2 = Instance.new('TextLabel', Frame_6) 
    TextLabel_2.Visible = false
    TextLabel_2.TextWrapped = true
    TextLabel_2.TextColor3 = Color3.new(0.666667, 0.666667, 0.666667)
    TextLabel_2.Text = ''
    TextLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
    TextLabel_2.Font = Enum.Font.Gotham
    TextLabel_2.BackgroundTransparency = 1
    TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel_2.ClipsDescendants = false
    TextLabel_2.Active = false
    TextLabel_2.TextSize = 14
    TextLabel_2.Size = UDim2.new(1, 0, 0, 14)

    task.delay(duration, function()
        if notif.Parent then
            tweenservice:Create(Frame_1, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = UDim2.fromScale(1.1, 0)}):Play()
            task.wait(0.5)
            if notif.Parent then
                notif:Destroy()
            end
        end
    end)
end

return elements
