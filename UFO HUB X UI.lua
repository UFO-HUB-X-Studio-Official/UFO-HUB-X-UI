--==========================================================
-- UFO HUB X • Hi-Tech UI (neon mint), thinner inner lines,
-- UFO docked to header
--==========================================================

-- ล้างของเดิม
pcall(function()
    local g = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI")
    if g then g:Destroy() end
end)

-- ===== THEME / SIZE =====
local TITLE         = "UFO  HUB X"

local GREEN         = Color3.fromRGB(0,255,140)     -- เขียวหลัก
local MINT          = Color3.fromRGB(120,255,220)   -- เส้นโทนมิ้นต์ (แทนขาว)
local MINT_SOFT     = Color3.fromRGB(90,210,190)    -- accent อ่อน
local BG_WINDOW     = Color3.fromRGB(16,16,16)
local BG_HEADER     = Color3.fromRGB(6,6,6)
local BG_PANEL      = Color3.fromRGB(22,22,22)
local BG_INNER      = Color3.fromRGB(18,18,18)
local TEXT_WHITE    = Color3.fromRGB(235,235,235)
local DANGER_RED    = Color3.fromRGB(200,40,40)

-- ขนาดรวม (กะทัดรัด)
local WIN_W, WIN_H  = 640, 360
local GAP_OUTER     = 14
local GAP_BETWEEN   = 12
local LEFT_RATIO    = 0.22
local RIGHT_RATIO   = 0.78

-- รูปภาพ
local IMG_SMALL     = "rbxassetid://95514334029879"      -- ซ้าย (เล็ก)
local IMG_LARGE     = "rbxassetid://117055535552131"     -- ขวา (ใหญ่)
local IMG_UFO       = "rbxassetid://100650447103028"     -- UFO

-- ===== HELPERS =====
local function corner(gui, r)
    local c = Instance.new("UICorner", gui)
    c.CornerRadius = UDim.new(0, r or 10)
    return c
end

local function stroke(gui, t, col, trans)
    local s = Instance.new("UIStroke", gui)
    s.Thickness = t or 1
    s.Color = col or MINT
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end

local function gradient(gui, col1, col2, rot)
    local g = Instance.new("UIGradient", gui)
    g.Color = ColorSequence.new(col1, col2)
    g.Rotation = rot or 0
    return g
end

-- ===== ROOT =====
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")

local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false
GUI.Parent = CoreGui

-- ===== WINDOW =====
local Window = Instance.new("Frame", GUI)
Window.AnchorPoint = Vector2.new(0.5,0.5)
Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.fromOffset(WIN_W, WIN_H)
Window.BackgroundColor3 = BG_WINDOW
Window.BorderSizePixel = 0
corner(Window, 12)
stroke(Window, 2.4, GREEN, 0) -- ขอบเขียวรอบ UI ใหญ่ (หนา)

-- Glow รอบนอก
do
    local Glow = Instance.new("ImageLabel", Window)
    Glow.BackgroundTransparency = 1
    Glow.AnchorPoint = Vector2.new(0.5,0.5)
    Glow.Position = UDim2.new(0.5,0,0.5,0)
    Glow.Size = UDim2.new(1.07,0,1.09,0)
    Glow.ZIndex = 0
    Glow.Image = "rbxassetid://5028857084"
    Glow.ImageColor3 = GREEN
    Glow.ImageTransparency = 0.78
    Glow.ScaleType = Enum.ScaleType.Slice
    Glow.SliceCenter = Rect.new(24,24,276,276)
end

-- Scale ให้พอดีจอ
local UIScale = Instance.new("UIScale", Window)
local function fit()
    local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    UIScale.Scale = math.clamp(math.min(v.X/860, v.Y/540), 0.72, 1.0)
end
fit(); RunS.RenderStepped:Connect(fit)

-- ===== HEADER (ไฮเทค + กราเดียนต์) =====
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1,0,0,42)
Header.BackgroundColor3 = BG_HEADER
Header.BorderSizePixel = 0
corner(Header, 12)
gradient(Header, Color3.fromRGB(10,10,10), Color3.fromRGB(0,0,0), 0)

-- Accent bar มิ้นต์เส้นบางใต้หัว
local HeadAccent = Instance.new("Frame", Header)
HeadAccent.AnchorPoint = Vector2.new(0.5,1)
HeadAccent.Position = UDim2.new(0.5,0,1,0)
HeadAccent.Size = UDim2.new(1,-20,0,1)
HeadAccent.BackgroundColor3 = MINT
HeadAccent.BorderSizePixel = 0
HeadAccent.BackgroundTransparency = 0.35

-- จุดมิ้นต์ทางซ้าย (แทน dot เขียวหนา ๆ)
local Dot = Instance.new("Frame", Header)
Dot.BackgroundColor3 = MINT
Dot.Position = UDim2.new(0,14,0.5,-4)
Dot.Size = UDim2.new(0,8,0,8)
Dot.BorderSizePixel = 0
corner(Dot, 4)

-- glow เล็ก ๆ ของจุด
local DotGlow = Instance.new("ImageLabel", Header)
DotGlow.BackgroundTransparency = 1
DotGlow.Image = "rbxassetid://5028857084"
DotGlow.ImageColor3 = MINT
DotGlow.ImageTransparency = 0.6
DotGlow.Position = UDim2.new(0,8,0.5,-10)
DotGlow.Size = UDim2.new(0,20,0,20)
DotGlow.ZIndex = 1

local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Position = UDim2.new(0,30,0,0)
TitleLbl.Size = UDim2.new(1,-90,1,0)
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.Text = TITLE
TitleLbl.TextSize = 15
TitleLbl.TextColor3 = TEXT_WHITE
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่ม X แดง
local BtnClose = Instance.new("TextButton", Header)
BtnClose.Size = UDim2.new(0,24,0,24)
BtnClose.Position = UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3 = DANGER_RED
BtnClose.Text = "X"
BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 13
BtnClose.TextColor3 = Color3.new(1,1,1)
BtnClose.BorderSizePixel = 0
corner(BtnClose, 6)
stroke(BtnClose, 1, Color3.fromRGB(255,0,0), 0.1)
BtnClose.MouseButton1Click:Connect(function() GUI.Enabled = false end)

-- ลากด้วย Header
do
    local dragging, start, startPos
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Window.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- ===== UFO Dock (ให้ยาน “ติดหัว UI” จริง ๆ + มีฐานเรืองแสง) =====
do
    -- แผ่นฐานเรืองกลางหัว (ฮาโล่)
    local Dock = Instance.new("ImageLabel", Window)
    Dock.BackgroundTransparency = 1
    Dock.AnchorPoint = Vector2.new(0.5,0)
    Dock.Position = UDim2.new(0.5,0,0,0)  -- ชิดขอบบนสุดของ Window
    Dock.Size = UDim2.new(0,110,0,36)
    Dock.Image = "rbxassetid://5028857084"
    Dock.ImageColor3 = MINT_SOFT
    Dock.ImageTransparency = 0.68
    Dock.ZIndex = 50

    local UFO = Instance.new("ImageLabel", Window)
    UFO.Name = "UFO_Top"
    UFO.BackgroundTransparency = 1
    UFO.Image = IMG_UFO
    UFO.Size = UDim2.new(0,86,0,86)
    UFO.AnchorPoint = Vector2.new(0.5,0)                 -- อ้างอิงด้านบนของยาน
    UFO.Position = UDim2.new(0.5,0,0,2)                  -- 2px จากขอบบน = เรียกว่าติดหัว
    UFO.ZIndex = 60
end

-- ===== BODY =====
local Body = Instance.new("Frame", Window)
Body.BackgroundTransparency = 1
Body.Position = UDim2.new(0,0,0,42)
Body.Size = UDim2.new(1,0,1,-42)

local Inner = Instance.new("Frame", Body)
Inner.BackgroundColor3 = BG_INNER
Inner.BorderSizePixel = 0
Inner.Position = UDim2.new(0,8,0,8)
Inner.Size = UDim2.new(1,-16,1,-16)
corner(Inner, 12)

-- กรอบใหญ่ด้านใน (เส้นมิ้นต์ “บางและจาง” แทนสีขาว)
local Content = Instance.new("Frame", Body)
Content.BackgroundColor3 = BG_PANEL
Content.Position = UDim2.new(0,GAP_OUTER,0,GAP_OUTER)
Content.Size = UDim2.new(1,-GAP_OUTER*2,1,-GAP_OUTER*2)
corner(Content, 12)
stroke(Content, 0.5, MINT, 0.35) -- บางลง + จางลง (ไม่แยงตา)

-- พื้นหลังสแกนไลน์เบา ๆ (ไฮเทค)
local Scan = Instance.new("Frame", Content)
Scan.BackgroundColor3 = Color3.fromRGB(255,255,255)
Scan.BackgroundTransparency = 1
Scan.Size = UDim2.fromScale(1,1)
local sg = gradient(Scan, Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255), 90)
sg.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0,1),
    NumberSequenceKeypoint.new(0.48,1),
    NumberSequenceKeypoint.new(0.5,0.85),
    NumberSequenceKeypoint.new(0.52,1),
    NumberSequenceKeypoint.new(1,1)
}

-- คอลัมน์ 2 ช่อง
local Columns = Instance.new("Frame", Content)
Columns.BackgroundTransparency = 1
Columns.Position = UDim2.new(0,8,0,8)
Columns.Size = UDim2.new(1,-16,1,-16)

-- === การ์ดซ้าย (กรอบเขียวหลัก + เส้นมิ้นต์บางซ้อน) ===
local Left = Instance.new("Frame", Columns)
Left.BackgroundColor3 = Color3.fromRGB(16,16,16)
Left.Size = UDim2.new(LEFT_RATIO, -GAP_BETWEEN/2, 1, 0)
Left.ClipsDescendants = true
corner(Left, 10)
stroke(Left, 1.2, GREEN, 0)        -- กรอบนอกเขียว
stroke(Left, 0.45, MINT, 0.35)     -- เส้นในมิ้นต์ บาง+โปร่ง

-- มุมเรือง (corner accents)
for _, pos in ipairs({"TL","TR","BL","BR"}) do
    local a = Instance.new("Frame", Left)
    a.BackgroundColor3 = MINT
    a.BorderSizePixel = 0
    a.Size = UDim2.new(0,10,0,2)
    if pos=="TL" then a.Position = UDim2.new(0,6,0,6)
    elseif pos=="TR" then a.Position = UDim2.new(1,-16,0,6)
    elseif pos=="BL" then a.Position = UDim2.new(0,6,1,-8)
    else a.Position = UDim2.new(1,-16,1,-8) end
    a.BackgroundTransparency = 0.25
end

-- === การ์ดขวา (เหมือนซ้าย) ===
local Right = Instance.new("Frame", Columns)
Right.BackgroundColor3 = Color3.fromRGB(16,16,16)
Right.Position = UDim2.new(LEFT_RATIO, GAP_BETWEEN, 0, 0)
Right.Size = UDim2.new(RIGHT_RATIO, -GAP_BETWEEN/2, 1, 0)
Right.ClipsDescendants = true
corner(Right, 10)
stroke(Right, 1.2, GREEN, 0)
stroke(Right, 0.45, MINT, 0.35)

for _, pos in ipairs({"TL","TR","BL","BR"}) do
    local a = Instance.new("Frame", Right)
    a.BackgroundColor3 = MINT
    a.BorderSizePixel = 0
    a.Size = UDim2.new(0,10,0,2)
    if pos=="TL" then a.Position = UDim2.new(0,6,0,6)
    elseif pos=="TR" then a.Position = UDim2.new(1,-16,0,6)
    elseif pos=="BL" then a.Position = UDim2.new(0,6,1,-8)
    else a.Position = UDim2.new(1,-16,1,-8) end
    a.BackgroundTransparency = 0.25
end

-- ===== รูปภาพ (Crop เต็มกรอบ) =====
local imgL = Instance.new("ImageLabel", Left)
imgL.BackgroundTransparency = 1
imgL.Size = UDim2.new(1,0,1,0)
imgL.Image = IMG_SMALL
imgL.ScaleType = Enum.ScaleType.Crop

local imgR = Instance.new("ImageLabel", Right)
imgR.BackgroundTransparency = 1
imgR.Size = UDim2.new(1,0,1,0)
imgR.Image = IMG_LARGE
imgR.ScaleType = Enum.ScaleType.Crop

-- Toggle ซ่อน/โชว์ด้วย RightShift
do
    local vis = true
    UIS.InputBegan:Connect(function(i, gp)
        if not gp and i.KeyCode == Enum.KeyCode.RightShift then
            vis = not vis
            GUI.Enabled = vis
        end
    end)
end
--==========================================================
-- END
--==========================================================
