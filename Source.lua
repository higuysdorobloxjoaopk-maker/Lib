local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local UILib = {}
UILib.__index = UILib

local idCounter = 0
local function generateId()
    idCounter = idCounter + 1
    return "id" .. idCounter
end

function UILib.new(title)
    local self = setmetatable({}, UILib)
    
    self.elements = {}
    self.sections = {}
    
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "UILib_Interface"
    self.ScreenGui.Parent = PlayerGui
    self.ScreenGui.ResetOnSpawn = false

    -- MainFrame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 220, 0, 140)
    self.MainFrame.Position = UDim2.new(0.5, -110, 0.5, -70)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 20)
    self.MainFrame.BorderSizePixel = 1
    self.MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    self.MainFrame.Active = true
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui

    -- TopBar
    self.TopBar = Instance.new("Frame")
    self.TopBar.Size = UDim2.new(1, 0, 0, 25)
    self.TopBar.BackgroundColor3 = Color3.fromRGB(35, 58, 95)
    self.TopBar.BorderSizePixel = 0
    self.TopBar.Active = true
    self.TopBar.Parent = self.MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 28, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or "UI Library"
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSans
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = self.TopBar

    local CollapseBtn = Instance.new("TextButton")
    CollapseBtn.Size = UDim2.new(0,25,0,25)
    CollapseBtn.BackgroundTransparency = 1
    CollapseBtn.Text = "▼"
    CollapseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    CollapseBtn.TextSize = 10
    CollapseBtn.Parent = self.TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0,25,0,25)
    CloseBtn.Position = UDim2.new(1,-25,0,0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    CloseBtn.TextSize = 14
    CloseBtn.Parent = self.TopBar

    -- Content
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Size = UDim2.new(1,0,1,-25)
    self.ContentFrame.Position = UDim2.new(0,0,0,25)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.ScrollBarThickness = 2
    self.ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(35,58,95)
    self.ContentFrame.CanvasSize = UDim2.new(0,0,0,0)
    self.ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ContentFrame.Parent = self.MainFrame

    self.layout = Instance.new("UIListLayout")
    self.layout.Padding = UDim.new(0,8)
    self.layout.SortOrder = Enum.SortOrder.LayoutOrder
    self.layout.Parent = self.ContentFrame

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0,10)
    UIPadding.PaddingTop = UDim.new(0,10)
    UIPadding.Parent = self.ContentFrame

    -- Resize
    self.ResizeHandle = Instance.new("Frame")
    self.ResizeHandle.Size = UDim2.new(0,20,0,20)
    self.ResizeHandle.Position = UDim2.new(1,-20,1,-20)
    self.ResizeHandle.BackgroundTransparency = 1
    self.ResizeHandle.Active = true
    self.ResizeHandle.Parent = self.MainFrame

    local Triangle = Instance.new("TextLabel")
    Triangle.Size = UDim2.new(1,0,1,0)
    Triangle.BackgroundTransparency = 1
    Triangle.Text = "◢"
    Triangle.TextColor3 = Color3.fromRGB(35,58,95)
    Triangle.TextSize = 18
    Triangle.Font = Enum.Font.Arial
    Triangle.TextXAlignment = Enum.TextXAlignment.Right
    Triangle.TextYAlignment = Enum.TextYAlignment.Bottom
    Triangle.Parent = self.ResizeHandle

    -- DRAG
    local dragging = false
    local dragStart, startPos

    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- RESIZE
    local resizing = false
    local resizeStart, startSize

    self.ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = self.MainFrame.Size
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart

            local newWidth = math.max(70, startSize.X.Offset + delta.X)
            local newHeight = math.max(50, startSize.Y.Offset + delta.Y)

            self.MainFrame.Size = UDim2.new(0,newWidth,0,newHeight)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            resizing = false
        end
    end)

    -- MINIMIZE
    local isCollapsed = false
    local originalY = self.MainFrame.Size.Y.Offset

    CollapseBtn.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed

        if isCollapsed then
            originalY = self.MainFrame.Size.Y.Offset
            self.MainFrame:TweenSize(UDim2.new(0,self.MainFrame.Size.X.Offset,0,25),"Out","Quad",0.2,true)
            self.ContentFrame.Visible = false
            self.ResizeHandle.Visible = false
            CollapseBtn.Text = "►"
        else
            self.MainFrame:TweenSize(UDim2.new(0,self.MainFrame.Size.X.Offset,0,originalY),"Out","Quad",0.2,true)
            self.ContentFrame.Visible = true
            self.ResizeHandle.Visible = true
            CollapseBtn.Text = "▼"
        end
    end)

    -- CLOSE
    CloseBtn.MouseButton1Click:Connect(function()
        self.ScreenGui:Destroy()
    end)

    -- ADJUST LAYOUT ON SIZE CHANGE
    self.MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
        self:adjustLayout()
    end)
    self:adjustLayout()

    return self
end

function UILib:adjustLayout()
    local w = self.MainFrame.Size.X.Offset
    local cols = 1
    if w >= 500 then
        cols = 3
    end
    self.layout.FillDirection = (cols > 1) and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
    local areas = {}
    for _, child in ipairs(self.ContentFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name == "SectionFrame" then
            table.insert(areas, child)
        end
    end
    local contentW = self.ContentFrame.AbsoluteSize.X
    local leftPad = 10
    local rightPad = 10
    local availW = contentW - leftPad - rightPad
    local itemPad = self.layout.Padding.Offset
    if cols > 1 then
        local totalPad = (cols - 1) * itemPad
        local itemW = (availW - totalPad) / cols
        for _, area in ipairs(areas) do
            area.Size = UDim2.new(0, itemW, 0, area.Size.Y.Offset)
        end
    else
        for _, area in ipairs(areas) do
            area.Size = UDim2.new(1, -leftPad - rightPad, 0, area.Size.Y.Offset)
        end
    end
end

function UILib:createSection(name)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = "SectionFrame"
    SectionFrame.BackgroundColor3 = Color3.fromRGB(20,25,30)
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Parent = self.ContentFrame

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1,0,0,20)
    Header.BackgroundColor3 = Color3.fromRGB(35,58,95)
    Header.Parent = SectionFrame

    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Size = UDim2.new(1,-25,1,0)
    SectionTitle.Position = UDim2.new(0,5,0,0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = name
    SectionTitle.TextColor3 = Color3.fromRGB(255,255,255)
    SectionTitle.TextSize = 14
    SectionTitle.Font = Enum.Font.SourceSans
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = Header

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0,20,1,0)
    MinBtn.Position = UDim2.new(1,-20,0,0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "▼"
    MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
    MinBtn.TextSize = 10
    MinBtn.Parent = Header

    local SectionContent = Instance.new("Frame")
    SectionContent.Name = "SectionContent"
    SectionContent.Size = UDim2.new(1,0,0,0)
    SectionContent.Position = UDim2.new(0,0,0,20)
    SectionContent.BackgroundTransparency = 1
    SectionContent.Parent = SectionFrame

    local SectionList = Instance.new("UIListLayout")
    SectionList.Padding = UDim.new(0,5)
    SectionList.SortOrder = Enum.SortOrder.LayoutOrder
    SectionList.Parent = SectionContent

    local SectionPadding = Instance.new("UIPadding")
    SectionPadding.PaddingLeft = UDim.new(0,5)
    SectionPadding.PaddingTop = UDim.new(0,5)
    SectionPadding.Parent = SectionContent

    SectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentH = SectionList.AbsoluteContentSize.Y + 10
        SectionContent.Size = UDim2.new(1,0,0,contentH)
        SectionFrame.Size = UDim2.new(SectionFrame.Size.X.Scale, SectionFrame.Size.X.Offset, 0, 20 + contentH)
        self.ContentFrame.CanvasSize = UDim2.new(0,0,0,self.layout.AbsoluteContentSize.Y + 20)
    end)

    local isMin = false
    local origH = 0
    MinBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        if isMin then
            origH = SectionFrame.Size.Y.Offset
            SectionFrame:TweenSize(UDim2.new(SectionFrame.Size.X.Scale, SectionFrame.Size.X.Offset, 0,20),"Out","Quad",0.2,true)
            SectionContent.Visible = false
            MinBtn.Text = "►"
        else
            SectionFrame:TweenSize(UDim2.new(SectionFrame.Size.X.Scale, SectionFrame.Size.X.Offset, 0,origH),"Out","Quad",0.2,true)
            SectionContent.Visible = true
            MinBtn.Text = "▼"
        end
    end)

    local sectionId = generateId()
    self.sections[sectionId] = SectionFrame
    self:adjustLayout()
    return SectionFrame.SectionContent
end

function UILib:createLabel(section, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,0,0,15)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200,200,200)
    Label.TextSize = 14
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = section

    local id = generateId()
    self.elements[id] = {obj = Label, type = 'label'}
    return id
end

function UILib:createToggle(section, name, default, callback)
    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Size = UDim2.new(1,0,0,20)
    ToggleContainer.BackgroundTransparency = 1
    ToggleContainer.Parent = section

    local ToggleBox = Instance.new("Frame")
    ToggleBox.Size = UDim2.new(0,18,0,18)
    ToggleBox.BackgroundColor3 = default and Color3.fromRGB(120,190,255) or Color3.fromRGB(25,35,50)
    ToggleBox.BorderColor3 = default and Color3.fromRGB(35,58,95) or Color3.fromRGB(40,50,70)
    ToggleBox.BorderSizePixel = 2
    ToggleBox.Parent = ToggleContainer

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1,0)
    UICorner.Parent = ToggleBox

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1,0,1,0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleBox

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1,-25,1,0)
    ToggleLabel.Position = UDim2.new(0,25,0,0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(200,200,200)
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Enum.Font.Code
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleContainer

    local toggled = default or false
    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        ToggleBox.BackgroundColor3 = toggled and Color3.fromRGB(120,190,255) or Color3.fromRGB(25,35,50)
        ToggleBox.BorderColor3 = toggled and Color3.fromRGB(35,58,95) or Color3.fromRGB(40,50,70)
        if callback then callback(toggled) end
    end)

    local id = generateId()
    self.elements[id] = {obj = ToggleContainer, type = 'toggle', value = toggled, button = ToggleButton, box = ToggleBox, callback = callback}
    return id
end

function UILib:createButton(section, name, callback)
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Size = UDim2.new(1,0,0,20)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = section

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,1,0)
    Button.BackgroundColor3 = Color3.fromRGB(35,58,95)
    Button.BorderSizePixel = 0
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.TextSize = 14
    Button.Font = Enum.Font.Code
    Button.Parent = ButtonContainer

    Button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    local id = generateId()
    self.elements[id] = {obj = ButtonContainer, type = 'button', button = Button, callback = callback}
    return id
end

function UILib:createTextbox(section, name, placeholder, callback)
    local TextboxContainer = Instance.new("Frame")
    TextboxContainer.Size = UDim2.new(1,0,0,20)
    TextboxContainer.BackgroundTransparency = 1
    TextboxContainer.Parent = section

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.5,0,1,0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = name
    TextLabel.TextColor3 = Color3.fromRGB(200,200,200)
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.Code
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = TextboxContainer

    local Textbox = Instance.new("TextBox")
    Textbox.Size = UDim2.new(0.5,0,1,0)
    Textbox.Position = UDim2.new(0.5,0,0,0)
    Textbox.BackgroundColor3 = Color3.fromRGB(25,35,50)
    Textbox.BorderColor3 = Color3.fromRGB(40,50,70)
    Textbox.BorderSizePixel = 1
    Textbox.Text = ""
    Textbox.PlaceholderText = placeholder or ""
    Textbox.TextColor3 = Color3.fromRGB(255,255,255)
    Textbox.TextSize = 14
    Textbox.Font = Enum.Font.Code
    Textbox.Parent = TextboxContainer

    Textbox.FocusLost:Connect(function(enter)
        if enter and callback then callback(Textbox.Text) end
    end)

    local id = generateId()
    self.elements[id] = {obj = TextboxContainer, type = 'textbox', textbox = Textbox, callback = callback}
    return id
end

function UILib:createSlider(section, name, min, max, default, callback)
    local SliderContainer = Instance.new("Frame")
    SliderContainer.Size = UDim2.new(1,0,0,20)
    SliderContainer.BackgroundTransparency = 1
    SliderContainer.Parent = section

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(0.4,0,1,0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name
    SliderLabel.TextColor3 = Color3.fromRGB(200,200,200)
    SliderLabel.TextSize = 14
    SliderLabel.Font = Enum.Font.Code
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderContainer

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.6,0,0.5,0)
    SliderFrame.Position = UDim2.new(0.4,0,0.25,0)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(25,35,50)
    SliderFrame.BorderColor3 = Color3.fromRGB(40,50,70)
    SliderFrame.BorderSizePixel = 1
    SliderFrame.Parent = SliderContainer

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0,0,1,0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(120,190,255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderFrame

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0,10,2,0)
    SliderButton.Position = UDim2.new(0,-5, -0.5,0)
    SliderButton.BackgroundColor3 = Color3.fromRGB(35,58,95)
    SliderButton.BorderSizePixel = 0
    SliderButton.Text = ""
    SliderButton.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0,50,1,0)
    ValueLabel.Position = UDim2.new(1,5,0,0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Color3.fromRGB(200,200,200)
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.Parent = SliderContainer

    local value = default or min
    local function updateValue(pos)
        local percent = math.clamp((pos - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * percent
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderButton.Position = UDim2.new(percent, -5, -0.5, 0)
        ValueLabel.Text = math.round(value)
        if callback then callback(value) end
    end

    updateValue(SliderFrame.AbsolutePosition.X + (SliderFrame.AbsoluteSize.X * ((value - min) / (max - min))))

    local sliding = false
    SliderButton.MouseButton1Down:Connect(function()
        sliding = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X)
        end
    end)

    local id = generateId()
    self.elements[id] = {obj = SliderContainer, type = 'slider', value = value, min = min, max = max, callback = callback}
    return id
end

function UILib:createColorPicker(section, name, default, callback)
    local ColorPickerContainer = Instance.new("Frame")
    ColorPickerContainer.Size = UDim2.new(1,0,0,80)
    ColorPickerContainer.BackgroundTransparency = 1
    ColorPickerContainer.Parent = section

    local CPLabel = Instance.new("TextLabel")
    CPLabel.Size = UDim2.new(1,0,0,20)
    CPLabel.BackgroundTransparency = 1
    CPLabel.Text = name
    CPLabel.TextColor3 = Color3.fromRGB(200,200,200)
    CPLabel.TextSize = 14
    CPLabel.Font = Enum.Font.Code
    CPLabel.TextXAlignment = Enum.TextXAlignment.Left
    CPLabel.Parent = ColorPickerContainer

    local RSlider = self:createSlider(ColorPickerContainer, "R", 0, 255, default.R * 255, function(v) self:update(id, {r = v/255}) end)
    local GSlider = self:createSlider(ColorPickerContainer, "G", 0, 255, default.G * 255, function(v) self:update(id, {g = v/255}) end)
    local BSlider = self:createSlider(ColorPickerContainer, "B", 0, 255, default.B * 255, function(v) self:update(id, {b = v/255}) end)

    local Preview = Instance.new("Frame")
    Preview.Size = UDim2.new(0,30,0,30)
    Preview.Position = UDim2.new(1,-30,0,20)
    Preview.BackgroundColor3 = default
    Preview.BorderSizePixel = 1
    Preview.BorderColor3 = Color3.fromRGB(60,60,60)
    Preview.Parent = ColorPickerContainer

    local color = default
    local id = generateId()
    self.elements[id] = {obj = ColorPickerContainer, type = 'colorpicker', value = color, preview = Preview, rslider = RSlider, gslider = GSlider, bslider = BSlider, callback = callback}
    return id
end

function UILib:createDropdown(section, name, type, items, callback)
    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Size = UDim2.new(1,0,0,20)
    DropdownContainer.BackgroundTransparency = 1
    DropdownContainer.Parent = section

    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Size = UDim2.new(0.5,0,1,0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = name
    DropdownLabel.TextColor3 = Color3.fromRGB(200,200,200)
    DropdownLabel.TextSize = 14
    DropdownLabel.Font = Enum.Font.Code
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownContainer

    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(0.5,0,1,0)
    DropdownButton.Position = UDim2.new(0.5,0,0,0)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(25,35,50)
    DropdownButton.BorderColor3 = Color3.fromRGB(40,50,70)
    DropdownButton.BorderSizePixel = 1
    DropdownButton.Text = "Select"
    DropdownButton.TextColor3 = Color3.fromRGB(255,255,255)
    DropdownButton.TextSize = 14
    DropdownButton.Font = Enum.Font.Code
    DropdownButton.Parent = DropdownContainer

    local DropdownList = Instance.new("ScrollingFrame")
    DropdownList.Size = UDim2.new(1,0,0,100)
    DropdownList.Position = UDim2.new(0,0,1,0)
    DropdownList.BackgroundColor3 = Color3.fromRGB(15,17,20)
    DropdownList.BorderColor3 = Color3.fromRGB(60,60,60)
    DropdownList.BorderSizePixel = 1
    DropdownList.ScrollBarThickness = 2
    DropdownList.Visible = false
    DropdownList.ZIndex = 10
    DropdownList.Parent = DropdownContainer

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0,2)
    ListLayout.Parent = DropdownList

    local ListPadding = Instance.new("UIPadding")
    ListPadding.PaddingTop = UDim.new(0,2)
    ListPadding.PaddingLeft = UDim.new(0,2)
    ListPadding.Parent = DropdownList

    DropdownButton.MouseButton1Click:Connect(function()
        DropdownList.Visible = not DropdownList.Visible
    end)

    local selected = type == 'multi' and {} or nil
    local itemObjs = {}

    local function addItem(text)
        if itemObjs[text] then return end
        local ItemButton = Instance.new("TextButton")
        ItemButton.Size = UDim2.new(1,0,0,20)
        ItemButton.BackgroundTransparency = 1
        ItemButton.Text = text
        ItemButton.TextColor3 = Color3.fromRGB(200,200,200)
        ItemButton.TextSize = 14
        ItemButton.Font = Enum.Font.Code
        ItemButton.TextXAlignment = Enum.TextXAlignment.Left
        ItemButton.Parent = DropdownList

        if type == 'multi' then
            local CheckBox = Instance.new("Frame")
            CheckBox.Size = UDim2.new(0,18,0,18)
            CheckBox.Position = UDim2.new(1,-25,0,1)
            CheckBox.BackgroundColor3 = Color3.fromRGB(25,35,50)
            CheckBox.BorderColor3 = Color3.fromRGB(40,50,70)
            CheckBox.BorderSizePixel = 2
            CheckBox.Parent = ItemButton
            local UICorner = Instance.new("UICorner")
            UICorner.Parent = CheckBox
            ItemButton.MouseButton1Click:Connect(function()
                local isSelected = table.find(selected, text)
                if isSelected then
                    table.remove(selected, isSelected)
                    CheckBox.BackgroundColor3 = Color3.fromRGB(25,35,50)
                    CheckBox.BorderColor3 = Color3.fromRGB(40,50,70)
                else
                    table.insert(selected, text)
                    CheckBox.BackgroundColor3 = Color3.fromRGB(120,190,255)
                    CheckBox.BorderColor3 = Color3.fromRGB(35,58,95)
                end
                DropdownButton.Text = #selected > 0 and table.concat(selected, ", ") or "Select"
                if callback then callback(selected) end
            end)
        else
            ItemButton.MouseButton1Click:Connect(function()
                selected = text
                DropdownButton.Text = text
                DropdownList.Visible = false
                if callback then callback(selected) end
            end)
        end
        itemObjs[text] = ItemButton
        DropdownList.CanvasSize = UDim2.new(0,0,0,ListLayout.AbsoluteContentSize.Y + 4)
    end

    local function removeItem(text)
        if itemObjs[text] then
            itemObjs[text]:Destroy()
            itemObjs[text] = nil
            if type == 'multi' then
                local idx = table.find(selected, text)
                if idx then table.remove(selected, idx) end
            elseif selected == text then
                selected = nil
            end
            DropdownList.CanvasSize = UDim2.new(0,0,0,ListLayout.AbsoluteContentSize.Y + 4)
        end
    end

    local function hasItem(text)
        return itemObjs[text] \~= nil
    end

    for _, item in ipairs(items or {}) do
        addItem(item)
    end

    if type == 'multi' then
        local SelectAll = Instance.new("TextButton")
        SelectAll.Size = UDim2.new(1,0,0,20)
        SelectAll.BackgroundTransparency = 1
        SelectAll.Text = "Select All"
        SelectAll.TextColor3 = Color3.fromRGB(200,200,200)
        SelectAll.TextSize = 14
        SelectAll.Font = Enum.Font.Code
        SelectAll.TextXAlignment = Enum.TextXAlignment.Left
        SelectAll.Parent = DropdownList
        SelectAll.LayoutOrder = -1
        SelectAll.MouseButton1Click:Connect(function()
            selected = {}
            for text, obj in pairs(itemObjs) do
                table.insert(selected, text)
                obj.CheckBox.BackgroundColor3 = Color3.fromRGB(120,190,255)
                obj.CheckBox.BorderColor3 = Color3.fromRGB(35,58,95)
            end
            DropdownButton.Text = #selected > 0 and table.concat(selected, ", ") or "Select"
            if callback then callback(selected) end
        end)
        DropdownList.CanvasSize = UDim2.new(0,0,0,ListLayout.AbsoluteContentSize.Y + 4)
    end

    if type == 'players' then
        local function updatePlayers()
            local currentPlayers = {}
            for _, p in ipairs(Players:GetPlayers()) do
                table.insert(currentPlayers, p.Name)
            end
            for text in pairs(itemObjs) do
                if not table.find(currentPlayers, text) then
                    removeItem(text)
                end
            end
            for _, name in ipairs(currentPlayers) do
                if not hasItem(name) then
                    addItem(name)
                end
            end
        end
        updatePlayers()
        spawn(function()
            while DropdownContainer.Parent do
                wait(5)
                updatePlayers()
            end
        end)
    end

    local id = generateId()
    self.elements[id] = {
        obj = DropdownContainer, 
        type = 'dropdown', 
        ddtype = type, 
        selected = selected, 
        callback = callback, 
        addItem = addItem, 
        removeItem = removeItem, 
        hasItem = hasItem,
        button = DropdownButton
    }
    return id
end

function UILib:update(id, props)
    local el = self.elements[id]
    if not el then return end

    if el.type == 'toggle' then
        if props.toggle \~= nil then
            el.value = props.toggle
            el.box.BackgroundColor3 = el.value and Color3.fromRGB(120,190,255) or Color3.fromRGB(25,35,50)
            el.box.BorderColor3 = el.value and Color3.fromRGB(35,58,95) or Color3.fromRGB(40,50,70)
            if el.callback then el.callback(el.value) end
        end
    elseif el.type == 'button' then
        if props.text then
            el.button.Text = props.text
        end
    elseif el.type == 'textbox' then
        if props.text then
            el.textbox.Text = props.text
        end
    elseif el.type == 'slider' then
        if props.value then
            el.value = math.clamp(props.value, el.min, el.max)
            -- update visual, but since no direct function, assume user sets
        end
    elseif el.type == 'colorpicker' then
        local changed = false
        if props.r then el.value = Color3.new(props.r, el.value.G, el.value.B) changed = true end
        if props.g then el.value = Color3.new(el.value.R, props.g, el.value.B) changed = true end
        if props.b then el.value = Color3.new(el.value.R, el.value.G, props.b) changed = true end
        if changed then
            el.preview.BackgroundColor3 = el.value
            if el.callback then el.callback(el.value) end
            -- update sliders if needed, but recursive, skip
        end
    elseif el.type == 'dropdown' then
        if props.addItem then
            el.addItem(props.addItem)
        end
        if props.removeItem then
            el.removeItem(props.removeItem)
        end
        if props.text then
            el.button.Text = props.text
        end
    end
end

function UILib:addDropdownItem(id, item)
    local el = self.elements[id]
    if el and el.type == 'dropdown' then
        el.addItem(item)
    end
end

function UILib:removeDropdownItem(id, item)
    local el = self.elements[id]
    if el and el.type == 'dropdown' then
        el.removeItem(item)
    end
end

function UILib:hasDropdownItem(id, item)
    local el = self.elements[id]
    if el and el.type == 'dropdown' then
        return el.hasItem(item)
    end
    return false
end

return UILib
