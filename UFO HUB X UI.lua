--==========================================================
-- UFO HUB X • Full UI + UFO Intro/Outro + AFK Always-On
--==========================================================

-- เคลียร์ของเก่าถ้ามี
pcall(function()
    local g = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI")
    if g then g:Destroy() end
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
local GAP_OUTER    = 14
local GAP_BETWEEN  = 12
local LEFT_RATIO   = 0.22
local RIGHT_RATIO  = 0.78

-- IMAGES
local IMG_SMALL = "rbxassetid://121069267171370"
local IMG_LARGE = "rbxassetid://108408843188558"
local IMG_UFO_TOP= "rbxassetid://100650447103028"
local IMG_UFO_OVERLAY = "rbxassetid://140388309537044" -- ✅ ยานสำหรับอนิเมชัน

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
local TS      = game:GetService("TweenService")
local CP      = game:GetService("ContentProvider")

local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"; GUI.IgnoreGuiInset = true; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false; GUI.Parent = CoreGui

-- WINDOW
local Window = Instance.new("Frame", GUI)
Window.Name = "Window"
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

local Dot = Instance.new("Frame", Header)
Dot.BackgroundColor3 = MINT; Dot.Position = UDim2.new(0,14,0.5,-4); Dot.Size = UDim2.new(0,8,0,8)
Dot.BorderSizePixel = 0; corner(Dot, 4)

local BtnClose = Instance.new("TextButton", Header)
BtnClose.Name = "CloseX"
BtnClose.Size = UDim2.new(0,24,0,24); BtnClose.Position = UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3 = DANGER_RED; BtnClose.Text = "X"; BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 13; BtnClose.TextColor3 = Color3.new(1,1,1); BtnClose.BorderSizePixel = 0
corner(BtnClose, 6); stroke(BtnClose, 1, Color3.fromRGB(255,0,0), 0.1)
-- ❌ ไม่ผูกปุ่มนี้ให้ปิดทันที เราจะไป hook ในคอนโทรลเลอร์ (เพื่อให้ยานเล่นก่อน)

-- drag
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

-- ===== UFO TOP (ประดับบนหัว) + TITLE =====
do
    local UFO_Y_OFFSET   = 84
    local TITLE_Y_OFFSET = 8

    local UFO = Instance.new("ImageLabel", Window)
    UFO.Name = "UFO_Top"; UFO.BackgroundTransparency = 1; UFO.Image = IMG_UFO_TOP
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

-- BODY
local Body = Instance.new("Frame", Window)
Body.BackgroundTransparency = 1; Body.Position = UDim2.new(0,0,0,46); Body.Size = UDim2.new(1,0,1,-46)

local Inner = Instance.new("Frame", Body)
Inner.BackgroundColor3 = BG_INNER; Inner.BorderSizePixel = 0
Inner.Position = UDim2.new(0,8,0,8); Inner.Size = UDim2.new(1,-16,1,-16); corner(Inner, 12)

local Content = Instance.new("Frame", Body)
Content.BackgroundColor3 = BG_PANEL; Content.Position = UDim2.new(0,GAP_OUTER,0,GAP_OUTER)
Content.Size = UDim2.new(1,-GAP_OUTER*2,1,-GAP_OUTER*2); corner(Content, 12); stroke(Content, 0.5, MINT, 0.35)

local Columns = Instance.new("Frame", Content)
Columns.BackgroundTransparency = 1; Columns.Position = UDim2.new(0,8,0,8); Columns.Size = UDim2.new(1,-16,1,-16)

local Left = Instance.new("Frame", Columns)
Left.BackgroundColor3 = Color3.fromRGB(16,16,16); Left.Size = UDim2.new(LEFT_RATIO, -GAP_BETWEEN/2, 1, 0)
Left.ClipsDescendants = true; corner(Left, 10); stroke(Left, 1.2, GREEN, 0); stroke(Left, 0.45, MINT, 0.35)

local Right = Instance.new("Frame", Columns)
Right.BackgroundColor3 = Color3.fromRGB(16,16,16)
Right.Position = UDim2.new(LEFT_RATIO, GAP_BETWEEN, 0, 0)
Right.Size = UDim2.new(RIGHT_RATIO, -GAP_BETWEEN/2, 1, 0)
Right.ClipsDescendants = true; corner(Right, 10); stroke(Right, 1.2, GREEN, 0); stroke(Right, 0.45, MINT, 0.35)

local imgL = Instance.new("ImageLabel", Left)
imgL.BackgroundTransparency = 1; imgL.Size = UDim2.new(1,0,1,0); imgL.Image = IMG_SMALL; imgL.ScaleType = Enum.ScaleType.Crop

local imgR = Instance.new("ImageLabel", Right)
imgR.BackgroundTransparency = 1; imgR.Size = UDim2.new(1,0,1,0); imgR.Image = IMG_LARGE; imgR.ScaleType = Enum.ScaleType.Crop

--==========================================================
-- AFK SHIELD (Always-On) • ทำงานแม้ปิด/ซ่อน UI
--==========================================================
do
    local Players           = game:GetService("Players")
    local UserInputService  = game:GetService("UserInputService")
    local LocalPlayer       = Players.LocalPlayer
    local VirtualUser       = game:GetService("VirtualUser")

    getgenv().UFO_AFK_SHIELD = getgenv().UFO_AFK_SHIELD or {}
    local Shield = getgenv().UFO_AFK_SHIELD

    if Shield.conn then pcall(function() Shield.conn:Disconnect() end) end
    if Shield.keepaliveLoop then Shield.keepaliveLoop = false end

    Shield.enabled = true

    Shield.conn = LocalPlayer.Idled:Connect(function()
        if Shield.enabled then
            VirtualUser:CaptureController()
            local cam = workspace.CurrentCamera
            local pos = cam and cam.CFrame.Position or Vector3.new()
            VirtualUser:ClickButton2(Vector2.new(0,0), CFrame.new(pos))
        end
    end)

    local lastRealInput = os.clock()
    UserInputService.InputBegan:Connect(function() lastRealInput = os.clock() end)
    UserInputService.InputChanged:Connect(function() lastRealInput = os.clock() end)

    Shield.keepaliveLoop = true
    task.spawn(function()
        while Shield.keepaliveLoop and Shield.enabled do
            task.wait(30)
            if os.clock() - lastRealInput > 540 then
                VirtualUser:CaptureController()
                local cam = workspace.CurrentCamera
                local pos = cam and cam.CFrame.Position or Vector3.new()
                VirtualUser:ClickButton2(Vector2.new(0,0), CFrame.new(pos))
                lastRealInput = os.clock()
            end
        end
    end)
end
--==========================================================
-- UFO INTRO/OUTRO • FAILSAFE (ทำงานแม้หา Window ไม่เจอ)
--==========================================================
do
    local TS  = game:GetService("TweenService")
    local UIS = game:GetService("UserInputService")
    local CP  = game:GetService("ContentProvider")
    local CG  = game:GetService("CoreGui")

    -- หา ScreenGui ของเรา (พยายามหลายแบบ; ถ้าไม่เจอใช้อันแรก ๆ ใน CoreGui)
    local GUI = CG:FindFirstChild("UFO_HUB_X_UI")
    if not GUI then
        for _,g in ipairs(CG:GetChildren()) do
            if g:IsA("ScreenGui") and (g.Name:lower():find("ufo") or g.Name:lower():find("hub")) then GUI = g break end
        end
        GUI = GUI or CG:FindFirstChildWhichIsA("ScreenGui")
        if not GUI then return end
    end
    GUI.Enabled = true

    -- หา "หน้าต่างหลัก" ให้แม่นที่สุด: 1) ชื่อ Window 2) เฟรมที่ใหญ่สุดใต้ GUI 3) ถ้าไม่เจอ ใช้ศูนย์กลางจอ
    local Window = GUI:FindFirstChild("Window") or GUI:FindFirstChildWhichIsA("Frame")
    do
        local biggest, area = nil, 0
        for _,f in ipairs(GUI:GetDescendants()) do
            if f:IsA("Frame") and f.Visible then
                local s = f.AbsoluteSize; local a = s.X*s.Y
                if a > area then area, biggest = a, f end
            end
        end
        if biggest then Window = biggest end
    end

    local UIScale = Window and Window:FindFirstChildOfClass("UIScale")
    if Window and not UIScale then UIScale = Instance.new("UIScale", Window); UIScale.Scale = 1 end

    local UFO_ID    = "rbxassetid://140388309537044"
    local PRE_HOLD  = 2.0   -- ยานค้างก่อนโชว์ UI
    local POST_HOLD = 2.0   -- ยานค้างหลัง UI โผล่

    local animBusy = false
    local isShown  = (not Window) or (Window.Visible ~= false) -- ถ้าไม่มี Window ถือว่า "แสดงอยู่"

    -- เครื่องมือ
    local function tween(o,t,goal,style,dir)
        local tw = TS:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), goal)
        tw:Play(); tw.Completed:Wait()
    end

    local function getCenter()
        if Window then
            local p,s = Window.AbsolutePosition, Window.AbsoluteSize
            return p.X + s.X/2, p.Y + s.Y/2, s.X, s.Y
        else
            local cam = workspace.CurrentCamera
            local v = cam and cam.ViewportSize or Vector2.new(1280,720)
            return v.X/2, v.Y/2, v.X, v.Y
        end
    end

    local function makeOverlay()
        -- สร้าง ScreenGui เลเยอร์บนสุด สำหรับแผ่นบัง + ยาน (ไม่แกะของเดิม)
        local overlay = Instance.new("ScreenGui")
        overlay.Name = "UFO_INTRO_FAILSAFE"; overlay.IgnoreGuiInset = true
        overlay.ResetOnSpawn = false; overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        overlay.DisplayOrder = 1_000_000 -- ให้อยู่บนสุด
        overlay.Parent = CG

        -- ตำแหน่ง/ขนาดอิงหน้าต่าง ถ้าไม่มีใช้ทั้งจอ
        local cx, cy, w, h = getCenter()

        -- แผ่นบัง (กัน UI โผล่ก่อน)
        local blocker = Instance.new("Frame", overlay)
        blocker.BackgroundColor3 = Color3.new(0,0,0)
        blocker.BackgroundTransparency = 0
        blocker.BorderSizePixel = 0
        blocker.ZIndex = 998
        blocker.Size = UDim2.fromOffset(w, h)
        blocker.Position = UDim2.fromOffset(cx - w/2, cy - h/2)

        -- ยาน
        local u = Instance.new("ImageLabel", overlay)
        u.Name = "UFO_Overlay"; u.BackgroundTransparency = 1
        u.Image = UFO_ID; u.ZIndex = 999
        u.AnchorPoint = Vector2.new(0.5,0.5)
        u.Position = UDim2.fromOffset(cx, cy)
        u.Size = UDim2.fromOffset(40,40)
        u.ImageTransparency = 1
        pcall(function() CP:PreloadAsync({u}) end)

        return overlay, blocker, u
    end

    local function showUI()
        if Window then
            local s0 = UIScale and (UIScale.Scale == 0 and 1 or UIScale.Scale) or 1
            if UIScale then UIScale.Scale = s0 * 0.96 end
            Window.Visible = true; Window.GroupTransparency = 1
            tween(Window, 0.22, {GroupTransparency = 0})
            if UIScale then tween(UIScale, 0.22, {Scale = s0}) end
        else
            GUI.Enabled = true
        end
    end

    local function hideUI()
        if Window then
            local s0 = UIScale and (UIScale.Scale == 0 and 1 or UIScale.Scale) or 1
            tween(Window, 0.18, {GroupTransparency = 1})
            if UIScale then tween(UIScale, 0.18, {Scale = s0 * 0.96}) end
            Window.Visible = false
            if UIScale then UIScale.Scale = s0 end
        else
            GUI.Enabled = false
        end
    end

    local function playOpen()
        if animBusy or isShown then return end
        animBusy = true

        -- บังคับซ่อนก่อนเสมอ
        if Window then Window.Visible = false; Window.GroupTransparency = 1 else GUI.Enabled = false end

        local overlay, blocker, u = makeOverlay()
        tween(u, 0.10, {ImageTransparency = 0.05})
        tween(u, 0.22, {Size = UDim2.fromOffset(220,220)})
        task.wait(PRE_HOLD)

        showUI()

        task.wait(POST_HOLD)
        tween(u, 0.14, {ImageTransparency = 1})
        tween(blocker, 0.12, {BackgroundTransparency = 1})
        overlay:Destroy()

        isShown = true
        animBusy = false
    end

    local function playClose()
        if animBusy or not isShown then return end
        animBusy = true

        local overlay, blocker, u = makeOverlay()
        tween(u, 0.10, {ImageTransparency = 0.05, Size = UDim2.fromOffset(160,160)})

        hideUI()

        tween(u, 0.12, {ImageTransparency = 1})
        tween(blocker, 0.08, {BackgroundTransparency = 1})
        overlay:Destroy()

        isShown = false
        animBusy = false
    end

    -- ปุ่ม X (ถ้ามี)
    local function hookX()
        local X = nil
        for _,o in ipairs((Window or GUI):GetDescendants()) do
            if o:IsA("TextButton") and o.Visible and (o.Text and o.Text:upper()=="X") then X = o break end
        end
        if X then
            X.MouseButton1Click:Connect(function() if isShown then playClose() end end)
        end
    end
    hookX()

    -- RightShift
    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            if isShown then playClose() else playOpen() end
        end
    end)

    -- เล่นครั้งแรกทันที (ยานต้องขึ้นก่อนเสมอ)
    task.defer(function()
        if isShown then
            if Window then Window.Visible = false else GUI.Enabled = false end
            isShown = false
        end
        playOpen()
    end)
end
--==========================================================
