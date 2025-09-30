--==========================================================
-- UFO HUB X • tuned layout (title higher, UFO lower)
-- (Full file with AFK Always-On integrated)
--==========================================================

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
BtnClose.MouseButton1Click:Connect(function() GUI.Enabled = false end)

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

-- ===== UFO + TITLE (ปรับตามคำขอ) =====
do
    local UFO_Y_OFFSET   = 84  -- ⬇️ ยานลงมาใกล้กรอบ
    local TITLE_Y_OFFSET = 8   -- ⬆️ ชื่อขึ้นไปอีกนิด

    -- UFO
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

    -- TITLE
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

-- toggle show/hide (RightShift)
do local vis=true
    UIS.InputBegan:Connect(function(i,gp)
        if not gp and i.KeyCode==Enum.KeyCode.RightShift then vis=not vis; GUI.Enabled=vis end
    end)
end

--==========================================================
-- AFK SHIELD (Always-On) • ทำงานแม้ปิด/ซ่อน UI • ตลอดที่อยู่ในเกม
--==========================================================
do
    local Players            = game:GetService("Players")
    local UserInputService   = game:GetService("UserInputService")
    local LocalPlayer        = Players.LocalPlayer
    local VirtualUser        = game:GetService("VirtualUser")

    -- ป้องกันโหลดซ้ำ / cleanup คอนเนกชันเดิมถ้ามี
    getgenv().UFO_AFK_SHIELD = getgenv().UFO_AFK_SHIELD or {}
    local Shield = getgenv().UFO_AFK_SHIELD

    if Shield.conn then pcall(function() Shield.conn:Disconnect() end) end
    if Shield.keepaliveLoop then Shield.keepaliveLoop = false end

    Shield.enabled = true

    -- เมื่อ Roblox มองว่า Idle → ส่งอินพุตจำลองปลุกทันที (เบา/ไม่รบกวน)
    Shield.conn = LocalPlayer.Idled:Connect(function()
        if Shield.enabled then
            VirtualUser:CaptureController()
            local cam = workspace.CurrentCamera
            local pos = cam and cam.CFrame.Position or Vector3.new()
            VirtualUser:ClickButton2(Vector2.new(0,0), CFrame.new(pos))
        end
    end)

    -- ติดตามอินพุตจริงจากผู้เล่น เพื่อไม่แทรกตอนเล่นอยู่
    local lastRealInput = os.clock()
    UserInputService.InputBegan:Connect(function() lastRealInput = os.clock() end)
    UserInputService.InputChanged:Connect(function() lastRealInput = os.clock() end)

    -- ประกันเพิ่ม: ถ้าเงียบเกิน ~9 นาที ให้สะกิดเอง 1 ครั้ง
    Shield.keepaliveLoop = true
    task.spawn(function()
        while Shield.keepaliveLoop and Shield.enabled do
            task.wait(30) -- เช็คทุก 30 วิ (ภาระต่ำ)
            if os.clock() - lastRealInput > 540 then -- ~9 นาที
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
-- END
--==========================================================
--==========================================================
-- UFO POP-IN/OUT ANIM (วางท้ายไฟล์ หลังสร้าง GUI/Window)
--==========================================================
do
    local TS   = game:GetService("TweenService")
    local UIS  = game:GetService("UserInputService")
    local CGui = game:GetService("CoreGui")

    local GUI = CGui:FindFirstChild("UFO_HUB_X_UI")
    if not GUI then return end

    local Window = GUI:FindFirstChildWhichIsA("Frame")
    if not Window then return end

    local UIScale = Window:FindFirstChildOfClass("UIScale")
    if not UIScale then UIScale = Instance.new("UIScale", Window); UIScale.Scale = 1 end

    local stateVisible = Window.Visible ~= false
    local animBusy = false

    local function makeUFO()
        task.wait()
        local p, s = Window.AbsolutePosition, Window.AbsoluteSize
        local cx, cy = p.X + s.X/2, p.Y + s.Y/2

        local u = Instance.new("ImageLabel")
        u.Image = "rbxassetid://140388309537044"
        u.BackgroundTransparency = 1
        u.ZIndex = 999
        u.AnchorPoint = Vector2.new(0.5,0.5)
        u.Position = UDim2.fromOffset(cx, cy)
        u.Size = UDim2.fromOffset(40,40)
        u.ImageTransparency = 1
        u.Parent = GUI
        return u
    end

    local function tween(obj, t, goal)
        local tw = TS:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
        tw:Play(); tw.Completed:Wait()
    end

    local function showWithUFO()
        if animBusy or stateVisible then return end
        animBusy = true
        local u = makeUFO()
        tween(u,0.2,{ImageTransparency=0.1,Size=UDim2.fromOffset(220,220)})
        Window.Visible = true
        Window.GroupTransparency = 1
        tween(Window,0.25,{GroupTransparency=0})
        tween(u,0.15,{ImageTransparency=1})
        u:Destroy()
        stateVisible = true
        animBusy = false
    end

    local function hideWithUFO()
        if animBusy or not stateVisible then return end
        animBusy = true
        local u = makeUFO()
        tween(u,0.15,{ImageTransparency=0.1,Size=UDim2.fromOffset(160,160)})
        tween(Window,0.2,{GroupTransparency=1})
        Window.Visible = false
        tween(u,0.15,{ImageTransparency=1})
        u:Destroy()
        stateVisible = false
        animBusy = false
    end

    -- Hook ปุ่ม X
    for _,o in ipairs(Window:GetDescendants()) do
        if o:IsA("TextButton") and o.Text:upper()=="X" then
            o.MouseButton1Click:Connect(function()
                if stateVisible then hideWithUFO() end
            end)
        end
    end

    -- Hook RightShift
    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.RightShift then
            if stateVisible then hideWithUFO() else showWithUFO() end
        end
    end)

    -- โชว์ครั้งแรก
    task.defer(function()
        if stateVisible then
            Window.Visible = false
            showWithUFO()
        end
    end)
end
--==========================================================
-- UFO HUB X • Toggle + Persist + Smart Default Gap
--==========================================================
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local Http    = game:GetService("HttpService")

-- หา GUI/Window หลัก
local MAIN_GUI = CoreGui:FindFirstChild("UFO_HUB_X_UI")
if not MAIN_GUI then return end

local WINDOW do
    for _,o in ipairs(MAIN_GUI:GetChildren()) do
        if o:IsA("Frame") then WINDOW = o break end
    end
end
if not WINDOW then return end

-- แก้ปุ่ม X ให้ซ่อนเฉพาะหน้าต่าง
local function patchCloseButton(root)
    for _,o in ipairs(root:GetDescendants()) do
        if o:IsA("TextButton") and o.Text and o.Text:upper()=="X" then
            o.MouseButton1Click:Connect(function()
                WINDOW.Visible = false
            end)
        end
    end
end
patchCloseButton(MAIN_GUI)

-- กันภาพอมเขียว
for _,o in ipairs(MAIN_GUI:GetDescendants()) do
    if o:IsA("ImageLabel") or o:IsA("ImageButton") then
        o.ImageColor3 = Color3.new(1,1,1)
    end
end

-- Toggle GUI ใหม่
local OLD = CoreGui:FindFirstChild("UFO_HUB_X_Toggle")
if OLD then OLD:Destroy() end

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "UFO_HUB_X_Toggle"
ToggleGui.IgnoreGuiInset = true
ToggleGui.ResetOnSpawn   = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.Parent = CoreGui

-- ---------- Persist helpers ----------
local FILE = "UFO_HUB_X_Toggle.json"
local function canFS()
    return (typeof(writefile)=="function" and typeof(readfile)=="function" and typeof(isfile)=="function")
end
local function loadPos()
    if canFS() and isfile(FILE) then
        local ok, data = pcall(function() return Http:JSONDecode(readfile(FILE)) end)
        if ok and typeof(data)=="table" and data.x and data.y then
            return data.x, data.y, true -- true = loaded
        end
    elseif getgenv then
        local g = getgenv()
        if g.__UFO_TOGGLE_POS then
            return g.__UFO_TOGGLE_POS.x, g.__UFO_TOGGLE_POS.y, true
        end
    end
    return nil, nil, false
end
local function savePos(x,y)
    if canFS() then
        pcall(function() writefile(FILE, Http:JSONEncode({x=x,y=y})) end)
    elseif getgenv then
        getgenv().__UFO_TOGGLE_POS = {x=x,y=y}
    end
end

-- ---------- Smart default placement (ไม่ชิด UI) ----------
local BTN_W, BTN_H = 64, 64
local GAP = 48 -- ระยะห่างขั้นต่ำจากกรอบ UI (ปรับได้)
local function viewport()
    local cam = workspace.CurrentCamera
    local v = cam and cam.ViewportSize or Vector2.new(1920,1080)
    return v.X, v.Y
end
local function clamp(x,y)
    local vx, vy = viewport()
    x = math.clamp(x, 0, vx - BTN_W)
    y = math.clamp(y, 0, vy - BTN_H)
    return x, y
end

-- อ่านตำแหน่งที่เคยบันทึกไว้
local px, py, loaded = loadPos()

-- คำนวณเริ่มต้นแบบฉลาด (ถ้าไม่มีตำแหน่งเดิม)
if not loaded then
    -- ใช้ตำแหน่งจริงของหน้าต่าง
    task.wait() -- ให้ AbsolutePosition/Size อัปเดต
    local winPos = WINDOW.AbsolutePosition
    local winSize = WINDOW.AbsoluteSize
    -- วาง “ซ้ายมือของหน้าต่าง” และเลื่อนลงมานิดให้ดูสวย
    px = (winPos.X - BTN_W - GAP)
    py = (winPos.Y + math.floor(winSize.Y*0.15))
    px, py = clamp(px, py)
end

-- ---------- สร้างปุ่ม ----------
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "ToggleUI"
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
ToggleBtn.BorderSizePixel  = 0
ToggleBtn.Size     = UDim2.new(0, BTN_W, 0, BTN_H)
ToggleBtn.Position = UDim2.new(0, px, 0, py)
ToggleBtn.Image    = "rbxassetid://117052960049460"
ToggleBtn.ImageColor3 = Color3.new(1,1,1)
ToggleBtn.AutoButtonColor = false

local corner = Instance.new("UICorner", ToggleBtn)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", ToggleBtn)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0,255,140)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.LineJoinMode    = Enum.LineJoinMode.Round

ToggleBtn.MouseEnter:Connect(function() stroke.Thickness = 3 end)
ToggleBtn.MouseLeave:Connect(function() stroke.Thickness = 2 end)

-- กด -> Toggle เฉพาะ WINDOW
ToggleBtn.MouseButton1Click:Connect(function()
    WINDOW.Visible = not WINDOW.Visible
end)

-- คีย์ลัด RightShift -> Toggle
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        WINDOW.Visible = not WINDOW.Visible
    end
end)

-- ลากได้ + บันทึก
do
    local dragging = false
    local startPos, startMouse
    ToggleBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos   = Vector2.new(ToggleBtn.Position.X.Offset, ToggleBtn.Position.Y.Offset)
            startMouse = i.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    savePos(ToggleBtn.Position.X.Offset, ToggleBtn.Position.Y.Offset)
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - startMouse
            local nx, ny = clamp(startPos.X + delta.X, startPos.Y + delta.Y)
            ToggleBtn.Position = UDim2.new(0, nx, 0, ny)
        end
    end)
end
--==========================================================
-- END
--==========================================================
