--==========================================================
-- UFO HUB X • Pure UI Starter (FULL) 
-- - เขียว/ดำ • ขอบคม + Glow เบลอชัด • ปุ่ม X สีแดง
-- - ศูนย์จริงๆ: ไม่มีปุ่ม/ท็อกเกิลอัตโนมัติ
-- - มี API UFOUI ช่วยเพิ่มของทีหลัง
--==========================================================

----------------------[ CONFIG / THEME ]---------------------
local TITLE           = "UFO  HUB X"
local GREEN           = Color3.fromRGB(0,255,140)
local GREEN_DARK      = Color3.fromRGB(0,180,100)
local BG_WINDOW       = Color3.fromRGB(16,16,16)
local BG_HEADER       = Color3.fromRGB(0,0,0)
local BG_PANEL        = Color3.fromRGB(22,22,22)
local TEXT_WHITE      = Color3.fromRGB(235,235,235)

local BORDER_THIN     = 2
local BORDER_THICK    = 3
local CORNER_RADIUS   = 10
local WIN_SIZE        = Vector2.new(720, 420)  -- กxส
local SIDEBAR_W       = 190

-- asset รูป Glow เบลอ (ของ Roblox ทางการ)
local GLOW_IMAGE_ID   = "rbxassetid://5028857472" 

----------------------[ UTIL HELPERS ]----------------------
local function addCorner(gui, radius)
    local c = gui:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", gui)
    c.CornerRadius = UDim.new(0, radius or CORNER_RADIUS)
    return c
end

local function addStroke(gui, thickness, color, applyMode)
    local s = Instance.new("UIStroke")
    s.Parent = gui
    s.Thickness = thickness or BORDER_THIN
    s.Color = color or GREEN
    s.Transparency = 0
    s.ApplyStrokeMode = applyMode or Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end

-- Glow เบลอ: ใช้ ImageLabel ใหญ่กว่ากรอบเล็กน้อย
local function addGlowBehind(gui, color, transparency, expand)
    local glow = Instance.new("ImageLabel")
    glow.Name = "UFO_Glow"
    glow.BackgroundTransparency = 1
    glow.Image = GLOW_IMAGE_ID
    glow.ImageColor3 = color or GREEN
    glow.ImageTransparency = (transparency ~= nil) and transparency or 0.35
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(256,256,256,256) -- ให้ยืดแล้วเบลอพอดี
    local ex = expand or 24
    glow.Size = UDim2.new(1, ex*2, 1, ex*2)
    glow.Position = UDim2.new(0, -ex, 0, -ex)
    glow.ZIndex = (gui.ZIndex or 1) - 1
    glow.Parent = gui
    return glow
end

local function makeButtonLike(parent, text, size, bg, fg, borderClr)
    local b = Instance.new("TextButton")
    b.Name = "Btn_"..(text or "")
    b.Parent = parent
    b.AutoButtonColor = false
    b.Size = size or UDim2.new(0,100,0,36)
    b.BackgroundColor3 = bg or Color3.fromRGB(12,40,25)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamSemibold
    b.Text = text or ""
    b.TextSize = 14
    b.TextColor3 = fg or TEXT_WHITE
    addCorner(b, 8)
    addStroke(b, BORDER_THIN, borderClr or GREEN)
    return b
end

----------------------[ ROOT GUI ]-------------------------
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")

local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = CoreGui

-- Hotkey: RightShift ซ่อน/โชว์
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

----------------------[ WINDOW + HEADER ]-------------------
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
addGlowBehind(Window, GREEN, 0.28, 28)               -- 🌟 Glow ใหญ่รอบ Window
addStroke(Window, BORDER_THICK, GREEN)                -- เส้นคม

-- Responsive scale (จอเล็กไม่ล้น)
local UIScale = Instance.new("UIScale", Window)
UIScale.Scale = 1
local function fit()
    local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    local sx = math.clamp(v.X / 800, 0.75, 1.0)
    local sy = math.clamp(v.Y / 500, 0.75, 1.0)
    UIScale.Scale = math.min(sx, sy)
end
fit(); RunS.RenderStepped:Connect(fit)

-- Header (ลากได้)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = Window
Header.BackgroundColor3 = BG_HEADER
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1,0,0,40)
Header.ZIndex = 51
addCorner(Header, CORNER_RADIUS)

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
Title.ZIndex = 52

-- ปุ่ม X สีแดง
local BtnClose = makeButtonLike(Header, "X", UDim2.new(0,28,0,28), Color3.fromRGB(200,40,40), TEXT_WHITE, Color3.fromRGB(255,0,0))
BtnClose.Position = UDim2.new(1,-38,0.5,-14)
BtnClose.ZIndex = 52
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

----------------------[ BODY LAYOUT ]----------------------
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Parent = Window
Body.BackgroundTransparency = 1
Body.Position = UDim2.new(0,0,0,40)
Body.Size = UDim2.new(1,0,1,-40)
Body.ZIndex = 50

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = Body
Sidebar.BackgroundColor3 = BG_PANEL
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0,12,0,12)
Sidebar.Size = UDim2.new(0,SIDEBAR_W,1,-24)
Sidebar.ZIndex = 50
addCorner(Sidebar, 10)
addGlowBehind(Sidebar, GREEN, 0.35, 18)             -- 🌟 Glow กรอบซ้าย
addStroke(Sidebar, BORDER_THIN, GREEN)

local sbPad = Instance.new("UIPadding", Sidebar)
sbPad.PaddingTop, sbPad.PaddingLeft, sbPad.PaddingRight = UDim.new(0,12), UDim.new(0,12), UDim.new(0,12)
local sbList = Instance.new("UIListLayout", Sidebar)
sbList.Padding = UDim.new(0,8)
sbList.FillDirection = Enum.FillDirection.Vertical
sbList.SortOrder = Enum.SortOrder.LayoutOrder

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = Body
Content.BackgroundColor3 = BG_PANEL
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, 12+SIDEBAR_W+12, 0, 12)
Content.Size = UDim2.new(1, -(12+SIDEBAR_W+12+12), 1, -24)
Content.ZIndex = 50
addCorner(Content, 10)
addGlowBehind(Content, GREEN, 0.35, 18)             -- 🌟 Glow กรอบขวา
addStroke(Content, BORDER_THIN, GREEN)

----------------------[ API FOR EXTENSION ]-----------------
local UFOUI = {}

-- เพิ่มปุ่มใน Sidebar (คืนค่า button เผื่อผูก event ภายหลัง)
function UFOUI:AddSidebarButton(text)
    local b = makeButtonLike(Sidebar, text, UDim2.new(1,0,0,38), Color3.fromRGB(12,40,25), TEXT_WHITE, GREEN)
    b.ZIndex = 51
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(18,70,45) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(12,40,25) end)
    return b
end

-- ล้างของในโซน Content ทั้งหมด
function UFOUI:ClearContent()
    for _, c in ipairs(Content:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
end

-- สร้างกรอบการ์ดว่าง ๆ ใน Content (ไว้ใส่ของเอง)
function UFOUI:CreateCard(sizeY)
    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Parent = Content
    card.BackgroundColor3 = BG_PANEL
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, sizeY or 120)
    card.ZIndex = 51
    addCorner(card, 8)
    addStroke(card, BORDER_THIN, GREEN)
    local pad = Instance.new("UIPadding", card)
    pad.PaddingTop = UDim.new(0,10)
    pad.PaddingLeft = UDim.new(0,10)
    pad.PaddingRight = UDim.new(0,10)
    pad.PaddingBottom = UDim.new(0,10)
    return card
end

-- คืนอ้างอิงโครงหลักเผื่อใช้งาน
function UFOUI:GetRoot()
    return GUI, Window, Header, Sidebar, Content
end

-- (ไม่เรียกใช้ API ใด ๆ ที่ท้ายไฟล์ เพื่อคงสภาพ "ศูนย์จริงๆ")

--==========================================================
-- END (พร้อมใช้งาน / พร้อมต่อยอด)
--==========================================================
