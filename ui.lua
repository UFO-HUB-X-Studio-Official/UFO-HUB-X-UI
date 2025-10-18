--[[
UFO HUB X • Dual Panel (same look) + Safe Toggle (won't be deleted)
- Keeps existing toggle if already created
- Rebinds toggle to the new UI when UI script is re-run
- Creates toggle if missing
]]

--------------------------------- CLEAN (UI only) ---------------------------------
local CG = game:GetService("CoreGui")
pcall(function()
    local oldUI = CG:FindFirstChild("UFO_HUB_X_UI")
    if oldUI then oldUI:Destroy() end   -- ลบเฉพาะ UI หลัก, ไม่ยุ่งกับปุ่ม Toggle
end)

--------------------------------- THEME / SIZE ---------------------------------
local THEME = {
    GREEN=Color3.fromRGB(0,255,140),
    MINT=Color3.fromRGB(120,255,220),
    BG_WIN=Color3.fromRGB(16,16,16),
    BG_HEAD=Color3.fromRGB(6,6,6),
    BG_PANEL=Color3.fromRGB(22,22,22),
    BG_INNER=Color3.fromRGB(18,18,18),
    TEXT=Color3.fromRGB(235,235,235),
    RED=Color3.fromRGB(200,40,40),
    HILITE=Color3.fromRGB(22,30,24),
}
local SIZE={WIN_W=640,WIN_H=360,RADIUS=12,BORDER=3,HEAD_H=46,GAP_OUT=14,GAP_IN=8,BETWEEN=12,LEFT_RATIO=0.22}
local IMG_UFO="rbxassetid://100650447103028"
local ICON_PLAYER = 116976545042904
local ICON_HOME   = 134323882016779

--------------------------------- HELPERS ---------------------------------
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RunS=game:GetService("RunService")

local function corner(p,r)local u=Instance.new("UICorner",p)u.CornerRadius=UDim.new(0,r or 10)return u end
local function stroke(p,th,col,tr)local s=Instance.new("UIStroke",p)s.Thickness=th or 1;s.Color=col or THEME.MINT;s.Transparency=tr or 0.35;s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.LineJoinMode=Enum.LineJoinMode.Round;return s end

--------------------------------- ROOT UI ---------------------------------
local GUI=Instance.new("ScreenGui")
GUI.Name="UFO_HUB_X_UI"
GUI.IgnoreGuiInset=true
GUI.ResetOnSpawn=false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder = 100000
GUI.Parent = CG

local Win=Instance.new("Frame",GUI)
Win.Size=UDim2.fromOffset(SIZE.WIN_W,SIZE.WIN_H)
Win.AnchorPoint=Vector2.new(0.5,0.5); Win.Position=UDim2.new(0.5,0,0.5,0)
Win.BackgroundColor3=THEME.BG_WIN; Win.BorderSizePixel=0
corner(Win,SIZE.RADIUS); stroke(Win,3,THEME.GREEN,0)

-- Autoscale
do local sc=Instance.new("UIScale",Win)
   local function fit()
        local v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        sc.Scale=math.clamp(math.min(v.X/860,v.Y/540),0.72,1.0)
   end
   fit() RunS.RenderStepped:Connect(fit)
end

-- HEADER
local Header=Instance.new("Frame",Win)
Header.Size=UDim2.new(1,0,0,SIZE.HEAD_H)
Header.BackgroundColor3=THEME.BG_HEAD; Header.BorderSizePixel=0
corner(Header,SIZE.RADIUS)

local Accent=Instance.new("Frame",Header)
Accent.AnchorPoint=Vector2.new(0.5,1); Accent.Position=UDim2.new(0.5,0,1,0)
Accent.Size=UDim2.new(1,-20,0,1); Accent.BackgroundColor3=THEME.MINT
Accent.BackgroundTransparency=0.35; Accent.BorderSizePixel=0

local Title=Instance.new("TextLabel",Header)
Title.BackgroundTransparency=1; Title.AnchorPoint=Vector2.new(0.5,0)
Title.Position=UDim2.new(0.5,0,0,6); Title.Size=UDim2.new(0.8,0,0,36)
Title.Font=Enum.Font.GothamBold; Title.TextScaled=true; Title.RichText=true
Title.Text='<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
Title.TextColor3=THEME.TEXT

local BtnClose=Instance.new("TextButton",Header)
BtnClose.AutoButtonColor=false; BtnClose.Size=UDim2.fromOffset(24,24)
BtnClose.Position=UDim2.new(1,-34,0.5,-12); BtnClose.BackgroundColor3=THEME.RED
BtnClose.Text="X"; BtnClose.Font=Enum.Font.GothamBold; BtnClose.TextSize=13
BtnClose.TextColor3=Color3.new(1,1,1); BtnClose.BorderSizePixel=0
corner(BtnClose,6); stroke(BtnClose,1,Color3.fromRGB(255,0,0),0.1)

-- UFO icon
local UFO=Instance.new("ImageLabel",Win)
UFO.BackgroundTransparency=1; UFO.Image=IMG_UFO
UFO.Size=UDim2.fromOffset(168,168); UFO.AnchorPoint=Vector2.new(0.5,1)
UFO.Position=UDim2.new(0.5,0,0,84); UFO.ZIndex=4

-- BODY
local Body=Instance.new("Frame",Win)
Body.BackgroundColor3=THEME.BG_INNER; Body.BorderSizePixel=0
Body.Position=UDim2.new(0,SIZE.GAP_OUT,0,SIZE.HEAD_H+SIZE.GAP_OUT)
Body.Size=UDim2.new(1,-SIZE.GAP_OUT*2,1,-(SIZE.HEAD_H+SIZE.GAP_OUT*2))
corner(Body,12); stroke(Body,0.5,THEME.MINT,0.35)

-- LEFT
local LeftShell=Instance.new("Frame",Body)
LeftShell.BackgroundColor3=THEME.BG_PANEL; LeftShell.BorderSizePixel=0
LeftShell.Position=UDim2.new(0,SIZE.GAP_IN,0,SIZE.GAP_IN)
LeftShell.Size=UDim2.new(SIZE.LEFT_RATIO,-(SIZE.BETWEEN/2),1,-SIZE.GAP_IN*2)
corner(LeftShell,10); stroke(LeftShell,1.2,THEME.GREEN,0); stroke(LeftShell,0.45,THEME.MINT,0.35)

local LeftScroll=Instance.new("ScrollingFrame",LeftShell)
LeftScroll.BackgroundTransparency=1; LeftScroll.Size=UDim2.fromScale(1,1)
LeftScroll.ScrollBarThickness=0; LeftScroll.ScrollingDirection=Enum.ScrollingDirection.Y
LeftScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
local padL=Instance.new("UIPadding",LeftScroll)
padL.PaddingTop=UDim.new(0,8); padL.PaddingLeft=UDim.new(0,8); padL.PaddingRight=UDim.new(0,8); padL.PaddingBottom=UDim.new(0,8)
local LeftList=Instance.new("UIListLayout",LeftScroll); LeftList.Padding=UDim.new(0,8)

-- RIGHT
local RightShell=Instance.new("Frame",Body)
RightShell.BackgroundColor3=THEME.BG_PANEL; RightShell.BorderSizePixel=0
RightShell.Position=UDim2.new(SIZE.LEFT_RATIO,SIZE.BETWEEN,0,SIZE.GAP_IN)
RightShell.Size=UDim2.new(1-SIZE.LEFT_RATIO,-SIZE.GAP_IN-SIZE.BETWEEN,1,-SIZE.GAP_IN*2)
corner(RightShell,10); stroke(RightShell,1.2,THEME.GREEN,0); stroke(RightShell,0.45,THEME.MINT,0.35)

local RightScroll=Instance.new("ScrollingFrame",RightShell)
RightScroll.BackgroundTransparency=1; RightScroll.Size=UDim2.fromScale(1,1)
RightScroll.ScrollBarThickness=0; RightScroll.ScrollingDirection=Enum.ScrollingDirection.Y
RightScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
local padR=Instance.new("UIPadding",RightScroll)
padR.PaddingTop=UDim.new(0,12); padR.PaddingLeft=UDim.new(0,12); padR.PaddingRight=UDim.new(0,12); padR.PaddingBottom=UDim.new(0,12)
local RightList=Instance.new("UIListLayout",RightScroll); RightList.Padding=UDim.new(0,10)

-- ===== Iconed Tab Button (with FX) =====
local function makeTabButton(parent, label, iconId)
    local holder = Instance.new("Frame", parent)
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1,0,0,38)

    local b = Instance.new("TextButton", holder)
    b.AutoButtonColor=false; b.Text=""; b.Size=UDim2.new(1,0,1,0)
    b.BackgroundColor3=THEME.BG_INNER
    corner(b,8)
    local st = stroke(b,1,THEME.MINT,0.35)

    local ic = Instance.new("ImageLabel", b)
    ic.BackgroundTransparency = 1
    ic.Image = "rbxassetid://"..tostring(iconId)
    ic.Size = UDim2.fromOffset(22,22)
    ic.Position = UDim2.new(0,10,0.5,-11)

    local tx = Instance.new("TextLabel", b)
    tx.BackgroundTransparency=1; tx.TextColor3=THEME.TEXT
    tx.Font=Enum.Font.GothamMedium; tx.TextSize=15; tx.TextXAlignment=Enum.TextXAlignment.Left
    tx.Position=UDim2.new(0,38,0,0); tx.Size=UDim2.new(1,-46,1,0)
    tx.Text = label

    local flash = Instance.new("Frame", b)
    flash.BackgroundColor3 = THEME.GREEN
    flash.BackgroundTransparency = 1
    flash.BorderSizePixel = 0
    flash.AnchorPoint = Vector2.new(0.5,0.5)
    flash.Position = UDim2.new(0.5,0,0.5,0)
    flash.Size = UDim2.new(0,0,0,0)
    corner(flash,12)

    b.MouseButton1Down:Connect(function()
        TS:Create(b, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1,-2)}):Play()
    end)
    b.MouseButton1Up:Connect(function()
        TS:Create(b, TweenInfo.new(0.10, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1,0)}):Play()
    end)

    local function setActive(on)
        if on then
            b.BackgroundColor3 = THEME.HILITE
            st.Color = THEME.GREEN; st.Transparency = 0; st.Thickness = 2
            flash.BackgroundTransparency = 0.35; flash.Size = UDim2.new(0,0,0,0)
            TS:Create(flash, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1}):Play()
        else
            b.BackgroundColor3 = THEME.BG_INNER
            st.Color = THEME.MINT; st.Transparency = 0.35; st.Thickness = 1
        end
    end
    return b, setActive
end

local function showRight(titleText, iconId)
    for _,c in ipairs(RightScroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
    local row = Instance.new("Frame", RightScroll)
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1,0,0,28)
    local icon = Instance.new("ImageLabel", row)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://"..tostring(iconId or "")
    icon.Size = UDim2.fromOffset(20,20)
    icon.Position = UDim2.new(0,0,0.5,-10)
    local head = Instance.new("TextLabel", row)
    head.BackgroundTransparency=1; head.Font=Enum.Font.GothamBold; head.TextSize=18
    head.TextXAlignment=Enum.TextXAlignment.Left; head.TextColor3=THEME.TEXT
    head.Position = UDim2.new(0,26,0,0); head.Size=UDim2.new(1,-26,1,0)
    head.Text = titleText
end

-- Tabs: Player first, then Home
local btnPlayer, setPlayerActive = makeTabButton(LeftScroll, "Player", ICON_PLAYER)
local btnHome,   setHomeActive   = makeTabButton(LeftScroll, "Home",   ICON_HOME)

btnPlayer.MouseButton1Click:Connect(function()
    setPlayerActive(true); setHomeActive(false)
    showRight("Player", ICON_PLAYER)
end)
btnHome.MouseButton1Click:Connect(function()
    setPlayerActive(false); setHomeActive(true)
    showRight("Home", ICON_HOME)
end)

-- default
btnPlayer:Activate(); btnPlayer.MouseButton1Click:Fire()

--------------------------------- SAFE TOGGLE ---------------------------------
-- หา/สร้างปุ่มลอย ถ้ามีแล้วจะ reuse และ rebind
local ToggleGui = CG:FindFirstChild("UFO_HUB_X_Toggle")
if not ToggleGui then
    ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "UFO_HUB_X_Toggle"
    ToggleGui.IgnoreGuiInset=true
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToggleGui.DisplayOrder = 100001 -- เหนือ UI
    ToggleGui.Parent = CG

    local Toggle = Instance.new("ImageButton", ToggleGui)
    Toggle.Name = "Button"
    Toggle.Size = UDim2.fromOffset(64,64)
    Toggle.Position = UDim2.fromOffset(90,220)
    Toggle.Image = "rbxassetid://117052960049460"
    Toggle.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Toggle.BorderSizePixel=0
    corner(Toggle,8); stroke(Toggle,2,THEME.GREEN,0)
end

local ToggleBtn = ToggleGui:FindFirstChild("Button") :: ImageButton

-- ป้องกันผูกซ้ำ
if getgenv().UFO_ToggleConn then
    pcall(function() getgenv().UFO_ToggleConn:Disconnect() end)
end
if getgenv().UFO_RSConn then
    pcall(function() getgenv().UFO_RSConn:Disconnect() end)
end
if getgenv().UFO_DragMove then
    pcall(function() getgenv().UFO_DragMove:Disconnect() end)
end

local function setUIVisible(v)
    GUI.Enabled = v
    Win.Visible = v
    getgenv().UFO_ISOPEN = v
end
setUIVisible(true)

-- click toggle
getgenv().UFO_ToggleConn = ToggleBtn.MouseButton1Click:Connect(function()
    setUIVisible(not GUI.Enabled)
end)

-- RightShift
getgenv().UFO_RSConn = UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        setUIVisible(not GUI.Enabled)
    end
end)

-- drag
do
    local dragging=false; local start; local startPos
    ToggleBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Vector2.new(ToggleBtn.Position.X.Offset, ToggleBtn.Position.Y.Offset)
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    getgenv().UFO_DragMove = UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start; ToggleBtn.Position=UDim2.fromOffset(startPos.X+d.X, startPos.Y+d.Y)
        end
    end)
end

-- ปุ่ม X บนหัว
BtnClose.MouseButton1Click:Connect(function()
    setUIVisible(false)
end)
--==========================================================
-- UFO HUB X • Standalone Toggle (v3)
--  - ปุ่มปิด/เปิด “ของตัวเอง” มีกรอบเขียว, ลากได้, บล็อกกล้องขณะลาก
--  - ไม่โดน UI หลักลบทิ้ง และสามารถรีโหลด UI หลักกี่ครั้งก็ยังอยู่
--  - ซิงก์สถานะกับหน้าต่างหลักชื่อ "UFO_HUB_X_UI"
--==========================================================
do
    local Players  = game:GetService("Players")
    local CoreGui  = game:GetService("CoreGui")
    local UIS      = game:GetService("UserInputService")
    local CAS      = game:GetService("ContextActionService")

    -- โทนสี + ไอคอน
    local GREEN = Color3.fromRGB(0,255,140)
    local TOGGLE_ICON = "rbxassetid://117052960049460"

    -- ---------- หา UI หลักแบบทนทาน ----------
    local function findMain()
        local root = CoreGui:FindFirstChild("UFO_HUB_X_UI")
        if not root then
            local pg = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
            if pg then root = pg:FindFirstChild("UFO_HUB_X_UI") end
        end
        local win
        if root then
            win = root:FindFirstChild("Win") or root:FindFirstChildWhichIsA("Frame")
        end
        return root, win
    end

    local function setOpen(open)
        local gui, win = findMain()
        if gui then gui.Enabled = open end
        if win then win.Visible = open end
        getgenv().UFO_ISOPEN = not not open
    end

    -- เซ็ตสถานะเริ่มต้นตามของจริง (กันกดแล้วต้องกด 2 ครั้ง)
    do
        local gui, win = findMain()
        getgenv().UFO_ISOPEN = (gui and gui.Enabled ~= false) and (win and win.Visible ~= false)
    end

    -- ---------- ล้างปุ่มเก่าชื่อเดียวกัน (ไม่ยุ่งปุ่มชื่ออื่น) ----------
    pcall(function() CoreGui:FindFirstChild("UFO_HUB_X_ToggleV3"):Destroy() end)

    -- ---------- สร้างปุ่มลอยของตัวเอง ----------
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "UFO_HUB_X_ToggleV3"
    ToggleGui.IgnoreGuiInset = true
    ToggleGui.DisplayOrder = 100001
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToggleGui.Parent = CoreGui

    local Btn = Instance.new("ImageButton")
    Btn.Name = "Button"
    Btn.Size = UDim2.fromOffset(64,64)
    Btn.Position = UDim2.fromOffset(90,220)
    Btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Btn.BorderSizePixel = 0
    Btn.Image = TOGGLE_ICON
    Btn.Parent = ToggleGui

    local c = Instance.new("UICorner", Btn)
    c.CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke", Btn)
    s.Thickness = 2
    s.Color = GREEN

    -- ---------- คลิก/คีย์ลัด เปิด-ปิด ----------
    if getgenv().UFO_ToggleClickConn then pcall(function() getgenv().UFO_ToggleClickConn:Disconnect() end) end
    getgenv().UFO_ToggleClickConn = Btn.MouseButton1Click:Connect(function()
        setOpen(not getgenv().UFO_ISOPEN)
    end)

    if getgenv().UFO_RSConn then pcall(function() getgenv().UFO_RSConn:Disconnect() end) end
    getgenv().UFO_RSConn = UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            setOpen(not getgenv().UFO_ISOPEN)
        end
    end)

    -- ---------- จับปุ่ม X บนหัวของ UI หลัก ให้ซิงก์สถานะ ----------
    task.defer(function()
        local root = ({findMain()})[1]
        if root then
            for _,o in ipairs(root:GetDescendants()) do
                if o:IsA("TextButton") and (o.Text or ""):upper() == "X" then
                    o.MouseButton1Click:Connect(function() setOpen(false) end)
                end
            end
        end
    end)

    -- ---------- ลากปุ่ม + บล็อกการหมุนกล้องตอนลาก ----------
    local function bindBlock(on)
        local name = "UFO_BlockLook_ToggleV3"
        if on then
            CAS:BindActionAtPriority(
                name,
                function() return Enum.ContextActionResult.Sink end,
                false,
                9000,
                Enum.UserInputType.MouseMovement,
                Enum.UserInputType.Touch,
                Enum.UserInputType.MouseButton1
            )
        else
            pcall(function() CAS:UnbindAction(name) end)
        end
    end

    if getgenv().UFO_DragConn then pcall(function() getgenv().UFO_DragConn:Disconnect() end) end
    local dragging, startPos, origin
    Btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging = true
            origin = i.Position
            startPos = Vector2.new(Btn.Position.X.Offset, Btn.Position.Y.Offset)
            bindBlock(true)
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    bindBlock(false)
                end
            end)
        end
    end)

    getgenv().UFO_DragConn = UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - origin
            Btn.Position = UDim2.fromOffset(startPos.X + d.X, startPos.Y + d.Y)
        end
    end)

    -- ทำให้สถานะปุ่มตรงกับ UI หลักตอนเริ่มรัน
    setOpen(getgenv().UFO_ISOPEN)
end
