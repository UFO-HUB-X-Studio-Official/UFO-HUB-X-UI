--==========================================================
-- UFO HUB X • tuned layout (title higher, UFO lower)
-- (Full file with AFK Always-On + SCROLL + RECOVERY v3)
--==========================================================

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
local GAP_OUTER    = 14
local GAP_BETWEEN  = 12
local LEFT_RATIO   = 0.22
local RIGHT_RATIO  = 0.78

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

local Dot = Instance.new("Frame", Header)
Dot.BackgroundColor3 = MINT; Dot.Position = UDim2.new(0,14,0.5,-4); Dot.Size = UDim2.new(0,8,0,8)
Dot.BorderSizePixel = 0; corner(Dot, 4)

local BtnClose = Instance.new("TextButton", Header)
BtnClose.Size = UDim2.new(0,24,0,24); BtnClose.Position = UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3 = DANGER_RED; BtnClose.Text = "X"; BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 13; BtnClose.TextColor3 = Color3.new(1,1,1); BtnClose.BorderSizePixel = 0
corner(BtnClose, 6); stroke(BtnClose, 1, Color3.fromRGB(255,0,0), 0.1)

-- ✅ ปุ่ม X ซ่อนเฉพาะ Window + sync flag
BtnClose.MouseButton1Click:Connect(function()
    Window.Visible = false
    getgenv().UFO_ISOPEN = false
end)

-- drag (fix: block camera input while dragging)
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
        else
            pcall(function() CAS:UnbindAction(name) end)
        end
    end

    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Window.Position
            bindBlock(true)
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then
                    dragging=false
                    bindBlock(false)
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            Window.Position=UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset+d.X,
                startPos.Y.Scale,
                startPos.Y.Offset+d.Y
            )
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
-- SCROLLBAR PATCH • ซ่อนแท่งสกอลล์บาร์ (เลื่อนยังทำงานได้)
--==========================================================
do
    local function hideScroll(sf)
        if sf and sf:IsA("ScrollingFrame") then
            sf.ScrollBarThickness = 0   -- 🫥 ซ่อนแท่ง
        end
    end

    local leftSF  = Left:FindFirstChildWhichIsA("ScrollingFrame")
    local rightSF = Right:FindFirstChildWhichIsA("ScrollingFrame")

    hideScroll(leftSF)   -- ซ่อนฝั่งซ้าย
    hideScroll(rightSF)  -- ซ่อนฝั่งขวา (ถ้ามี)
end


--==========================================================
-- AFK SHIELD (Always-On)
--==========================================================
do
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local VirtualUser = game:GetService("VirtualUser")

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
----------------------------------------------------------------
-- UFO HUB X : Player Button + BigHeader (ADD-ON, DROP-IN ONLY)
-- วางต่อท้ายสคริปต์เดิมได้เลย ไม่ลบ/แก้อะไรของเดิม
----------------------------------------------------------------
local TS = game:GetService("TweenService")

-- ไอคอนที่ใช้ทั้งปุ่มซ้าย และหัวข้อใหญ่ฝั่งขวา (เปลี่ยนได้)
local PLAYER_ICON = "rbxassetid://116976545042904"

-- ===== ปุ่ม PLAYER (ฝั่งซ้าย) =====
local BtnPlayer = Left:FindFirstChild("BtnPlayer")
if not BtnPlayer then
    BtnPlayer = Instance.new("Frame")
    BtnPlayer.Name = "BtnPlayer"
    BtnPlayer.Parent = Left
    BtnPlayer.Size = UDim2.new(1, -12, 0, 46)
    BtnPlayer.Position = UDim2.new(0, 6, 0, 6)
    BtnPlayer.BackgroundColor3 = Color3.fromRGB(20,20,20)
    BtnPlayer.BorderSizePixel = 0
    BtnPlayer.ClipsDescendants = true
    corner(BtnPlayer, 10)
    stroke(BtnPlayer, 1.2, Color3.fromRGB(0,255,140), 0.6) -- กรอบเขียว

    -- ปุ่มคลิกโปร่งใส
    local Click = Instance.new("TextButton")
    Click.Name = "Click"
    Click.Parent = BtnPlayer
    Click.BackgroundTransparency = 1
    Click.BorderSizePixel = 0
    Click.Size = UDim2.new(1,0,1,0)
    Click.Text = ""

    -- รูปไอคอนทางซ้าย
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Parent = BtnPlayer
    Icon.BackgroundTransparency = 1
    Icon.AnchorPoint = Vector2.new(0,0.5)
    Icon.Position  = UDim2.new(0, 10, 0.5, 0)
    Icon.Size      = UDim2.new(0, 22, 0, 22)
    Icon.Image     = PLAYER_ICON
    Icon.ScaleType = Enum.ScaleType.Fit
    Icon.ZIndex    = 2

    -- ชื่อ "Player"
    local Text = Instance.new("TextLabel")
    Text.Name = "Label"
    Text.Parent = BtnPlayer
    Text.BackgroundTransparency = 1
    Text.AnchorPoint = Vector2.new(0,0.5)
    Text.Position = UDim2.new(0, 42, 0.5, 0)
    Text.Size = UDim2.new(1, -52, 1, 0)
    Text.Font = Enum.Font.GothamBold
    Text.Text = "Player"
    Text.TextSize = 15
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.TextColor3 = Color3.fromRGB(255,255,255)
    Text.ZIndex = 2

    -- เอฟเฟกต์ปุ่ม
    local COLOR_IDLE   = Color3.fromRGB(20,20,20)
    local COLOR_HOVER  = Color3.fromRGB(28,28,28)
    local COLOR_ACTIVE = Color3.fromRGB(40,40,40)

    local function tweenBG(c)
        TS:Create(BtnPlayer, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = c
        }):Play()
    end

    BtnPlayer:SetAttribute("active", false)

    Click.MouseEnter:Connect(function()
        if not BtnPlayer:GetAttribute("active") then
            tweenBG(COLOR_HOVER)
        end
    end)

    Click.MouseLeave:Connect(function()
        if not BtnPlayer:GetAttribute("active") then
            tweenBG(COLOR_IDLE)
        end
    end)

    Click.MouseButton1Down:Connect(function()
        tweenBG(COLOR_ACTIVE)
        Icon:TweenSize(UDim2.new(0,20,0,20), "Out", "Quad", 0.08, true)
    end)

    Click.MouseButton1Up:Connect(function()
        Icon:TweenSize(UDim2.new(0,22,0,22), "Out", "Quad", 0.08, true)
    end)

    -- เมื่อคลิกปุ่ม: ทำให้ Active + แสดงหัวข้อใหญ่ฝั่งขวา
    Click.MouseButton1Click:Connect(function()
        BtnPlayer:SetAttribute("active", true)
        tweenBG(COLOR_ACTIVE)
        -- เอฟเฟกต์ขอบ
        stroke(BtnPlayer, 1.8, Color3.fromRGB(0,255,140), 1)
        task.delay(0.25, function()
            stroke(BtnPlayer, 1.2, Color3.fromRGB(0,255,140), 0.6)
        end)

        -- โชว์หัวข้อใหญ่เฉพาะตอนกดปุ่ม
        local header = Right:FindFirstChild("BigHeader")
        if header then
            header.Visible = true
        end
    end)
end

-- ===== หัวข้อใหญ่ฝั่งขวา (ชื่อ + รูป) เริ่มต้นซ่อน =====
local BigHeader = Right:FindFirstChild("BigHeader")
if not BigHeader then
    BigHeader = Instance.new("Frame")
    BigHeader.Name = "BigHeader"
    BigHeader.Parent = Right
    BigHeader.BackgroundTransparency = 1      -- ไม่มีกรอบเพิ่ม
    BigHeader.Size = UDim2.new(0, 200, 0, 36)
    BigHeader.Position = UDim2.new(0, 14, 0, 12) -- มุมซ้ายบนของ Right
    BigHeader.Visible = false                  -- << สำคัญ: ซ่อนก่อน จนกว่าจะกดปุ่ม

    local HIcon = Instance.new("ImageLabel")
    HIcon.Name = "Icon"
    HIcon.Parent = BigHeader
    HIcon.BackgroundTransparency = 1
    HIcon.AnchorPoint = Vector2.new(0, 0.5)
    HIcon.Position = UDim2.new(0, 0, 0.5, 0)
    HIcon.Size = UDim2.fromOffset(24, 24)
    HIcon.Image = PLAYER_ICON
    HIcon.ScaleType = Enum.ScaleType.Fit

    local HText = Instance.new("TextLabel")
    HText.Name = "Title"
    HText.Parent = BigHeader
    HText.BackgroundTransparency = 1
    HText.AnchorPoint = Vector2.new(0, 0.5)
    HText.Position = UDim2.new(0, 30, 0.5, 0)
    HText.Size = UDim2.new(1, -34, 1, 0)
    HText.Font = Enum.Font.GothamBold
    HText.Text = "Player"
    HText.TextSize = 18
    HText.TextXAlignment = Enum.TextXAlignment.Left
    HText.TextColor3 = Color3.fromRGB(255,255,255)
else
    -- ถ้ามีอยู่แล้ว ให้แน่ใจว่าเริ่มต้นซ่อนก่อน
    BigHeader.Visible = false
end
----------------------------------------------------------------
-- END (จบส่วนเพิ่ม)
----------------------------------------------------------------
----------------------------------------------------------------
-- UFO HUB X : PLAYER PAGE (Perfect Align + MAX SYSTEM)
-- • เวลาอยู่ใต้ชื่อในแท่งดำขอบเขียว (ตำแหน่งเดียวกับกรอบแดง)
-- • เวลาเล็กลง ขาวในกรอบดำ
-- • ครบ 1 ปี = แสดงคำว่า MAX และหยุดนับ
----------------------------------------------------------------
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LP          = Players.LocalPlayer

local function safeCorner(ui, r) if typeof(corner)=="function" then corner(ui, r) end end
local function safeStroke(ui, t, c, tr) if typeof(stroke)=="function" then stroke(ui, t, c, tr) end end

----------------------------------------------------------------
-- Player Page setup
----------------------------------------------------------------
local PlayerPage = Right:FindFirstChild("PlayerPage")
if not PlayerPage then
	PlayerPage = Instance.new("Frame")
	PlayerPage.Name = "PlayerPage"
	PlayerPage.Parent = Right
	PlayerPage.BackgroundTransparency = 1
	PlayerPage.Size = UDim2.new(1, 0, 1, 0)
	PlayerPage.Visible = false
end

-- ล้างของเก่า
for _, n in ipairs({"BarDays","BarHours","BarMins"}) do
	local f = PlayerPage:FindFirstChild(n)
	if f then f:Destroy() end
end
for _, ch in ipairs(PlayerPage:GetChildren()) do
	if ch:IsA("TextLabel") and ch.Text == "Label" then ch:Destroy() end
end

----------------------------------------------------------------
-- Avatar
----------------------------------------------------------------
local AVATAR_W, AVATAR_H = 130, 130
local AVATAR_Y = 16

local Avatar = PlayerPage:FindFirstChild("Avatar") or Instance.new("ImageLabel")
Avatar.Name = "Avatar"
Avatar.Parent = PlayerPage
Avatar.BackgroundColor3 = Color3.fromRGB(22,22,22)
Avatar.BorderSizePixel = 0
Avatar.ScaleType = Enum.ScaleType.Crop
safeCorner(Avatar, 12)
safeStroke(Avatar, 1, Color3.fromRGB(0,255,140), 0.35)
Avatar.AnchorPoint = Vector2.new(0.5,0)
Avatar.Position = UDim2.new(0.5,0,0,AVATAR_Y)
Avatar.Size = UDim2.fromOffset(AVATAR_W,AVATAR_H)

task.spawn(function()
	local ok, url = pcall(function()
		return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)
	Avatar.Image = ok and url or "rbxassetid://0"
end)

----------------------------------------------------------------
-- NameBar (ดำ + ขอบเขียว + ชื่อ)
----------------------------------------------------------------
local NAME_W, NAME_H = 260, 26
local NAME_GAP = 8

local NameBar = PlayerPage:FindFirstChild("NameBar") or Instance.new("Frame")
NameBar.Name = "NameBar"
NameBar.Parent = PlayerPage
NameBar.BorderSizePixel = 0
NameBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
safeCorner(NameBar, 6)
safeStroke(NameBar, 1.5, Color3.fromRGB(0,255,140), 0.6)
NameBar.AnchorPoint = Vector2.new(0.5, 0)
NameBar.Position = UDim2.new(0.5, 0, 0, AVATAR_Y + AVATAR_H + NAME_GAP)
NameBar.Size = UDim2.fromOffset(NAME_W, NAME_H)

local NameText = NameBar:FindFirstChild("NameText") or Instance.new("TextLabel")
NameText.Name = "NameText"
NameText.Parent = NameBar
NameText.BackgroundTransparency = 1
NameText.Font = Enum.Font.GothamBold
NameText.TextXAlignment = Enum.TextXAlignment.Center
NameText.Size = UDim2.new(1,-16,1,0)
NameText.Position = UDim2.new(0,8,0,0)
NameText.Text = LP.DisplayName or LP.Name
NameText.TextSize = 17
NameText.TextColor3 = Color3.fromRGB(255,255,255)

----------------------------------------------------------------
-- TimeBar (ใหม่) — เป็นแท่งดำขอบเขียวใต้ NameBar
----------------------------------------------------------------
local TIME_W, TIME_H = 160, 20  -- ขนาดแบบในรูป (เล็กลง)
local TIME_GAP = 6
local TimeBar = PlayerPage:FindFirstChild("TimeBar") or Instance.new("Frame")
TimeBar.Name = "TimeBar"
TimeBar.Parent = PlayerPage
TimeBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
TimeBar.BorderSizePixel = 0
safeCorner(TimeBar, 6)
safeStroke(TimeBar, 1.5, Color3.fromRGB(0,255,140), 0.6)
TimeBar.AnchorPoint = Vector2.new(0.5,0)
TimeBar.Position = UDim2.new(0.5,0,0, NameBar.Position.Y.Offset + NAME_H + TIME_GAP)
TimeBar.Size = UDim2.fromOffset(TIME_W,TIME_H)

local TimeLabel = TimeBar:FindFirstChild("TimeLabel") or Instance.new("TextLabel")
TimeLabel.Name = "TimeLabel"
TimeLabel.Parent = TimeBar
TimeLabel.BackgroundTransparency = 1
TimeLabel.Font = Enum.Font.GothamBold
TimeLabel.TextColor3 = Color3.fromRGB(255,255,255)
TimeLabel.TextScaled = true
TimeLabel.Text = "00:00.00"
TimeLabel.Size = UDim2.new(1,0,1,0)
TimeLabel.Position = UDim2.new(0,0,0,0)

----------------------------------------------------------------
-- ระบบเวลา + เซฟไฟล์ + MAX system
----------------------------------------------------------------
local SAVE_FILE = "ufo_hubx_time.json"
getgenv().UFO_TIME = getgenv().UFO_TIME or nil

local function loadTime()
	if getgenv().UFO_TIME then return end
	local ok, data = pcall(function()
		if isfile and isfile(SAVE_FILE) then
			return HttpService:JSONDecode(readfile(SAVE_FILE))
		end
	end)
	if ok and type(data)=="table" and type(data.total_cs)=="number" then
		getgenv().UFO_TIME = { total_cs = math.max(0, data.total_cs), last = os.clock() }
	else
		getgenv().UFO_TIME = { total_cs = 0, last = os.clock() }
	end
end

local function saveTime()
	pcall(function()
		if writefile then
			writefile(SAVE_FILE, HttpService:JSONEncode({ total_cs = getgenv().UFO_TIME.total_cs }))
		end
	end)
end

loadTime()
local T = getgenv().UFO_TIME
local isMaxed = false

RunService.Heartbeat:Connect(function(dt)
	if isMaxed then return end
	T.total_cs += math.floor(dt * 100 + 0.5)
	T.last = os.clock()
end)

task.spawn(function()
	while task.wait(15) do saveTime() end
end)
pcall(function() game:BindToClose(saveTime) end)

----------------------------------------------------------------
-- แสดงเวลา + สีชื่อ + MAX Logic
----------------------------------------------------------------
local function updateNameColor(days)
	if days >= 365 then
		NameText.TextColor3 = Color3.fromRGB(255,60,60)
	elseif days >= 30 then
		NameText.TextColor3 = Color3.fromRGB(255,215,0)
	elseif days >= 7 then
		NameText.TextColor3 = Color3.fromRGB(0,255,140)
	else
		NameText.TextColor3 = Color3.fromRGB(255,255,255)
	end
end

task.spawn(function()
	while task.wait(0.05) do
		local cs = T.total_cs
		local total_s = math.floor(cs / 100)
		local days = math.floor(total_s / 86400)
		local hours = math.floor(total_s / 3600)
		local mins  = math.floor((total_s % 3600) / 60)
		local secs  = math.floor(total_s % 60)

		if days >= 365 then
			isMaxed = true
			TimeLabel.Text = "MAX"
			TimeLabel.TextColor3 = Color3.fromRGB(255,60,60)
			saveTime()
		else
			TimeLabel.Text = string.format("%02d:%02d.%02d", hours, mins, secs)
			updateNameColor(days)
		end
	end
end)

----------------------------------------------------------------
-- ปุ่ม Player (โชว์/ซ่อน)
----------------------------------------------------------------
local BtnPlayer = Left:FindFirstChild("BtnPlayer")
local ClickBtn = BtnPlayer and BtnPlayer:FindFirstChild("Click")
if ClickBtn then
	ClickBtn.MouseButton1Click:Connect(function()
		for _, v in ipairs(Right:GetChildren()) do
			if v:IsA("Frame") then v.Visible = false end
		end
		PlayerPage.Visible = true
	end)
end
-- 🛸 UFO HUB X : SPEED + JUMP sliders (final v4)
-- - ตำแหน่งเดิมใต้ TimeLabel
-- - Labels สีขาวล้วน ไม่มีเส้นเขียว
-- - ช่วงค่า: Speed 0–200, Jump 0–200
-- - เปิดสวิตช์แต่ยัง 0 => ใช้ค่าปกติ (ไม่ล็อกตัวละคร)

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput  = game:GetService("UserInputService")
local LP         = Players.LocalPlayer

local function corner(ui, r)
	local c = ui:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r); c.Parent = ui
end
local function stroke(ui, t, col, tr)
	local s = ui:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	s.Thickness = t; s.Color = col; s.Transparency = tr or 0.25; s.Parent = ui
end
local function clamp(n,a,b) return math.max(a, math.min(b,n)) end
local function isPrimary(io)
	return io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch
end

-- ui anchors
local PlayerPage = Right and Right:FindFirstChild("PlayerPage")
if not PlayerPage then
	for _,v in ipairs(LP:WaitForChild("PlayerGui"):GetDescendants()) do
		if v:IsA("Frame") and v.Name=="PlayerPage" then PlayerPage=v break end
	end
end
if not PlayerPage then return end
local TimeLabel = PlayerPage:FindFirstChild("TimeLabel")

-- humanoid
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum  = Char:WaitForChild("Humanoid")
Hum.UseJumpPower = true

-- ==== CONFIG ====
local CFG = {
	BOX_W = 360, BOX_H = 58,
	BOX_Y_OFFSET = 24,        -- ระยะห่างจาก TimeLabel (ตำแหน่งเดิม)
	ROW_GAP = 4,
	LABEL_W = 84,
	TRACK_W = 120, TRACK_H = 8,
	KNOB_W = 8,
	SWITCH_W = 28, SWITCH_H = 14,
	COLOR_BG = Color3.fromRGB(0,0,0),
	COLOR_ACC = Color3.fromRGB(0,255,140),
	Z = 200,
}
local MAX_SPEED = 200
local MAX_JUMP  = 200
local DEF_WALKSPEED = 16
local DEF_JUMPPOWER = 50

-- กล่องรวม
local Box = Instance.new("Frame")
Box.Name = "SlidersBox"
Box.Parent = PlayerPage
Box.BackgroundColor3 = CFG.COLOR_BG
Box.BorderSizePixel  = 0
corner(Box,8) stroke(Box,1.2,CFG.COLOR_ACC,0.35)
Box.ZIndex = CFG.Z

local function placeBox()
	local baseY = (TimeLabel and (TimeLabel.Position.Y.Offset + TimeLabel.AbsoluteSize.Y)) or 210
	Box.AnchorPoint = Vector2.new(0.5,0)
	Box.Position    = UDim2.new(0.5,0,0, baseY + CFG.BOX_Y_OFFSET)
	Box.Size        = UDim2.fromOffset(CFG.BOX_W, CFG.BOX_H)
end
placeBox()
-- ยึดตำแหน่งเดิม: อัปเดตตาม TimeLabel เท่านั้น
RunService.RenderStepped:Connect(placeBox)

-- row factory
local function makeRow(name, emoji, MAX)
	local row = Instance.new("Frame")
	row.Name=name; row.Parent=Box; row.BackgroundTransparency=1
	row.Size=UDim2.new(1,-10,0,CFG.TRACK_H+12)
	row.Position=UDim2.new(0,5,0,0); row.ZIndex=CFG.Z

	-- label: ขาวล้วน ไม่มีเส้น/พื้นหลัง
	local lbl=Instance.new("TextLabel")
	lbl.Name="Title"; lbl.Parent=row
	lbl.BackgroundTransparency = 1
	lbl.Text=name.." "..emoji
	lbl.Font=Enum.Font.GothamBold; lbl.TextSize=13
	lbl.TextColor3=Color3.fromRGB(255,255,255)
	lbl.TextXAlignment=Enum.TextXAlignment.Left
	lbl.AnchorPoint=Vector2.new(0,0.5)
	lbl.Position=UDim2.new(0,0,0.5,0)
	lbl.Size=UDim2.fromOffset(CFG.LABEL_W,18)
	lbl.ZIndex=CFG.Z+1

	local track=Instance.new("Frame")
	track.Name="Track"; track.Parent=row
	track.BackgroundColor3=CFG.COLOR_BG; track.BorderSizePixel=0
	track.AnchorPoint=Vector2.new(0,0.5)
	track.Position=UDim2.new(0,CFG.LABEL_W+8,0.5,0)
	track.Size=UDim2.fromOffset(CFG.TRACK_W, CFG.TRACK_H)
	corner(track,8); stroke(track,1,CFG.COLOR_ACC,0.35)
	track.ZIndex=CFG.Z+1

	local fill=Instance.new("Frame")
	fill.Name="Fill"; fill.Parent=track
	fill.BackgroundColor3=CFG.COLOR_ACC; fill.BorderSizePixel=0
	fill.AnchorPoint=Vector2.new(0,0.5)
	fill.Position=UDim2.new(0,0,0.5,0)
	fill.Size=UDim2.new(0,0,1,0)
	corner(fill,8); fill.ZIndex=CFG.Z+2

	local knob=Instance.new("Frame")
	knob.Name="Knob"; knob.Parent=track
	knob.BackgroundColor3=Color3.fromRGB(255,255,255)
	knob.BorderSizePixel=0; knob.AnchorPoint=Vector2.new(0.5,0.5)
	knob.Position=UDim2.new(0,0,0.5,0)
	knob.Size=UDim2.fromOffset(CFG.KNOB_W, CFG.TRACK_H+4)
	corner(knob,8); stroke(knob,1,CFG.COLOR_ACC,0.35)
	knob.ZIndex=CFG.Z+3

	local valLabel=Instance.new("TextLabel")
	valLabel.Name="ValText"; valLabel.Parent=row
	valLabel.BackgroundTransparency=1
	valLabel.Font=Enum.Font.GothamBold; valLabel.TextSize=12
	valLabel.TextColor3=Color3.fromRGB(255,255,255)
	valLabel.Text="0"
	valLabel.AnchorPoint=Vector2.new(0,0.5)
	valLabel.Position=UDim2.new(0, CFG.LABEL_W + CFG.TRACK_W + 12, 0.5, 0)
	valLabel.Size=UDim2.fromOffset(36,14)
	valLabel.ZIndex=CFG.Z+2

	local sw=Instance.new("Frame")
	sw.Name="Switch"; sw.Parent=row
	sw.BackgroundColor3=CFG.COLOR_BG; sw.BorderSizePixel=0
	sw.AnchorPoint=Vector2.new(1,0.5)
	sw.Position=UDim2.new(1,0,0.5,0)
	sw.Size=UDim2.fromOffset(CFG.SWITCH_W, CFG.SWITCH_H)
	corner(sw,999); stroke(sw,1,CFG.COLOR_ACC,0.35)
	sw.ZIndex=CFG.Z+1

	local dot=Instance.new("Frame")
	dot.Name="Dot"; dot.Parent=sw
	dot.BackgroundColor3=Color3.fromRGB(120,120,120)
	dot.AnchorPoint=Vector2.new(0,0.5)
	dot.Position=UDim2.new(0,2,0.5,0)
	dot.Size=UDim2.fromOffset(CFG.SWITCH_H-4, CFG.SWITCH_H-4)
	corner(dot,999); dot.ZIndex=CFG.Z+2

	local maxVal = Instance.new("IntValue"); maxVal.Name="Max"; maxVal.Value=MAX; maxVal.Parent=row
	local val    = Instance.new("NumberValue"); val.Name="Value"; val.Value=0;   val.Parent=row
	local ena    = Instance.new("BoolValue");   ena.Name="Enabled"; ena.Value=false; ena.Parent=row

	-- interaction
	local dragging=nil
	local function setFromX(px)
		local absX=track.AbsolutePosition.X
		local w=math.max(1, track.AbsoluteSize.X - CFG.KNOB_W)
		local rel=clamp(px - absX, 0, w)
		local v=math.floor((rel / w) * maxVal.Value + 0.5)
		val.Value=v
		fill.Size=UDim2.new(0, rel + CFG.KNOB_W/2, 1, 0)
		knob.Position=UDim2.new(0, rel, 0.5, 0)
		valLabel.Text=tostring(v)
	end

	track.InputBegan:Connect(function(io) if isPrimary(io) then setFromX(io.Position.X) end end)
	knob.InputBegan:Connect(function(io) if isPrimary(io) then dragging=row end end)
	UserInput.InputChanged:Connect(function(io)
		if dragging==row and (io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch) then
			setFromX(io.Position.X)
		end
	end)
	UserInput.InputEnded:Connect(function(io) if isPrimary(io) and dragging==row then dragging=nil end end)

	sw.InputBegan:Connect(function(io)
		if isPrimary(io) then
			ena.Value = not ena.Value
			if ena.Value then
				dot.Position = UDim2.new(1, -(CFG.SWITCH_H-2), 0.5, 0)
				dot.BackgroundColor3 = CFG.COLOR_ACC
			else
				dot.Position = UDim2.new(0, 2, 0.5, 0)
				dot.BackgroundColor3 = Color3.fromRGB(120,120,120)
			end
		end
	end)

	return row
end

local rowSpeed = makeRow("Speed","🚀", MAX_SPEED)
local rowJump  = makeRow("Jump","🦘",  MAX_JUMP)
rowSpeed.Position = UDim2.new(0,5,0,4)
rowJump.Position  = UDim2.new(0,5,0,4 + (CFG.TRACK_H+12) + CFG.ROW_GAP)

-- อัปเดตค่าจริง
RunService.Heartbeat:Connect(function()
	if not Hum or not Hum.Parent then
		Char = LP.Character or LP.CharacterAdded:Wait()
		Hum  = Char:WaitForChild("Humanoid")
		Hum.UseJumpPower = true
	end

	-- SPEED
	if rowSpeed.Enabled.Value then
		local v=rowSpeed.Value.Value
		if v>0 then Hum.WalkSpeed=clamp(v,0,MAX_SPEED) else Hum.WalkSpeed=DEF_WALKSPEED end
	else
		Hum.WalkSpeed=DEF_WALKSPEED
	end

	-- JUMP
	if rowJump.Enabled.Value then
		local v=rowJump.Value.Value
		if v>0 then Hum.JumpPower=clamp(v,0,MAX_JUMP) else Hum.JumpPower=DEF_JUMPPOWER end
	else
		Hum.JumpPower=DEF_JUMPPOWER
	end
end)
----------------------------------------------------------------
-- UFO HUB X : FLY CONTROLS (robust drop-in / always show)
----------------------------------------------------------------
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local function waitChar()
	local ch = LP.Character or LP.CharacterAdded:Wait()
	local hum = ch:WaitForChild("Humanoid")
	local hrp = ch:WaitForChild("HumanoidRootPart")
	return ch, hum, hrp
end
local Char, Hum, HRP = waitChar()

-- safe helpers
local function corner(ui, r)
	local c = ui:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r); c.Parent = ui
end
local function stroke(ui, t, col, tr)
	local s = ui:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	s.Thickness = t; s.Color = col; s.Transparency = tr or 0.35; s.Parent = ui
end

-- ===== find PlayerPage / anchor position =====
local RightGui = Right or script.Parent or LP:FindFirstChildOfClass("PlayerGui")
local PlayerPage = Right and Right:FindFirstChild("PlayerPage")
if not PlayerPage then
	-- หาแบบกว้าง ๆ เผื่อชื่อไม่ตรง
	if RightGui then
		for _,v in ipairs(RightGui:GetDescendants()) do
			if v:IsA("Frame") and v.Name == "PlayerPage" then PlayerPage = v break end
		end
	end
end
if not PlayerPage then return end
PlayerPage.ClipsDescendants = false -- กันโดนบัง

local TimeLabel = PlayerPage:FindFirstChild("TimeLabel")
-- Fallback Y ถ้าไม่เจอ TimeLabel
local baseY = (TimeLabel and (TimeLabel.Position.Y.Offset + TimeLabel.AbsoluteSize.Y)) or 206

-- ===== CONFIG (ยาวเท่าบาร์แดงในรูป) =====
local CFG = {
	W = 460, H = 36, Y_GAP = 10,
	BTN_W = 64, BTN_H = 18, BTN_S = 6,
	TITLE_W = 78,
	COLOR_BG  = Color3.fromRGB(0,0,0),
	COLOR_ACC = Color3.fromRGB(0,255,140),
	Z = 50, -- ดันให้อยู่บนสุด
}

-- ===== build FlyBox =====
local FlyBox = PlayerPage:FindFirstChild("FlyBox")
if not FlyBox then
	FlyBox = Instance.new("Frame")
	FlyBox.Name = "FlyBox"
	FlyBox.Parent = PlayerPage
end
FlyBox.BackgroundColor3 = CFG.COLOR_BG
FlyBox.BorderSizePixel = 0
FlyBox.AnchorPoint = Vector2.new(0.5, 0)
FlyBox.Position    = UDim2.new(0.5, 0, 0, baseY + CFG.Y_GAP)
FlyBox.Size        = UDim2.fromOffset(CFG.W, CFG.H)
FlyBox.Visible     = true
FlyBox.ZIndex      = CFG.Z
FlyBox.ClipsDescendants = false
corner(FlyBox, 8); stroke(FlyBox, 1.2, CFG.COLOR_ACC, 0.35)

-- title
local Title = FlyBox:FindFirstChild("Title") or Instance.new("TextLabel")
Title.Name = "Title"; Title.Parent = FlyBox
Title.BackgroundColor3 = CFG.COLOR_BG; Title.BorderSizePixel = 0
Title.Text = "Fly ✈️"; Title.Font = Enum.Font.GothamBold; Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.AnchorPoint = Vector2.new(0,0.5)
Title.Position = UDim2.new(0, 6, 0.5, 0)
Title.Size     = UDim2.fromOffset(CFG.TITLE_W, 18)
Title.ZIndex   = CFG.Z+1
corner(Title,8); stroke(Title,1,CFG.COLOR_ACC,0.35)

-- switch
local Switch = FlyBox:FindFirstChild("Switch") or Instance.new("Frame")
Switch.Name="Switch"; Switch.Parent=FlyBox
Switch.BackgroundColor3 = CFG.COLOR_BG; Switch.BorderSizePixel=0
Switch.AnchorPoint = Vector2.new(1,0.5)
Switch.Position    = UDim2.new(1, -6, 0.5, 0)
Switch.Size        = UDim2.fromOffset(36,16)
Switch.ZIndex      = CFG.Z+1
corner(Switch,999); stroke(Switch,1,CFG.COLOR_ACC,0.35)

local Dot = Switch:FindFirstChild("Dot") or Instance.new("Frame")
Dot.Name="Dot"; Dot.Parent=Switch
Dot.BackgroundColor3 = Color3.fromRGB(120,120,120)
Dot.AnchorPoint = Vector2.new(0,0.5)
Dot.Position = UDim2.new(0,2,0.5,0)
Dot.Size     = UDim2.fromOffset(12,12)
Dot.ZIndex   = CFG.Z+2
corner(Dot,999)

local Enabled = FlyBox:FindFirstChild("Enabled") or Instance.new("BoolValue")
Enabled.Name="Enabled"; Enabled.Parent=FlyBox; Enabled.Value=false

-- make button helper
local function makeBtn(name, txt)
	local b = FlyBox:FindFirstChild(name) or Instance.new("TextButton")
	b.Name=name; b.Parent=FlyBox
	b.BackgroundColor3 = CFG.COLOR_BG; b.BorderSizePixel=0
	b.Text=txt; b.Font=Enum.Font.GothamBold; b.TextSize=13
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.AutoButtonColor=true
	b.Size=UDim2.fromOffset(CFG.BTN_W, CFG.BTN_H)
	b.ZIndex = CFG.Z+1
	corner(b,8); stroke(b,1,CFG.COLOR_ACC,0.35)
	return b
end

local BtnLeft  = makeBtn("BtnLeft","◀")
local BtnFwd   = makeBtn("BtnFwd","▲")
local BtnRight = makeBtn("BtnRight","▶")
local BtnDown  = makeBtn("BtnDown","Down")
local BtnBack  = makeBtn("BtnBack","▼")
local BtnUp    = makeBtn("BtnUp","Up")

-- layout 2 rows, centered between title and switch
local function layoutButtons()
	local usable = CFG.W - (6 + CFG.TITLE_W + 6) - (36 + 6) -- left pads + title + space + switch + right pad
	local startX = 6 + CFG.TITLE_W + math.max(6, math.floor((usable - (CFG.BTN_W*3 + CFG.BTN_S*2))/2))
	local rowY1  = math.floor((CFG.H - (CFG.BTN_H*2 + 4)) / 2)
	local rowY2  = rowY1 + CFG.BTN_H + 4
	BtnLeft.Position  = UDim2.new(0, startX + (CFG.BTN_W+CFG.BTN_S)*0, 0, rowY1)
	BtnFwd.Position   = UDim2.new(0, startX + (CFG.BTN_W+CFG.BTN_S)*1, 0, rowY1)
	BtnRight.Position = UDim2.new(0, startX + (CFG.BTN_W+CFG.BTN_S)*2, 0, rowY1)
	BtnDown.Position  = UDim2.new(0, startX + (CFG.BTN_W+CFG.BTN_S)*0, 0, rowY2)
	BtnBack.Position  = UDim2.new(0, startX + (CFG.BTN_W+CFG.BTN_S)*1, 0, rowY2)
	BtnUp.Position    = UDim2.new(0, startX + (CFG.BTN_W+CFG.BTN_S)*2, 0, rowY2)
end
layoutButtons()

-- ถ้ามี SlidersBox ก็เลื่อนลงไปต่อท้ายอัตโนมัติ
local SlidersBox = PlayerPage:FindFirstChild("SlidersBox")
if SlidersBox then
	SlidersBox.AnchorPoint = Vector2.new(0.5,0)
	SlidersBox.Position    = UDim2.new(0.5,0,0, FlyBox.Position.Y.Offset + CFG.H + 12)
	SlidersBox.ZIndex      = CFG.Z-5
end

----------------------------------------------------------------
-- Flight system (with noclip)
----------------------------------------------------------------
local key = {w=false,a=false,s=false,d=false,up=false,down=false}
local btn = {fwd=false,back=false,left=false,right=false,up=false,down=false}

-- on-screen hold
local function hold(name, on) btn[name]=on end
BtnFwd.MouseButton1Down:Connect(function() hold("fwd",true) end)
BtnFwd.MouseButton1Up:Connect(function() hold("fwd",false) end)
BtnBack.MouseButton1Down:Connect(function() hold("back",true) end)
BtnBack.MouseButton1Up:Connect(function() hold("back",false) end)
BtnLeft.MouseButton1Down:Connect(function() hold("left",true) end)
BtnLeft.MouseButton1Up:Connect(function() hold("left",false) end)
BtnRight.MouseButton1Down:Connect(function() hold("right",true) end)
BtnRight.MouseButton1Up:Connect(function() hold("right",false) end)
BtnUp.MouseButton1Down:Connect(function() hold("up",true) end)
BtnUp.MouseButton1Up:Connect(function() hold("up",false) end)
BtnDown.MouseButton1Down:Connect(function() hold("down",true) end)
BtnDown.MouseButton1Up:Connect(function() hold("down",false) end)

-- keyboard
UIS.InputBegan:Connect(function(io,gp)
	if gp then return end
	if io.KeyCode==Enum.KeyCode.W then key.w=true end
	if io.KeyCode==Enum.KeyCode.S then key.s=true end
	if io.KeyCode==Enum.KeyCode.A then key.a=true end
	if io.KeyCode==Enum.KeyCode.D then key.d=true end
	if io.KeyCode==Enum.KeyCode.Space then key.up=true end
	if io.KeyCode==Enum.KeyCode.LeftControl then key.down=true end
end)
UIS.InputEnded:Connect(function(io)
	if io.KeyCode==Enum.KeyCode.W then key.w=false end
	if io.KeyCode==Enum.KeyCode.S then key.s=false end
	if io.KeyCode==Enum.KeyCode.A then key.a=false end
	if io.KeyCode==Enum.KeyCode.D then key.d=false end
	if io.KeyCode==Enum.KeyCode.Space then key.up=false end
	if io.KeyCode==Enum.KeyCode.LeftControl then key.down=false end
end)

-- switch toggle
Switch.InputBegan:Connect(function(io)
	if io.UserInputType == Enum.UserInputType.MouseButton1 then
		Enabled.Value = not Enabled.Value
		if Enabled.Value then
			Dot.Position = UDim2.new(1, -14, 0.5, 0)
			Dot.BackgroundColor3 = CFG.COLOR_ACC
		else
			Dot.Position = UDim2.new(0, 2, 0.5, 0)
			Dot.BackgroundColor3 = Color3.fromRGB(120,120,120)
		end
	end
end)

-- noclip toggler
local function setNoCollide(on)
	for _,d in ipairs(Char:GetDescendants()) do
		if d:IsA("BasePart") then d.CanCollide = not on end
	end
end

-- physics
local speed, ascend = 80, 60
local function camRight() return workspace.CurrentCamera.CFrame.RightVector end
local function camLook()  return workspace.CurrentCamera.CFrame.LookVector  end

local BV = Instance.new("BodyVelocity")
BV.MaxForce = Vector3.new(1e9,1e9,1e9)
BV.Velocity = Vector3.zero
BV.Parent = HRP
BV.P = 1e4

RunService.Heartbeat:Connect(function()
	-- refresh on respawn
	if not Hum or not Hum.Parent then
		Char, Hum, HRP = waitChar()
		BV.Parent = HRP
	end

	if Enabled.Value then
		setNoCollide(true)
		Hum:ChangeState(Enum.HumanoidStateType.Physics)

		local v = Vector3.zero
		if btn.fwd or key.w   then v += camLook()*speed end
		if btn.back or key.s  then v -= camLook()*speed end
		if btn.left or key.a  then v -= camRight()*speed end
		if btn.right or key.d then v += camRight()*speed end
		if btn.up or key.up   then v += Vector3.new(0,ascend,0) end
		if btn.down or key.down then v -= Vector3.new(0,ascend,0) end

		BV.Velocity = v
	else
		BV.Velocity = Vector3.zero
		setNoCollide(false)
		if Hum:GetState()==Enum.HumanoidStateType.Physics then
			Hum:ChangeState(Enum.HumanoidStateType.Running)
		end
	end
end)
