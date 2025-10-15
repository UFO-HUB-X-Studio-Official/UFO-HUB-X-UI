pcall(function()
    local g = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI")
    if g then g:Destroy() end
    local t = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_Toggle")
    if t then t:Destroy() end
end)

-- THEME
local GREEN        = Color3.fromRGB(0,255,140)
local MINT         = Color3.fromRGB(120,255,220)
local MINT_SOFT    = Color3.fromRGB(90,210,190)
local BG_WINDOW    = Color3.fromRGB(16,16,16)
local BG_HEADER    = Color3.fromRGB(6,6,6)
local BG_PANEL     = Color3.fromRGB(22,22,22)
local BG_INNER     = Color3.fromRGB(18,18,18)
local TEXT_WHITE   = Color3.fromRGB(235,235,235)
local DANGER_RED   = Color3.fromRGB(200,40,40)

-- SIZE
local WIN_W, WIN_H = 640, 360

-- IMAGES
local IMG_SMALL = "rbxassetid://121069267171370"
local IMG_LARGE = "rbxassetid://108408843188558"
local IMG_UFO   = "rbxassetid://100650447103028"

-- HELPERS
local function corner(gui, r)
    local c = Instance.new("UICorner", gui); c.CornerRadius = UDim.new(0, r or 10); return c
end
local function stroke(gui, t, col, trans)
    local s = Instance.new("UIStroke", gui)
    s.Thickness, s.Color, s.Transparency = t or 1, col or MINT, trans or 0.35
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end
local function gradient(gui, c1, c2, rot)
    local g = Instance.new("UIGradient", gui); g.Color = ColorSequence.new(c1, c2); g.Rotation = rot or 0; return g
end

-- ROOT
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")

local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"; GUI.IgnoreGuiInset = true; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false; GUI.Parent = CoreGui

-- WINDOW
local Window = Instance.new("Frame", GUI)
Window.AnchorPoint = Vector2.new(0.5,0.5); Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.fromOffset(WIN_W, WIN_H); Window.BackgroundColor3 = BG_WINDOW; Window.BorderSizePixel = 0
corner(Window, 12); stroke(Window, 3, GREEN, 0)

-- glow
do
    local Glow = Instance.new("ImageLabel", Window)
    Glow.BackgroundTransparency = 1; Glow.AnchorPoint = Vector2.new(0.5,0.5)
    Glow.Position = UDim2.new(0.5,0,0.5,0); Glow.Size = UDim2.new(1.07,0,1.09,0)
    Glow.Image = "rbxassetid://5028857084"; Glow.ImageColor3 = GREEN; Glow.ImageTransparency = 0.78
    Glow.ScaleType = Enum.ScaleType.Slice; Glow.SliceCenter = Rect.new(24,24,276,276); Glow.ZIndex = 0
end

-- autoscale
local UIScale = Instance.new("UIScale", Window)
local function fit()
    local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    UIScale.Scale = math.clamp(math.min(v.X/860, v.Y/540), 0.72, 1.0)
end
fit(); RunS.RenderStepped:Connect(fit)

-- HEADER
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1,0,0,46); Header.BackgroundColor3 = BG_HEADER; Header.BorderSizePixel = 0
corner(Header, 12); gradient(Header, Color3.fromRGB(10,10,10), Color3.fromRGB(0,0,0), 0)

local HeadAccent = Instance.new("Frame", Header)
HeadAccent.AnchorPoint = Vector2.new(0.5,1); HeadAccent.Position = UDim2.new(0.5,0,1,0)
HeadAccent.Size = UDim2.new(1,-20,0,1); HeadAccent.BackgroundColor3 = MINT; HeadAccent.BackgroundTransparency = 0.35
HeadAccent.BorderSizePixel = 0

-- (ลบ Dot ออก)
-- local Dot = Instance.new("Frame", Header) -- ❌ ไม่สร้างจุดกลม

local BtnClose = Instance.new("TextButton", Header)
BtnClose.Size = UDim2.new(0,24,0,24); BtnClose.Position = UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3 = DANGER_RED; BtnClose.Text = "X"; BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 13; BtnClose.TextColor3 = Color3.new(1,1,1); BtnClose.BorderSizePixel = 0
corner(BtnClose, 6); stroke(BtnClose, 1, Color3.fromRGB(255,0,0), 0.1)

BtnClose.MouseButton1Click:Connect(function()
    Window.Visible = false
    getgenv().UFO_ISOPEN = false
end)

-- drag (block camera)
do
    local dragging, start, startPos
    local CAS = game:GetService("ContextActionService")
    local function bindBlock(on)
        local name="UFO_BlockLook_Window"
        if on then
            local fn=function() return Enum.ContextActionResult.Sink end
            CAS:BindActionAtPriority(name, fn, false, 9000,
                Enum.UserInputType.MouseMovement,
                Enum.UserInputType.Touch,
                Enum.UserInputType.MouseButton1)
        else pcall(function() CAS:UnbindAction(name) end) end
    end
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Window.Position; bindBlock(true)
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; bindBlock(false) end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            Window.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

-- ===== UFO + TITLE =====
do
    local UFO_Y_OFFSET   = 84
    local TITLE_Y_OFFSET = 8

    local UFO = Instance.new("ImageLabel", Window)
    UFO.Name = "UFO_Top"; UFO.BackgroundTransparency = 1; UFO.Image = IMG_UFO
    UFO.Size = UDim2.new(0,168,0,168)
    UFO.AnchorPoint = Vector2.new(0.5,1)
    UFO.Position = UDim2.new(0.5, 0, 0, UFO_Y_OFFSET)
    UFO.ZIndex = 60

    local Halo = Instance.new("ImageLabel", Window)
    Halo.BackgroundTransparency = 1; Halo.AnchorPoint = Vector2.new(0.5,0)
    Halo.Position = UDim2.new(0.5,0,0,0); Halo.Size = UDim2.new(0, 200, 0, 60)
    Halo.Image = "rbxassetid://5028857084"; Halo.ImageColor3 = MINT_SOFT; Halo.ImageTransparency = 0.72
    Halo.ZIndex = 50

    local TitleCenter = Instance.new("TextLabel", Header)
    TitleCenter.BackgroundTransparency = 1; TitleCenter.AnchorPoint = Vector2.new(0.5,0)
    TitleCenter.Position = UDim2.new(0.5, 0, 0, TITLE_Y_OFFSET)
    TitleCenter.Size = UDim2.new(0.8, 0, 0, 36)
    TitleCenter.Font = Enum.Font.GothamBold; TitleCenter.RichText = true; TitleCenter.TextScaled = true
    TitleCenter.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
    TitleCenter.TextColor3 = TEXT_WHITE; TitleCenter.ZIndex = 61
end

--========================
-- BODY
--========================
local Body = Instance.new("Frame", Window)
Body.BackgroundTransparency = 1
Body.Position = UDim2.new(0,0,0,46)
Body.Size     = UDim2.new(1,0,1,-46)

local Inner = Instance.new("Frame", Body)
Inner.BackgroundColor3 = BG_INNER
Inner.BorderSizePixel  = 0
Inner.Position = UDim2.new(0,8,0,8)
Inner.Size     = UDim2.new(1,-16,1,-16)
corner(Inner, 12)

local Content = Instance.new("Frame", Body)
Content.BackgroundColor3 = BG_PANEL
Content.Position = UDim2.new(0,10,0,10)
Content.Size     = UDim2.new(1,-20,1,-20)
corner(Content, 12); stroke(Content, 0.5, MINT, 0.35)

local Columns = Instance.new("Frame", Content)
Columns.BackgroundTransparency = 1
Columns.Position = UDim2.new(0,8,0,8)
Columns.Size     = UDim2.new(1,-16,1,-16)

-- ซ้าย/ขวา
local Left=Instance.new("Frame",Columns)
Left.BackgroundColor3=Color3.fromRGB(16,16,16); Left.Size=UDim2.new(0.22,-6,1,0)
Left.ClipsDescendants=true; corner(Left,10); stroke(Left,1.2,GREEN,0); stroke(Left,0.45,MINT,0.35)

local Right=Instance.new("Frame",Columns)
Right.BackgroundColor3=Color3.fromRGB(16,16,16)
Right.Position=UDim2.new(0.22,12,0,0); Right.Size=UDim2.new(0.78,-6,1,0)
Right.ClipsDescendants=true; corner(Right,10); stroke(Right,1.2,GREEN,0); stroke(Right,0.45,MINT,0.35)

-- พื้นหลัง
local imgL = Instance.new("ImageLabel", Left)
imgL.BackgroundTransparency = 1; imgL.Size = UDim2.new(1,0,1,0)
imgL.Image = IMG_SMALL or ""; imgL.ScaleType = Enum.ScaleType.Crop; imgL.ZIndex = 0

local imgR = Instance.new("ImageLabel", Right)
imgR.BackgroundTransparency = 1; imgR.Size = UDim2.new(1,0,1,0)
imgR.Image = IMG_LARGE or ""; imgR.ScaleType = Enum.ScaleType.Crop; imgR.ZIndex = 0

-- สร้าง ScrollingFrame
local function makeScroller(panel)
    local sc = Instance.new("ScrollingFrame")
    sc.Name = "Scroll"
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ClipsDescendants = true
    sc.ScrollingDirection = Enum.ScrollingDirection.Y
    sc.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    sc.ScrollBarThickness = 6
    sc.ScrollBarImageColor3 = GREEN
    sc.ScrollBarImageTransparency = 0.1
    sc.Position = UDim2.new(0,8,0,8)
    sc.Size     = UDim2.new(1,-16,1,-16)
    sc.CanvasSize = UDim2.new(0,0,0,0)
    sc.Parent = panel

    local pad = Instance.new("UIPadding", sc)
    pad.PaddingLeft = UDim.new(0,4)
    pad.PaddingRight = UDim.new(0,4)
    pad.PaddingTop = UDim.new(0,4)
    pad.PaddingBottom = UDim.new(0,8)

    local list = Instance.new("UIListLayout", sc)
    list.Padding = UDim.new(0,8)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local function refreshCanvas()
        sc.CanvasSize = UDim2.fromOffset(0, list.AbsoluteContentSize.Y + 8)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas)
    panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshCanvas)
    task.defer(refreshCanvas)
    return sc
end

local LeftScroll  = makeScroller(Left)
local RightScroll = makeScroller(Right)

--==========================================================
-- UFO RECOVERY PATCH (Final Fix v3: sync flag + block camera drag)
--==========================================================
do
    local CoreGui = game:GetService("CoreGui")
    local UIS     = game:GetService("UserInputService")
    local CAS     = game:GetService("ContextActionService")

    local function findMain()
        local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
        local win
        if gui then win = gui:FindFirstChildWhichIsA("Frame") end
        return gui, win
    end

    local function showUI()
        local gui, win = findMain()
        if gui then gui.Enabled = true end
        if win then win.Visible = true end
        getgenv().UFO_ISOPEN = true
    end

    local function hideUI()
        local gui, win = findMain()
        if win then win.Visible = false end
        getgenv().UFO_ISOPEN = false
    end

    -- ตั้งค่า flag เริ่มตามสถานะจริงของหน้าต่าง (กันกดครั้งแรกไม่ขึ้น)
    do
        local _, win = findMain()
        getgenv().UFO_ISOPEN = (win and win.Visible) and true or false
    end

    -- ปุ่ม X ทั้งระบบ -> ซ่อน + sync flag (กันกดเปิดต้องกดสองครั้ง)
    for _,o in ipairs(CoreGui:GetDescendants()) do
        if o:IsA("TextButton") and o.Text and o.Text:upper()=="X" then
            o.MouseButton1Click:Connect(function() hideUI() end)
        end
    end

    -- ปุ่ม Toggle (ImageButton) + กรอบเขียว + ลากได้ + บล็อกกล้องขณะลาก
    local toggleGui = CoreGui:FindFirstChild("UFO_HUB_X_Toggle")
    if toggleGui then toggleGui:Destroy() end

    local ToggleGui = Instance.new("ScreenGui", CoreGui)
    ToggleGui.Name = "UFO_HUB_X_Toggle"; ToggleGui.IgnoreGuiInset = true

    local ToggleBtn = Instance.new("ImageButton", ToggleGui)
    ToggleBtn.Size = UDim2.fromOffset(64,64); ToggleBtn.Position = UDim2.fromOffset(80,200)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Image = "rbxassetid://117052960049460"
    local c = Instance.new("UICorner", ToggleBtn); c.CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke", ToggleBtn); s.Thickness=2; s.Color=GREEN

    local function toggleUI()
        if getgenv().UFO_ISOPEN then hideUI() else showUI() end
    end
    ToggleBtn.MouseButton1Click:Connect(toggleUI)

    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.RightShift then toggleUI() end
    end)

    -- Drag ปุ่มสี่เหลี่ยม + block camera
    do
        local dragging=false; local start; local startPos
        local function bindBlock(on)
            local name="UFO_BlockLook_Toggle"
            if on then
                local fn=function() return Enum.ContextActionResult.Sink end
                CAS:BindActionAtPriority(name, fn, false, 9000,
                    Enum.UserInputType.MouseMovement,
                    Enum.UserInputType.Touch,
                    Enum.UserInputType.MouseButton1)
            else
                pcall(function() CAS:UnbindAction(name) end)
            end
        end

        ToggleBtn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; start=i.Position
                startPos=Vector2.new(ToggleBtn.Position.X.Offset, ToggleBtn.Position.Y.Offset)
                bindBlock(true)
                i.Changed:Connect(function()
                    if i.UserInputState==Enum.UserInputState.End then
                        dragging=false; bindBlock(false)
                    end
                end)
            end
        end)

        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local d=i.Position-start
                ToggleBtn.Position=UDim2.fromOffset(startPos.X+d.X,startPos.Y+d.Y)
            end
        end)
    end
end

local LeftScroll  = makeScroller(Left)
local RightScroll = makeScroller(Right)

----------------------------------------------------------------
-- FULL-FIT FIX: Left Scroll + Player Button (no margins)
----------------------------------------------------------------

-- ลบสกรอลเก่าแล้วสร้างใหม่แบบไม่มีช่องว่างเลย
local old = Left:FindFirstChildOfClass("ScrollingFrame")
if old then old:Destroy() end

local LeftScroll = Instance.new("ScrollingFrame", Left)
LeftScroll.Name = "Scroll"
LeftScroll.BackgroundTransparency = 1
LeftScroll.BorderSizePixel = 0
LeftScroll.ClipsDescendants = true
LeftScroll.ScrollingDirection = Enum.ScrollingDirection.Y
LeftScroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
LeftScroll.ScrollBarThickness = 6
LeftScroll.ScrollBarImageColor3 = GREEN
LeftScroll.ScrollBarImageTransparency = 0.1
LeftScroll.Position = UDim2.new(0,0,0,0)     -- ❗ชิดขอบจริง ๆ
LeftScroll.Size     = UDim2.new(1,0,1,0)     -- ❗กว้าง/สูงเต็มกรอบ
LeftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LeftScroll.CanvasSize = UDim2.new(0,0,0,0)
LeftScroll.ZIndex = 50

-- ไม่ใช้ UIPadding เลย และตั้ง UIListLayout แบบไม่เว้นระยะ
local list = Instance.new("UIListLayout", LeftScroll)
list.Padding = UDim.new(0,0)                 -- ❗ไม่มีช่องว่าง
list.SortOrder = Enum.SortOrder.LayoutOrder

-- เคลียร์ปุ่มเดิม
for _,o in ipairs(LeftScroll:GetChildren()) do
    if o.Name == "Player_Left" then o:Destroy() end
end

-- ========== ปุ่ม Player แบบเต็มกรอบ ==========
local LEFT_H = 40
local LBtn = Instance.new("TextButton", LeftScroll)
LBtn.Name = "Player_Left"
LBtn.AutoButtonColor = false
LBtn.Text = ""
LBtn.BackgroundColor3 = Color3.fromRGB(15,15,15)
LBtn.BorderSizePixel = 0
LBtn.Size = UDim2.new(1,0,0,LEFT_H)          -- ❗เต็มความกว้างจริง ๆ
LBtn.ZIndex = 60
local LCorner = Instance.new("UICorner", LBtn); LCorner.CornerRadius = UDim.new(0,8)

-- เส้นขอบเขียว (บางลง)
local LStroke = Instance.new("UIStroke", LBtn)
LStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
LStroke.LineJoinMode = Enum.LineJoinMode.Round
LStroke.Thickness = 1.0
LStroke.Color = GREEN
LStroke.Transparency = 0

-- ไอคอน + ข้อความ (ไอคอนใหญ่ขึ้น)
local ICON = 28
local ACCENT_ASSETS = {
    GREEN = "rbxassetid://112510739340023",
    RED   = "rbxassetid://131641206815699",
    GOLD  = "rbxassetid://127371066511941",
    WHITE = "rbxassetid://106330577092636",
}
local CURRENT = getgenv().UFO_ACCENT or "GREEN"
local function currentIcon() return ACCENT_ASSETS[CURRENT] or ACCENT_ASSETS.GREEN end

local LIcon = Instance.new("ImageLabel", LBtn)
LIcon.BackgroundTransparency = 1
LIcon.Size = UDim2.fromOffset(ICON, ICON)
LIcon.Position = UDim2.fromOffset(10, (LEFT_H-ICON)/2)
LIcon.Image = currentIcon()
LIcon.ZIndex = 61

local LTitle = Instance.new("TextLabel", LBtn)
LTitle.BackgroundTransparency = 1
LTitle.Text = "Player"
LTitle.Font = Enum.Font.GothamBold
LTitle.TextSize = 16
LTitle.TextColor3 = Color3.fromRGB(255,255,255)
LTitle.TextXAlignment = Enum.TextXAlignment.Left
LTitle.Position = UDim2.fromOffset(10 + ICON + 8, (LEFT_H-18)/2)
LTitle.Size = UDim2.new(1, -(10 + ICON + 8 + 10), 0, 18)
LTitle.ZIndex = 61

-- ========== ฝั่งขวา: แสดงรูป+ชื่อเมื่อกด ==========
-- ลองหา RightScroll ถ้ายังไม่มีให้สร้างสั้น ๆ
local RightScroll = Right:FindFirstChildOfClass("ScrollingFrame")
if not RightScroll then
    RightScroll = Instance.new("ScrollingFrame", Right)
    RightScroll.Name = "Scroll"
    RightScroll.BackgroundTransparency = 1
    RightScroll.BorderSizePixel = 0
    RightScroll.ClipsDescendants = true
    RightScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    RightScroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    RightScroll.ScrollBarThickness = 6
    RightScroll.ScrollBarImageColor3 = GREEN
    RightScroll.ScrollBarImageTransparency = 0.1
    RightScroll.Position = UDim2.new(0,8,0,8)
    RightScroll.Size     = UDim2.new(1,-16,1,-16)
    RightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local rl = Instance.new("UIListLayout", RightScroll); rl.Padding = UDim.new(0,8)
end

-- ล้างของเก่าด้านขวา
for _,o in ipairs(RightScroll:GetChildren()) do
    if o.Name == "Player_Right" then o:Destroy() end
end

local RIGHT_W, RIGHT_H = 260, 34
local RFrame = Instance.new("Frame", RightScroll)
RFrame.Name = "Player_Right"
RFrame.BackgroundTransparency = 1
RFrame.Size = UDim2.fromOffset(RIGHT_W, RIGHT_H)
RFrame.Visible = false
RFrame.ZIndex = 60

local RIcon = Instance.new("ImageLabel", RFrame)
RIcon.BackgroundTransparency = 1
RIcon.Size = UDim2.fromOffset(ICON+4, ICON+4)
RIcon.Position = UDim2.fromOffset(0, (RIGHT_H-(ICON+4))/2)
RIcon.Image = currentIcon()
RIcon.ZIndex = 61

local RTitle = Instance.new("TextLabel", RFrame)
RTitle.BackgroundTransparency = 1
RTitle.Text = "Player"
RTitle.Font = Enum.Font.GothamBold
RTitle.TextSize = 16
RTitle.TextColor3 = Color3.fromRGB(255,255,255)
RTitle.TextXAlignment = Enum.TextXAlignment.Left
RTitle.Position = UDim2.fromOffset(ICON+10, (RIGHT_H-18)/2)
RTitle.Size = UDim2.new(1, -(ICON+14), 0, 18)
RTitle.ZIndex = 61

LBtn.MouseButton1Click:Connect(function()
    RFrame.Visible = true
end)
