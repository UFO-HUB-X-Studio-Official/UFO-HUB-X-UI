--==========================================================
-- UFO HUB X • UFO ติดกับขอบบน + Stroke ขาว
--==========================================================

pcall(function()
    local g = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI")
    if g then g:Destroy() end
end)

--===== CONFIG =====
local TITLE       = "UFO  HUB X"
local GREEN       = Color3.fromRGB(0,255,140)
local WHITE       = Color3.fromRGB(255,255,255)
local BG_WINDOW   = Color3.fromRGB(16,16,16)
local BG_HEADER   = Color3.fromRGB(0,0,0)
local BG_PANEL    = Color3.fromRGB(22,22,22)
local BG_INNER    = Color3.fromRGB(20,20,20)
local TEXT_WHITE  = Color3.fromRGB(235,235,235)

local WIN_W, WIN_H = 640, 360
local GAP_OUTER    = 14
local GAP_BETWEEN  = 12
local LEFT_RATIO   = 0.22
local RIGHT_RATIO  = 0.78

-- รูป
local IMG_SMALL = "rbxassetid://95514334029879"      -- ซ้ายเล็ก
local IMG_LARGE = "rbxassetid://117055535552131"     -- ขวาใหญ่
local IMG_UFO   = "rbxassetid://100650447103028"     -- UFO

--===== HELPERS =====
local function corner(gui, r)
    local c = Instance.new("UICorner", gui)
    c.CornerRadius = UDim.new(0, r or 10)
    return c
end
local function stroke(gui, t, col)
    local s = Instance.new("UIStroke", gui)
    s.Thickness = t or 1
    s.Color = col or WHITE
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end

--===== ROOT =====
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")

local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false
GUI.Parent = CoreGui

--===== WINDOW =====
local Window = Instance.new("Frame", GUI)
Window.AnchorPoint = Vector2.new(0.5,0.5)
Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.fromOffset(WIN_W,WIN_H)
Window.BackgroundColor3 = BG_WINDOW
Window.BorderSizePixel = 0
corner(Window,10)
stroke(Window,1,GREEN)

-- Glow เล็ก ๆ
do
    local Glow = Instance.new("ImageLabel", Window)
    Glow.BackgroundTransparency = 1
    Glow.AnchorPoint = Vector2.new(0.5,0.5)
    Glow.Position = UDim2.new(0.5,0,0.5,0)
    Glow.Size = UDim2.new(1.06,0,1.08,0)
    Glow.ZIndex = 0
    Glow.Image = "rbxassetid://5028857084"
    Glow.ImageColor3 = GREEN
    Glow.ImageTransparency = 0.78
    Glow.ScaleType = Enum.ScaleType.Slice
    Glow.SliceCenter = Rect.new(24,24,276,276)
end

-- Scale auto
local UIScale = Instance.new("UIScale", Window)
local function fit()
    local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    UIScale.Scale = math.clamp(math.min(v.X/860,v.Y/540),0.72,1.0)
end
fit()
RunS.RenderStepped:Connect(fit)

--===== HEADER =====
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1,0,0,40)
Header.BackgroundColor3 = BG_HEADER
Header.BorderSizePixel = 0
corner(Header,10)

local Dot = Instance.new("Frame", Header)
Dot.BackgroundColor3 = GREEN
Dot.Position = UDim2.new(0,14,0.5,-5)
Dot.Size = UDim2.new(0,10,0,10)
corner(Dot,5)

local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Position = UDim2.new(0,30,0,0)
TitleLbl.Size = UDim2.new(1,-90,1,0)
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.Text = TITLE
TitleLbl.TextSize = 15
TitleLbl.TextColor3 = TEXT_WHITE
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local BtnClose = Instance.new("TextButton", Header)
BtnClose.Size = UDim2.new(0,24,0,24)
BtnClose.Position = UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3 = Color3.fromRGB(200,40,40)
BtnClose.Text = "X"
BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 13
BtnClose.TextColor3 = Color3.new(1,1,1)
BtnClose.BorderSizePixel = 0
corner(BtnClose,6)
stroke(BtnClose,1,Color3.fromRGB(255,0,0))
BtnClose.MouseButton1Click:Connect(function() GUI.Enabled=false end)

-- Drag
do
    local dragging, start, startPos
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; start=i.Position; startPos=Window.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-start
            Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

--===== UFO ติดขอบบน =====
do
    local UFO = Instance.new("ImageLabel", Window)
    UFO.Name = "UFO_Top"
    UFO.BackgroundTransparency = 1
    UFO.Image = IMG_UFO
    UFO.Size = UDim2.new(0,84,0,84)
    UFO.AnchorPoint = Vector2.new(0.5,1)
    UFO.Position = UDim2.new(0.5,0,0,0) -- ขยับลงมาติดกับขอบบนจริง ๆ
    UFO.ZIndex = 60
end

--===== BODY =====
local Body = Instance.new("Frame", Window)
Body.BackgroundTransparency = 1
Body.Position = UDim2.new(0,0,0,40)
Body.Size = UDim2.new(1,0,1,-40)

local Inner = Instance.new("Frame", Body)
Inner.BackgroundColor3 = BG_INNER
Inner.Position = UDim2.new(0,8,0,8)
Inner.Size = UDim2.new(1,-16,1,-16)
corner(Inner,10)

local Content = Instance.new("Frame", Body)
Content.BackgroundColor3 = BG_PANEL
Content.Position = UDim2.new(0,GAP_OUTER,0,GAP_OUTER)
Content.Size = UDim2.new(1,-GAP_OUTER*2,1,-GAP_OUTER*2)
corner(Content,10)
stroke(Content,1,WHITE)

local Columns = Instance.new("Frame", Content)
Columns.BackgroundTransparency = 1
Columns.Position = UDim2.new(0,8,0,8)
Columns.Size = UDim2.new(1,-16,1,-16)

-- ซ้ายเล็ก
local Left = Instance.new("Frame", Columns)
Left.BackgroundColor3 = Color3.fromRGB(16,16,16)
Left.Size = UDim2.new(LEFT_RATIO,-GAP_BETWEEN/2,1,0)
corner(Left,10)
stroke(Left,1,WHITE)

-- ขวาใหญ่
local Right = Instance.new("Frame", Columns)
Right.BackgroundColor3 = Color3.fromRGB(16,16,16)
Right.Position = UDim2.new(LEFT_RATIO,GAP_BETWEEN,0,0)
Right.Size = UDim2.new(RIGHT_RATIO,-GAP_BETWEEN/2,1,0)
corner(Right,10)
stroke(Right,1,WHITE)

-- รูป
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
