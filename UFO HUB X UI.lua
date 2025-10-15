--==========================================================
-- UFO HUB X — UI Style (ภาพที่ 2 เป๊ะ) + Recovery Toggle + Simple API
--==========================================================

pcall(function()
    local cg = game:GetService("CoreGui")
    for _,n in ipairs({"UFO_HUB_X_UI","UFO_HUB_X_Toggle"}) do
        local x = cg:FindFirstChild(n); if x then x:Destroy() end
    end
end)

-- THEME (โทนเดียวกับรูปที่ 2)
local GREEN        = Color3.fromRGB(0,255,140)
local MINT         = Color3.fromRGB(120,255,220)
local MINT_SOFT    = Color3.fromRGB(90,210,190)
local BG_WINDOW    = Color3.fromRGB(16,16,16)
local BG_HEADER    = Color3.fromRGB(6,6,6)
local BG_PANEL     = Color3.fromRGB(22,22,22)
local BG_INNER     = Color3.fromRGB(18,18,18)
local TEXT_WHITE   = Color3.fromRGB(235,235,235)
local DANGER_RED   = Color3.fromRGB(200,40,40)

-- SIZE (อัตราส่วน/ขนาดแบบรูปที่ 2)
local WIN_W, WIN_H = 860, 520
local LEFT_RATIO   = 0.24 -- ซ้ายแคบ ขวากว้าง

-- IMAGES (เปลี่ยนเลขตามต้องการ)
local IMG_UFO      = "rbxassetid://100650447103028"    -- โลโก้ UFO บนหัว
local IMG_GLOW     = "rbxassetid://5028857084"         -- glow 9-slice
local IMG_SHADOW   = "rbxassetid://1316045217"         -- เงา
local IMG_ALIEN_BG = "rbxassetid://108408843188558"    -- พื้นหลังฝั่งขวา (แก้ได้ภายหลังผ่าน API)

-- Services
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local CAS     = game:GetService("ContextActionService")
local RunS    = game:GetService("RunService")

-- Helpers
local function corner(gui, r)
    local c = Instance.new("UICorner", gui); c.CornerRadius = UDim.new(0, r or 20); return c
end
local function stroke(gui, t, col, trans)
    local s = Instance.new("UIStroke", gui)
    s.Thickness, s.Color, s.Transparency = t or 1, col or GREEN, trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = gui
    return s
end
local function gradient(gui, c1, c2)
    local g = Instance.new("UIGradient", gui)
    g.Color = ColorSequence.new(c1, c2); g.Parent = gui
    return g
end

-- ScreenGui
local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false
GUI.Parent = CoreGui

-- Window
local Window = Instance.new("Frame", GUI)
Window.AnchorPoint = Vector2.new(0.5,0.5)
Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.fromOffset(WIN_W, WIN_H)
Window.BackgroundColor3 = BG_WINDOW
Window.BorderSizePixel = 0
corner(Window, 24)
stroke(Window, 3, GREEN, 0)

-- Outer glow + shadow
do
    local Glow = Instance.new("ImageLabel", Window)
    Glow.BackgroundTransparency = 1
    Glow.AnchorPoint = Vector2.new(0.5,0.5)
    Glow.Position = UDim2.new(0.5,0,0.5,0)
    Glow.Size = UDim2.new(1.08,0,1.10,0)
    Glow.Image = IMG_GLOW
    Glow.ImageColor3 = GREEN
    Glow.ImageTransparency = 0.78
    Glow.ScaleType = Enum.ScaleType.Slice
    Glow.SliceCenter = Rect.new(24,24,276,276)
    Glow.ZIndex = 0

    local Shadow = Instance.new("ImageLabel", Window)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = IMG_SHADOW
    Shadow.ImageColor3 = Color3.new(0,0,0)
    Shadow.ImageTransparency = 0.4
    Shadow.Size = UDim2.new(1,80,1,80)
    Shadow.Position = UDim2.new(0,-40,0,-24)
    Shadow.ZIndex = 0
end

-- Header
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1,-20,0,52)
Header.Position = UDim2.new(0,10,0,10)
Header.BackgroundColor3 = BG_HEADER
Header.BorderSizePixel = 0
corner(Header, 16)
stroke(Header, 1, MINT, 0.25)
do
    local accent = Instance.new("Frame", Header)
    accent.AnchorPoint = Vector2.new(0.5,1)
    accent.Position = UDim2.new(0.5,0,1,0)
    accent.Size = UDim2.new(1,-20,0,1)
    accent.BackgroundColor3 = MINT
    accent.BackgroundTransparency = 0.35
    accent.BorderSizePixel = 0
    gradient(Header, Color3.fromRGB(12,12,12), Color3.fromRGB(0,0,0))
end

-- Halo + UFO + Title
do
    local Halo = Instance.new("ImageLabel", Window)
    Halo.BackgroundTransparency = 1
    Halo.AnchorPoint = Vector2.new(0.5,0)
    Halo.Position = UDim2.new(0.5,0,0,0)
    Halo.Size = UDim2.new(0,200,0,60)
    Halo.Image = IMG_GLOW
    Halo.ImageColor3 = MINT_SOFT
    Halo.ImageTransparency = 0.72
    Halo.ZIndex = 50

    local UFO = Instance.new("ImageLabel", Window)
    UFO.BackgroundTransparency = 1
    UFO.Image = IMG_UFO
    UFO.Size = UDim2.new(0,168,0,168)
    UFO.AnchorPoint = Vector2.new(0.5,1)
    UFO.Position = UDim2.new(0.5,0,0,84)
    UFO.ZIndex = 60
end
do
    local Title = Instance.new("TextLabel", Header)
    Title.BackgroundTransparency = 1
    Title.AnchorPoint = Vector2.new(0.5,0)
    Title.Position = UDim2.new(0.5,0,0,8)
    Title.Size = UDim2.new(0.8,0,0,36)
    Title.Font = Enum.Font.GothamBold
    Title.RichText = true
    Title.TextScaled = true
    Title.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
    Title.TextColor3 = TEXT_WHITE
end

-- Header controls: – □ X (X = Hide)
local function hdrBtn(txt, offX, col)
    local b = Instance.new("TextButton", Header)
    b.BackgroundTransparency = 1
    b.AutoButtonColor = false
    b.Size = UDim2.new(0,28,0,28)
    b.Position = UDim2.new(1, offX, 0.5, -14)
    b.Text = txt; b.Font = Enum.Font.GothamBold; b.TextSize = 18; b.TextColor3 = col
    return b
end
local BtnMin   = hdrBtn("–", -86, GREEN)
local BtnExp   = hdrBtn("□", -54, GREEN)
local BtnClose = hdrBtn("X", -22, DANGER_RED)
do
    local Xbg = Instance.new("Frame", Header)
    Xbg.Size = UDim2.new(0,24,0,24); Xbg.Position = UDim2.new(1,-26,0.5,-12)
    Xbg.BackgroundColor3 = DANGER_RED; Xbg.BackgroundTransparency = 1; Xbg.ZIndex = 70; corner(Xbg,6)
    BtnClose.MouseEnter:Connect(function() Xbg.BackgroundTransparency = 0.2 end)
    BtnClose.MouseLeave:Connect(function() Xbg.BackgroundTransparency = 1 end)
end

-- Drag window + block camera ขณะลาก
do
    local dragging, start, startPos
    local function block(on)
        local name="UFO_BlockLook_Window"
        if on then
            local fn=function() return Enum.ContextActionResult.Sink end
            CAS:BindActionAtPriority(name, fn, false, 9000,
                Enum.UserInputType.MouseMovement, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
        else pcall(function() CAS:UnbindAction(name) end) end
    end
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Window.Position; block(true)
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; block(false) end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            Window.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

-- BODY & PANELS (เหมือนรูป)
local Body=Instance.new("Frame",Window)
Body.BackgroundTransparency=1; Body.Position=UDim2.new(0,0,0,56); Body.Size=UDim2.new(1,0,1,-56)

local Inner=Instance.new("Frame",Body)
Inner.BackgroundColor3=BG_INNER; Inner.BorderSizePixel=0
Inner.Position=UDim2.new(0,8,0,8); Inner.Size=UDim2.new(1,-16,1,-16); corner(Inner,14)

local Content=Instance.new("Frame",Body)
Content.BackgroundColor3=BG_PANEL; Content.Position=UDim2.new(0,14,0,14); Content.Size=UDim2.new(1,-28,1,-28)
corner(Content,14); stroke(Content,0.8,MINT,0.35)

local Columns=Instance.new("Frame",Content)
Columns.BackgroundTransparency=1; Columns.Position=UDim2.new(0,8,0,8); Columns.Size=UDim2.new(1,-16,1,-16)

local Left=Instance.new("Frame",Columns)
Left.BackgroundColor3=Color3.fromRGB(16,16,16); Left.Size=UDim2.new(LEFT_RATIO,-6,1,0)
Left.ClipsDescendants=true; corner(Left,14); stroke(Left,1.6,GREEN,0); stroke(Left,0.45,MINT,0.35)

local Right=Instance.new("Frame",Columns)
Right.BackgroundColor3=Color3.fromRGB(16,16,16)
Right.Position=UDim2.new(LEFT_RATIO,12,0,0); Right.Size=UDim2.new(1-LEFT_RATIO,-6,1,0)
Right.ClipsDescendants=true; corner(Right,14); stroke(Right,1.6,GREEN,0); stroke(Right,0.45,MINT,0.35)

-- พื้นหลังฝั่งขวา (ภาพเอเลี่ยน)
local RightBG=Instance.new("ImageLabel",Right)
RightBG.BackgroundTransparency=1; RightBG.Image=IMG_ALIEN_BG
RightBG.Size=UDim2.fromScale(1,1); RightBG.ScaleType=Enum.ScaleType.Fit; RightBG.ZIndex=1

-- สร้าง ScrollingFrame แยกอิสระ
local function attachScroll(host)
    local sf=Instance.new("ScrollingFrame",host)
    sf.Name="Scroll"; sf.Size=UDim2.fromScale(1,1); sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollingDirection=Enum.ScrollingDirection.Y
    sf.AutomaticCanvasSize=Enum.AutomaticSize.Y; sf.CanvasSize=UDim2.new()
    sf.ScrollBarThickness=6; sf.ScrollBarImageTransparency=1
    local pad=Instance.new("UIPadding",sf); pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8); pad.PaddingLeft=UDim.new(0,8); pad.PaddingRight=UDim.new(0,8)
    local list=Instance.new("UIListLayout",sf); list.Padding=UDim.new(0,8); list.SortOrder=Enum.SortOrder.LayoutOrder
    return sf
end
local LeftScroll  = attachScroll(Left)
local RightScroll = attachScroll(Right)

-- แถวสไตล์เดียวกับรูป
local function row(parent, text)
    local f = Instance.new("Frame", parent)
    f.BackgroundColor3 = Color3.fromRGB(10,12,10)
    f.Size = UDim2.new(1,0,0,42)
    corner(f, 20)
    stroke(f,1.2, GREEN, 0.12)
    local t = Instance.new("TextLabel", f)
    t.BackgroundTransparency = 1; t.Size = UDim2.new(1,-20,1,0); t.Position = UDim2.new(0,10,0,0)
    t.Font = Enum.Font.GothamSemibold; t.TextSize = 16; t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextColor3 = TEXT_WHITE; t.Text = text
end

-- (ตัวอย่างเล็ก ๆ — ลบได้)
for i=1,8 do row(LeftScroll,  ("Left Panel · Item "..i)) end
for i=1,8 do row(RightScroll, ("Right Panel · Item "..i)) end

-- ปุ่มหัวทำงาน
local savedSize, savedPos
local function hideUI() Window.Visible=false; getgenv().UFO_ISOPEN=false end
BtnMin.MouseButton1Click:Connect(function() GUI.Enabled=false; getgenv().UFO_ISOPEN=false end)
BtnExp.MouseButton1Click:Connect(function()
    local expanded = (Window.Size.X.Scale > 0)
    if not expanded then
        savedSize, savedPos = Window.Size, Window.Position
        Window.Position = UDim2.new(0.5,0,0.5,0)
        Window.Size = UDim2.new(1,-40,1,-40)
    else
        Window.Size = savedSize or UDim2.fromOffset(WIN_W, WIN_H)
        Window.Position = savedPos or UDim2.new(0.5,0,0.5,0)
    end
end)
BtnClose.MouseButton1Click:Connect(hideUI)

-- Autoscale (ให้ฟีลเดิมทุกหน้าจอ)
do
    local UIScale = Instance.new("UIScale", Window)
    local function fit()
        local cam = workspace.CurrentCamera
        local v = cam and cam.ViewportSize or Vector2.new(1280,720)
        UIScale.Scale = math.clamp(math.min(v.X/1100, v.Y/700), 0.72, 1.0)
    end
    fit(); RunS.RenderStepped:Connect(fit)
end

--==========================
-- UFO TOGGLE v2 (robust)
--==========================
do
    local CoreGui = game:GetService("CoreGui")
    local UIS     = game:GetService("UserInputService")
    local CAS     = game:GetService("ContextActionService")
    local RS      = game:GetService("RunService")

    -- หา UI หลักทุกครั้งแบบปลอดภัย
    local function findUI()
        local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
        local win
        if gui then
            for _,c in ipairs(gui:GetChildren()) do
                if c:IsA("Frame") then win = c break end
            end
        end
        return gui, win
    end

    local function showUI()
        local gui, win = findUI()
        if gui then gui.Enabled = true end
        if win then win.Visible = true end
        getgenv().UFO_ISOPEN = true
    end

    local function hideUI()
        local gui, win = findUI()
        if gui then gui.Enabled = true end -- อย่าปิดทั้ง ScreenGui เพราะ toggle อยู่คนละ ScreenGui
        if win then win.Visible = false end
        getgenv().UFO_ISOPEN = false
    end

    -- ตั้งค่าเริ่มต้น
    do
        local _, win = findUI()
        getgenv().UFO_ISOPEN = (win and win.Visible) and true or false
    end

    -- เคลียร์ toggle เดิม
    for _,n in ipairs({"UFO_HUB_X_Toggle","UFO_HUB_X_ToggleV2"}) do
        local g = CoreGui:FindFirstChild(n)
        if g then g:Destroy() end
    end

    -- ===== สร้างปุ่มลอยตัวใหม่ =====
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "UFO_HUB_X_ToggleV2"
    ToggleGui.IgnoreGuiInset = true
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToggleGui.DisplayOrder = 9e6            -- ให้ชนะทุกอย่าง
    ToggleGui.ResetOnSpawn = false
    ToggleGui.Parent = CoreGui

    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Name = "UFO_Fab"
    ToggleBtn.Size = UDim2.fromOffset(64,64)
    ToggleBtn.Position = UDim2.fromOffset(80,220)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Image = "rbxassetid://117052960049460" -- ไอคอน
    ToggleBtn.ZIndex = 999999
    ToggleBtn.Parent = ToggleGui

    do -- สไตล์กรอบนีออน
        local c = Instance.new("UICorner", ToggleBtn)  c.CornerRadius = UDim.new(0,10)
        local s = Instance.new("UIStroke", ToggleBtn)  s.Thickness = 2; s.Color = Color3.fromRGB(0,255,140)
    end

    local function toggle()
        if getgenv().UFO_ISOPEN then hideUI() else showUI() end
    end
    ToggleBtn.MouseButton1Click:Connect(toggle)

    -- ฮอตคีย์
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.RightShift or i.KeyCode==Enum.KeyCode.F8 or i.KeyCode==Enum.KeyCode.BackQuote then
            toggle()
        end
    end)

    -- ลากได้ + บล็อกกล้องขณะลาก
    do
        local dragging=false; local startPos; local startInput
        local function block(on)
            local name="UFO_BlockLook_ToggleV2"
            if on then
                local fn=function() return Enum.ContextActionResult.Sink end
                CAS:BindActionAtPriority(name, fn, false, 9000,
                    Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1)
            else pcall(function() CAS:UnbindAction(name) end) end
        end

        ToggleBtn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true
                startInput = i
                startPos = Vector2.new(ToggleBtn.Position.X.Offset, ToggleBtn.Position.Y.Offset)
                block(true)
                i.Changed:Connect(function()
                    if i.UserInputState==Enum.UserInputState.End then dragging=false; block(false) end
                end)
            end
        end)

        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local delta = i.Position - startInput.Position
                ToggleBtn.Position = UDim2.fromOffset(startPos.X + delta.X, startPos.Y + delta.Y)
            end
        end)
    end

    -- วงจรเฝ้า: ถ้า UI ถูกเกมซ่อน/รีเซ็ต ให้คืนสถานะแฟล็ก & ปุ่มอยู่เสมอ
    task.spawn(function()
        while ToggleGui.Parent do
            if not CoreGui:FindFirstChild("UFO_HUB_X_UI") then
                -- ถ้า UI หลักโดนลบ ก็กดปิดสถานะไว้ แต่ปุ่มยังอยู่
                getgenv().UFO_ISOPEN = false
            end
            -- กันปุ่มโดนเปลี่ยน ZIndex/DisplayOrder โดยเกมอื่น
            ToggleGui.DisplayOrder = 9e6
            ToggleBtn.ZIndex = 999999
            task.wait(1)
        end
    end)
end

--==========================================================
-- 💡 Simple API (ใช้/ไม่ใช้ก็ได้) — คงหน้าตาเดิม 100%
--==========================================================
do
    local UFO = getgenv().UFO or {}
    function UFO.AddLeft(text)  row(LeftScroll,  tostring(text)) end
    function UFO.AddRight(text) row(RightScroll, tostring(text)) end
    function UFO.ClearLeft()    for _,c in ipairs(LeftScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end end
    function UFO.ClearRight()   for _,c in ipairs(RightScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end end
    function UFO.SetRightBg(id) RightBG.Image = "rbxassetid://"..tostring(id) end
    function UFO.Show()         GUI.Enabled=true; Window.Visible=true; getgenv().UFO_ISOPEN=true end
    function UFO.Hide()         Window.Visible=false; getgenv().UFO_ISOPEN=false end
    function UFO.Destroy()      if GUI then GUI:Destroy() end; local t=CoreGui:FindFirstChild("UFO_HUB_X_Toggle"); if t then t:Destroy() end end
    getgenv().UFO = UFO
end
