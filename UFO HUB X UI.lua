-- UFO HUB X UI — Delta-first Compatible Demo (all-in-one)
-- Features: 4 Themes, Scale (80–130%), Visibility (100/50/0), Left/Right independent scroll,
-- Header controls: Minimize, Expand/Restore, Close (hide), Logo ID input
-- Safe parent for most executors: gethui() -> CoreGui -> PlayerGui

local Services = setmetatable({}, {__index=function(_,k) return game:GetService(k) end})
local Players, UIS, RunService = Services.Players, Services.UserInputService, Services.RunService

-- Resolve LocalPlayer even if executor injects weirdly
local LP = Players.LocalPlayer or Players:GetPlayers()[1]
while not LP do task.wait(); LP = Players.LocalPlayer or Players:GetPlayers()[1] end

-- Choose a safe GUI parent
local function getSafeParent()
    local ok, gui = pcall(function()
        if gethui then
            local h = gethui()
            if typeof(h) == "Instance" then return h end
        end
        return Services.CoreGui
    end)
    if ok and gui then return gui end
    return LP:WaitForChild("PlayerGui")
end

local GUI_PARENT = getSafeParent()

-- Clean previous
local EXIST = GUI_PARENT:FindFirstChild("UFO_HUB_X_UI")
if EXIST then EXIST:Destroy() end

-- Debug helper
local function log(...) pcall(print, "[UFO HUB X]", ...) end
log("Loaded ✅  executor parent:", GUI_PARENT:GetFullName())

-- ===== Theme Tokens =====
local Theme = {
    name = "Alien Green",
    Border = Color3.fromRGB(0,230,118),  -- #00E676
    Text = Color3.fromRGB(230,255,230),
    TextMuted = Color3.fromRGB(168,213,184),
    Panel = Color3.fromRGB(10,15,10),
    Header = Color3.fromRGB(10,20,10),
    Danger = Color3.fromRGB(255,59,59)
}
local THEMES = {
    ["Alien Green"] = {
        Border = Color3.fromRGB(0,230,118), Text=Color3.fromRGB(230,255,230),
        TextMuted=Color3.fromRGB(168,213,184), Panel=Color3.fromRGB(10,15,10),
        Header=Color3.fromRGB(10,20,10), Danger=Color3.fromRGB(255,59,59)
    },
    ["Demon Red"] = {
        Border = Color3.fromRGB(255,59,59), Text=Color3.fromRGB(255,240,240),
        TextMuted=Color3.fromRGB(255,160,160), Panel=Color3.fromRGB(14,8,8),
        Header=Color3.fromRGB(22,10,10), Danger=Color3.fromRGB(255,80,80)
    },
    ["Royal Gold"] = {
        Border = Color3.fromRGB(212,175,55), Text=Color3.fromRGB(255,246,220),
        TextMuted=Color3.fromRGB(235,210,150), Panel=Color3.fromRGB(16,12,6),
        Header=Color3.fromRGB(22,18,8), Danger=Color3.fromRGB(255,90,90)
    },
    ["Galaxy Guardian"] = {
        Border = Color3.fromRGB(46,224,170), Text=Color3.fromRGB(220,255,245),
        TextMuted=Color3.fromRGB(170,220,205), Panel=Color3.fromRGB(6,10,8),
        Header=Color3.fromRGB(8,16,14), Danger=Color3.fromRGB(255,80,80)
    },
}

-- ===== Config State =====
local state = {
    scale = 1.00,        -- 0.8 .. 1.3
    visibility = 1.00,   -- 1.00 = 100% (ทึบ), 0.5 = 50%, 0.0 = โปร่ง
    expanded = false,
    hidden = false,
    logoId = nil,
    themeName = "Alien Green"
}

-- ===== UI FACTORY =====
local function stroke(parent, thickness, color)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Thickness = thickness or 1
    s.Color = color or Theme.Border
    s.Parent = parent
    return s
end
local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = parent
    return c
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UFO_HUB_X_UI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GUI_PARENT

-- Root window
local Root = Instance.new("Frame")
Root.Name = "Root"
Root.AnchorPoint = Vector2.new(0.5,0.5)
Root.Size = UDim2.new(0, 720, 0, 420)
Root.Position = UDim2.new(0.5,0,0.5,0)
Root.BackgroundColor3 = Color3.new(0,0,0)
Root.Parent = ScreenGui
corner(Root, 12); stroke(Root, 2, Theme.Border)

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1,0,0,36)
Header.BackgroundColor3 = Theme.Header
Header.Parent = Root
stroke(Header, 1, Theme.Border)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,44,0,0)
Title.Size = UDim2.new(1, -140, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "UFO HUB X  |  v1.0"
Title.TextSize = 18
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Logo (supports Roblox ImageId)
local Logo = Instance.new("ImageLabel")
Logo.BackgroundTransparency = 1
Logo.Size = UDim2.new(0,28,0,28)
Logo.Position = UDim2.new(0,6,0.5,-14)
Logo.ScaleType = Enum.ScaleType.Fit
Logo.ImageTransparency = 0
Logo.Parent = Header
-- default vector-ish dot if no ID:
Logo.Image = "rbxassetid://7734068321" -- placeholder circle icon

-- Header Controls
local function makeHdrBtn(txt, offX, color)
    local b = Instance.new("TextButton")
    b.BackgroundTransparency = 1
    b.Size = UDim2.new(0,28,0,28)
    b.Position = UDim2.new(1, offX, 0.5, -14)
    b.Text = txt
    b.TextColor3 = color
    b.Font = Enum.Font.GothamBold
    b.TextSize = 20
    b.AutoButtonColor = false
    b.Parent = Header
    return b
end
local BtnMin = makeHdrBtn("-", -88, Theme.Border)
local BtnExp = makeHdrBtn("⬜", -56, Theme.Border)
local BtnClose = makeHdrBtn("X", -24, Theme.Danger)

-- Drag window
do
    local dragging, startPos, startMouse
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = Root.Position
            startMouse = UIS:GetMouseLocation()
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = UIS:GetMouseLocation() - startMouse
            Root.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)
end

-- Layout: Left / Right
local Left = Instance.new("Frame")
Left.Name = "Left"
Left.BackgroundColor3 = Theme.Panel
Left.Position = UDim2.new(0,0,0,36)
Left.Size = UDim2.new(0,200,1,-36)
Left.Parent = Root
corner(Left, 10); stroke(Left,1,Theme.Border)

local Right = Instance.new("Frame")
Right.Name = "Right"
Right.BackgroundColor3 = Theme.Panel
Right.Position = UDim2.new(0,200,0,36)
Right.Size = UDim2.new(1,-200,1,-36)
Right.Parent = Root
corner(Right, 10); stroke(Right,1,Theme.Border)

-- Independent Scrolls
local function makeScroll(parent, padding)
    local sc = Instance.new("ScrollingFrame")
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.Size = UDim2.new(1,0,1,0)
    sc.CanvasSize = UDim2.new(0,0,0,0)
    sc.ScrollBarThickness = 5
    sc.ScrollBarImageColor3 = Theme.Border
    sc.Parent = parent
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, padding or 6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = sc
    lay.Changed:Connect(function(prop)
        if prop == "AbsoluteContentSize" then
            sc.CanvasSize = UDim2.fromOffset(0, lay.AbsoluteContentSize.Y+12)
        end
    end)
    return sc, lay
end

local LeftScroll = makeScroll(Left, 6)
local RightScroll = makeScroll(Right, 8)

-- Nav buttons (Left)
local function navBtn(text, active)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-12,0,36)
    b.Position = UDim2.new(0,6,0,0)
    b.BackgroundColor3 = Theme.Panel
    b.AutoButtonColor = false
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 16
    b.TextColor3 = active and Theme.Text or Theme.TextMuted
    b.Parent = LeftScroll
    corner(b,8); stroke(b,1,Theme.Border)
    b.MouseEnter:Connect(function() b.TextColor3 = Theme.Text end)
    b.MouseLeave:Connect(function() if not active then b.TextColor3 = Theme.TextMuted end end)
    return b
end

local tabs = {"Main","Terminal","Missions","Inventory","Upgrades","Utility","Visual","Settings"}
local tabButtons = {}
for _,t in ipairs(tabs) do
    tabButtons[t] = navBtn(t, t=="Main")
end

-- Simple content generators
local function label(parent, text, size)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1,-16,0,size or 28)
    l.Position = UDim2.new(0,8,0,0)
    l.Font = Enum.Font.GothamSemibold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    l.TextSize = 16
    l.TextColor3 = Theme.Text
    l.Parent = parent
    return l
end

local function rowToggle(parent, text, init, callback)
    local holder = Instance.new("Frame")
    holder.BackgroundColor3 = Theme.Panel
    holder.Size = UDim2.new(1,-16,0,40)
    holder.Position = UDim2.new(0,8,0,0)
    holder.Parent = parent
    corner(holder,8); stroke(holder,1,Theme.Border)

    local tl = Instance.new("TextLabel")
    tl.BackgroundTransparency = 1
    tl.Size = UDim2.new(1,-60,1,0)
    tl.Position = UDim2.new(0,10,0,0)
    tl.Font = Enum.Font.Gotham
    tl.Text = text
    tl.TextSize = 16
    tl.TextColor3 = Theme.Text
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = holder

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,40,0,24)
    btn.Position = UDim2.new(1,-50,0.5,-12)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = holder
    corner(btn,12); stroke(btn,1,Theme.Border)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,18,0,18)
    dot.Position = UDim2.new(init and 1 or 0, init and -20 or 2, 0.5, -9)
    dot.BackgroundColor3 = init and Theme.Border or Theme.TextMuted
    dot.Parent = btn
    corner(dot,9)

    local val = init
    local function set(v)
        val=v
        dot.Position = UDim2.new(v and 1 or 0, v and -20 or 2, 0.5, -9)
        dot.BackgroundColor3 = v and Theme.Border or Theme.TextMuted
        pcall(callback, v)
    end
    btn.MouseButton1Click:Connect(function() set(not val) end)
    return holder, set
end

local function rowButton(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-16,0,40)
    b.Position = UDim2.new(0,8,0,0)
    b.BackgroundColor3 = Theme.Panel
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 16
    b.TextColor3 = Theme.Text
    b.AutoButtonColor = false
    b.Parent = parent
    corner(b,8); stroke(b,1,Theme.Border)
    b.MouseButton1Click:Connect(function() pcall(callback) end)
    return b
end

-- Repaint helper when theme/visibility changes
local function applyTheme()
    local t = THEMES[state.themeName] or THEMES["Alien Green"]
    Theme.Border, Theme.Text, Theme.TextMuted = t.Border, t.Text, t.TextMuted
    Theme.Panel, Theme.Header, Theme.Danger = t.Panel, t.Header, t.Danger

    Root.BackgroundColor3 = Color3.new(0,0,0)
    Left.BackgroundColor3 = Theme.Panel
    Right.BackgroundColor3 = Theme.Panel
    Header.BackgroundColor3 = Theme.Header
    Title.TextColor3 = Theme.Text
    BtnMin.TextColor3, BtnExp.TextColor3, BtnClose.TextColor3 = Theme.Border, Theme.Border, Theme.Danger
    Logo.ImageColor3 = Color3.new(1,1,1) -- untouched, but allows palette on monochrome icons

    -- update strokes colors
    for _,inst in ipairs({Root,Left,Right,Header}) do
        local s = inst:FindFirstChildOfClass("UIStroke")
        if s then s.Color = Theme.Border end
    end
    for _,btn in pairs(tabButtons) do
        btn.TextColor3 = Theme.TextMuted
        local s = btn:FindFirstChildOfClass("UIStroke"); if s then s.Color = Theme.Border end
    end
end

local function applyScale()
    local s = math.clamp(state.scale, 0.8, 1.3)
    Root.Size = UDim2.new(0, math.floor(720*s), 0, math.floor(420*s))
end

local function applyVisibility()
    local v = state.visibility  -- 1.0, 0.5, 0.0
    Left.BackgroundTransparency = 1 - v
    Right.BackgroundTransparency = 1 - v
    -- keep header/outline solid for readability
    Header.BackgroundTransparency = math.clamp(1 - v*0.85, 0, 0.6)
end

-- ===== Content: Main =====
local function mountMain()
    RightScroll:ClearAllChildren()
    label(RightScroll, "Welcome to UFO HUB X — Alien High-Tech UI", 28)
    label(RightScroll, "ลองเปิด Settings เพื่อสลับธีม/ปรับขนาด/ปรับความทึบ", 24)
    label(RightScroll, "เลื่อนซ้าย-ขวาแยกอิสระได้แล้ว (ลองใส่รายการเยอะ ๆ )", 24)
    for i=1,10 do
        rowButton(RightScroll, "Demo Action "..i, function() log("Clicked demo action", i) end)
    end
end

-- ===== Content: Settings =====
local function mountSettings()
    RightScroll:ClearAllChildren()
    label(RightScroll, "Settings", 30)

    -- Theme buttons
    label(RightScroll, "Theme", 24)
    for name,_ in pairs(THEMES) do
        rowButton(RightScroll, "Switch to "..name, function()
            state.themeName = name
            applyTheme()
            applyVisibility()
        end)
    end

    -- Scale controls
    label(RightScroll, "Scale (80%–130%)", 24)
    rowButton(RightScroll, "Scale -", function()
        state.scale = math.max(0.8, math.floor((state.scale-0.05)*100+0.5)/100)
        applyScale()
    end)
    rowButton(RightScroll, "Scale +", function()
        state.scale = math.min(1.3, math.floor((state.scale+0.05)*100+0.5)/100)
        applyScale()
    end)

    -- Visibility
    label(RightScroll, "Visibility", 24)
    rowButton(RightScroll, "100% (ทึบ)", function() state.visibility=1.0; applyVisibility() end)
    rowButton(RightScroll, "50% (กึ่งโปร่ง)", function() state.visibility=0.5; applyVisibility() end)
    rowButton(RightScroll, "0% (ล่องหน เหลือเส้น)", function() state.visibility=0.0; applyVisibility() end)

    -- Logo ImageId
    label(RightScroll, "Logo Image ID", 24)
    local holder = Instance.new("Frame"); holder.Size=UDim2.new(1,-16,0,40); holder.Position=UDim2.new(0,8,0,0)
    holder.BackgroundColor3 = Theme.Panel; holder.Parent=RightScroll; corner(holder,8); stroke(holder,1,Theme.Border)
    local tb = Instance.new("TextBox")
    tb.BackgroundTransparency = 1; tb.Size=UDim2.new(1,-100,1,0); tb.Position=UDim2.new(0,10,0,0)
    tb.Font=Enum.Font.Gotham; tb.TextSize=16; tb.TextColor3=Theme.Text; tb.PlaceholderText="ใส่เลข ImageId (เช่น 123456789)"
    tb.Parent = holder
    local applyBtn = rowButton(RightScroll, "Apply Logo ID", function()
        local id = tonumber(tb.Text)
        if id then
            state.logoId = id
            Logo.Image = "rbxassetid://"..id
            log("Logo set to", id)
        else
            log("Invalid ImageId")
        end
    end)
end

-- Tab switching
local currentTab = "Main"
local function switchTab(name)
    currentTab = name
    for t,btn in pairs(tabButtons) do
        local active = (t==name)
        btn.TextColor3 = active and Theme.Text or Theme.TextMuted
    end
    if name=="Main" then mountMain()
    elseif name=="Settings" then mountSettings()
    else
        RightScroll:ClearAllChildren()
        label(RightScroll, name.." — Coming Soon", 28)
        for i=1,8 do rowButton(RightScroll, name.." Action "..i, function() end) end
    end
    -- auto-scroll left to active
    LeftScroll.CanvasPosition = Vector2.new(0, (tabButtons[name].AbsolutePosition.Y - LeftScroll.AbsolutePosition.Y) - 40)
end
for name,btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- Header buttons behavior
local savedSize, savedPos
BtnMin.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
    -- simple tray: press F8 to toggle back
end)
BtnExp.MouseButton1Click:Connect(function()
    state.expanded = not state.expanded
    if state.expanded then
        savedSize, savedPos = Root.Size, Root.Position
        Root.Position = UDim2.new(0.5,0,0.5,0)
        Root.Size = UDim2.new(1,-40,1,-40)
    else
        Root.Size = savedSize or UDim2.new(0,720,0,420)
        Root.Position = savedPos or UDim2.new(0.5,0,0.5,0)
    end
end)
BtnClose.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false  -- ซ่อน (ไม่ destroy)
end)

-- Hotkeys
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F8 then
        ScreenGui.Enabled = not ScreenGui.Enabled
    elseif input.KeyCode == Enum.KeyCode.BackQuote then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Apply initial
applyTheme(); applyScale(); applyVisibility()
switchTab("Main")

-- FPS guard: if low fps, reduce header transparency effects
local avg = 60
RunService.RenderStepped:Connect(function(dt)
    avg = math.clamp(avg*0.9 + (1/dt)*0.1, 10, 120)
    if avg < 45 then
        -- keep it lightweight (already minimal in this demo)
    end
end)

log("UI ready. Hotkeys: F8 or ` to show/hide; use Settings to tweak.")
