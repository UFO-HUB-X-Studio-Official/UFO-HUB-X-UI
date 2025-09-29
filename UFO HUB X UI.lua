--==========================================================
-- UFO HUB X • Pure UI (ศูนย์จริง) + ขอบเขียวเรือง (Glow) + ปุ่ม X สีแดง
-- ก็อปวางใช้ได้ทันที
--==========================================================

--====================[ THEME / CONFIG ]====================
local TITLE          = "UFO  HUB X"
local GREEN          = Color3.fromRGB(0,255,140)
local GREEN_DARK     = Color3.fromRGB(0,180,100)
local BG_WINDOW      = Color3.fromRGB(16,16,16)
local BG_HEADER      = Color3.fromRGB(0,0,0)
local BG_PANEL       = Color3.fromRGB(22,22,22)
local TEXT_WHITE     = Color3.fromRGB(235,235,235)

local BORDER_THIN    = 2
local BORDER_THICK   = 3
local CORNER_RADIUS  = 10
local WIN_SIZE       = Vector2.new(720, 420)
local SIDEBAR_W      = 190

--====================[ UTILS ]====================
local function corner(gui, radius)
    local c = gui:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", gui)
    c.CornerRadius = UDim.new(0, radius or CORNER_RADIUS)
    return c
end

-- เส้นขอบคม
local function stroke(gui, thickness, color)
    local s = Instance.new("UIStroke")
    s.Name = "UFOStroke"
    s.Parent = gui
    s.Thickness = thickness or BORDER_THIN
    s.Color = color or GREEN
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end

-- ขอบเรือง (Glow) = เส้นนอกหนา + ไล่สี + โปร่งใสนิด ๆ
local function glow(gui, thickness)
    local g = Instance.new("UIStroke")
    g.Name = "UFOGlow"
    g.Parent = gui
    g.Thickness = thickness or 6
    g.Color = GREEN
    g.Transparency = 0.35
    g.ApplyStrokeMode = Enum.ApplyStrokeMode.Outline
    g.LineJoinMode = Enum.LineJoinMode.Round

    local grad = Instance.new("UIGradient")
    grad.Name = "UFOGlowGradient"
    grad.Parent = g
    grad.Rotation = 90
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, GREEN),
        ColorSequenceKeypoint.new(0.50, GREEN_DARK),
        ColorSequenceKeypoint.new(1.00, GREEN),
    })
    return g
end

--====================[ ROOT GUI ]====================
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")

local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = CoreGui

-- Hotkey ซ่อน/โชว์ (RightShift)
do
    local visible = true
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            visible = not visible
            GUI.Enabled = visible
        end
    end)
end

--====================[ WINDOW + HEADER ]====================
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5,0.5)
Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.fromOffset(WIN_SIZE.X, WIN_SIZE.Y)
Window.BackgroundColor3 = BG_WINDOW
Window.BorderSizePixel = 0
Window.Parent = GUI
corner(Window, CORNER_RADIUS)
glow(Window, 7)                          -- 🌟 Glow รอบกรอบ
stroke(Window, BORDER_THICK, GREEN)      -- เส้นคมด้านใน

-- Responsive scale
local UIScale = Instance.new("UIScale", Window)
UIScale.Scale = 1
local function fit()
    local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    local sx = math.clamp(v.X / 800, 0.75, 1.0)
    local sy = math.clamp(v.Y / 500, 0.75, 1.0)
    UIScale.Scale = math.min(sx, sy)
end
fit()
RunS.RenderStepped:Connect(fit)

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = Window
Header.BackgroundColor3 = BG_HEADER
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1,0,0,40)
corner(Header, CORNER_RADIUS)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,14,0,0)
Title.Size = UDim2.new(1,-120,1,0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Text = TITLE
Title.TextColor3 = TEXT_WHITE

-- 🔴 ปุ่มปิด (X) สีแดง + hover
local BtnClose = Instance.new("TextButton")
BtnClose.Name = "Close"
BtnClose.Parent = Header
BtnClose.AutoButtonColor = false
BtnClose.Text = "X"
BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 14
BtnClose.TextColor3 = Color3.fromRGB(255,255,255)
BtnClose.BackgroundColor3 = Color3.fromRGB(200,40,40) -- แดงพื้น
BtnClose.BorderSizePixel = 0
BtnClose.Position = UDim2.new(1,-38,0.5,-14)
BtnClose.Size = UDim2.new(0,28,0,28)
corner(BtnClose, 8)
stroke(BtnClose, 2, Color3.fromRGB(255,0,0))          -- ขอบแดงคม
BtnClose.MouseEnter:Connect(function() BtnClose.BackgroundColor3 = Color3.fromRGB(255,60,60) end)
BtnClose.MouseLeave:Connect(function() BtnClose.BackgroundColor3 = Color3.fromRGB(200,40,40) end)
BtnClose.MouseButton1Click:Connect(function() GUI.Enabled = false end)

-- Drag by Header
do
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

--====================[ BODY: Sidebar + Content ]====================
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Parent = Window
Body.BackgroundTransparency = 1
Body.Position = UDim2.new(0,0,0,40)
Body.Size = UDim2.new(1,0,1,-40)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = Body
Sidebar.BackgroundColor3 = BG_PANEL
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0,12,0,12)
Sidebar.Size = UDim2.new(0,SIDEBAR_W,1,-24)
corner(Sidebar, 10)
glow(Sidebar, 6)                         -- 🌟 Glow กรอบซ้าย
stroke(Sidebar, BORDER_THIN, GREEN)

local sbList = Instance.new("UIListLayout", Sidebar)
sbList.Padding = UDim.new(0,8)
sbList.FillDirection = Enum.FillDirection.Vertical
sbList.SortOrder = Enum.SortOrder.LayoutOrder
local sbPad = Instance.new("UIPadding", Sidebar)
sbPad.PaddingTop, sbPad.PaddingLeft, sbPad.PaddingRight = UDim.new(0,12), UDim.new(0,12), UDim.new(0,12)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = Body
Content.BackgroundColor3 = BG_PANEL
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, 12+SIDEBAR_W+12, 0, 12)
Content.Size = UDim2.new(1, -(12+SIDEBAR_W+12+12), 1, -24)
corner(Content, 10)
glow(Content, 6)                         -- 🌟 Glow กรอบขวา (ตำแหน่งลูกศร)
stroke(Content, BORDER_THIN, GREEN)

-- ตอนนี้ยัง “ศูนย์จริง ๆ” (ไม่มีปุ่ม/ท็อกเกิล)
-- คุณพร้อมจะเติมอะไร ค่อยบอกมา เดี๋ยวผมต่อยอดให้ทันที
