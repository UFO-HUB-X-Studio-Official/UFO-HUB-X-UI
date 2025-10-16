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
--=== UFO HUB X: Build real PLAYER button from guide rectangles ===
local CoreGui = game:GetService("CoreGui")
local GUI = CoreGui:FindFirstChild("UFO_HUB_X_UI")
if not GUI then return end

local function findFrameByColor(root, col)
    for _,v in ipairs(root:GetDescendants()) do
        if v:IsA("Frame") and v.Visible and v.BackgroundTransparency==0 then
            local c=v.BackgroundColor3
            if math.abs(c.R-col.R)<1e-3 and math.abs(c.G-col.G)<1e-3 and math.abs(c.B-col.B)<1e-3 then
                return v
            end
        end
    end
end

local leftGuide=findFrameByColor(GUI,Color3.fromRGB(255,255,255))
local rightGuide=findFrameByColor(GUI,Color3.fromRGB(255,0,0))
if not(leftGuide and rightGuide)then return end
local leftParent=leftGuide.Parent
local rightParent=rightGuide.Parent

local ICONS={
    GREEN="rbxassetid://112510739340023",
    RED="rbxassetid://131641206815699",
    GOLD="rbxassetid://127371066511941",
    WHITE="rbxassetid://106330577092636"
}
local current=getgenv().UFO_ACCENT or "GREEN"
local iconId=ICONS[current] or ICONS.GREEN

local LBtn=Instance.new("TextButton")
LBtn.Name="Btn_Player_Left"
LBtn.Parent=leftParent
LBtn.AutoButtonColor=false
LBtn.Text=""
LBtn.BackgroundColor3=Color3.fromRGB(14,14,14)
LBtn.BorderSizePixel=0
LBtn.Position=leftGuide.Position
LBtn.Size=leftGuide.Size
LBtn.ZIndex=(leftGuide.ZIndex or 10)+1
local LCorner=Instance.new("UICorner",LBtn)
LCorner.CornerRadius=UDim.new(0,8)
local LStroke=Instance.new("UIStroke",LBtn)
LStroke.Thickness=1.5
LStroke.Color=Color3.fromRGB(0,255,140)
LStroke.Transparency=0
LStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
LStroke.LineJoinMode=Enum.LineJoinMode.Round
local LIcon=Instance.new("ImageLabel")
LIcon.BackgroundTransparency=1
LIcon.Image=iconId
LIcon.Size=UDim2.fromOffset(20,20)
LIcon.Position=UDim2.fromOffset(12,(leftGuide.AbsoluteSize.Y-20)/2)
LIcon.ZIndex=LBtn.ZIndex+1
LIcon.Parent=LBtn
local LText=Instance.new("TextLabel")
LText.BackgroundTransparency=1
LText.Text="Player"
LText.Font=Enum.Font.GothamBold
LText.TextSize=16
LText.TextColor3=Color3.fromRGB(255,255,255)
LText.TextXAlignment=Enum.TextXAlignment.Left
LText.Position=UDim2.fromOffset(12+20+8,(leftGuide.AbsoluteSize.Y-18)/2)
LText.Size=UDim2.new(1,-(12+20+8+10),0,18)
LText.ZIndex=LBtn.ZIndex+1
LText.Parent=LBtn

local RHeader=Instance.new("Frame")
RHeader.Name="Player_Header_Right"
RHeader.Parent=rightParent
RHeader.BackgroundTransparency=1
RHeader.BorderSizePixel=0
RHeader.Position=rightGuide.Position
RHeader.Size=rightGuide.Size
RHeader.ZIndex=(rightGuide.ZIndex or 10)+1
local RIcon=Instance.new("ImageLabel")
RIcon.BackgroundTransparency=1
RIcon.Image=iconId
RIcon.Size=UDim2.fromOffset(22,22)
RIcon.Position=UDim2.fromOffset(0,math.max(0,(rightGuide.AbsoluteSize.Y-22)/2))
RIcon.ZIndex=RHeader.ZIndex+1
RIcon.Parent=RHeader
local RText=Instance.new("TextLabel")
RText.BackgroundTransparency=1
RText.Text="Player"
RText.Font=Enum.Font.GothamBold
RText.TextSize=18
RText.TextColor3=Color3.fromRGB(255,255,255)
RText.TextXAlignment=Enum.TextXAlignment.Left
RText.Position=UDim2.fromOffset(22+8,math.max(0,(rightGuide.AbsoluteSize.Y-22)/2))
RText.Size=UDim2.new(1,-(22+8),0,22)
RText.ZIndex=RHeader.ZIndex+1
RText.Parent=RHeader

leftGuide:Destroy()
rightGuide:Destroy()
LBtn.MouseButton1Click:Connect(function()
    RHeader.Visible=not RHeader.Visible
end)

--========================================
-- UFO HUB X : Force-hide all scrollbars
--========================================
do
    local CoreGui = game:GetService("CoreGui")
    local GUI = CoreGui:FindFirstChild("UFO_HUB_X_UI")
    if not GUI then return end

    -- สีเขียวธีมที่ใช้ (ไว้ตรวจจับกรอบแท่ง custom ถ้ามี)
    local GREEN = Color3.fromRGB(0,255,140)

    -- ซ่อนแถบเลื่อนของ ScrollingFrame มาตรฐาน Roblox
    local function hideNativeScrollBar(sc: ScrollingFrame)
        sc.ScrollBarThickness = 0
        sc.ScrollBarImageTransparency = 1
        sc.VerticalScrollBarInset = Enum.ScrollBarInset.None
        sc.TopImage, sc.MidImage, sc.BottomImage = "", "", ""
    end

    -- ถ้ามีคนทำแท่งสกอร์ลเองเป็น Frame บาง ๆ สีเขียว ให้ปิดทิ้ง
    local function tryHideCustomBar(obj: Instance)
        if obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("TextButton") then
            local s = obj.AbsoluteSize
            -- นิยาม "แท่งแนวตั้ง" ทั่วไป: กว้างไม่เกิน 10px และสูงยาวกว่า 40px
            local looksLikeBar = (s.X <= 10 and s.Y >= 40)
            local col = (obj:IsA("ImageLabel") and obj.ImageColor3) or (obj.BackgroundColor3)
            local isGreenish = false
            if col then
                -- เทียบใกล้เคียงสีเขียวธีม
                local dx = math.abs(col.R - GREEN.R)
                local dy = math.abs(col.G - GREEN.G)
                local dz = math.abs(col.B - GREEN.B)
                isGreenish = (dx + dy + dz) < 0.25
            end
            if looksLikeBar and isGreenish then
                obj.Visible = false
                if obj:FindFirstChildOfClass("UIStroke") then
                    obj:FindFirstChildOfClass("UIStroke").Transparency = 1
                end
            end
        end
    end

    -- ใช้กับของที่มีอยู่แล้ว
    for _, d in ipairs(GUI:GetDescendants()) do
        if d:IsA("ScrollingFrame") then
            hideNativeScrollBar(d)
        else
            tryHideCustomBar(d)
        end
    end

    -- เฝ้าดูของที่ถูกเพิ่มใหม่ภายหลัง
    GUI.DescendantAdded:Connect(function(d)
        if d:IsA("ScrollingFrame") then
            hideNativeScrollBar(d)
        else
            -- รอสัก 1 เฟรมให้มันวางตัวเสร็จก่อนค่อยเช็คขนาด
            task.defer(function() tryHideCustomBar(d) end)
        end
    end)
end
