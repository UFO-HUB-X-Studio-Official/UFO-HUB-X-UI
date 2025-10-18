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
--== UFO HUB X • Adapter API (keep our UI 100%, use "popular-lib" style system) ==--

-- prerequisites: หน้าต่างหลักของคุณต้องสร้างแล้ว และมีโหนดเหล่านี้:
-- CoreGui/UFO_HUB_X_UI/Window/.../LeftScroll (เมนูซ้าย), RightScroll (คอนเทนต์ขวา)
-- ถ้าใช้สคริปต์ UI-Pro ของคุณอยู่แล้ว โหนดเหล่านี้มีครบ

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

local GUI = CoreGui:WaitForChild("UFO_HUB_X_UI", 10)
assert(GUI, "UFO HUB X: window not found. Run your UI first.")

local Window = GUI:FindFirstChildWhichIsA("Frame") or error("UFO HUB X: Frame not found.")
local LeftScroll  = Window:FindFirstChild("LeftScroll", true)  or error("LeftScroll missing")
local RightScroll = Window:FindFirstChild("RightScroll", true) or error("RightScroll missing")

-- ===== helpers (รูปลักษณ์คงเดิม) =====
local GREEN = Color3.fromRGB(0,255,140)
local MINT  = Color3.fromRGB(90,210,190)
local TEXT  = Color3.fromRGB(235,235,235)
local BG    = Color3.fromRGB(16,16,16)

local function corner(p, r) local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, r or 8); return c end
local function stroke(p, th, col, tr)
    local s = Instance.new("UIStroke", p)
    s.Thickness = th or 1; s.Color = col or MINT; s.Transparency = tr or 0.35
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end
local function vpad(parent, px)
    local pad = parent:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding", parent)
    pad.PaddingTop = UDim.new(0, px); pad.PaddingBottom = UDim.new(0, px); pad.PaddingLeft = UDim.new(0, px); pad.PaddingRight = UDim.new(0, px)
end
local function makeList(parent, gap)
    local l = parent:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", parent)
    l.Padding = UDim.new(0, gap or 8); l.SortOrder = Enum.SortOrder.LayoutOrder
    return l
end

-- =============== Adapter object (สไตล์ Linoria/Kavo) ===============
local Lib = {}
Lib.__index = Lib

local Tabs = {}        -- name -> {Button, Page}
local Current = nil    -- ชื่อแท็บปัจจุบัน
local Saves = {Data = {}}

-- =============== SaveManager (พื้นฐาน, ไม่พึ่งไฟล์) ===============
function Saves:Set(key, val) self.Data[key] = val end
function Saves:Get(key, def) local v = self.Data[key]; if v == nil then return def end; return v end
function Saves:Export() return HttpService:JSONEncode(self.Data) end
function Saves:Import(json) local ok, t = pcall(HttpService.JSONDecode, HttpService, json); if ok and typeof(t)=="table" then self.Data = t end end
Lib.SaveManager = Saves

-- =============== Tabs ===============
function Lib:CreateTab(tabName, iconId)
    assert(not Tabs[tabName], "duplicate tab: "..tabName)

    -- ปุ่มซ้าย (หน้าตาเหมือนของเรา)
    local BTN_H = 44
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_"..tabName
    btn.Parent = LeftScroll
    btn.Size = UDim2.new(1,0,0,BTN_H)
    btn.BackgroundColor3 = BG
    btn.AutoButtonColor = false
    btn.Text = ""
    corner(btn, 8)
    local st = stroke(btn, 1, MINT, 0.35)

    if iconId then
        local ico = Instance.new("ImageLabel", btn)
        ico.BackgroundTransparency = 1
        ico.Image = iconId
        ico.Size = UDim2.fromOffset(BTN_H-10, BTN_H-10)
        ico.Position = UDim2.new(0,8,0.5,-(BTN_H-10)/2)
    end

    local lbl = Instance.new("TextLabel", btn)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, BTN_H+4, 0, 0)
    lbl.Size = UDim2.new(1, -(BTN_H+12), 1, 0)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = TEXT
    lbl.Text = tabName

    -- หน้าคอนเทนต์ขวา
    local page = Instance.new("Frame")
    page.Name = "Page_"..tabName
    page.Size = UDim2.fromScale(1,0) -- สูงอัตโนมัติผ่าน ScrollingFrame
    page.BackgroundTransparency = 1
    page.Visible = false

    -- กล่องใส่คอนโทรลจริง (วางใน RightScroll)
    local pageHost = Instance.new("Frame", RightScroll)
    pageHost.Name = "Host_"..tabName
    pageHost.BackgroundTransparency = 1
    pageHost.Size = UDim2.fromScale(1,0)
    pageHost.Visible = false

    -- list ใน host
    makeList(pageHost, 8); vpad(pageHost, 8)

    local function setActive(on)
        if on then
            btn.BackgroundColor3 = Color3.fromRGB(22,30,24)
            st.Color = GREEN; st.Thickness = 2; st.Transparency = 0
        else
            btn.BackgroundColor3 = BG
            st.Color = MINT; st.Thickness = 1; st.Transparency = 0.35
        end
    end

    btn.MouseButton1Click:Connect(function()
        for name, t in pairs(Tabs) do
            t.Page.Visible = false
            t.Host.Visible = false
            t.SetActive(false)
        end
        page.Visible = true
        pageHost.Visible = true
        setActive(true)
        Current = tabName
    end)

    Tabs[tabName] = {Button = btn, Page = page, Host = pageHost, SetActive = setActive}
    if not Current then btn:Activate() btn.MouseButton1Click:Fire() end

    -- คืน object แท็บมี method เพิ่มคอนโทรล
    local TabObj = {}
    TabObj.__index = TabObj

    local function addRow(height)
        local row = Instance.new("Frame", pageHost)
        row.BackgroundColor3 = Color3.fromRGB(18,18,18)
        row.Size = UDim2.new(1,0,0,height or 44)
        row.BorderSizePixel = 0
        corner(row, 8); stroke(row,1,Color3.fromRGB(0,255,140),0.12)
        return row
    end

    function TabObj:AddLabel(text)
        local row = addRow(36)
        local t = Instance.new("TextLabel", row)
        t.BackgroundTransparency = 1
        t.Size = UDim2.fromScale(1,1)
        t.Font = Enum.Font.Gotham
        t.TextSize = 14
        t.TextColor3 = TEXT
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = "  "..tostring(text or "")
        return t
    end

    function TabObj:AddButton(opts) -- {Text, Callback}
        local row = addRow(40)
        local b = Instance.new("TextButton", row)
        b.AutoButtonColor = false
        b.Text = tostring((opts and opts.Text) or "Button")
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 14; b.TextColor3 = Color3.fromRGB(220,255,235)
        b.BackgroundColor3 = Color3.fromRGB(15,15,15)
        b.Size = UDim2.new(0, 160, 1, -8); b.Position = UDim2.new(1, -170, 0, 4)
        corner(b, 8); stroke(b,1,Color3.fromRGB(0,255,140),0.2)
        b.MouseButton1Click:Connect(function() if opts and opts.Callback then pcall(opts.Callback) end end)

        local t = Instance.new("TextLabel", row)
        t.BackgroundTransparency = 1
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Font = Enum.Font.Gotham
        t.TextSize = 14; t.TextColor3 = TEXT
        t.Position = UDim2.new(0,10,0,0); t.Size = UDim2.new(1,-190,1,0)
        t.Text = tostring((opts and opts.Text) or "Button")
        return b
    end

    function TabObj:AddToggle(opts) -- {Text, Default=false, Callback}
        local row = addRow(44)
        local t = Instance.new("TextLabel", row)
        t.BackgroundTransparency = 1
        t.Position = UDim2.new(0,10,0,0); t.Size = UDim2.new(1,-90,1,0)
        t.Font = Enum.Font.Gotham; t.TextSize = 14; t.TextColor3 = TEXT
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = tostring(opts and opts.Text or "Toggle")

        local btn = Instance.new("ImageButton", row)
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.fromOffset(64,26)
        btn.Position = UDim2.new(1,-74,0.5,-13)
        local function set(on)
            btn.Image = on and "rbxassetid://102713893228795" or "rbxassetid://136780249528523"
        end
        local state = (opts and opts.Default)==true
        set(state)
        btn.MouseButton1Click:Connect(function()
            state = not state; set(state)
            Saves:Set("tg:"..tabName..":"..(opts and opts.Text or ""), state)
            if opts and opts.Callback then pcall(opts.Callback, state) end
        end)

        -- restore ถ้ามี
        local keep = Saves:Get("tg:"..tabName..":"..(opts and opts.Text or ""), nil)
        if typeof(keep)=="boolean" then state=keep; set(state) end

        local api = {}
        function api:Set(v) state = v and true or false; set(state); if opts and opts.Callback then pcall(opts.Callback, state) end end
        function api:Get() return state end
        return api
    end

    function TabObj:AddSlider(opts) -- {Text, Min=0, Max=100, Default=0, Callback}
        local row = addRow(52)
        local t = Instance.new("TextLabel", row)
        t.BackgroundTransparency = 1
        t.Position = UDim2.new(0,10,0,0); t.Size = UDim2.new(1,-90,0,24)
        t.Font = Enum.Font.Gotham; t.TextSize = 14; t.TextColor3 = TEXT
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = tostring(opts and opts.Text or "Slider")

        local track = Instance.new("Frame", row)
        track.BackgroundColor3 = Color3.fromRGB(25,25,25)
        track.BorderSizePixel = 0
        track.Size = UDim2.new(1,-90,0,10)
        track.Position = UDim2.new(0,10,0,32)
        corner(track,5)

        local fill = Instance.new("Frame", track)
        fill.BackgroundColor3 = GREEN
        fill.BorderSizePixel = 0
        fill.Size = UDim2.fromOffset(0,10)
        corner(fill,5)

        local min = (opts and opts.Min) or 0
        local max = (opts and opts.Max) or 100
        local val = math.clamp((opts and opts.Default) or min, min, max)

        local function render()
            local w = track.AbsoluteSize.X
            local pct = (val-min)/(max-min)
            fill.Size = UDim2.fromOffset(math.max(0, math.floor(w*pct)), 10)
        end
        render(); track:GetPropertyChangedSignal("AbsoluteSize"):Connect(render)

        local sliding = false
        local function setFromX(x)
            local rel = math.clamp((x - track.AbsolutePosition.X)/math.max(1,track.AbsoluteSize.X), 0, 1)
            val = math.floor(min + (max-min)*rel + 0.5)
            render()
            Saves:Set("sl:"..tabName..":"..(opts and opts.Text or ""), val)
            if opts and opts.Callback then pcall(opts.Callback, val) end
        end
        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                sliding = true; setFromX(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                setFromX(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i) if sliding and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then sliding=false end end)

        -- restore
        local keep = Saves:Get("sl:"..tabName..":"..(opts and opts.Text or ""), nil)
        if typeof(keep)=="number" then val = math.clamp(keep, min, max); render() end

        local api = {}
        function api:Set(v) val = math.clamp(tonumber(v) or min, min, max); render(); if opts and opts.Callback then pcall(opts.Callback, val) end end
        function api:Get() return val end
        return api
    end

    function TabObj:AddDropdown(opts) -- {Text, Values={}, Default, Callback}
        local row = addRow(44)
        local t = Instance.new("TextLabel", row)
        t.BackgroundTransparency = 1
        t.Position = UDim2.new(0,10,0,0); t.Size = UDim2.new(1,-190,1,0)
        t.Font = Enum.Font.Gotham; t.TextSize = 14; t.TextColor3 = TEXT
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = tostring(opts and opts.Text or "Dropdown")

        local b = Instance.new("TextButton", row)
        b.AutoButtonColor = false
        b.Text = tostring(opts and opts.Default or "Select")
        b.Font = Enum.Font.GothamSemibold; b.TextSize = 14; b.TextColor3 = Color3.fromRGB(220,255,235)
        b.BackgroundColor3 = Color3.fromRGB(15,15,15)
        b.Size = UDim2.new(0, 160, 0, 32); b.Position = UDim2.new(1, -170, 0.5, -16)
        corner(b, 8); stroke(b,1,Color3.fromRGB(0,255,140),0.2)

        local popup = Instance.new("Frame", row)
        popup.Visible = false; popup.ZIndex = 10
        popup.BackgroundColor3 = Color3.fromRGB(8,8,8)
        popup.Size = UDim2.new(0, 200, 0, math.clamp( (#(opts.Values or {}))*32 + 12, 44, 180))
        popup.Position = UDim2.new(1, -170, 0, 40)
        corner(popup, 8); stroke(popup,1,Color3.fromRGB(0,255,140),0.2)
        vpad(popup,6); makeList(popup,6)

        local function choose(v)
            b.Text = tostring(v)
            Saves:Set("dd:"..tabName..":"..(opts.Text or ""), v)
            popup.Visible = false
            if opts.Callback then pcall(opts.Callback, v) end
        end
        for _,v in ipairs(opts.Values or {}) do
            local it = Instance.new("TextButton", popup)
            it.AutoButtonColor = false
            it.Size = UDim2.new(1,0,0,26)
            it.BackgroundColor3 = Color3.fromRGB(18,18,18)
            it.Text = tostring(v); it.TextColor3 = TEXT; it.Font = Enum.Font.Gotham; it.TextSize = 14
            corner(it,6); stroke(it,1,Color3.fromRGB(0,255,140),0.08)
            it.MouseButton1Click:Connect(function() choose(v) end)
        end

        b.MouseButton1Click:Connect(function() popup.Visible = not popup.Visible end)
        row.InputBegan:Connect(function(i) if popup.Visible and i.UserInputType==Enum.UserInputType.MouseButton1 then popup.Visible=false end end)

        local keep = Saves:Get("dd:"..tabName..":"..(opts.Text or ""), nil)
        if keep ~= nil then b.Text = tostring(keep) end
        return { Set = function(_,v) choose(v) end, Get = function() return b.Text end }
    end

    return setmetatable({}, TabObj)
end

-- ========= usage example (เหมือน lib อื่น แต่ยังใช้หน้าตาเรา) =========
--[[
local WindowAPI = Lib
local tMain = WindowAPI:CreateTab("Main", "rbxassetid://134323882016779")
tMain:AddLabel("Main features")
tMain:AddToggle({Text="God Mode", Default=false, Callback=function(on) print("God",on) end})
tMain:AddSlider({Text="Speed", Min=16, Max=100, Default=32, Callback=function(v) print("spd",v) end})
tMain:AddDropdown({Text="Team", Values={"Blue","Red","Spec"}, Default="Blue", Callback=function(v) print("team",v) end})

local tPlayer = WindowAPI:CreateTab("Player", "rbxassetid://116976545042904")
tPlayer:AddButton({Text="Give Coins", Callback=function() print("coins") end})
]]
return Lib
