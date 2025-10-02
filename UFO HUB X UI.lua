--==========================================================
-- UFO HUB X • tuned layout (title higher, UFO lower)
-- (Full file with AFK Always-On integrated + BUGFIXED TOGGLES)
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

-- ✅ PATCH: ปุ่ม X ซ่อนเฉพาะ Window (ไม่ปิดทั้ง GUI)
BtnClose.MouseButton1Click:Connect(function()
    Window.Visible = false
end)

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

-- 🧹 (ลบ toggle เดิมที่ใช้ GUI.Enabled ออกแล้ว เพื่อกันชน)

--==========================================================
-- AFK SHIELD (Always-On) • ทำงานแม้ปิด/ซ่อน UI • ตลอดที่อยู่ในเกม
--==========================================================
do
    local Players            = game:GetService("Players")
    local UserInputService   = game:GetService("UserInputService")
    local LocalPlayer        = Players.LocalPlayer
    local VirtualUser        = game:GetService("VirtualUser")

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
-- UFO HUB X • Toggle + Persist + Smart Default Gap (BUGFIXED)
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

-- แก้ปุ่ม X ให้ซ่อนเฉพาะหน้าต่าง (เผื่อมี TextButton X อื่น ๆ)
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

-- ทำลายปุ่ม Toggle เก่าถ้ามี
local OLD = CoreGui:FindFirstChild("UFO_HUB_X_Toggle")
if OLD then OLD:Destroy() end

-- ---------- Persist helpers ----------
local FILE = "UFO_HUB_X_Toggle.json"
local function canFS()
    return (typeof(writefile)=="function" and typeof(readfile)=="function" and typeof(isfile)=="function")
end
local function loadPos()
    if canFS() and isfile(FILE) then
        local ok, data = pcall(function() return Http:JSONDecode(readfile(FILE)) end)
        if ok and typeof(data)=="table" and data.x and data.y then
            return data.x, data.y, true
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

-- ---------- Smart default placement ----------
local BTN_W, BTN_H = 64, 64
local GAP = 48
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

-- คำนวณเริ่มต้นถ้าไม่มีตำแหน่งเดิม
if not loaded then
    task.wait()
    local winPos = WINDOW.AbsolutePosition
    local winSize = WINDOW.AbsoluteSize
    px = (winPos.X - BTN_W - GAP)
    py = (winPos.Y + math.floor(winSize.Y*0.15))
    px, py = clamp(px, py)
end

-- ---------- สร้างปุ่ม Toggle ----------
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "UFO_HUB_X_Toggle"
ToggleGui.IgnoreGuiInset = true
ToggleGui.ResetOnSpawn   = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.Parent = CoreGui

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
corner(ToggleBtn, 8)

local stroke = Instance.new("UIStroke", ToggleBtn)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0,255,140)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.LineJoinMode    = Enum.LineJoinMode.Round

ToggleBtn.MouseEnter:Connect(function() stroke.Thickness = 3 end)
ToggleBtn.MouseLeave:Connect(function() stroke.Thickness = 2 end)

-- ✅ PATCH: ปุ่มสี่เหลี่ยมต้องบังคับเปิด GUI ก่อน แล้วค่อยสลับ Window
ToggleBtn.MouseButton1Click:Connect(function()
    MAIN_GUI.Enabled = true
    Window.Visible = not Window.Visible
end)

-- ✅ PATCH: RightShift ก็เช่นกัน
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MAIN_GUI.Enabled = true
        Window.Visible = not Window.Visible
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
--==========================================================
-- UFO_RECOVERY_PATCH • บังคับเปิด GUI + ซ่อน/โชว์ได้เสมอ
-- วาง "ท้ายไฟล์" นี้เสมอ
--==========================================================
do
    local CoreGui = game:GetService("CoreGui")
    local UIS     = game:GetService("UserInputService")

    -- locate gui + window every time (กันกรณีถูกสร้างใหม่/เปลี่ยนพ่อ)
    local function findMain()
        local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
        if not gui then
            for _,g in ipairs(CoreGui:GetChildren()) do
                if g:IsA("ScreenGui") and g.Name:lower():find("ufo_hub_x_ui") then gui = g break end
            end
        end
        local win
        if gui then
            for _,o in ipairs(gui:GetChildren()) do
                if o:IsA("Frame") then win = o break end
            end
            if not win then win = gui:FindFirstChildWhichIsA("Frame") end
        end
        return gui, win
    end

    local function forceEnable(gui)
        if not gui then return end
        -- ยิงเปิดซ้ำหลายเฟรมเพื่อ “ชนะ” handler อื่นที่เพิ่งปิด
        for _=1,5 do
            gui.Enabled = true
            task.wait(0.02)
        end
        -- ดันขึ้นบนสุดเผื่อโดนซ่อนหลัง UI อื่น
        pcall(function() gui.DisplayOrder = 1_000_000 end)
    end

    local function forceShow()
        local gui, win = findMain()
        if not gui then return end
        forceEnable(gui)
        if not win then
            -- พยายามหาอีกครั้งหลังเปิด
            task.wait()
            _, win = findMain()
        end
        if win then
            win.Visible = true
            if win.GroupTransparency ~= nil then
                win.GroupTransparency = 0
            end
        end
    end

    local function softHide()
        local gui, win = findMain()
        if win then win.Visible = false end
        -- กันโดนปิดทั้ง GUI จาก handler อื่น: รี-enable ในเฟรมถัดไป
        task.defer(function()
            local g = select(1, findMain())
            if g then g.Enabled = true end
        end)
    end

    -- แพตช์ปุ่ม X ทั้งหมดให้ซ่อนเฉพาะ Window
    local function patchX()
        local gui, win = findMain()
        if not gui then return end
        for _,o in ipairs(gui:GetDescendants()) do
            if o:IsA("TextButton") and o.Text and o.Text:upper()=="X" and not o:GetAttribute("UFO_X_PATCHED") then
                o:SetAttribute("UFO_X_PATCHED", true)
                o.MouseButton1Click:Connect(softHide)
            end
        end
    end
    patchX()
    -- เผื่อ UI มีการรีเฟรช สแกนซ้ำเป็นระยะสั้น ๆ
    task.spawn(function()
        while task.wait(0.5) do
            patchX()
        end
    end)

    -- ==== Hook ปุ่มสี่เหลี่ยม (ถ้ามี), ถ้าไม่มีไม่เป็นไร ====
    local function hookToggleButton()
        local toggleGui = CoreGui:FindFirstChild("UFO_HUB_X_Toggle")
        if not toggleGui then return end
        local btn = toggleGui:FindFirstChild("ToggleUI", true)
        if not (btn and btn:IsA("ImageButton")) then return end
        if btn:GetAttribute("UFO_TGL_PATCHED") then return end
        btn:SetAttribute("UFO_TGL_PATCHED", true)
        btn.MouseButton1Click:Connect(function()
            local _, win = findMain()
            local willShow = not (win and win.Visible)
            if willShow then
                forceShow()
            else
                softHide()
            end
        end)
    end
    hookToggleButton()
    task.spawn(function()
        while task.wait(0.5) do
            hookToggleButton()
        end
    end)

    -- ==== RightShift ====
    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            local _, win = findMain()
            if win and win.Visible then
                softHide()
            else
                forceShow()
            end
        end
    end)
end
