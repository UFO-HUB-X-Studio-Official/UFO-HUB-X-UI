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
-- RIGHT HEADER: ป้าย "Player" มุมซ้ายบนของกรอบ Right (ทับรูป)
----------------------------------------------------------------
do
    local header = Right:FindFirstChild("RightHeader")
    if not header then
        header = Instance.new("Frame")
        header.Name = "RightHeader"
        header.Parent = Right
        header.BackgroundColor3 = (BG_INNER or Color3.fromRGB(22,22,22))
        header.BorderSizePixel = 0
        header.ZIndex = 30
        header.Position = UDim2.new(0, 12, 0, 10)   -- ระยะจากมุมซ้ายบนของ Right
        header.Size     = UDim2.new(0, 140, 0, 32)

        -- ขอบมน + เส้นเรือง
        if typeof(corner) == "function" then corner(header, 10) end
        if typeof(stroke) == "function" then stroke(header, 1, (MINT or Color3.fromRGB(0,255,140)), 0.35) end

        -- ไอคอนจุดเขียว (แทนรูปคนเล็ก ๆ)
        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.Parent = header
        dot.BackgroundColor3 = (GREEN or Color3.fromRGB(0, 255, 140))
        dot.BorderSizePixel = 0
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.Position = UDim2.new(0, 9, 0.5, 0)
        dot.Size = UDim2.new(0, 10, 0, 10)
        dot.ZIndex = 31
        if typeof(corner) == "function" then corner(dot, 6) end

        -- ข้อความ "Player"
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Parent = header
        title.BackgroundTransparency = 1
        title.AnchorPoint = Vector2.new(0, 0.5)
        title.Position = UDim2.new(0, 26, 0.5, 0)
        title.Size = UDim2.new(1, -30, 1, -6)
        title.Text = "Player"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.TextColor3 = (TEXT_WHITE or Color3.fromRGB(255,255,255))
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 31
    end
end

----------------------------------------------------------------
-- TAB / BUTTON EFFECT: ทำให้ BtnPlayer มีเอฟเฟกต์กด + Active state
----------------------------------------------------------------
do
    -- สีปุ่มตอนปกติ / ตอน Active / ตอนกดค้าง
    local COLOR_IDLE   = (BG_INNER or Color3.fromRGB(22,22,22))
    local COLOR_ACTIVE = Color3.fromRGB(34,34,34)
    local COLOR_DOWN   = Color3.fromRGB(18,18,18)

    -- ถ้าปุ่มถูกสร้างไว้แล้ว ให้ตั้งค่ามาตรฐาน
    if BtnPlayer and BtnPlayer:IsA("TextButton") then
        BtnPlayer.AutoButtonColor = false
        BtnPlayer.BackgroundColor3 = COLOR_IDLE
        BtnPlayer.TextColor3 = (TEXT_WHITE or Color3.fromRGB(255,255,255))
        BtnPlayer.ZIndex = 20

        -- ปรับเส้นขอบของปุ่ม (ถ้ามี helper)
        if typeof(stroke) == "function" then
            -- ลบ UIStroke เดิมซ้ำซ้อน (กันหนาเกิน)
            for _,c in ipairs(BtnPlayer:GetChildren()) do
                if c:IsA("UIStroke") then c:Destroy() end
            end
            stroke(BtnPlayer, 1, (MINT or Color3.fromRGB(0,255,140)), 0.35)
        end
    end

    -- เก็บกลุ่มแท็บเผื่ออนาคต (ตอนนี้มีหน้าเดียว)
    local Tabs = {
        { btn = BtnPlayer, page = PlayerPage }
        -- ถ้ามีแท็บอื่นก็ใส่เพิ่มได้แบบนี้:
        -- { btn = BtnInventory, page = InventoryPage },
        -- { btn = BtnSettings,  page = SettingsPage  },
    }

    local function styleTab(tab, active)
        if not (tab and tab.btn and tab.page) then return end
        tab.page.Visible = active

        -- ปรับสีให้รู้ว่ากำลังอยู่แท็บนี้
        if active then
            tab.btn.BackgroundColor3 = COLOR_ACTIVE
            -- เน้นเส้นขอบตอน Active
            local strokeObj = tab.btn:FindFirstChildOfClass("UIStroke")
            if strokeObj then strokeObj.Transparency = 0.15 end
        else
            tab.btn.BackgroundColor3 = COLOR_IDLE
            local strokeObj = tab.btn:FindFirstChildOfClass("UIStroke")
            if strokeObj then strokeObj.Transparency = 0.35 end
        end
    end

    local function setActive(which)
        for i,tab in ipairs(Tabs) do
            styleTab(tab, i == which)
        end
    end

    -- เอฟเฟกต์ตอนกดค้าง (กดลง/ปล่อย/เมาส์ออก)
    local function attachPressEffect(btn, index)
        if not btn then return end
        btn.InputBegan:Connect(function(io)
            if io.UserInputType == Enum.UserInputType.MouseButton1
            or io.UserInputType == Enum.UserInputType.Touch then
                btn.BackgroundColor3 = COLOR_DOWN
            end
        end)
        btn.InputEnded:Connect(function(io)
            if io.UserInputType == Enum.UserInputType.MouseButton1
            or io.UserInputType == Enum.UserInputType.Touch then
                setActive(index)  -- เลือกแท็บนี้เป็น Active
            end
        end)
        btn.MouseLeave:Connect(function()
            -- กลับไปตามสถานะปัจจุบัน (Active/Idle)
            -- ดูว่าแท็บนี้ Active อยู่ไหม
            local isActive = btn.BackgroundColor3 == COLOR_DOWN
            -- ป้องกันกลับผิดสีด้วยการรีเซ็ตตาม setActive อีกครั้ง
            for i,tab in ipairs(Tabs) do
                if tab.btn == btn then
                    -- ใช้ค่า Visible ของ page เป็นตัวตัดสิน
                    isActive = tab.page.Visible
                    break
                end
            end
            btn.BackgroundColor3 = isActive and COLOR_ACTIVE or COLOR_IDLE
        end)
        btn.MouseEnter:Connect(function()
            -- hover เล็ก ๆ (ถ้าอยากได้)
        end)
        btn.MouseButton1Click:Connect(function()
            setActive(index)
        end)
    end

    -- ผูกทุกแท็บ
    for i,tab in ipairs(Tabs) do
        attachPressEffect(tab.btn, i)
    end

    -- ค่าเริ่มต้น: เปิดหน้า Player เป็นแท็บแอคทีฟ
    setActive(1)
end
