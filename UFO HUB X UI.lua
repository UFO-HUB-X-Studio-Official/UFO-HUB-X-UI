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
--========================
-- Hide Scrollbar Tracks (Left & Right)
--========================
do
    local CoreGui = game:GetService("CoreGui")
    local GUI = CoreGui:FindFirstChild("UFO_HUB_X_UI")
    if not GUI then return end

    for _, sc in ipairs(GUI:GetDescendants()) do
        if sc:IsA("ScrollingFrame") then
            -- ทำให้แถบเลื่อนหายไป แต่ยังเลื่อนได้ตามปกติ
            sc.ScrollBarThickness = 0
            sc.ScrollBarImageTransparency = 1
            sc.VerticalScrollBarInset = Enum.ScrollBarInset.None
            -- กันค่าจากสคริปต์อื่นย้อนกลับ
            pcall(function() sc.TopImage   = "" end)
            pcall(function() sc.MidImage   = "" end)
            pcall(function() sc.BottomImage= "" end)
        end
    end
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
-- UFO HUB X — Fix Button Border + Down Offset (copy-paste once)
--========================
do
    local GREEN = Color3.fromRGB(0,255,140)
    local CoreGui = game:GetService("CoreGui")

    -- ไอคอนธีม
    local ACCENT_ASSETS = {
        GREEN = "rbxassetid://112510739340023",
        RED   = "rbxassetid://131641206815699",
        GOLD  = "rbxassetid://127371066511941",
        WHITE = "rbxassetid://106330577092636",
    }
    local CURRENT = (getgenv and getgenv().UFO_ACCENT) or "GREEN"
    local ICON_ID = ACCENT_ASSETS[CURRENT] or ACCENT_ASSETS.GREEN

    -- หา GUI/Window
    local GUI = CoreGui:FindFirstChild("UFO_HUB_X_UI"); if not GUI then return end

    local function findLargestFrame(root)
        local best, area = nil, 0
        for _,d in ipairs(root:GetDescendants()) do
            if d:IsA("Frame") and d.Visible then
                local a = d.AbsoluteSize.X*d.AbsoluteSize.Y
                if a>area then best,area=d,a end
            end
        end
        return best
    end
    local Window = findLargestFrame(GUI); if not Window then return end

    -- ระบุแผงซ้าย/ขวา (Frame ที่ ClipsDescendants และมี UIStroke)
    local panels = {}
    for _,d in ipairs(Window:GetDescendants()) do
        if d:IsA("Frame") and d.Visible and d.ClipsDescendants then
            local hasStroke=false
            for _,c in ipairs(d:GetChildren()) do
                if c:IsA("UIStroke") then hasStroke=true break end
            end
            if hasStroke and d.AbsoluteSize.X>100 and d.AbsoluteSize.Y>100 then
                table.insert(panels,d)
            end
        end
    end
    table.sort(panels,function(a,b) return a.AbsolutePosition.X<b.AbsolutePosition.X end)
    if #panels<2 then return end
    local LeftPanel, RightPanel = panels[1], panels[#panels]

    -- สร้าง/หา ScrollingFrame ให้ "อยู่เหนือ" เส้นลายกรอบ (ZIndex สูงกว่า) และเต็มกรอบจริง
    local function ensureScroll(panel)
        local sc
        for _,ch in ipairs(panel:GetChildren()) do
            if ch:IsA("ScrollingFrame") then sc=ch break end
        end
        if not sc then
            sc = Instance.new("ScrollingFrame", panel)
            sc.Name="Scroll"
            sc.BackgroundTransparency=1
            sc.BorderSizePixel=0
            sc.ScrollingDirection=Enum.ScrollingDirection.Y
            sc.VerticalScrollBarInset=Enum.ScrollBarInset.ScrollBar
            sc.ScrollBarThickness=6
            sc.ScrollBarImageColor3=GREEN
            local list=Instance.new("UIListLayout",sc)
            list.Padding=UDim.new(0,8)
            list.SortOrder=Enum.SortOrder.LayoutOrder
        end
        sc.Position = UDim2.fromOffset(0,0)
        sc.Size     = UDim2.new(1,0,1,0)
        sc.ZIndex   = 50 -- << สูงกว่าเส้นลายในกรอบ

        -- เคลียร์ UIPadding ที่อาจดันปุ่มให้ไม่เต็ม
        for _,ch in ipairs(sc:GetChildren()) do
            if ch:IsA("UIPadding") then ch:Destroy() end
        end
        return sc
    end

    local LeftScroll  = ensureScroll(LeftPanel)
    local RightScroll = ensureScroll(RightPanel)

    -- ล้างของเดิม
    for _,o in ipairs(LeftScroll:GetChildren())  do if o.Name=="SpacerTop" or o.Name=="Player_Left" then o:Destroy() end end
    for _,o in ipairs(RightScroll:GetChildren()) do if o.Name=="SpacerTop" or o.Name=="Player_Right" then o:Destroy() end end

    -- ===== ระยะเลื่อนลงมาอีกนิด (ทั้งซ้าย/ขวา) =====
    local TOP_OFFSET = 10 -- px
    local LSpacer = Instance.new("Frame", LeftScroll)
    LSpacer.Name="SpacerTop"; LSpacer.BackgroundTransparency=1; LSpacer.Size=UDim2.new(1,0,0,TOP_OFFSET)
    LSpacer.LayoutOrder = 0; LSpacer.ZIndex = 51

    local RSpacer = Instance.new("Frame", RightScroll)
    RSpacer.Name="SpacerTop"; RSpacer.BackgroundTransparency=1; RSpacer.Size=UDim2.new(1,0,0,TOP_OFFSET)
    RSpacer.LayoutOrder = 0; RSpacer.ZIndex = 51

    -- ===== ปุ่มซ้าย: ขอบเขียว 1.5 ชัดเจน =====
    local LBtn = Instance.new("TextButton", LeftScroll)
    LBtn.Name="Player_Left"
    LBtn.AutoButtonColor=false
    LBtn.Text=""
    LBtn.BackgroundColor3=Color3.fromRGB(15,15,15)
    LBtn.BorderSizePixel=0
    LBtn.Size=UDim2.new(1,0,0,36) -- เต็มความกว้าง
    LBtn.LayoutOrder=1
    LBtn.ZIndex=51
    Instance.new("UICorner", LBtn).CornerRadius=UDim.new(0,8)

    local LStroke = Instance.new("UIStroke", LBtn)
    LStroke.Thickness = 1.5
    LStroke.Color = GREEN
    LStroke.Transparency = 0
    LStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    LStroke.LineJoinMode = Enum.LineJoinMode.Round

    local LIcon = Instance.new("ImageLabel", LBtn)
    LIcon.BackgroundTransparency=1
    LIcon.Size=UDim2.fromOffset(20,20)
    LIcon.Position=UDim2.fromOffset(12,(36-20)/2)
    LIcon.Image=ICON_ID
    LIcon.ZIndex=52

    local LTitle = Instance.new("TextLabel", LBtn)
    LTitle.BackgroundTransparency=1
    LTitle.Text="Player"
    LTitle.Font=Enum.Font.GothamBold
    LTitle.TextSize=15
    LTitle.TextColor3=Color3.new(1,1,1)
    LTitle.TextXAlignment=Enum.TextXAlignment.Left
    LTitle.Position=UDim2.fromOffset(12+20+8,(36-18)/2)
    LTitle.Size=UDim2.new(1,-(12+20+8+10),0,18)
    LTitle.ZIndex=52

    -- ===== หัวข้อด้านขวา (เลื่อนลงเหมือนเดิม) =====
    local RHead = Instance.new("Frame", RightScroll)
    RHead.Name="Player_Right"
    RHead.BackgroundTransparency=1
    RHead.Size=UDim2.new(1,0,0,26)
    RHead.LayoutOrder=1
    RHead.ZIndex=51

    local RIcon = Instance.new("ImageLabel", RHead)
    RIcon.BackgroundTransparency=1
    RIcon.Size=UDim2.fromOffset(22,22)
    RIcon.Position=UDim2.fromOffset(4,2)
    RIcon.Image=ICON_ID
    RIcon.ZIndex=52

    local RTitle = Instance.new("TextLabel", RHead)
    RTitle.BackgroundTransparency=1
    RTitle.Text="Player"
    RTitle.Font=Enum.Font.GothamBold
    RTitle.TextSize=16
    RTitle.TextColor3=Color3.new(1,1,1)
    RTitle.TextXAlignment=Enum.TextXAlignment.Left
    RTitle.Position=UDim2.fromOffset(4+22+8,2)
    RTitle.Size=UDim2.new(1,-(4+22+8+4),0,22)
    RTitle.ZIndex=52

    -- คลิกปุ่มซ้ายแล้วค่อยแสดงหัวข้อขวา
    RHead.Visible = false
    LBtn.MouseButton1Click:Connect(function()
        RHead.Visible = true
    end)
end
