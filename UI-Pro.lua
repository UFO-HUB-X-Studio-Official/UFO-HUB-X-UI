--== UFO Hub X • Toast chain (2-step) ==--

pcall(function()
    local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _,n in ipairs({"UFO_Toast_Test","UFO_Toast_Test_2"}) do
        local g = pg:FindFirstChild(n); if g then g:Destroy() end
    end
end)

-- ===== CONFIG (คงพารามิเตอร์เดิมที่จูนไว้) =====
local EDGE_RIGHT_PAD  = 2
local EDGE_BOTTOM_PAD = 2
local TOAST_W, TOAST_H = 320, 86
local RADIUS, STROKE_TH = 10, 2
local GREEN = Color3.fromRGB(0,255,140)
local BLACK = Color3.fromRGB(10,10,10)

local LOGO_STEP1 = "rbxassetid://89004973470552"   -- อันแรก (มีหลอด)
local LOGO_STEP2 = "rbxassetid://83753985156201"   -- อันที่สอง (ไม่มีหลอด)

local TITLE_TOP = 12
local MSG_TOP   = 34
local BAR_LEFT  = 68
local BAR_RIGHT_PAD = 12
local BAR_H     = 10
local LOAD_TIME = 2.2 -- ระยะเวลา progress รวม

local TS = game:GetService("TweenService")
local RunS = game:GetService("RunService")
local Players = game:GetService("Players")
local PG = Players.LocalPlayer:WaitForChild("PlayerGui")

local function tween(inst, ti, ease, dir, props)
    return TS:Create(inst, TweenInfo.new(ti, ease or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function makeToastGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.Parent = PG
    return gui
end

local function buildBox(parent)
    local box = Instance.new("Frame")
    box.Name = "Toast"
    box.AnchorPoint = Vector2.new(1,1)
    box.Position = UDim2.new(1, -EDGE_RIGHT_PAD, 1, -(EDGE_BOTTOM_PAD - 24)) -- เริ่มต่ำกว่าเล็กน้อย
    box.Size = UDim2.fromOffset(TOAST_W, TOAST_H)
    box.BackgroundColor3 = BLACK
    box.BorderSizePixel = 0
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, RADIUS)
    local stroke = Instance.new("UIStroke", box)
    stroke.Thickness = STROKE_TH
    stroke.Color = GREEN
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    return box
end

local function buildTitle(box)
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.RichText = true
    title.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(235,235,235)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.fromOffset(68, TITLE_TOP)
    title.Size = UDim2.fromOffset(TOAST_W - 78, 20)
    title.Parent = box
    return title
end

local function buildMsg(box, text)
    local msg = Instance.new("TextLabel")
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.Gotham
    msg.Text = text
    msg.TextSize = 13
    msg.TextColor3 = Color3.fromRGB(200,200,200)
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Position = UDim2.fromOffset(68, MSG_TOP)
    msg.Size = UDim2.fromOffset(TOAST_W - 78, 18)
    msg.Parent = box
    return msg
end

local function buildLogo(box, imageId)
    local logo = Instance.new("ImageLabel")
    logo.BackgroundTransparency = 1
    logo.Image = imageId
    logo.Size = UDim2.fromOffset(54, 54)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.Position = UDim2.new(0, 8, 0.5, -2) -- ขยับขึ้นนิดให้กึ่งกลางขึ้นอีกนิด
    logo.Parent = box
    return logo
end

--== Step 1: มี progress bar ==--
local gui1 = makeToastGui("UFO_Toast_Test")
local box1 = buildBox(gui1)
buildLogo(box1, LOGO_STEP1)
buildTitle(box1)
local msg1 = buildMsg(box1, "Initializing... please wait")

-- progress bar
local barWidth = TOAST_W - BAR_LEFT - BAR_RIGHT_PAD
local track = Instance.new("Frame")
track.BackgroundColor3 = Color3.fromRGB(25,25,25)
track.BorderSizePixel = 0
track.Position = UDim2.fromOffset(BAR_LEFT, TOAST_H - (BAR_H + 12))
track.Size = UDim2.fromOffset(barWidth, BAR_H)
track.Parent = box1
Instance.new("UICorner", track).CornerRadius = UDim.new(0, BAR_H // 2)

local fill = Instance.new("Frame")
fill.BackgroundColor3 = GREEN
fill.BorderSizePixel = 0
fill.Size = UDim2.fromOffset(0, BAR_H)
fill.Parent = track
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, BAR_H // 2)

local pct = Instance.new("TextLabel")
pct.BackgroundTransparency = 1
pct.Font = Enum.Font.GothamBold
pct.TextSize = 12
pct.TextColor3 = Color3.new(1,1,1)
pct.TextStrokeTransparency = 0.15
pct.TextStrokeColor3 = Color3.new(0,0,0)
pct.TextXAlignment = Enum.TextXAlignment.Center
pct.TextYAlignment = Enum.TextYAlignment.Center
pct.AnchorPoint = Vector2.new(0.5,0.5)
pct.Position = UDim2.fromScale(0.5,0.5)
pct.Size = UDim2.fromScale(1,1)
pct.Text = "0%"
pct.ZIndex = 20
pct.Parent = track

-- slide in (นุ่ม)
tween(box1, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {Position = UDim2.new(1, -EDGE_RIGHT_PAD, 1, -EDGE_BOTTOM_PAD)}):Play()

task.spawn(function()
    local t0 = time()
    local progress = 0
    while progress < 100 do
        progress = math.clamp(math.floor(((time() - t0)/LOAD_TIME)*100 + 0.5), 0, 100)
        fill.Size = UDim2.fromOffset(math.floor(barWidth*(progress/100)), BAR_H)
        pct.Text = progress .. "%"
        RunS.Heartbeat:Wait()
    end
    msg1.Text = "Loaded successfully."
    task.wait(0.35)

    -- slide out นุ่มขึ้น (Quint InOut)
    local out1 = tween(box1, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut,
        {Position = UDim2.new(1, -EDGE_RIGHT_PAD, 1, -(EDGE_BOTTOM_PAD - 24))})
    out1:Play()
    out1.Completed:Wait()
    gui1:Destroy()

    --== Step 2: Toast แจ้งเสร็จสิ้น (ไม่มี progress) ==--
    local gui2 = makeToastGui("UFO_Toast_Test_2")
    local box2 = buildBox(gui2)
    buildLogo(box2, LOGO_STEP2)
    buildTitle(box2)
    buildMsg(box2, "Download UI completed. ✅")

    -- slide in
    tween(box2, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out,
        {Position = UDim2.new(1, -EDGE_RIGHT_PAD, 1, -EDGE_BOTTOM_PAD)}):Play()

    -- >>> ถ้ามีฟังก์ชันเปิด UI หลัก ให้ผูกตรงนี้ <<<
    -- if _G.UFO_ShowMainUI then _G.UFO_ShowMainUI() end

    -- ค้างโชว์สักพักแล้วค่อยเลื่อนลงหาย
    task.wait(1.6)
    local out2 = tween(box2, 0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut,
        {Position = UDim2.new(1, -EDGE_RIGHT_PAD, 1, -(EDGE_BOTTOM_PAD - 24))})
    out2:Play()
    out2.Completed:Wait()
    gui2:Destroy()
end)
