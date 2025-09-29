--==========================================================
-- UFO HUB X • UI + Images in Panels (ใช้ Roblox Image ID)
--==========================================================

-- ตั้งค่า
local TITLE       = "UFO  HUB X"
local GREEN       = Color3.fromRGB(0,255,140)
local BG_WINDOW   = Color3.fromRGB(16,16,16)
local BG_HEADER   = Color3.fromRGB(0,0,0)
local BG_PANEL    = Color3.fromRGB(22,22,22)
local TEXT_WHITE  = Color3.fromRGB(235,235,235)

local WIN_W, WIN_H = 780, 440
local SIDEBAR_W    = 210

-- 👉 ใส่ Image ID ของคุณตรงนี้
local ROBLOX_IMAGE_ID = 95486407220826  -- ตัวเลขที่คุณให้มา
local IMAGE_ASSET_URL = "rbxassetid://"..tostring(ROBLOX_IMAGE_ID)

-- ผู้ช่วย
local function corner(gui, r)
    local c = Instance.new("UICorner", gui); c.CornerRadius = UDim.new(0, r or 10); return c
end
local function stroke(gui, t, col, mode)
    local s = Instance.new("UIStroke", gui)
    s.Thickness = t or 1.5
    s.Color = col or GREEN
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end

-- ราก GUI
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")

local GUI = Instance.new("ScreenGui", CoreGui)
GUI.Name = "UFO_HUB_X_UI"
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false

-- หน้าต่าง
local Window = Instance.new("Frame", GUI)
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5,0.5)
Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.fromOffset(WIN_W, WIN_H)
Window.BackgroundColor3 = BG_WINDOW
Window.BorderSizePixel = 0
corner(Window, 10)
stroke(Window, 1.5, GREEN, Enum.ApplyStrokeMode.Border)

-- Glow บางรอบนอก (อยู่ใต้ Window)
local Glow = Instance.new("ImageLabel", Window)
Glow.Name = "Glow"
Glow.BackgroundTransparency = 1
Glow.AnchorPoint = Vector2.new(0.5,0.5)
Glow.Position = UDim2.new(0.5,0,0.5,0)
Glow.Size = UDim2.new(1.15,0,1.15,0)       -- ขยายเล็กน้อย
Glow.ZIndex = 0
Glow.Image = "rbxassetid://5028857084"     -- Glow สำเร็จรูป
Glow.ImageColor3 = GREEN
Glow.ImageTransparency = 0.60              -- โปร่ง ให้ไม่ทับเนื้อหา
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(24,24,276,276)

-- ปรับสเกลอัตโนมัติ
local UIScale = Instance.new("UIScale", Window)
local function fit()
    local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    UIScale.Scale = math.clamp(math.min(v.X/900, v.Y/560), 0.75, 1.0)
end
fit(); RunS.RenderStepped:Connect(fit)

-- Header (สีดำ)
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1,0,0,42)
Header.BackgroundColor3 = BG_HEADER
Header.BorderSizePixel = 0
Header.ZIndex = 2
corner(Header, 10)

local Title = Instance.new("TextLabel", Header)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,14,0,0)
Title.Size = UDim2.new(1,-60,1,0)
Title.Font = Enum.Font.GothamBold
Title.Text = TITLE
Title.TextSize = 16
Title.TextColor3 = TEXT_WHITE
Title.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่ม X สีแดง
local BtnClose = Instance.new("TextButton", Header)
BtnClose.Size = UDim2.new(0,28,0,28)
BtnClose.Position = UDim2.new(1,-38,0.5,-14)
BtnClose.BackgroundColor3 = Color3.fromRGB(200,40,40)
BtnClose.Text = "X"
BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 14
BtnClose.TextColor3 = Color3.new(1,1,1)
BtnClose.AutoButtonColor = false
BtnClose.BorderSizePixel = 0
corner(BtnClose, 6)
stroke(BtnClose, 1.2, Color3.fromRGB(255,0,0))
BtnClose.MouseEnter:Connect(function() BtnClose.BackgroundColor3 = Color3.fromRGB(255,60,60) end)
BtnClose.MouseLeave:Connect(function() BtnClose.BackgroundColor3 = Color3.fromRGB(200,40,40) end)
BtnClose.MouseButton1Click:Connect(function() GUI.Enabled = false end)

-- ลากได้
do
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Window.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ซ่อน/โชว์ด้วย RightShift
do
    local visible = true
    UIS.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then visible = not visible; GUI.Enabled = visible end
    end)
end

-- Body
local Body = Instance.new("Frame", Window)
Body.BackgroundTransparency = 1
Body.Position = UDim2.new(0,0,0,42)
Body.Size = UDim2.new(1,0,1,-42)

-- กรอบใน: ทำให้ดูแยกจากฉากหลัง
local Inner = Instance.new("Frame", Body)
Inner.Position = UDim2.new(0,10,0,10)
Inner.Size = UDim2.new(1,-20,1,-20)
Inner.BackgroundColor3 = Color3.fromRGB(20,20,20)
Inner.BorderSizePixel = 0
corner(Inner, 10)

-- Sidebar (ซ้าย)
local Sidebar = Instance.new("Frame", Body)
Sidebar.BackgroundColor3 = BG_PANEL
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0,18,0,18)
Sidebar.Size = UDim2.new(0,SIDEBAR_W,1,-36)
corner(Sidebar, 8); stroke(Sidebar, 1, GREEN)
local sbPad = Instance.new("UIPadding", Sidebar)
sbPad.PaddingTop, sbPad.PaddingLeft, sbPad.PaddingRight = UDim.new(0,12), UDim.new(0,12), UDim.new(0,12)

-- Content (ขวา)
local Content = Instance.new("Frame", Body)
Content.BackgroundColor3 = BG_PANEL
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, 18+SIDEBAR_W+12, 0, 18)
Content.Size = UDim2.new(1, -(18+SIDEBAR_W+12+18), 1, -36)
corner(Content, 8); stroke(Content, 1, GREEN)

--================== ใส่รูปภาพลงในสองพาเนล ==================
local function makeImageCard(parent)
    local card = Instance.new("Frame", parent)
    card.BackgroundColor3 = Color3.fromRGB(16,16,16)
    card.BorderSizePixel = 0
    corner(card, 10); stroke(card, 1, GREEN)
    card.ClipsDescendants = true

    local img = Instance.new("ImageLabel", card)
    img.BackgroundTransparency = 1
    img.Size = UDim2.new(1,0,1,0)
    img.Image = IMAGE_ASSET_URL         -- ใช้รูปเดียวกันทั้งสองฝั่ง
    img.ScaleType = Enum.ScaleType.Fit   -- คงอัตราส่วน
    -- ถ้าอยากครอบให้เต็มพอดี ใช้: img.ScaleType = Enum.ScaleType.Crop
    return card
end

-- จัดสองคอลัมน์
local grid = Instance.new("UIGridLayout", Content)
grid.CellPadding = UDim2.new(0,14,0,0)
grid.CellSize    = UDim2.new(0.5, -7, 1, 0) -- สองช่องเท่ากัน
grid.FillDirectionMaxCells = 2
grid.SortOrder = Enum.SortOrder.LayoutOrder

local leftCard  = makeImageCard(Content)
local rightCard = makeImageCard(Content)

-- (จบ) — ภาพสองฝั่งจะโหลดจาก ID ที่กำหนดไว้ข้างบน
