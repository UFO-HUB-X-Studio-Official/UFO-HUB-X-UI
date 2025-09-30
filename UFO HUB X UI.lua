--==========================================================
-- UFO HUB X • FULL TEST BUILD (self-contained)
-- - มีปุ่มลอยเปิด/ปิด, ปุ่ม X, RightShift
-- - Intro ครั้งแรก: UFO 2s -> UI -> UFO 2s -> fade
-- - Outro ปิด: UFO -> UI hide -> UFO fade
-- - AFK Always-On
--==========================================================

-- เคลียร์ของเก่า
pcall(function() local g = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI"); if g then g:Destroy() end end)
pcall(function() local g = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_Toggle"); if g then g:Destroy() end end)

-- SERVICES
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")
local TS      = game:GetService("TweenService")
local CP      = game:GetService("ContentProvider")

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

-- IMAGES
local IMG_SMALL        = "rbxassetid://121069267171370"
local IMG_LARGE        = "rbxassetid://108408843188558"
local IMG_UFO_TOP      = "rbxassetid://100650447103028"
local IMG_UFO_OVERLAY  = "rbxassetid://140388309537044" -- ✅ ยานอนิเมชัน

-- BUILD SCREEN GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"; GUI.IgnoreGuiInset = true; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false; GUI.Parent = CoreGui

-- WINDOW
local WIN_W, WIN_H = 640, 360
local Window = Instance.new("Frame", GUI)
Window.Name="Window"; Window.AnchorPoint = Vector2.new(0.5,0.5); Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.fromOffset(WIN_W, WIN_H); Window.BackgroundColor3 = BG_WINDOW; Window.BorderSizePixel = 0
do local c=Instance.new("UICorner",Window); c.CornerRadius=UDim.new(0,12) end
do local s=Instance.new("UIStroke",Window); s.Thickness=3; s.Color=GREEN; s.Transparency=0 end

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
local function fit() local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    UIScale.Scale = math.clamp(math.min(v.X/860, v.Y/540), 0.72, 1.0) end
fit(); RunS.RenderStepped:Connect(fit)

-- HEADER
local Header = Instance.new("Frame", Window)
Header.Size = UDim2.new(1,0,0,46); Header.BackgroundColor3 = BG_HEADER; Header.BorderSizePixel=0
do local c=Instance.new("UICorner",Header); c.CornerRadius=UDim.new(0,12) end
do local g=Instance.new("UIGradient",Header); g.Color=ColorSequence.new(Color3.fromRGB(10,10,10),Color3.fromRGB(0,0,0)) end

local Title = Instance.new("TextLabel", Header)
Title.AnchorPoint = Vector2.new(0.5,0); Title.Position=UDim2.new(0.5,0,0,8)
Title.Size = UDim2.new(0.8,0,0,36); Title.BackgroundTransparency=1
Title.Font=Enum.Font.GothamBold; Title.RichText=true; Title.TextScaled=true
Title.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
Title.TextColor3 = TEXT_WHITE; Title.ZIndex=61

local BtnClose = Instance.new("TextButton", Header)
BtnClose.Name="CloseX"; BtnClose.Size=UDim2.new(0,24,0,24); BtnClose.Position=UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3=DANGER_RED; BtnClose.BorderSizePixel=0; BtnClose.Text="X"
BtnClose.Font=Enum.Font.GothamBold; BtnClose.TextSize=13; BtnClose.TextColor3=Color3.new(1,1,1)
do local c=Instance.new("UICorner",BtnClose); c.CornerRadius=UDim.new(0,6) end
do local s=Instance.new("UIStroke",BtnClose); s.Thickness=1; s.Color=Color3.fromRGB(255,0,0); s.Transparency=0.1 end

-- DRAG
do
    local dragging, start, startPos
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Window.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- BODY (โครงซ้าย-ขวา)
local Body = Instance.new("Frame", Window)
Body.BackgroundTransparency=1; Body.Position=UDim2.new(0,0,0,46); Body.Size=UDim2.new(1,0,1,-46)

local Inner = Instance.new("Frame", Body)
Inner.BackgroundColor3 = BG_INNER; Inner.BorderSizePixel=0; Inner.Position=UDim2.new(0,8,0,8); Inner.Size=UDim2.new(1,-16,1,-16)
do local c=Instance.new("UICorner",Inner); c.CornerRadius=UDim.new(0,12) end

local Content = Instance.new("Frame", Body)
Content.BackgroundColor3=BG_PANEL; Content.Position=UDim2.new(0,14,0,14); Content.Size=UDim2.new(1,-28,1,-28)
do local c=Instance.new("UICorner",Content); c.CornerRadius=UDim.new(0,12) end
do local s=Instance.new("UIStroke",Content); s.Thickness=.5; s.Color=MINT; s.Transparency=.35 end

local LEFT_RATIO, GAP_BETWEEN = 0.22, 12
local Columns = Instance.new("Frame", Content)
Columns.BackgroundTransparency=1; Columns.Position=UDim2.new(0,8,0,8); Columns.Size=UDim2.new(1,-16,1,-16)

local Left = Instance.new("Frame", Columns)
Left.BackgroundColor3=Color3.fromRGB(16,16,16); Left.Size=UDim2.new(LEFT_RATIO,-GAP_BETWEEN/2,1,0)
do local c=Instance.new("UICorner",Left); c.CornerRadius=UDim.new(0,10) end
do local s=Instance.new("UIStroke",Left); s.Thickness=1.2; s.Color=GREEN end
do local s=Instance.new("UIStroke",Left); s.Thickness=.45; s.Color=MINT; s.Transparency=.35 end

local Right = Instance.new("Frame", Columns)
Right.BackgroundColor3=Color3.fromRGB(16,16,16); Right.Position=UDim2.new(LEFT_RATIO,GAP_BETWEEN,0,0)
Right.Size=UDim2.new(1-LEFT_RATIO,-GAP_BETWEEN/2,1,0)
do local c=Instance.new("UICorner",Right); c.CornerRadius=UDim.new(0,10) end
do local s=Instance.new("UIStroke",Right); s.Thickness=1.2; s.Color=GREEN end
do local s=Instance.new("UIStroke",Right); s.Thickness=.45; s.Color=MINT; s.Transparency=.35 end

local imgL = Instance.new("ImageLabel", Left)
imgL.BackgroundTransparency=1; imgL.Size=UDim2.new(1,0,1,0); imgL.Image=IMG_SMALL; imgL.ScaleType=Enum.ScaleType.Crop
local imgR = Instance.new("ImageLabel", Right)
imgR.BackgroundTransparency=1; imgR.Size=UDim2.new(1,0,1,0); imgR.Image=IMG_LARGE; imgR.ScaleType=Enum.ScaleType.Crop

--==========================================================
-- AFK Always-On (ทำงานแม้ปิด UI)
--==========================================================
do
    local Players, VirtualUser = game:GetService("Players"), game:GetService("VirtualUser")
    local LP = Players.LocalPlayer
    getgenv().UFO_AFK_SHIELD = getgenv().UFO_AFK_SHIELD or {}
    local S = getgenv().UFO_AFK_SHIELD
    if S.conn then pcall(function() S.conn:Disconnect() end) end
    if S.keepaliveLoop then S.keepaliveLoop=false end
    S.enabled=true
    S.conn = LP.Idled:Connect(function()
        if S.enabled then
            VirtualUser:CaptureController()
            local cam=workspace.CurrentCamera; local pos=cam and cam.CFrame.Position or Vector3.new()
            VirtualUser:ClickButton2(Vector2.new(0,0), CFrame.new(pos))
        end
    end)
    S.keepaliveLoop=true
    task.spawn(function()
        local last=os.clock()
        game:GetService("UserInputService").InputBegan:Connect(function() last=os.clock() end)
        game:GetService("UserInputService").InputChanged:Connect(function() last=os.clock() end)
        while S.keepaliveLoop and S.enabled do
            task.wait(30)
            if os.clock()-last>540 then
                VirtualUser:CaptureController()
                local cam=workspace.CurrentCamera; local pos=cam and cam.CFrame.Position or Vector3.new()
                VirtualUser:ClickButton2(Vector2.new(0,0), CFrame.new(pos))
                last=os.clock()
            end
        end
    end)
end

--==========================================================
-- UFO INTRO/OUTRO Controller (ทำงานได้แน่)
--==========================================================
local PRE_HOLD, POST_HOLD = 2.0, 2.0
local animBusy=false
local isShown=true  -- เริ่มต้นถือว่าโชว์อยู่ (เราจะซ่อนไว้ก่อน 1 เฟรม)

local function tween(o,t,goal,style,dir)
    local tw = TS:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), goal)
    tw:Play(); tw.Completed:Wait()
end

local function makeOverlay()
    local p,s = Window.AbsolutePosition, Window.AbsoluteSize
    local cx,cy = p.X+s.X/2, p.Y+s.Y/2
    local overlay = Instance.new("ScreenGui")
    overlay.Name="UFO_OVERLAY"; overlay.IgnoreGuiInset=true; overlay.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    overlay.DisplayOrder=1_000_000; overlay.Parent=CoreGui

    local blocker = Instance.new("Frame", overlay)
    blocker.BackgroundColor3=Color3.new(0,0,0); blocker.BackgroundTransparency=0; blocker.BorderSizePixel=0; blocker.ZIndex=998
    blocker.Size=UDim2.fromOffset(s.X,s.Y); blocker.Position=UDim2.fromOffset(p.X,p.Y)

    local u = Instance.new("ImageLabel", overlay)
    u.BackgroundTransparency=1; u.Image=IMG_UFO_OVERLAY; u.ZIndex=999
    u.AnchorPoint=Vector2.new(0.5,0.5); u.Position=UDim2.fromOffset(cx,cy)
    u.Size=UDim2.fromOffset(40,40); u.ImageTransparency=1
    pcall(function() CP:PreloadAsync({u}) end)
    return overlay, blocker, u
end

local function playOpen()
    if animBusy or isShown then return end
    animBusy=true

    Window.Visible=false; Window.GroupTransparency=1
    local overlay,blocker,u = makeOverlay()

    tween(u,0.10,{ImageTransparency=0.05})
    tween(u,0.22,{Size=UDim2.fromOffset(220,220)})
    task.wait(PRE_HOLD)

    local s0=UIScale.Scale==0 and 1 or UIScale.Scale
    UIScale.Scale=s0*0.96; Window.Visible=true
    tween(Window,0.22,{GroupTransparency=0}); tween(UIScale,0.22,{Scale=s0})

    task.wait(POST_HOLD)
    tween(u,0.14,{ImageTransparency=1})
    tween(blocker,0.12,{BackgroundTransparency=1})
    overlay:Destroy()

    isShown=true; animBusy=false
end

local function playClose()
    if animBusy or not isShown then return end
    animBusy=true

    local overlay,blocker,u = makeOverlay()
    tween(u,0.10,{ImageTransparency=0.05, Size=UDim2.fromOffset(160,160)})

    local s0=UIScale.Scale==0 and 1 or UIScale.Scale
    tween(Window,0.18,{GroupTransparency=1}); tween(UIScale,0.18,{Scale=s0*0.96})
    Window.Visible=false; UIScale.Scale=s0

    tween(u,0.12,{ImageTransparency=1}); tween(blocker,0.08,{BackgroundTransparency=1})
    overlay:Destroy()

    isShown=false; animBusy=false
end

-- ปุ่ม X
BtnClose.MouseButton1Click:Connect(function() if isShown then playClose() end end)

-- RightShift
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightShift then
        if isShown then playClose() else playOpen() end
    end
end)

-- ปุ่มลอยเปิด/ปิด (มุมซ้ายบน)
do
    local T = Instance.new("ScreenGui", CoreGui)
    T.Name="UFO_HUB_X_Toggle"; T.IgnoreGuiInset=true; T.DisplayOrder=1_000_001
    local b = Instance.new("ImageButton", T)
    b.Name="ToggleUI"; b.BackgroundTransparency=1; b.Image="rbxassetid://121069267171370"
    b.Size=UDim2.fromOffset(48,48); b.Position=UDim2.fromOffset(64,140); b.ZIndex=1000
    b.MouseButton1Click:Connect(function() if isShown then playClose() else playOpen() end end)
end

-- เล่น Intro ครั้งแรกทันที
task.defer(function()
    if isShown then Window.Visible=false; isShown=false end
    playOpen()
end)
