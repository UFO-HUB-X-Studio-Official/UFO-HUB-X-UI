--==========================================================
-- UFO HUB X • Layout (2 ช่อง: ซ้ายเล็ก/ขวาใหญ่) + ใส่รูปแยก
--==========================================================

-- เคลียร์ของเก่า
pcall(function()
    local g = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI")
    if g then g:Destroy() end
end)

-- ===== THEME =====
local TITLE        = "UFO  HUB X"
local GREEN        = Color3.fromRGB(0,255,140)
local BG_WINDOW    = Color3.fromRGB(16,16,16)
local BG_HEADER    = Color3.fromRGB(0,0,0)
local BG_PANEL     = Color3.fromRGB(22,22,22)
local BG_INNER     = Color3.fromRGB(20,20,20)
local TEXT_WHITE   = Color3.fromRGB(235,235,235)

local WIN_W, WIN_H = 820, 460  
local GAP_OUTER    = 18        
local GAP_BETWEEN  = 14        

local LEFT_RATIO   = 0.35      
local RIGHT_RATIO  = 0.65      

-- รูปภาพ Roblox
local IMG_SMALL = "rbxassetid://95514334029879"      -- ช่องเล็ก
local IMG_LARGE = "rbxassetid://117055535552131"     -- ช่องใหญ่

-- ===== HELPERS =====
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

-- ===== ROOT GUI =====
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
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5,0.5)
Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.fromOffset(WIN_W, WIN_H)
Window.BackgroundColor3 = BG_WINDOW
Window.BorderSizePixel = 0
corner(Window, 10)
stroke(Window, 1.5, GREEN)

-- Glow เบา ๆ รอบนอก
local Glow = Instance.new("ImageLabel", Window)
Glow.Name = "Glow"
Glow.BackgroundTransparency = 1
Glow.AnchorPoint = Vector2.new(0.5,0.5)
Glow.Position = UDim2.new(0.5,0,0.5,0)
Glow.Size = UDim2.new(1.10,0,1.10,0)
Glow.ZIndex = 0
Glow.Image = "rbxassetid://5028857084"
Glow.ImageColor3 = GREEN
Glow.ImageTransparency = 0.72
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(24,24,276,276)

-- ปรับสเกล
local UIScale = Instance.new("UIScale", Window)
local function fit()
    local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    UIScale.Scale = math.clamp(math.min(v.X/980, v.Y/600), 0.75, 1.0)
end
fit(); RunS.RenderStepped:Connect(fit)

-- ===== HEADER =====
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1,0,0,44)
Header.BackgroundColor3 = BG_HEADER
Header.BorderSizePixel = 0
Header.ZIndex = 2
corner(Header, 10)

local Dot = Instance.new("Frame", Header)
Dot.BackgroundColor3 = GREEN
Dot.BorderSizePixel = 0
Dot.Position = UDim2.new(0,14,0.5,-6)
Dot.Size = UDim2.new(0,12,0,12)
corner(Dot, 6)

local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Position = UDim2.new(0,32,0,0)
TitleLbl.Size = UDim2.new(1,-100,1,0)
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.Text = TITLE
TitleLbl.TextSize = 16
TitleLbl.TextColor3 = TEXT_WHITE
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

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
corner(BtnClose, 6); stroke(BtnClose, 1.2, Color3.fromRGB(255,0,0))
BtnClose.MouseEnter:Connect(function() BtnClose.BackgroundColor3 = Color3.fromRGB(255,60,60) end)
BtnClose.MouseLeave:Connect(function() BtnClose.BackgroundColor3 = Color3.fromRGB(200,40,40) end)
BtnClose.MouseButton1Click:Connect(function() GUI.Enabled = false end)

-- ===== BODY =====
local Body = Instance.new("Frame", Window)
Body.BackgroundTransparency = 1
Body.Position = UDim2.new(0,0,0,44)
Body.Size = UDim2.new(1,0,1,-44)

local Inner = Instance.new("Frame", Body)
Inner.BackgroundColor3 = BG_INNER
Inner.BorderSizePixel = 0
Inner.Position = UDim2.new(0,10,0,10)
Inner.Size = UDim2.new(1,-20,1,-20)
corner(Inner, 10)

-- ===== CONTENT AREA =====
local Content = Instance.new("Frame", Body)
Content.BackgroundColor3 = BG_PANEL
Content.BorderSizePixel = 0
Content.Position = UDim2.new(0, GAP_OUTER, 0, GAP_OUTER)
Content.Size = UDim2.new(1, -GAP_OUTER*2, 1, -GAP_OUTER*2)
corner(Content, 10); stroke(Content, 1, GREEN)

local Columns = Instance.new("Frame", Content)
Columns.BackgroundTransparency = 1
Columns.Position = UDim2.new(0, 8, 0, 8)
Columns.Size = UDim2.new(1, -16, 1, -16)

-- ซ้าย (เล็ก)
local Left = Instance.new("Frame", Columns)
Left.Name = "LeftCard"
Left.BackgroundColor3 = Color3.fromRGB(16,16,16)
Left.BorderSizePixel = 0
Left.Size = UDim2.new(LEFT_RATIO, -GAP_BETWEEN/2, 1, 0)
Left.Position = UDim2.new(0, 0, 0, 0)
Left.ClipsDescendants = true
corner(Left, 10); stroke(Left, 1, GREEN)

-- ขวา (ใหญ่)
local Right = Instance.new("Frame", Columns)
Right.Name = "RightCard"
Right.BackgroundColor3 = Color3.fromRGB(16,16,16)
Right.BorderSizePixel = 0
Right.Size = UDim2.new(RIGHT_RATIO, -GAP_BETWEEN/2, 1, 0)
Right.Position = UDim2.new(LEFT_RATIO, GAP_BETWEEN, 0, 0)
Right.ClipsDescendants = true
corner(Right, 10); stroke(Right, 1, GREEN)

-- ===== IMAGES =====
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
