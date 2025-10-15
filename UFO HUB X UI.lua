-- ✂️ เคลียร์ของเก่า
pcall(function()
    local cg = game:GetService("CoreGui")
    for _, name in ipairs({"UFO_HUB_X_UI","UFO_HUB_X_Toggle"}) do
        local g = cg:FindFirstChild(name)
        if g then g:Destroy() end
    end
end)

-- =================== CONFIG ===================
local CFG = {
    SHOW_HEADER_DOT = false,       -- ❌ เอาจุดกลมสีเขียวออก
    WIN_W = 640, WIN_H = 360,      -- ขนาดหน้าต่างเริ่มต้น
    MIN_SCALE = 0.72, MAX_SCALE = 1.0,

    -- THEME
    GREEN      = Color3.fromRGB(0,255,140),
    MINT       = Color3.fromRGB(120,255,220),
    MINT_SOFT  = Color3.fromRGB(90,210,190),
    BG_WINDOW  = Color3.fromRGB(16,16,16),
    BG_HEADER  = Color3.fromRGB(6,6,6),
    BG_PANEL   = Color3.fromRGB(22,22,22),
    BG_INNER   = Color3.fromRGB(18,18,18),
    TEXT_WHITE = Color3.fromRGB(235,235,235),
    DANGER_RED = Color3.fromRGB(200,40,40),

    -- ASSETS (ตามของเดิม)
    IMG_SMALL = "rbxassetid://121069267171370",
    IMG_LARGE = "rbxassetid://108408843188558",
    IMG_UFO   = "rbxassetid://100650447103028",
    GLOW_IMG  = "rbxassetid://5028857084",
}

-- =================== HELPERS ===================
local S = setmetatable({}, {__index = function(_, s) return game:GetService(s) end})
local function corner(gui, r) local c=Instance.new("UICorner", gui); c.CornerRadius=UDim.new(0, r or 10); return c end
local function stroke(gui, t, col, trans)
    local s = Instance.new("UIStroke", gui)
    s.Thickness = t or 1; s.Color = col or CFG.MINT; s.Transparency = trans or 0.35
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end
local function gradient(gui, c1, c2, rot)
    local g=Instance.new("UIGradient", gui); g.Color=ColorSequence.new(c1, c2); g.Rotation=rot or 0; return g
end

-- =================== ROOT GUI ===================
local GUI = Instance.new("ScreenGui")
GUI.Name="UFO_HUB_X_UI"; GUI.ResetOnSpawn=false; GUI.IgnoreGuiInset=true
GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; GUI.Parent=S.CoreGui

-- WINDOW
local Window = Instance.new("Frame", GUI)
Window.Name="Window"; Window.AnchorPoint=Vector2.new(0.5,0.5)
Window.Position=UDim2.new(0.5,0,0.5,0)
Window.Size=UDim2.fromOffset(CFG.WIN_W, CFG.WIN_H)
Window.BackgroundColor3=CFG.BG_WINDOW; Window.BorderSizePixel=0
corner(Window, 12); stroke(Window, 3, CFG.GREEN, 0)

-- Glow (เหมือนเดิม)
do
    local Glow = Instance.new("ImageLabel", Window)
    Glow.BackgroundTransparency=1; Glow.AnchorPoint=Vector2.new(0.5,0.5)
    Glow.Position=UDim2.new(0.5,0,0.5,0); Glow.Size=UDim2.new(1.07,0,1.09,0)
    Glow.Image = CFG.GLOW_IMG; Glow.ImageColor3 = CFG.GREEN; Glow.ImageTransparency = 0.78
    Glow.ScaleType = Enum.ScaleType.Slice; Glow.SliceCenter = Rect.new(24,24,276,276); Glow.ZIndex = 0
end

-- Autoscale ตาม Viewport
local UIScale = Instance.new("UIScale", Window)
local function fit()
    local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    UIScale.Scale = math.clamp(math.min(v.X/860, v.Y/540), CFG.MIN_SCALE, CFG.MAX_SCALE)
end
fit(); S.RunService.RenderStepped:Connect(fit)

-- =================== HEADER ===================
local Header = Instance.new("Frame", Window)
Header.Name="Header"; Header.Size=UDim2.new(1,0,0,46)
Header.BackgroundColor3=CFG.BG_HEADER; Header.BorderSizePixel=0
corner(Header, 12); gradient(Header, Color3.fromRGB(10,10,10), Color3.fromRGB(0,0,0), 0)

local HeadAccent = Instance.new("Frame", Header)
HeadAccent.AnchorPoint=Vector2.new(0.5,1); HeadAccent.Position=UDim2.new(0.5,0,1,0)
HeadAccent.Size=UDim2.new(1,-20,0,1); HeadAccent.BackgroundColor3=CFG.MINT
HeadAccent.BackgroundTransparency=0.35; HeadAccent.BorderSizePixel=0

-- จุดกลมเขียว (เลือกแสดง/ซ่อนด้วย CFG.SHOW_HEADER_DOT)
local Dot
if CFG.SHOW_HEADER_DOT then
    Dot = Instance.new("Frame", Header)
    Dot.BackgroundColor3 = CFG.MINT; Dot.Position = UDim2.new(0,14,0.5,-4)
    Dot.Size = UDim2.new(0,8,0,8); Dot.BorderSizePixel = 0; corner(Dot, 4)
end

-- Title กลาง
local TitleCenter = Instance.new("TextLabel", Header)
TitleCenter.BackgroundTransparency=1; TitleCenter.AnchorPoint=Vector2.new(0.5,0)
TitleCenter.Position=UDim2.new(0.5,0,0,8); TitleCenter.Size=UDim2.new(0.8,0,0,36)
TitleCenter.Font=Enum.Font.GothamBold; TitleCenter.RichText=true; TitleCenter.TextScaled=true
TitleCenter.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
TitleCenter.TextColor3 = CFG.TEXT_WHITE; TitleCenter.ZIndex = 61

-- ปุ่มปิด (ซ่อน Window แต่ไม่ทำลาย)
local BtnClose = Instance.new("TextButton", Header)
BtnClose.Name="Close"; BtnClose.Size=UDim2.new(0,24,0,24)
BtnClose.Position=UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3 = CFG.DANGER_RED; BtnClose.Text="X"
BtnClose.Font=Enum.Font.GothamBold; BtnClose.TextSize=13; BtnClose.TextColor3=Color3.new(1,1,1)
BtnClose.BorderSizePixel=0; corner(BtnClose, 6); stroke(BtnClose, 1, Color3.fromRGB(255,0,0), 0.1)

BtnClose.MouseButton1Click:Connect(function()
    Window.Visible=false
    getgenv().UFO_ISOPEN=false
end)

-- =================== DRAG (บล็อกการหมุนกล้องขณะลาก) ===================
do
    local dragging, start, startPos
    local CAS = S.ContextActionService
    local function bindBlock(on)
        local name="UFO_BlockLook_Window"
        if on then
            local fn=function() return Enum.ContextActionResult.Sink end
            CAS:BindActionAtPriority(name, fn, false, 9000,
                Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1)
        else
            pcall(function() CAS:UnbindAction(name) end)
        end
    end
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Window.Position; bindBlock(true)
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then dragging=false; bindBlock(false) end
            end)
        end
    end)
    S.UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            Window.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

-- =================== UFO Top (เหมือนเดิม) ===================
do
    local UFO_Y_OFFSET = 84
    local UFO = Instance.new("ImageLabel", Window)
    UFO.Name="UFO_Top"; UFO.BackgroundTransparency=1; UFO.Image=CFG.IMG_UFO
    UFO.Size=UDim2.new(0,168,0,168); UFO.AnchorPoint=Vector2.new(0.5,1)
    UFO.Position=UDim2.new(0.5,0,0,UFO_Y_OFFSET); UFO.ZIndex=60

    local Halo = Instance.new("ImageLabel", Window)
    Halo.BackgroundTransparency=1; Halo.AnchorPoint=Vector2.new(0.5,0)
    Halo.Position=UDim2.new(0.5,0,0,0); Halo.Size=UDim2.new(0,200,0,60)
    Halo.Image=CFG.GLOW_IMG; Halo.ImageColor3=CFG.MINT_SOFT; Halo.ImageTransparency=0.72; Halo.ZIndex=50
end

-- =================== BODY / COLUMNS ===================
local Body = Instance.new("Frame", Window)
Body.Name="Body"; Body.BackgroundTransparency=1
Body.Position=UDim2.new(0,0,0,46); Body.Size=UDim2.new(1,0,1,-46)

local Inner = Instance.new("Frame", Body)
Inner.Name="Inner"; Inner.BackgroundColor3=CFG.BG_INNER; Inner.BorderSizePixel=0
Inner.Position=UDim2.new(0,8,0,8); Inner.Size=UDim2.new(1,-16,1,-16)
corner(Inner, 12)

local Content = Instance.new("Frame", Body)
Content.Name="Content"; Content.BackgroundColor3=CFG.BG_PANEL
Content.Position=UDim2.new(0,14,0,14); Content.Size=UDim2.new(1,-28,1,-28)
corner(Content, 12); stroke(Content, 0.5, CFG.MINT, 0.35)

local Columns = Instance.new("Frame", Content)
Columns.Name="Columns"; Columns.BackgroundTransparency=1
Columns.Position=UDim2.new(0,8,0,8); Columns.Size=UDim2.new(1,-16,1,-16)

-- Left Panel
local Left = Instance.new("Frame", Columns)
Left.Name="Left"; Left.BackgroundColor3=Color3.fromRGB(16,16,16)
Left.Size=UDim2.new(0.22,-6,1,0)
Left.ClipsDescendants=true; corner(Left,10); stroke(Left,1.2,CFG.GREEN,0); stroke(Left,0.45,CFG.MINT,0.35)

-- Right Panel
local Right = Instance.new("Frame", Columns)
Right.Name="Right"; Right.BackgroundColor3=Color3.fromRGB(16,16,16)
Right.Position=UDim2.new(0.22,12,0,0); Right.Size=UDim2.new(0.78,-6,1,0)
Right.ClipsDescendants=true; corner(Right,10); stroke(Right,1.2,CFG.GREEN,0); stroke(Right,0.45,CFG.MINT,0.35)

-- Background images (เหมือนเดิม)
do
    local imgL = Instance.new("ImageLabel", Left)
    imgL.Name="BG"; imgL.BackgroundTransparency=1; imgL.Size=UDim2.new(1,0,1,0)
    imgL.Image=CFG.IMG_SMALL; imgL.ScaleType=Enum.ScaleType.Crop; imgL.ZIndex=0

    local imgR = Instance.new("ImageLabel", Right)
    imgR.Name="BG"; imgR.BackgroundTransparency=1; imgR.Size=UDim2.new(1,0,1,0)
    imgR.Image=CFG.IMG_LARGE; imgR.ScaleType=Enum.ScaleType.Crop; imgR.ZIndex=0
end

-- =================== SCROLL CONTAINERS (วางไว้พร้อมใช้) ===================
local function createScroll(host)
    -- Inset 2px เพื่อไม่ให้ Stroke กรอบทับขอบคอนเทนต์ (ดูเต็มสวย)
    local inset = Instance.new("Frame", host)
    inset.Name="Inset"; inset.BackgroundTransparency=1; inset.BorderSizePixel=0; inset.ClipsDescendants=true
    inset.Position=UDim2.fromOffset(2,2); inset.Size=UDim2.new(1,-4,1,-4); inset.ZIndex=1

    local sc = Instance.new("ScrollingFrame", inset)
    sc.Name="Scroll"; sc.BackgroundTransparency=1; sc.BorderSizePixel=0; sc.ClipsDescendants=true
    sc.ScrollingDirection=Enum.ScrollingDirection.Y
    sc.VerticalScrollBarInset=Enum.ScrollBarInset.ScrollBar
    sc.ScrollBarThickness=6; sc.ScrollBarImageColor3=CFG.GREEN; sc.ScrollBarImageTransparency=0.1
    sc.Size=UDim2.new(1,0,1,0); sc.Position=UDim2.new(0,0,0,0)
    sc.CanvasSize=UDim2.new(0,0,0,0); sc.AutomaticCanvasSize=Enum.AutomaticSize.Y; sc.ZIndex=2

    local list = Instance.new("UIListLayout", sc)
    list.Padding=UDim.new(0,8); list.SortOrder=Enum.SortOrder.LayoutOrder
    return sc
end

local LeftScroll  = createScroll(Left)
local RightScroll = createScroll(Right)

-- =================== TOGGLER (ปุ่มลอย + RightShift) ===================
do
    -- sync flag
    getgenv().UFO_ISOPEN = Window.Visible

    local old = S.CoreGui:FindFirstChild("UFO_HUB_X_Toggle")
    if old then old:Destroy() end

    local ToggleGui = Instance.new("ScreenGui", S.CoreGui)
    ToggleGui.Name="UFO_HUB_X_Toggle"; ToggleGui.IgnoreGuiInset=true

    local ToggleBtn = Instance.new("ImageButton", ToggleGui)
    ToggleBtn.Name="Toggle"; ToggleBtn.Size=UDim2.fromOffset(64,64); ToggleBtn.Position=UDim2.fromOffset(80,200)
    ToggleBtn.BackgroundColor3=Color3.fromRGB(0,0,0); ToggleBtn.BorderSizePixel=0
    ToggleBtn.Image="rbxassetid://117052960049460"
    corner(ToggleBtn, 8); local s=Instance.new("UIStroke", ToggleBtn); s.Thickness=2; s.Color=CFG.GREEN

    local function showUI() GUI.Enabled=true; Window.Visible=true; getgenv().UFO_ISOPEN=true end
    local function hideUI() Window.Visible=false; getgenv().UFO_ISOPEN=false end
    local function toggle() if getgenv().UFO_ISOPEN then hideUI() else showUI() end end

    ToggleBtn.MouseButton1Click:Connect(toggle)
    S.UserInputService.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==Enum.KeyCode.RightShift then toggle() end end)

    -- Drag ปุ่มลอย + บล็อกกล้อง
    local CAS=S.ContextActionService
    local dragging,start,startPos
    local function bindBlock(on)
        local name="UFO_BlockLook_Toggle"
        if on then
            local fn=function() return Enum.ContextActionResult.Sink end
            CAS:BindActionAtPriority(name, fn, false, 9000, Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1)
        else pcall(function() CAS:UnbindAction(name) end) end
    end
    ToggleBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Vector2.new(ToggleBtn.Position.X.Offset, ToggleBtn.Position.Y.Offset); bindBlock(true)
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; bindBlock(false) end end)
        end
    end)
    S.UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start; ToggleBtn.Position=UDim2.fromOffset(startPos.X+d.X, startPos.Y+d.Y)
        end
    end)
end

--========================
-- UFO HUB X — Add "Player" button (Left full-width, show header on Right)
--========================
do
    local GREEN = Color3.fromRGB(0,255,140)

    -- ไอคอนตามธีม (ถ้าไม่ได้ตั้งค่า ใช้สีเขียว)
    local ACCENT_ASSETS = {
        GREEN = "rbxassetid://112510739340023",
        RED   = "rbxassetid://131641206815699",
        GOLD  = "rbxassetid://127371066511941",
        WHITE = "rbxassetid://106330577092636",
    }
    local CURRENT = (getgenv and getgenv().UFO_ACCENT) or "GREEN"
    local ICON_ID = ACCENT_ASSETS[CURRENT] or ACCENT_ASSETS.GREEN

    local CoreGui = game:GetService("CoreGui")

    -- หาแผง Left/Right และ ScrollingFrame ให้ได้ชัวร์
    local function getPanels()
        local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
        assert(gui, "UFO_HUB_X_UI not found")
        local window = gui:FindFirstChild("Window", true)
        local content = window and window:FindFirstChild("Body", true)
        content = content and content:FindFirstChild("Frame", true) -- Content
        local columns = content and content:FindFirstChild("Frame")  -- Columns
        assert(columns, "Columns not found")

        local children = {}
        for _,ch in ipairs(columns:GetChildren()) do
            if ch:IsA("Frame") then table.insert(children, ch) end
        end
        table.sort(children, function(a,b) return a.AbsolutePosition.X < b.AbsolutePosition.X end)
        local Left, Right = children[1], children[2]
        assert(Left and Right, "Left/Right panels not found")
        return Left, Right
    end

    local function ensureScroll(panel)
        -- พยายามหา ScrollingFrame ที่มีอยู่ก่อน
        local sc = panel:FindFirstChildOfClass("ScrollingFrame")
        if not sc then
            -- บางโครงสร้างจะมี Frame ซ้อน ให้หา ScrollingFrame ที่เป็น descendant
            for _, d in ipairs(panel:GetDescendants()) do
                if d:IsA("ScrollingFrame") then sc = d break end
            end
        end
        -- ถ้าไม่มีจริง ๆ สร้างใหม่แบบเต็มกรอบ
        if not sc then
            local inset = Instance.new("Frame", panel)
            inset.Name = "Inset"
            inset.BackgroundTransparency = 1
            inset.Position = UDim2.fromOffset(0,0)
            inset.Size = UDim2.new(1,0,1,0)

            sc = Instance.new("ScrollingFrame", inset)
            sc.Name = "Scroll"
            sc.BackgroundTransparency = 1
            sc.BorderSizePixel = 0
            sc.ClipsDescendants = true
            sc.ScrollingDirection = Enum.ScrollingDirection.Y
            sc.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
            sc.ScrollBarThickness = 6
            sc.ScrollBarImageColor3 = GREEN
            sc.AutomaticCanvasSize = Enum.AutomaticSize.Y

            local list = Instance.new("UIListLayout", sc)
            list.Padding = UDim.new(0,8)
            list.SortOrder = Enum.SortOrder.LayoutOrder
        end
        -- กำจัด UIPadding ที่อาจทำให้ปุ่มไม่เต็ม
        for _, ch in ipairs(sc:GetChildren()) do
            if ch:IsA("UIPadding") then ch:Destroy() end
        end
        return sc
    end

    local function addPlayerButton()
        local LeftPanel, RightPanel = getPanels()
        local LeftScroll  = ensureScroll(LeftPanel)
        local RightScroll = ensureScroll(RightPanel)

        -- ลบของเดิม (กันซ้ำ)
        for _,o in ipairs(LeftScroll:GetChildren())  do if o.Name=="Player_Left"  then o:Destroy() end end
        for _,o in ipairs(RightScroll:GetChildren()) do if o.Name=="Player_Right" then o:Destroy() end end

        -- ===== Left: ปุ่มเต็มกรอบ พื้นดำ + ขอบเขียว 1.5 =====
        local LBtn = Instance.new("TextButton")
        LBtn.Name = "Player_Left"
        LBtn.AutoButtonColor = false
        LBtn.Text = ""
        LBtn.BackgroundColor3 = Color3.fromRGB(15,15,15)
        LBtn.BorderSizePixel = 0
        LBtn.Parent = LeftScroll
        -- เต็มกรอบจริง ๆ (ไม่มีหัก margin)
        LBtn.Size = UDim2.new(1, 0, 0, 34)
        LBtn.LayoutOrder = 1

        local LCorner = Instance.new("UICorner", LBtn)
        LCorner.CornerRadius = UDim.new(0, 8)

        local LStroke = Instance.new("UIStroke", LBtn)
        LStroke.Thickness = 1.5
        LStroke.Color = GREEN
        LStroke.Transparency = 0

        local LIcon = Instance.new("ImageLabel", LBtn)
        LIcon.BackgroundTransparency = 1
        LIcon.Size = UDim2.fromOffset(20,20)
        LIcon.Position = UDim2.fromOffset(12, (34-20)/2)
        LIcon.Image = ICON_ID

        local LTitle = Instance.new("TextLabel", LBtn)
        LTitle.BackgroundTransparency = 1
        LTitle.Text = "Player"
        LTitle.Font = Enum.Font.GothamBold
        LTitle.TextSize = 15
        LTitle.TextColor3 = Color3.new(1,1,1)
        LTitle.TextXAlignment = Enum.TextXAlignment.Left
        LTitle.Position = UDim2.fromOffset(12+20+8, (34-18)/2)
        LTitle.Size = UDim2.new(1, -(12+20+8+10), 0, 18)

        -- ===== Right: Header (ไอคอน + ชื่อ) ไม่มีกรอบ/พื้น แสดงเมื่อกด =====
        local RFrame = Instance.new("Frame", RightScroll)
        RFrame.Name = "Player_Right"
        RFrame.BackgroundTransparency = 1
        RFrame.Size = UDim2.new(1, 0, 0, 26)
        RFrame.Visible = false
        RFrame.LayoutOrder = 1

        local RIcon = Instance.new("ImageLabel", RFrame)
        RIcon.BackgroundTransparency = 1
        RIcon.Size = UDim2.fromOffset(22,22)
        RIcon.Position = UDim2.fromOffset(4, 2)
        RIcon.Image = ICON_ID

        local RTitle = Instance.new("TextLabel", RFrame)
        RTitle.BackgroundTransparency = 1
        RTitle.Text = "Player"
        RTitle.Font = Enum.Font.GothamBold
        RTitle.TextSize = 16
        RTitle.TextColor3 = Color3.new(1,1,1)
        RTitle.TextXAlignment = Enum.TextXAlignment.Left
        RTitle.Position = UDim2.fromOffset(4+22+8, 2)
        RTitle.Size = UDim2.new(1, -(4+22+8+4), 0, 22)

        -- แสดงฝั่งขวาหลังคลิกปุ่ม
        LBtn.MouseButton1Click:Connect(function()
            RFrame.Visible = true
        end)
    end

    -- สร้างปุ่ม
    addPlayerButton()
end
