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
--========================
-- BODY (รวม + Player Panel)
--========================
local Players   = game:GetService("Players")
local RunS      = game:GetService("RunService")
local LP        = Players.LocalPlayer

-- ขนาด/ระยะ
local GAP_OUTER    = 14
local GAP_BETWEEN  = 12
local LEFT_RATIO   = 0.22
local RIGHT_RATIO  = 0.78

-- BODY หลัก
local Body = Instance.new("Frame", Window)
Body.BackgroundTransparency = 1
Body.Position = UDim2.new(0,0,0,46)
Body.Size = UDim2.new(1,0,1,-46)

local Inner = Instance.new("Frame", Body)
Inner.BackgroundColor3 = BG_INNER
Inner.BorderSizePixel = 0
Inner.Position = UDim2.new(0,8,0,8)
Inner.Size = UDim2.new(1,-16,1,-16)
corner(Inner, 12)

local Content = Instance.new("Frame", Body)
Content.BackgroundColor3 = BG_PANEL
Content.Position = UDim2.new(0,GAP_OUTER,0,GAP_OUTER)
Content.Size = UDim2.new(1,-GAP_OUTER*2,1,-GAP_OUTER*2)
corner(Content, 12)
stroke(Content, 0.5, MINT, 0.35)

local Columns = Instance.new("Frame", Content)
Columns.BackgroundTransparency = 1
Columns.Position = UDim2.new(0,8,0,8)
Columns.Size = UDim2.new(1,-16,1,-16)

-- ซ้าย (ปุ่ม)
local Left = Instance.new("Frame", Columns)
Left.Name = "LeftPanel"
Left.BackgroundColor3 = Color3.fromRGB(16,16,16)
Left.Size = UDim2.new(LEFT_RATIO, -GAP_BETWEEN/2, 1, 0)
Left.ClipsDescendants = true
corner(Left, 10)
stroke(Left, 1.2, GREEN, 0)
stroke(Left, 0.45, MINT, 0.35)

-- ขวา (เนื้อหา)
local Right = Instance.new("Frame", Columns)
Right.Name = "RightPanel"
Right.BackgroundColor3 = Color3.fromRGB(16,16,16)
Right.Position = UDim2.new(LEFT_RATIO, GAP_BETWEEN, 0, 0)
Right.Size = UDim2.new(RIGHT_RATIO, -GAP_BETWEEN/2, 1, 0)
Right.ClipsDescendants = true
corner(Right, 10)
stroke(Right, 1.2, GREEN, 0)
stroke(Right, 0.45, MINT, 0.35)

--======================================================
-- PLAYER BUTTON (อยู่ซ้าย)
--======================================================
local BtnPlayer = Instance.new("TextButton", Left)
BtnPlayer.Name = "BtnPlayer"
BtnPlayer.Size = UDim2.new(1, -12, 0, 40)
BtnPlayer.Position = UDim2.new(0, 6, 0, 6)
BtnPlayer.BackgroundColor3 = BG_INNER
BtnPlayer.BorderSizePixel = 0
BtnPlayer.AutoButtonColor = false
corner(BtnPlayer, 10)
stroke(BtnPlayer, 1, GREEN, 0.35)
BtnPlayer.Text = "👤 Player"
BtnPlayer.Font = Enum.Font.GothamBold
BtnPlayer.TextSize = 14
BtnPlayer.TextColor3 = TEXT_WHITE

--======================================================
-- PLAYER PAGE (อยู่ขวา)
--======================================================
local PlayerPage = Instance.new("Frame", Right)
PlayerPage.Name = "PlayerPage"
PlayerPage.BackgroundTransparency = 1
PlayerPage.Size = UDim2.new(1,0,1,0)
PlayerPage.Visible = false

-- การ์ดผู้เล่น
local Card = Instance.new("Frame", PlayerPage)
Card.Name = "PlayerCard"
Card.BackgroundTransparency = 1
Card.AnchorPoint = Vector2.new(0.5,0)
Card.Position = UDim2.new(0.5,0,0,50)
Card.Size = UDim2.new(1,-60,1,-80)

local V = Instance.new("UIListLayout", Card)
V.FillDirection = Enum.FillDirection.Vertical
V.HorizontalAlignment = Enum.HorizontalAlignment.Center
V.VerticalAlignment   = Enum.VerticalAlignment.Start
V.Padding = UDim.new(0,10)

-- รูปผู้เล่น
local Avatar = Instance.new("ImageLabel", Card)
Avatar.Name = "Avatar"
Avatar.BackgroundColor3 = BG_INNER
Avatar.BorderSizePixel = 0
Avatar.Size = UDim2.fromOffset(180,180)
corner(Avatar,12)
stroke(Avatar,1,MINT,0.35)

local ok, url = pcall(function()
    local u = Players:GetUserThumbnailAsync(
        LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420
    )
    return u
end)
Avatar.Image = ok and url or "rbxassetid://0"

-- ชื่อผู้เล่น
local NameLabel = Instance.new("TextLabel", Card)
NameLabel.BackgroundTransparency = 1
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 20
NameLabel.TextColor3 = TEXT_WHITE
NameLabel.Text = LP.DisplayName or LP.Name

-- เวลาใช้งาน UI
local TimeLabel = Instance.new("TextLabel", Card)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextSize = 15
TimeLabel.TextColor3 = TEXT_WHITE
TimeLabel.Text = "ใช้ UFO HUB X ไปแล้ว: 0 วัน 0 ชั่วโมง 0 นาที"

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

-- กดปุ่ม → เปิดหน้า Player
BtnPlayer.MouseButton1Click:Connect(function()
    for _,child in ipairs(Right:GetChildren()) do
        if child:IsA("Frame") then child.Visible = false end
    end
    PlayerPage.Visible = true
end)

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
--====[ PLAYER TAB BUTTON (มีสถานะเลือก/ปกติ + เอฟเฟกต์กด) ]====

-- ปุ่มด้านซ้าย
local BtnPlayer = Instance.new("TextButton", Left)
BtnPlayer.Name = "TabBtn_Player"
BtnPlayer.Size = UDim2.new(1, -12, 0, 40)
BtnPlayer.Position = UDim2.new(0, 6, 0, 6)
BtnPlayer.BackgroundColor3 = BG_INNER
BtnPlayer.BorderSizePixel = 0
BtnPlayer.AutoButtonColor = false  -- คุมสีเอง
corner(BtnPlayer, 10)
local st = stroke(BtnPlayer, 1, GREEN, 0.35)

-- แถวจัดไอคอน+ข้อความ (แนวนอนติดกันสวยๆ)
local Row = Instance.new("Frame", BtnPlayer)
Row.BackgroundTransparency = 1
Row.Position = UDim2.fromOffset(8, 6)
Row.Size = UDim2.new(1, -16, 1, -12)
local H = Instance.new("UIListLayout", Row)
H.FillDirection = Enum.FillDirection.Horizontal
H.HorizontalAlignment = Enum.HorizontalAlignment.Left
H.VerticalAlignment = Enum.VerticalAlignment.Center
H.Padding = UDim.new(0, 6)

local Icon = Instance.new("ImageLabel", Row)
Icon.BackgroundTransparency = 1
Icon.Size = UDim2.fromOffset(24, 24)
Icon.Image = "rbxassetid://114530675624359"

local Txt = Instance.new("TextLabel", Row)
Txt.BackgroundTransparency = 1
Txt.Size = UDim2.new(1, 0, 1, 0)
Txt.TextXAlignment = Enum.TextXAlignment.Left
Txt.TextYAlignment = Enum.TextYAlignment.Center
Txt.Font = Enum.Font.GothamBold
Txt.Text = "Player"
Txt.TextSize = 16
Txt.TextColor3 = TEXT_WHITE

-- หน้า Player ด้านขวา
local PlayerPage = Right:FindFirstChild("PlayerPage") or Instance.new("Frame", Right)
PlayerPage.Name = "PlayerPage"
PlayerPage.BackgroundTransparency = 1
PlayerPage.Size = UDim2.new(1,0,1,0)
PlayerPage.Visible = false

-- หัวข้อบนขวา: ไอคอน + ข้อความ (ไม่มีเส้นขาวแนวตั้งแน่นอน)
if not PlayerPage:FindFirstChild("Header") then
    local Header = Instance.new("Frame", PlayerPage)
    Header.Name = "Header"
    Header.BackgroundTransparency = 1
    Header.Position = UDim2.fromOffset(12,8)
    Header.Size = UDim2.new(1,-24,0,28)

    local HH = Instance.new("UIListLayout", Header)
    HH.FillDirection = Enum.FillDirection.Horizontal
    HH.HorizontalAlignment = Enum.HorizontalAlignment.Left
    HH.VerticalAlignment = Enum.VerticalAlignment.Center
    HH.Padding = UDim.new(0, 6)

    local HIcon = Instance.new("ImageLabel", Header)
    HIcon.BackgroundTransparency = 1
    HIcon.Size = UDim2.fromOffset(24,24)
    HIcon.Image = "rbxassetid://114530675624359"

    local HTxt = Instance.new("TextLabel", Header)
    HTxt.BackgroundTransparency = 1
    HTxt.Size = UDim2.new(1,0,1,0)
    HTxt.TextXAlignment = Enum.TextXAlignment.Left
    HTxt.TextYAlignment = Enum.TextYAlignment.Center
    HTxt.Font = Enum.Font.GothamBold
    HTxt.Text = "Player"
    HTxt.TextSize = 18
    HTxt.TextColor3 = TEXT_WHITE
end

--================= ระบบสถานะปุ่ม (ไม่ให้รู้สึกว่ากดจนกว่าจะกดจริง) =================

local UIS = game:GetService("UserInputService")
local TS  = game:GetService("TweenService")
local uiScale = Instance.new("UIScale", BtnPlayer)
uiScale.Scale = 1  -- ค่าเริ่มต้นปกติ (จะไม่มีอาการยุบ/เด้งจนกว่าจะกดจริง)

-- ธีมสี/เส้น สำหรับสถานะ
local NORMAL_BG   = BG_INNER                 -- ปกติ
local NORMAL_ST   = 0.35

local HOVER_BG    = Color3.fromRGB(24,24,24) -- โฮเวอร์ (PC เท่านั้น)
local HOVER_ST    = 0.15

local ACTIVE_BG   = Color3.fromRGB(30,30,30) -- ถูกเลือกอยู่ (กดแล้ว)
local ACTIVE_ST   = 0.05

-- เก็บสถานะ
BtnPlayer:SetAttribute("Selected", false)

local function applyVisual(btn, state) -- state: "normal" | "hover" | "active"
    if state == "active" then
        btn.BackgroundColor3 = ACTIVE_BG
        st.Transparency = ACTIVE_ST
        uiScale.Scale = 1
    elseif state == "hover" then
        btn.BackgroundColor3 = HOVER_BG
        st.Transparency = HOVER_ST
        uiScale.Scale = 1
    else
        btn.BackgroundColor3 = NORMAL_BG
        st.Transparency = NORMAL_ST
        uiScale.Scale = 1
    end
end

-- ตั้งต้นเป็นปกติ (ไม่ดูเหมือนถูกกด)
applyVisual(BtnPlayer, "normal")

-- โฮเวอร์เฉพาะ PC และเฉพาะตอนยังไม่ได้ถูกเลือก
BtnPlayer.MouseEnter:Connect(function()
    if not UIS.TouchEnabled and not BtnPlayer:GetAttribute("Selected") then
        applyVisual(BtnPlayer, "hover")
    end
end)
BtnPlayer.MouseLeave:Connect(function()
    if not BtnPlayer:GetAttribute("Selected") then
        applyVisual(BtnPlayer, "normal")
    end
end)

-- เอฟเฟกต์ “กดจริง” ตอนกดลง/ปล่อย (ทั้ง PC/มือถือ) แต่ไม่เปลี่ยนสถานะถาวรจนกว่าจะคลิกเสร็จ
BtnPlayer.MouseButton1Down:Connect(function()
    TS:Create(uiScale, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.97}):Play()
end)
BtnPlayer.MouseButton1Up:Connect(function()
    TS:Create(uiScale, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)
BtnPlayer.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        TS:Create(uiScale, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.97}):Play()
    end
end)
BtnPlayer.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        TS:Create(uiScale, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
end)

-- ฟังก์ชันยกเลิกปุ่มอื่น ๆ ในแถบซ้าย (เผื่อมีหลายปุ่มในอนาคต)
local function clearOtherSelections(exceptBtn)
    for _,b in ipairs(Left:GetChildren()) do
        if b:IsA("TextButton") and b ~= exceptBtn then
            b:SetAttribute("Selected", false)
            -- รีหน้าตาเป็น normal
            local s = b:FindFirstChildOfClass("UIStroke")
            if s then s.Transparency = NORMAL_ST end
            b.BackgroundColor3 = NORMAL_BG
            local sc = b:FindFirstChildOfClass("UIScale")
            if sc then sc.Scale = 1 end
        end
    end
end

-- คลิกเพื่อ “เลือก” ปุ่มนี้ และโชว์หน้า Player
BtnPlayer.MouseButton1Click:Connect(function()
    clearOtherSelections(BtnPlayer)
    BtnPlayer:SetAttribute("Selected", true)
    applyVisual(BtnPlayer, "active")

    -- ซ่อนหน้าขวาอื่น ๆ แล้วโชว์หน้า Player
    for _,child in ipairs(Right:GetChildren()) do
        if child:IsA("Frame") then child.Visible = false end
    end
    PlayerPage.Visible = true
end)
