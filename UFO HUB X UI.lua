--==========================================================
-- UFO HUB X • Pure UI (สไตล์เหมือนรูปที่ 2)
-- - Header ดำ, ตัวอักษรขาว, ไอคอนวงกลมเขียว
-- - พื้นในเป็นเทาเข้ม #111 / การ์ด #161616, ขอบเขียวบาง ๆ
-- - ไม่มี Glow เขียวทับด้านใน (ให้ดูแยกเหมือนรูป 2)
-- - ลากได้, RightShift ซ่อน/โชว์, ปุ่ม X แดง
--==========================================================

----------------------[ THEME ]----------------------
local TITLE           = "UFO  HUB X"
local GREEN           = Color3.fromRGB(0,255,140)  -- accent
local BG_WINDOW       = Color3.fromRGB(16,16,16)   -- #101010
local BG_HEADER       = Color3.fromRGB(0,0,0)      -- #000000
local BG_PANEL        = Color3.fromRGB(22,22,22)   -- #161616
local BG_INNER        = Color3.fromRGB(20,20,20)   -- #141414 (เนื้อในการ์ด)
local TEXT_WHITE      = Color3.fromRGB(235,235,235)

local BORDER_THIN     = 2
local BORDER_THICK    = 3
local CORNER_RADIUS   = 10
local WIN_SIZE        = Vector2.new(780, 440)
local SIDEBAR_W       = 210

----------------------[ HELPERS ]--------------------
local function addCorner(gui, radius)
    local c = gui:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", gui)
    c.CornerRadius = UDim.new(0, radius or CORNER_RADIUS)
    return c
end

local function addStroke(gui, thickness, color, mode)
    local s = Instance.new("UIStroke")
    s.Parent = gui
    s.Thickness = thickness or BORDER_THIN
    s.Color = color or GREEN
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end

local function mkButton(parent, text, size)
    local b = Instance.new("TextButton")
    b.Name = "Btn_"..text
    b.Parent = parent
    b.Size = size or UDim2.new(0,28,0,28)
    b.BackgroundColor3 = Color3.fromRGB(12,40,25)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Font = Enum.Font.GothamSemibold
    b.Text = text
    b.TextSize = 14
    b.TextColor3 = TEXT_WHITE
    addCorner(b, 8); addStroke(b, BORDER_THIN, GREEN)
    return b
end

----------------------[ ROOT GUI ]-------------------
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")

local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = CoreGui

-- Hotkey: RightShift toggle
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

----------------------[ WINDOW ]---------------------
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5,0.5)
Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.fromOffset(WIN_SIZE.X, WIN_SIZE.Y)
Window.BackgroundColor3 = BG_WINDOW
Window.BorderSizePixel = 0
Window.ZIndex = 50
Window.Parent = GUI
addCorner(Window, CORNER_RADIUS)
addStroke(Window, BORDER_THICK, GREEN) -- เส้นเขียวรอบนอกแบบบาง (เหมือนรูป 2)

-- scale ให้พอดีจอ
local UIScale = Instance.new("UIScale", Window)
local function fit()
    local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    UIScale.Scale = math.clamp(math.min(v.X/900, v.Y/560), 0.75, 1.0)
end
fit(); RunS.RenderStepped:Connect(fit)

----------------------[ HEADER ]---------------------
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = Window
Header.BackgroundColor3 = BG_HEADER   -- สีดำสนิท
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1,0,0,42)
Header.ZIndex = 52
addCorner(Header, CORNER_RADIUS)

-- วงกลมไอคอนสีเขียวทางซ้าย (เหมือนรูป 2)
local Dot = Instance.new("Frame")
Dot.Parent = Header
Dot.BackgroundColor3 = GREEN
Dot.BorderSizePixel = 0
Dot.Position = UDim2.new(0,14,0.5,-6)
Dot.Size = UDim2.new(0,12,0,12)
addCorner(Dot, 6)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0,32,0,0) -- ขยับให้ต่อจากจุดเขียว
Title.Size = UDim2.new(1,-120,1,0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Text = TITLE
Title.TextColor3 = TEXT_WHITE
Title.ZIndex = 53

-- ปุ่ม X สีแดง (เหมือนรูป 2)
local BtnClose = mkButton(Header, "X", UDim2.new(0,28,0,28))
BtnClose.BackgroundColor3 = Color3.fromRGB(200,40,40)
BtnClose.TextColor3 = Color3.fromRGB(255,255,255)
BtnClose.Position = UDim2.new(1,-38,0.5,-14)
BtnClose.ZIndex = 53
BtnClose:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(255,0,0)
BtnClose.MouseEnter:Connect(function() BtnClose.BackgroundColor3 = Color3.fromRGB(255,60,60) end)
BtnClose.MouseLeave:Connect(function() BtnClose.BackgroundColor3 = Color3.fromRGB(200,40,40) end)
BtnClose.MouseButton1Click:Connect(function() GUI.Enabled = false end)

-- ลากหน้าต่างด้วย Header
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

----------------------[ BODY ]-----------------------
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Parent = Window
Body.BackgroundTransparency = 1
Body.Position = UDim2.new(0,0,0,42)
Body.Size = UDim2.new(1,0,1,-42)
Body.ZIndex = 50

-- พื้นด้านใน (ทำให้เข้มกว่าพื้นเกม เพื่อ “แยก” เหมือนรูป 2)
local InnerBG = Instance.new("Frame")
InnerBG.Name = "InnerBG"
InnerBG.Parent = Body
InnerBG.BackgroundColor3 = BG_INNER
InnerBG.BorderSizePixel = 0
InnerBG.Position = UDim2.new(0,10,0,10)
InnerBG.Size = UDim2.new(1,-20,1,-20)
InnerBG.ZIndex = 49
addCorner(InnerBG, CORNER_RADIUS)

-- Sidebar ซ้าย
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = Body
Sidebar.BackgroundColor3 = BG_PANEL
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0,18,0,18)
Sidebar.Size = UDim2.new(0,SIDEBAR_W,1,-36)
Sidebar.ZIndex = 51
addCorner(Sidebar, 10)
addStroke(Sidebar, BORDER_THIN, GREEN)

local sbPad = Instance.new("UIPadding", Sidebar)
sbPad.PaddingTop, sbPad.PaddingLeft, sbPad.PaddingRight = UDim.new(0,12), UDim.new(0,12), UDim.new(0,12)
local sbList = Instance.new("UIListLayout", Sidebar)
sbList.Padding = UDim.new(0,8)
sbList.FillDirection = Enum.FillDirection.Vertical
sbList.SortOrder = Enum.SortOrder.LayoutOrder

-- Content ขวา
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = Body
Content.BackgroundColor3 = BG_PANEL
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, 18+SIDEBAR_W+12, 0, 18)
Content.Size = UDim2.new(1, -(18+SIDEBAR_W+12+18), 1, -36)
Content.ZIndex = 51
addCorner(Content, 10)
addStroke(Content, BORDER_THIN, GREEN)

-- เนื้อด้านในของการ์ด (ทำให้คล้ำกว่าขอบ ดู “แยก” เหมือนรูป 2)
local ContentPad = Instance.new("UIPadding", Content)
ContentPad.PaddingTop, ContentPad.PaddingLeft, ContentPad.PaddingRight, ContentPad.PaddingBottom =
    UDim.new(0,10), UDim.new(0,10), UDim.new(0,10), UDim.new(0,10)

----------------------[ API (Optional) ]--------------
local UFOUI = {}

function UFOUI:AddSidebarButton(text)
    local b = Instance.new("TextButton")
    b.Name = "SB_"..text
    b.Parent = Sidebar
    b.Size = UDim2.new(1,0,0,38)
    b.BackgroundColor3 = Color3.fromRGB(12,40,25)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Font = Enum.Font.GothamSemibold
    b.Text = text
    b.TextSize = 14
    b.TextColor3 = TEXT_WHITE
    addCorner(b, 8); addStroke(b, BORDER_THIN, GREEN)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(18,70,45) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(12,40,25) end)
    return b
end

function UFOUI:ClearContent()
    for _, c in ipairs(Content:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
end

function UFOUI:CreateCard(h)
    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Parent = Content
    card.BackgroundColor3 = BG_INNER
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1,0,0,h or 130)
    addCorner(card, 8); addStroke(card, BORDER_THIN, GREEN)
    local p = Instance.new("UIPadding", card)
    p.PaddingTop = UDim.new(0,10); p.PaddingLeft = UDim.new(0,10); p.PaddingRight = UDim.new(0,10); p.PaddingBottom = UDim.new(0,10)
    return card
end

function UFOUI:GetRoot()
    return GUI, Window, Header, Sidebar, Content
end

-- (ไม่สร้างปุ่มอัตโนมัติ เพื่อให้ “ศูนย์” จริง ๆ ตามที่ต้องการ)
--==========================================================
-- END
--==========================================================
