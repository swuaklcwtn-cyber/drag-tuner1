local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

local FULLSCREEN_IMAGE_ID = "rbxassetid://128731569679349"
local FULLSCREEN_IMAGE_KEY = Enum.KeyCode.H

local Defaults = {
    Horsepower = 7000,
    TopSpeed = 450,
    Acceleration = 999,

    Handling = 5,
    BrakeForce = 50000,
    SteerAngle = 45,
    SteerMaxTorque = 999999,

    FinalDrive = 2.0,

    PeakRPM = 12000,
    Redline = 14000,
    EqPoint = 11500,

    SusStiffness = 30,
    SusDamping = 25000,

    DriftSlide = 0,
    RearGripDrift = 1,
    RearGripHandbrake = 1
}

local Settings = {}
for k, v in pairs(Defaults) do
    Settings[k] = v
end

local FieldMeta = {
    Engine = {
        {Key = "Horsepower", Label = "Horsepower", Min = 500, Max = 15000, Step = 50},
        {Key = "TopSpeed", Label = "Top Speed", Min = 100, Max = 700, Step = 5},
        {Key = "Acceleration", Label = "Acceleration", Min = 100, Max = 2500, Step = 25},
        {Key = "PeakRPM", Label = "Peak RPM", Min = 1000, Max = 25000, Step = 100},
        {Key = "Redline", Label = "Redline", Min = 1000, Max = 30000, Step = 100},
        {Key = "EqPoint", Label = "EQ Point", Min = 1000, Max = 25000, Step = 100}
    },

    Drive = {
        {Key = "FinalDrive", Label = "Final Drive", Min = 0.5, Max = 5, Step = 0.1},
        {Key = "Handling", Label = "Handling", Min = 1, Max = 10, Step = 1},
        {Key = "BrakeForce", Label = "Brake Force", Min = 1000, Max = 100000, Step = 500},
        {Key = "SteerAngle", Label = "Steer Angle", Min = 10, Max = 70, Step = 1},
        {Key = "SteerMaxTorque", Label = "Steer Torque", Min = 1000, Max = 1000000, Step = 1000}
    },

    Suspension = {
        {Key = "SusStiffness", Label = "Suspension Stiffness", Min = 1, Max = 100, Step = 1},
        {Key = "SusDamping", Label = "Suspension Damping", Min = 100, Max = 50000, Step = 100},
        {Key = "DriftSlide", Label = "Drift Slide", Min = 0, Max = 10, Step = 0.1},
        {Key = "RearGripDrift", Label = "Rear Grip Drift", Min = 0, Max = 5, Step = 0.1},
        {Key = "RearGripHandbrake", Label = "Rear Grip Handbrake", Min = 0, Max = 5, Step = 0.1}
    }
}

local NameAliases = {
    horsepower = "Horsepower",
    hp = "Horsepower",

    topspeed = "TopSpeed",
    ["top speed"] = "TopSpeed",
    maxspeed = "TopSpeed",

    acceleration = "Acceleration",
    accel = "Acceleration",

    handling = "Handling",

    brakeforce = "BrakeForce",
    ["brake force"] = "BrakeForce",

    steerangle = "SteerAngle",
    ["steer angle"] = "SteerAngle",

    steermaxtorque = "SteerMaxTorque",
    ["steer max torque"] = "SteerMaxTorque",

    finaldrive = "FinalDrive",
    ["final drive"] = "FinalDrive",

    peakrpm = "PeakRPM",
    ["peak rpm"] = "PeakRPM",

    redline = "Redline",

    eqpoint = "EqPoint",
    ["eq point"] = "EqPoint",

    susstiffness = "SusStiffness",
    ["sus stiffness"] = "SusStiffness",
    suspensionstiffness = "SusStiffness",
    ["suspension stiffness"] = "SusStiffness",

    susdamping = "SusDamping",
    ["sus damping"] = "SusDamping",
    suspensiondamping = "SusDamping",
    ["suspension damping"] = "SusDamping",

    driftslide = "DriftSlide",
    ["drift slide"] = "DriftSlide",

    reargripdrift = "RearGripDrift",
    ["rear grip drift"] = "RearGripDrift",

    reargriphandbrake = "RearGripHandbrake",
    ["rear grip handbrake"] = "RearGripHandbrake"
}

local Theme = {
    Bg = Color3.fromRGB(11, 12, 15),
    Panel = Color3.fromRGB(18, 20, 25),
    Panel2 = Color3.fromRGB(23, 26, 32),
    Panel3 = Color3.fromRGB(29, 33, 40),
    Panel4 = Color3.fromRGB(34, 39, 48),

    Stroke = Color3.fromRGB(52, 58, 70),
    StrokeSoft = Color3.fromRGB(39, 44, 54),

    Text = Color3.fromRGB(238, 242, 247),
    Muted = Color3.fromRGB(138, 148, 162),

    Accent = Color3.fromRGB(0, 170, 255),
    Accent2 = Color3.fromRGB(0, 115, 255),

    Green = Color3.fromRGB(55, 210, 125),
    Orange = Color3.fromRGB(255, 165, 55),
    Red = Color3.fromRGB(255, 72, 84),

    SliderBack = Color3.fromRGB(42, 48, 58),
    White = Color3.fromRGB(255, 255, 255)
}

local function tween(obj, props, time)
    pcall(function()
        TweenService:Create(
            obj,
            TweenInfo.new(time or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            props
        ):Play()
    end)
end

local function makeCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

local function makeStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function makeLabel(parent, text, size, font, color)
    local l = Instance.new("TextLabel")
    l.Parent = parent
    l.BackgroundTransparency = 1
    l.Text = text or ""
    l.Font = font or Enum.Font.Gotham
    l.TextSize = size or 12
    l.TextColor3 = color or Theme.Text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.BorderSizePixel = 0
    return l
end

local function formatNumber(n)
    n = tonumber(n) or 0

    if math.abs(n) >= 1000 then
        local str = tostring(math.floor(n))
        local result = ""

        while string.len(str) > 3 do
            result = "," .. string.sub(str, -3) .. result
            str = string.sub(str, 1, string.len(str) - 3)
        end

        return str .. result
    end

    if n % 1 ~= 0 then
        return tostring(math.floor(n * 10 + 0.5) / 10)
    end

    return tostring(math.floor(n))
end

local function clampToStep(value, min, max, step)
    value = math.clamp(value, min, max)

    if step and step > 0 then
        value = math.floor((value / step) + 0.5) * step
    end

    return math.clamp(value, min, max)
end

local guiParent = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui")

pcall(function()
    local old = guiParent:FindFirstChild("DragTunerV7_Tabs")
    if old then
        old:Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "DragTunerV7_Tabs"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.Parent = guiParent

local fullscreenImageVisible = false

local fullscreenImage = Instance.new("ImageLabel")
fullscreenImage.Parent = gui
fullscreenImage.Name = "FullscreenHImage"
fullscreenImage.Size = UDim2.new(1, 0, 1, 0)
fullscreenImage.Position = UDim2.new(0, 0, 0, 0)
fullscreenImage.BackgroundTransparency = 1
fullscreenImage.BorderSizePixel = 0
fullscreenImage.Image = FULLSCREEN_IMAGE_ID
fullscreenImage.ImageTransparency = 1
fullscreenImage.ScaleType = Enum.ScaleType.Stretch
fullscreenImage.Visible = false
fullscreenImage.ZIndex = 100000

local function setFullscreenImage(state)
    fullscreenImageVisible = state

    if state then
        fullscreenImage.Visible = true
        fullscreenImage.ImageTransparency = 1
        tween(fullscreenImage, {ImageTransparency = 0}, 0.12)
    else
        tween(fullscreenImage, {ImageTransparency = 1}, 0.12)

        delay(0.13, function()
            if not fullscreenImageVisible then
                fullscreenImage.Visible = false
            end
        end)
    end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if UIS:GetFocusedTextBox() then
        return
    end

    if input.KeyCode == FULLSCREEN_IMAGE_KEY then
        setFullscreenImage(not fullscreenImageVisible)
    end
end)

local notifyHolder = Instance.new("Frame")
notifyHolder.Parent = gui
notifyHolder.Size = UDim2.new(0, 280, 0, 140)
notifyHolder.Position = UDim2.new(0, 14, 1, -154)
notifyHolder.BackgroundTransparency = 1
notifyHolder.BorderSizePixel = 0
notifyHolder.ZIndex = 5000

local activeNotifies = {}

local function notify(text, mode)
    local color = Theme.Red

    if mode == "green" then
        color = Theme.Green
    elseif mode == "orange" then
        color = Theme.Orange
    end

    local n = Instance.new("Frame")
    n.Parent = notifyHolder
    n.Size = UDim2.new(0, 260, 0, 38)
    n.Position = UDim2.new(0, -280, 1, -38)
    n.BackgroundColor3 = Theme.Panel
    n.BackgroundTransparency = 0.04
    n.BorderSizePixel = 0
    n.ZIndex = 5001
    makeCorner(n, 9)
    makeStroke(n, Theme.StrokeSoft, 1, 0.25)

    local bar = Instance.new("Frame")
    bar.Parent = n
    bar.Size = UDim2.new(0, 4, 1, -12)
    bar.Position = UDim2.new(0, 8, 0, 6)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.ZIndex = 5002
    makeCorner(bar, 8)

    local dot = Instance.new("Frame")
    dot.Parent = n
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 20, 0.5, -4)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.ZIndex = 5002
    makeCorner(dot, 20)

    local label = makeLabel(n, text, 11, Enum.Font.GothamSemibold, Theme.Text)
    label.Position = UDim2.new(0, 36, 0, 0)
    label.Size = UDim2.new(1, -46, 1, 0)
    label.ZIndex = 5002

    table.insert(activeNotifies, n)

    for i, item in ipairs(activeNotifies) do
        local y = -38 - ((#activeNotifies - i) * 44)
        tween(item, {Position = UDim2.new(0, 0, 1, y)}, 0.16)
    end

    delay(2.3, function()
        tween(n, {
            Position = UDim2.new(0, -280, n.Position.Y.Scale, n.Position.Y.Offset),
            BackgroundTransparency = 1
        }, 0.18)

        delay(0.2, function()
            for i, item in ipairs(activeNotifies) do
                if item == n then
                    table.remove(activeNotifies, i)
                    break
                end
            end

            if n then
                n:Destroy()
            end

            for i, item in ipairs(activeNotifies) do
                local y = -38 - ((#activeNotifies - i) * 44)
                tween(item, {Position = UDim2.new(0, 0, 1, y)}, 0.16)
            end
        end)
    end)
end

local shadow = Instance.new("Frame")
shadow.Parent = gui
shadow.Size = UDim2.new(0, 324, 0, 384)
shadow.Position = UDim2.new(0.05, 8, 0.17, 10)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.58
shadow.BorderSizePixel = 0
shadow.ZIndex = 1
makeCorner(shadow, 12)

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 324, 0, 384)
frame.Position = UDim2.new(0.05, 0, 0.17, 0)
frame.BackgroundColor3 = Theme.Bg
frame.BorderSizePixel = 0
frame.Active = true
frame.ZIndex = 2
makeCorner(frame, 12)
makeStroke(frame, Theme.Stroke, 1, 0.15)

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 23, 29)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 12, 15))
})
mainGradient.Rotation = 90
mainGradient.Parent = frame

local top = Instance.new("Frame")
top.Parent = frame
top.Size = UDim2.new(1, 0, 0, 46)
top.BackgroundColor3 = Theme.Panel
top.BorderSizePixel = 0
top.Active = true
top.ZIndex = 3
makeCorner(top, 12)

local topMask = Instance.new("Frame")
topMask.Parent = top
topMask.Size = UDim2.new(1, 0, 0, 14)
topMask.Position = UDim2.new(0, 0, 1, -14)
topMask.BackgroundColor3 = Theme.Panel
topMask.BorderSizePixel = 0
topMask.ZIndex = 3

local accent = Instance.new("Frame")
accent.Parent = top
accent.Size = UDim2.new(0, 3, 0, 26)
accent.Position = UDim2.new(0, 11, 0, 10)
accent.BackgroundColor3 = Theme.Accent
accent.BorderSizePixel = 0
accent.ZIndex = 4
makeCorner(accent, 6)

local title = makeLabel(top, "DRAG TUNER", 14, Enum.Font.GothamBold, Theme.Text)
title.Position = UDim2.new(0, 22, 0, 5)
title.Size = UDim2.new(1, -90, 0, 20)
title.ZIndex = 4

local subtitle = makeLabel(top, "tabbed auto apply", 10, Enum.Font.Gotham, Theme.Muted)
subtitle.Position = UDim2.new(0, 23, 0, 24)
subtitle.Size = UDim2.new(1, -95, 0, 15)
subtitle.ZIndex = 4

local miniBtn = Instance.new("TextButton")
miniBtn.Parent = top
miniBtn.Size = UDim2.new(0, 28, 0, 24)
miniBtn.Position = UDim2.new(1, -38, 0, 11)
miniBtn.BackgroundColor3 = Theme.Panel3
miniBtn.Text = "—"
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 16
miniBtn.TextColor3 = Theme.Text
miniBtn.BorderSizePixel = 0
miniBtn.AutoButtonColor = false
miniBtn.ZIndex = 4
makeCorner(miniBtn, 7)
makeStroke(miniBtn, Theme.StrokeSoft, 1, 0.25)

local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil
local shadowStartPos = nil

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        shadowStartPos = shadow.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput and dragStart and startPos and shadowStartPos then
        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

        shadow.Position = UDim2.new(
            shadowStartPos.X.Scale,
            shadowStartPos.X.Offset + delta.X,
            shadowStartPos.Y.Scale,
            shadowStartPos.Y.Offset + delta.Y
        )
    end
end)

local tabBar = Instance.new("Frame")
tabBar.Parent = frame
tabBar.Size = UDim2.new(1, -16, 0, 30)
tabBar.Position = UDim2.new(0, 8, 0, 54)
tabBar.BackgroundColor3 = Theme.Panel
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 3
makeCorner(tabBar, 8)
makeStroke(tabBar, Theme.StrokeSoft, 1, 0.35)

local pagesHolder = Instance.new("Frame")
pagesHolder.Parent = frame
pagesHolder.Size = UDim2.new(1, -16, 1, -94)
pagesHolder.Position = UDim2.new(0, 8, 0, 90)
pagesHolder.BackgroundTransparency = 1
pagesHolder.BorderSizePixel = 0
pagesHolder.ZIndex = 3

local Tabs = {}
local Pages = {}
local activeTab = nil

local tabNames = {"Main", "Engine", "Drive", "Suspension", "Credits"}

local function setTab(name)
    activeTab = name

    for tabName, btn in pairs(Tabs) do
        if tabName == name then
            btn.BackgroundTransparency = 0
            tween(btn, {BackgroundColor3 = Theme.Accent}, 0.12)
            btn.TextColor3 = Theme.White
        else
            tween(btn, {BackgroundColor3 = Theme.Panel3}, 0.12)
            btn.BackgroundTransparency = 1
            btn.TextColor3 = Theme.Muted
        end
    end

    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end
end

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Parent = tabBar
    btn.Size = UDim2.new(1 / #tabNames, -3, 1, -6)
    btn.Position = UDim2.new((i - 1) / #tabNames, 2, 0, 3)
    btn.BackgroundColor3 = Theme.Panel3
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = Theme.Muted
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 4
    makeCorner(btn, 6)

    btn.MouseButton1Click:Connect(function()
        setTab(name)
    end)

    Tabs[name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Parent = pagesHolder
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Active = true
    page.ZIndex = 3

    local inner = Instance.new("Frame")
    inner.Parent = page
    inner.Name = "Inner"
    inner.Size = UDim2.new(1, -2, 0, 0)
    inner.BackgroundTransparency = 1
    inner.BorderSizePixel = 0
    inner.ZIndex = 3

    Pages[name] = page
end

local currentVehicle = nil
local autoSerial = 0
local sliderControls = {}

local function tuneTable(tbl)
    local changed = 0

    for key, value in pairs(Settings) do
        if tbl[key] ~= nil and tbl[key] ~= value then
            tbl[key] = value
            changed = changed + 1
        end
    end

    if tbl.Horsepower ~= nil or tbl.TopSpeed ~= nil or tbl.Acceleration ~= nil then
        for key, value in pairs(Settings) do
            if tbl[key] == nil then
                tbl[key] = value
                changed = changed + 1
            end
        end
    end

    return changed
end

local function applyTune(car, quiet)
    if not car then
        if not quiet then
            notify("No car selected", "red")
        end
        return 0
    end

    local changed = 0
    local touched = 0

    for _, v in ipairs(car:GetDescendants()) do
        if v:IsA("ModuleScript") then
            local ok, cfg = pcall(function()
                return require(v)
            end)

            if ok and type(cfg) == "table" then
                local c = tuneTable(cfg)

                if c > 0 then
                    changed = changed + c
                end

                if cfg.Horsepower ~= nil or cfg.TopSpeed ~= nil or cfg.Acceleration ~= nil then
                    touched = touched + 1
                end
            end
        end

        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local normalized = string.lower(v.Name)
            local key = NameAliases[normalized]

            if key and Settings[key] ~= nil then
                touched = touched + 1

                if v.Value ~= Settings[key] then
                    v.Value = Settings[key]
                    changed = changed + 1
                end
            end
        end
    end

    if changed > 0 then
        notify("Applied to " .. car.Name .. " | " .. tostring(changed) .. " changed", "green")
    elseif touched > 0 then
        notify("Found " .. car.Name .. " | values already matched", "orange")
    else
        notify("Found " .. car.Name .. " | no supported values", "orange")
    end

    return changed
end

local function scheduleAutoApply(reason)
    autoSerial = autoSerial + 1
    local thisSerial = autoSerial

    delay(0.16, function()
        if thisSerial ~= autoSerial then
            return
        end

        if currentVehicle then
            applyTune(currentVehicle, true)
        else
            notify("No car selected | values saved", "red")
        end
    end)
end

local function setCurrentVehicleFromSeat(seat)
    if not seat or not seat:IsA("VehicleSeat") then
        return
    end

    local occ = seat.Occupant

    if occ and LP.Character and occ.Parent == LP.Character then
        currentVehicle = seat:FindFirstAncestorOfClass("Model")

        if currentVehicle then
            notify("Selected " .. currentVehicle.Name, "green")
            scheduleAutoApply("vehicle selected")
        end
    end
end

local function seatSetup(seat)
    if not seat or not seat:IsA("VehicleSeat") then
        return
    end

    seat:GetPropertyChangedSignal("Occupant"):Connect(function()
        setCurrentVehicleFromSeat(seat)
    end)

    setCurrentVehicleFromSeat(seat)
end

local function scanSeats()
    local foundSeat = false

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            foundSeat = true
            seatSetup(obj)
            setCurrentVehicleFromSeat(obj)
        end
    end

    if currentVehicle then
        notify("Vehicle ready: " .. currentVehicle.Name, "green")
    elseif foundSeat then
        notify("Seats found | sit in one", "orange")
    else
        notify("No VehicleSeat found", "red")
    end
end

workspace.DescendantAdded:Connect(function(obj)
    seatSetup(obj)
end)

local function addCard(pageName, height)
    local page = Pages[pageName]
    local inner = page.Inner

    local y = inner.Size.Y.Offset

    local card = Instance.new("Frame")
    card.Parent = inner
    card.Size = UDim2.new(1, 0, 0, height)
    card.Position = UDim2.new(0, 0, 0, y)
    card.BackgroundColor3 = Theme.Panel2
    card.BorderSizePixel = 0
    card.ZIndex = 4
    makeCorner(card, 8)
    makeStroke(card, Theme.StrokeSoft, 1, 0.4)

    inner.Size = UDim2.new(1, -2, 0, y + height + 7)
    page.CanvasSize = UDim2.new(0, 0, 0, y + height + 10)

    return card
end

local function createButton(parent, text, xScale, xOffset, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(xScale, -4, 0, 30)
    btn.Position = UDim2.new(xOffset, 2, 1, -37)
    btn.BackgroundColor3 = Theme.Panel3
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Theme.Text
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = 5
    makeCorner(btn, 7)
    makeStroke(btn, Theme.StrokeSoft, 1, 0.3)

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = Theme.Panel4}, 0.12)
    end)

    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = Theme.Panel3}, 0.12)
    end)

    btn.MouseButton1Click:Connect(callback)

    return btn
end

local function createSlider(pageName, meta)
    local card = addCard(pageName, 48)

    local label = makeLabel(card, meta.Label, 12, Enum.Font.GothamBold, Theme.Text)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.Size = UDim2.new(1, -92, 0, 18)
    label.ZIndex = 5

    local valueBox = Instance.new("Frame")
    valueBox.Parent = card
    valueBox.Size = UDim2.new(0, 76, 0, 20)
    valueBox.Position = UDim2.new(1, -86, 0, 5)
    valueBox.BackgroundColor3 = Theme.Panel3
    valueBox.BorderSizePixel = 0
    valueBox.ZIndex = 5
    makeCorner(valueBox, 6)
    makeStroke(valueBox, Theme.StrokeSoft, 1, 0.38)

    local valueText = makeLabel(valueBox, formatNumber(Settings[meta.Key]), 11, Enum.Font.GothamBold, Theme.Accent)
    valueText.Size = UDim2.new(1, 0, 1, 0)
    valueText.TextXAlignment = Enum.TextXAlignment.Center
    valueText.ZIndex = 6

    local bar = Instance.new("Frame")
    bar.Parent = card
    bar.Size = UDim2.new(1, -22, 0, 6)
    bar.Position = UDim2.new(0, 11, 0, 33)
    bar.BackgroundColor3 = Theme.SliderBack
    bar.BorderSizePixel = 0
    bar.Active = true
    bar.ZIndex = 5
    makeCorner(bar, 20)

    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 6
    makeCorner(fill, 20)

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    })
    fillGradient.Parent = fill

    local knob = Instance.new("Frame")
    knob.Parent = bar
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0, 15, 0, 15)
    knob.BackgroundColor3 = Theme.White
    knob.BorderSizePixel = 0
    knob.Active = true
    knob.ZIndex = 7
    makeCorner(knob, 20)
    makeStroke(knob, Theme.Accent, 2, 0)

    local sliding = false

    local function setVisual(value, noApply)
        value = clampToStep(value, meta.Min, meta.Max, meta.Step)

        local percent = 0
        if meta.Max ~= meta.Min then
            percent = math.clamp((value - meta.Min) / (meta.Max - meta.Min), 0, 1)
        end

        Settings[meta.Key] = value
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, 0, 0.5, 0)
        valueText.Text = formatNumber(value)

        if not noApply then
            scheduleAutoApply(meta.Label .. " changed")
        end
    end

    local function updateFromInput(input)
        if not input then
            return
        end

        local barX = bar.AbsolutePosition.X
        local barW = bar.AbsoluteSize.X

        if barW <= 0 then
            return
        end

        local percent = math.clamp((input.Position.X - barX) / barW, 0, 1)
        local value = meta.Min + ((meta.Max - meta.Min) * percent)

        setVisual(value, false)
    end

    local function startSlide(input)
        sliding = true
        dragging = false
        tween(knob, {Size = UDim2.new(0, 19, 0, 19)}, 0.1)
        updateFromInput(input)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            startSlide(input)
        end
    end)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            startSlide(input)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and sliding then
            sliding = false
            tween(knob, {Size = UDim2.new(0, 15, 0, 15)}, 0.12)

            if currentVehicle then
                applyTune(currentVehicle, true)
            end
        end
    end)

    sliderControls[meta.Key] = {
        Set = setVisual
    }

    setVisual(Settings[meta.Key], true)
end

local mainCard = addCard("Main", 118)

local mainTitle = makeLabel(mainCard, "Auto Apply Tuner", 14, Enum.Font.GothamBold, Theme.Text)
mainTitle.Position = UDim2.new(0, 12, 0, 8)
mainTitle.Size = UDim2.new(1, -24, 0, 20)
mainTitle.ZIndex = 5

local mainDesc = makeLabel(mainCard, "Change a slider and it applies automatically to the selected VehicleSeat model. Press H to toggle the fullscreen image.", 11, Enum.Font.Gotham, Theme.Muted)
mainDesc.Position = UDim2.new(0, 12, 0, 31)
mainDesc.Size = UDim2.new(1, -24, 0, 34)
mainDesc.TextWrapped = true
mainDesc.TextYAlignment = Enum.TextYAlignment.Top
mainDesc.ZIndex = 5

createButton(mainCard, "RESET", 0.5, 0, function()
    for key, value in pairs(Defaults) do
        Settings[key] = value

        if sliderControls[key] then
            sliderControls[key].Set(value, true)
        end
    end

    scheduleAutoApply("reset")
    notify("Defaults restored", "orange")
end)

createButton(mainCard, "RESCAN", 0.5, 0.5, function()
    scanSeats()
end)

for pageName, fields in pairs(FieldMeta) do
    for _, meta in ipairs(fields) do
        createSlider(pageName, meta)
    end
end

local creditsCard = addCard("Credits", 150)

local creditsTitle = makeLabel(creditsCard, "Credits", 15, Enum.Font.GothamBold, Theme.Text)
creditsTitle.Position = UDim2.new(0, 12, 0, 10)
creditsTitle.Size = UDim2.new(1, -24, 0, 22)
creditsTitle.ZIndex = 5

local credit1 = makeLabel(creditsCard, "@9enda", 13, Enum.Font.GothamBold, Theme.Accent)
credit1.Position = UDim2.new(0, 12, 0, 44)
credit1.Size = UDim2.new(1, -24, 0, 20)
credit1.ZIndex = 5

local credit2 = makeLabel(creditsCard, "@0_bd3", 13, Enum.Font.GothamBold, Theme.Accent)
credit2.Position = UDim2.new(0, 12, 0, 68)
credit2.Size = UDim2.new(1, -24, 0, 20)
credit2.ZIndex = 5

local credit3 = makeLabel(creditsCard, "etc", 12, Enum.Font.Gotham, Theme.Muted)
credit3.Position = UDim2.new(0, 12, 0, 92)
credit3.Size = UDim2.new(1, -24, 0, 20)
credit3.ZIndex = 5

local creditsNote = makeLabel(creditsCard, "Compact tabbed auto-apply tuner UI.", 11, Enum.Font.Gotham, Theme.Muted)
creditsNote.Position = UDim2.new(0, 12, 0, 118)
creditsNote.Size = UDim2.new(1, -24, 0, 18)
creditsNote.ZIndex = 5

local minimized = false
local fullSize = frame.Size
local shadowFullSize = shadow.Size

miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        tabBar.Visible = false
        pagesHolder.Visible = false
        subtitle.Text = "minimized"
        miniBtn.Text = "+"

        tween(frame, {Size = UDim2.new(0, 324, 0, 46)}, 0.18)
        tween(shadow, {Size = UDim2.new(0, 324, 0, 46)}, 0.18)
    else
        tween(frame, {Size = fullSize}, 0.18)
        tween(shadow, {Size = shadowFullSize}, 0.18)

        delay(0.16, function()
            if not minimized then
                tabBar.Visible = true
                pagesHolder.Visible = true
                subtitle.Text = "tabbed auto apply"
                miniBtn.Text = "—"
            end
        end)
    end
end)

setTab("Main")
scanSeats()

notify("Drag Tuner V7 loaded", "orange")

print("Drag Tuner V7 Tabbed Auto UI Loaded")
