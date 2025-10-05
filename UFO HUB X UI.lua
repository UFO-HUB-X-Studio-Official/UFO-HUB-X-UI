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
-- UFO HUB X : PLAYER PAGE (Final Align + Perfect Layout)
-- จัดตำแหน่งเป๊ะเหมือนภาพตัวอย่าง v2
----------------------------------------------------------------
local Players = game:GetService("Players")
local RunS = game:GetService("RunService")
local LP = Players.LocalPlayer

-- helper ปลอดภัย
local function safeCorner(ui, r) if typeof(corner)=="function" then corner(ui, r) end end
local function safeStroke(ui, t, c, tr)
	if typeof(stroke)=="function" then stroke(ui, t, c, tr) end
end

----------------------------------------------------------------
-- MAIN PAGE (ฝั่งขวา)
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

----------------------------------------------------------------
-- รูปผู้เล่น (Avatar)
----------------------------------------------------------------
local Avatar = PlayerPage:FindFirstChild("Avatar") or Instance.new("ImageLabel")
Avatar.Name = "Avatar"
Avatar.Parent = PlayerPage
Avatar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Avatar.BorderSizePixel = 0
Avatar.ScaleType = Enum.ScaleType.Crop
safeCorner(Avatar, 12)
safeStroke(Avatar, 1, Color3.fromRGB(0, 255, 140), 0.35)

-- ✅ ขนาดและตำแหน่ง (เท่ากับในรูปที่ 2 เป๊ะ)
Avatar.AnchorPoint = Vector2.new(0.5, 0)
Avatar.Position = UDim2.new(0.5, 0, 0, 100)
Avatar.Size = UDim2.fromOffset(150, 150)

task.spawn(function()
	local ok, url = pcall(function()
		return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)
	Avatar.Image = ok and url or "rbxassetid://0"
end)

----------------------------------------------------------------
-- ชื่อผู้เล่น (Name Bar)
----------------------------------------------------------------
local NameBar = PlayerPage:FindFirstChild("NameBar") or Instance.new("Frame")
NameBar.Name = "NameBar"
NameBar.Parent = PlayerPage
NameBar.BorderSizePixel = 0
safeCorner(NameBar, 8)
NameBar.BackgroundColor3 = Color3.fromRGB(245, 200, 40)

-- ✅ ขนาดและตำแหน่งตามกรอบเหลือง
NameBar.AnchorPoint = Vector2.new(0.5, 0)
NameBar.Position = UDim2.new(0.5, 0, 0, 260)
NameBar.Size = UDim2.fromOffset(200, 26)

local NameText = NameBar:FindFirstChild("NameText") or Instance.new("TextLabel")
NameText.Name = "NameText"
NameText.Parent = NameBar
NameText.BackgroundTransparency = 1
NameText.Font = Enum.Font.GothamBold
NameText.TextXAlignment = Enum.TextXAlignment.Center
NameText.Text = LP.DisplayName or LP.Name
NameText.TextSize = 17
NameText.TextColor3 = Color3.fromRGB(25, 25, 25)
NameText.Size = UDim2.new(1, -16, 1, 0)
NameText.Position = UDim2.new(0, 8, 0, 0)

----------------------------------------------------------------
-- แถบนับเวลา (3 ช่อง)
----------------------------------------------------------------
local function makeBar(name, y)
	local bar = PlayerPage:FindFirstChild(name) or Instance.new("Frame")
	bar.Name = name
	bar.Parent = PlayerPage
	bar.BorderSizePixel = 0
	safeCorner(bar, 6)
	bar.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.new(0.5, 0, 0, y)
	bar.Size = UDim2.fromOffset(220, 22)

	local lbl = bar:FindFirstChild("Label") or Instance.new("TextLabel")
	lbl.Name = "Label"
	lbl.Parent = bar
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = Color3.fromRGB(30, 30, 30)
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.Size = UDim2.new(1, -16, 1, 0)
	return lbl
end

local LabelDays = makeBar("BarDays", 290)
local LabelHrs = makeBar("BarHours", 315)
local LabelMin = makeBar("BarMins", 340)

--======================================================
-- TIME TRACKER (นับเมื่อมี UI รันอยู่)
--======================================================
getgenv().UFO_PLAYTIME = getgenv().UFO_PLAYTIME or { start = os.time(), base = 0 }
local PT = getgenv().UFO_PLAYTIME

local function setNameColor(days)
    if days >= 365 then
        NameLabel.TextColor3 = Color3.fromRGB(255,60,60)   -- 1 ปี = แดง
    elseif days >= 30 then
        NameLabel.TextColor3 = Color3.fromRGB(255,215,0)   -- 30 วัน = ทอง
    elseif days >= 7 then
        NameLabel.TextColor3 = Color3.fromRGB(0,255,140)   -- 7 วัน = เขียว
    else
        NameLabel.TextColor3 = TEXT_WHITE                  -- ปกติ = ขาว
    end
end

local acc = 0
RunS.Heartbeat:Connect(function(dt)
    acc += dt; if acc < 1 then return end; acc = 0
    local now   = os.time()
    local total = (PT.base or 0) + (now - (PT.start or now))
    local d = math.floor(total/86400)
    local h = math.floor((total%86400)/3600)
    local m = math.floor((total%3600)/60)
    TimeLabel.Text = string.format("ใช้ UFO HUB X ไปแล้ว: %d วัน  %d ชั่วโมง  %d นาที", d, h, m)
    setNameColor(d)
end)

----------------------------------------------------------------
-- ผูกกับปุ่ม Player เดิม (โชว์/ซ่อน)
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
----------------------------------------------------------------
-- PLAYER PAGE : precise layout patch (วางต่อท้ายได้เลย)
-- ไม่ลบของเก่า/ไม่สร้างหัวข้อ Player ใหม่
----------------------------------------------------------------
local PlayerPage = Right:FindFirstChild("PlayerPage")
if not PlayerPage then return end

-- ================= CONFIG (ปรับละเอียดได้) =================
local AVATAR_W, AVATAR_H = 150, 150   -- ✅ ทำให้เล็กลงตามรูปที่ 2
local AVATAR_Y           = 24         -- ✅ ยกสูงขึ้น (จากขอบบน Right ลงมา 24px)

local NAME_W,  NAME_H    = 280, 24    -- แถบชื่อ (เหลือง)
local NAME_GAP           = 10         -- ช่องว่างระหว่างรูปกับชื่อ

local TIME_W,  TIME_H    = 280, 18    -- แถบเวลา (ขาว)
local TIME_GAP           = 6          -- ระยะห่างระหว่างแถบเวลาแต่ละเส้น
-- ============================================================

-- reference to parts
local Avatar  = PlayerPage:FindFirstChild("Avatar")
local NameBar = PlayerPage:FindFirstChild("NameBar")
local BarDays = PlayerPage:FindFirstChild("BarDays")
local BarHours= PlayerPage:FindFirstChild("BarHours")
local BarMins = PlayerPage:FindFirstChild("BarMins")

-- 1) รูปผู้เล่น (กึ่งกลางแนวนอน + ยกสูง)
if Avatar then
    Avatar.AnchorPoint = Vector2.new(0.5, 0)
    Avatar.Position    = UDim2.new(0.5, 0, 0, AVATAR_Y)
    Avatar.Size        = UDim2.fromOffset(AVATAR_W, AVATAR_H)
end

-- 2) ชื่อใต้รูป (กึ่งกลางแนวนอน)
local nameY = AVATAR_Y + AVATAR_H + NAME_GAP
if NameBar then
    NameBar.AnchorPoint = Vector2.new(0.5, 0)
    NameBar.Position    = UDim2.new(0.5, 0, 0, nameY)
    NameBar.Size        = UDim2.fromOffset(NAME_W, NAME_H)
end

-- 3) แถบเวลา 3 เส้น (เรียงจากบนลงล่าง ใต้ชื่อ)
local firstTimeY = nameY + NAME_H + 8
if BarDays then
    BarDays.AnchorPoint = Vector2.new(0.5, 0)
    BarDays.Position    = UDim2.new(0.5, 0, 0, firstTimeY)
    BarDays.Size        = UDim2.fromOffset(TIME_W, TIME_H)
end

if BarHours then
    BarHours.AnchorPoint = Vector2.new(0.5, 0)
    BarHours.Position    = UDim2.new(0.5, 0, 0, firstTimeY + TIME_GAP + TIME_H*0)
    BarHours.Size        = UDim2.fromOffset(TIME_W, TIME_H)
end

if BarMins then
    BarMins.AnchorPoint = Vector2.new(0.5, 0)
    BarMins.Position    = UDim2.new(0.5, 0, 0, firstTimeY + TIME_GAP*2 + TIME_H*1)
    -- หมายเหตุ: ถ้าต้องการห่างเท่ากันเป๊ะ ให้คงสูตรนี้ไว้
    BarMins.Size        = UDim2.fromOffset(TIME_W, TIME_H)
end
----------------------------------------------------------------
-- PLAYER DISPLAY (Version 2 - precise layout + name color system)
----------------------------------------------------------------
local PlayerPage = Right:FindFirstChild("PlayerPage")
if not PlayerPage then return end

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local TS = game:GetService("TweenService")

-- CONFIG ตำแหน่งและขนาด (ปรับละเอียด)
local AVATAR_W, AVATAR_H = 130, 130   -- ✅ ทำให้เล็กลง
local AVATAR_Y           = 16         -- ✅ ยกสูงขึ้น

local NAME_W,  NAME_H    = 260, 26    -- ✅ ขนาดชื่อใหม่ (สีดำ + เส้นเขียว)
local NAME_GAP           = 8

local TIME_W,  TIME_H    = 260, 18
local TIME_GAP           = 6

----------------------------------------------------------------
-- Avatar
----------------------------------------------------------------
local Avatar = PlayerPage:FindFirstChild("Avatar")
if Avatar then
	Avatar.AnchorPoint = Vector2.new(0.5, 0)
	Avatar.Position = UDim2.new(0.5, 0, 0, AVATAR_Y)
	Avatar.Size = UDim2.fromOffset(AVATAR_W, AVATAR_H)
end

----------------------------------------------------------------
-- Name bar (ดำ + ขอบเขียว + ตัวอักษรขาว)
----------------------------------------------------------------
local NameBar = PlayerPage:FindFirstChild("NameBar")
if NameBar then
	NameBar.AnchorPoint = Vector2.new(0.5, 0)
	NameBar.Position = UDim2.new(0.5, 0, 0, AVATAR_Y + AVATAR_H + NAME_GAP)
	NameBar.Size = UDim2.fromOffset(NAME_W, NAME_H)
	NameBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
	NameBar.BorderSizePixel = 0
	corner(NameBar, 6)
	stroke(NameBar, 1.5, Color3.fromRGB(0,255,140), 0.6)

	local label = NameBar:FindFirstChildOfClass("TextLabel")
	if label then
		label.TextColor3 = Color3.fromRGB(255,255,255)
		label.Text = plr.Name
	end
end

----------------------------------------------------------------
-- Timer bars
----------------------------------------------------------------
local BarDays = PlayerPage:FindFirstChild("BarDays")
local BarHours = PlayerPage:FindFirstChild("BarHours")
local BarMins = PlayerPage:FindFirstChild("BarMins")

local firstY = AVATAR_Y + AVATAR_H + NAME_H + 12
if BarDays then
	BarDays.AnchorPoint = Vector2.new(0.5, 0)
	BarDays.Position = UDim2.new(0.5, 0, 0, firstY)
	BarDays.Size = UDim2.fromOffset(TIME_W, TIME_H)
end
if BarHours then
	BarHours.AnchorPoint = Vector2.new(0.5, 0)
	BarHours.Position = UDim2.new(0.5, 0, 0, firstY + TIME_H + TIME_GAP)
	BarHours.Size = UDim2.fromOffset(TIME_W, TIME_H)
end
if BarMins then
	BarMins.AnchorPoint = Vector2.new(0.5, 0)
	BarMins.Position = UDim2.new(0.5, 0, 0, firstY + (TIME_H + TIME_GAP) * 2)
	BarMins.Size = UDim2.fromOffset(TIME_W, TIME_H)
end
----------------------------------------------------------------
-- UFO HUB X : REALTIME PLAYTIME (Simplified + Save + Color system)
----------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer

-- 🔧 ตำแหน่งหน้า Player Page ที่มีอยู่แล้ว
local PlayerPage = Right:FindFirstChild("PlayerPage")
if not PlayerPage then return end

-- ⚙️ UI อ้างอิงที่มีอยู่แล้ว
local NameBar = PlayerPage:FindFirstChild("NameBar")
local NameText = NameBar and NameBar:FindFirstChildOfClass("TextLabel")

----------------------------------------------------------------
-- ตัวแสดงเวลา (แทนช่องสีขาว 3 ช่อง)
----------------------------------------------------------------
local TimeLabel = PlayerPage:FindFirstChild("TimeLabel")
if not TimeLabel then
	TimeLabel = Instance.new("TextLabel")
	TimeLabel.Name = "TimeLabel"
	TimeLabel.Parent = PlayerPage
	TimeLabel.BackgroundTransparency = 1
	TimeLabel.Font = Enum.Font.GothamBold
	TimeLabel.TextColor3 = Color3.fromRGB(255,255,255)
	TimeLabel.TextScaled = true
	TimeLabel.Size = UDim2.new(1,0,0,30)
	TimeLabel.AnchorPoint = Vector2.new(0.5,0)
	TimeLabel.Position = UDim2.new(0.5,0,0, NameBar.Position.Y.Offset + 40)
	TimeLabel.Text = "00:00.00"
end

----------------------------------------------------------------
-- 🧠 ระบบเก็บเวลา (เซฟข้ามเซสชัน)
----------------------------------------------------------------
local function loadTime()
	pcall(function()
		local saved = isfile and readfile("ufo_hubx_time.json")
		if saved then
			local data = HttpService:JSONDecode(saved)
			if data and data.total then
				getgenv().UFO_TIME = data
				return
			end
		end
	end)
	getgenv().UFO_TIME = { total = 0, last = os.time() }
end

local function saveTime()
	pcall(function()
		if writefile then
			writefile("ufo_hubx_time.json", HttpService:JSONEncode(getgenv().UFO_TIME))
		end
	end)
end

loadTime()
local T = getgenv().UFO_TIME

----------------------------------------------------------------
-- ⏱️ ระบบนับเวลาแบบเรียลไทม์
--   ถ้า UI ปิด แต่ยังรันระบบ UFO อยู่ มันจะนับต่อ
----------------------------------------------------------------
RunService.Heartbeat:Connect(function()
	local now = os.time()
	local delta = now - (T.last or now)
	if delta > 0 then
		T.total += delta
		T.last = now
	end
end)

-- บันทึกทุก ๆ 60 วินาที
task.spawn(function()
	while task.wait(60) do
		saveTime()
	end
end)

----------------------------------------------------------------
-- 💡 อัปเดตตัวเลขเวลาและสีชื่อ
----------------------------------------------------------------
task.spawn(function()
	while task.wait(0.1) do
		local total = T.total + (os.time() - (T.last or os.time()))
		local days = math.floor(total / 86400)
		local hours = math.floor((total % 86400) / 3600)
		local mins = math.floor((total % 3600) / 60)
		local secs = math.floor(total % 60)

		TimeLabel.Text = string.format("%02d:%02d.%02d", hours, mins, secs)

		-- เปลี่ยนสีชื่อผู้เล่นตามเวลา
		if NameText then
			if days >= 365 then
				NameText.TextColor3 = Color3.fromRGB(255,60,60) -- 🔴 1 ปี
			elseif days >= 30 then
				NameText.TextColor3 = Color3.fromRGB(255,215,0) -- 🟡 1 เดือน
			elseif days >= 7 then
				NameText.TextColor3 = Color3.fromRGB(0,255,140) -- 🟢 7 วัน
			else
				NameText.TextColor3 = Color3.fromRGB(255,255,255) -- ⚪ เริ่มต้น
			end
		end
	end
end)
