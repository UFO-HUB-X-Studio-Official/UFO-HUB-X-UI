--[[
UFO HUB X • One-shot = Toast(2-step) + Main UI (100%)
- Step1: Toast โหลด + แถบเปอร์เซ็นต์
- Step2: Toast "ดาวน์โหลดเสร็จ" โผล่ "พร้อมกับ" UI หลัก แล้วเลือนหายเอง
]]

------------------------------------------------------------
-- 1) ห่อ "UI หลักของคุณ (เดิม 100%)" ไว้ในฟังก์ชัน _G.UFO_ShowMainUI()
------------------------------------------------------------
_G.UFO_ShowMainUI = function()

--[[
UFO HUB X • Main UI + Safe Toggle (one-shot paste)
- ไม่ลบปุ่ม Toggle อีกต่อไป (ลบเฉพาะ UI หลัก)
- Toggle อยู่ของตัวเอง, มีขอบเขียว, ลากได้, บล็อกกล้องตอนลาก
- ซิงก์สถานะกับ UI หลักอัตโนมัติ และรีบอินด์ทุกครั้งที่ UI ถูกสร้างใหม่
]]

local Players  = game:GetService("Players")
local CoreGui  = game:GetService("CoreGui")
local UIS      = game:GetService("UserInputService")
local CAS      = game:GetService("ContextActionService")
local TS       = game:GetService("TweenService")
local RunS     = game:GetService("RunService")

-- ===== Theme / Size =====
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
local ICON_QUEST   = 72473476254744
local ICON_SHOP     = 139824330037901
local ICON_UPDATE   = 134419329246667
local ICON_SERVER   = 77839913086023
local ICON_SETTINGS = 72289858646360
local TOGGLE_ICON = "rbxassetid://117052960049460"

local function corner(p,r) local u=Instance.new("UICorner",p) u.CornerRadius=UDim.new(0,r or 10) return u end
local function stroke(p,th,col,tr) local s=Instance.new("UIStroke",p) s.Thickness=th or 1 s.Color=col or THEME.MINT s.Transparency=tr or 0.35 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.LineJoinMode=Enum.LineJoinMode.Round return s end

-- ===== Utilities: find main UI + sync =====
local function findMain()
    local root = CoreGui:FindFirstChild("UFO_HUB_X_UI")
    if not root then
        local pg = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pg then root = pg:FindFirstChild("UFO_HUB_X_UI") end
    end
    local win = root and (root:FindFirstChild("Win") or root:FindFirstChildWhichIsA("Frame")) or nil
    return root, win
end

local function setOpen(open)
    local gui, win = findMain()
    if gui then gui.Enabled = open end
    if win then win.Visible = open end
    getgenv().UFO_ISOPEN = not not open
end

-- ====== SAFE TOGGLE (สร้าง/รีใช้, ไม่โดนลบ) ======
local ToggleGui = CoreGui:FindFirstChild("UFO_HUB_X_Toggle") :: ScreenGui
if not ToggleGui then
    ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "UFO_HUB_X_Toggle"
    ToggleGui.IgnoreGuiInset = true
    ToggleGui.DisplayOrder = 100001
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToggleGui.ResetOnSpawn = false
    ToggleGui.Parent = CoreGui

    local Btn = Instance.new("ImageButton", ToggleGui)
    Btn.Name = "Button"
    Btn.Size = UDim2.fromOffset(64,64)
    Btn.Position = UDim2.fromOffset(90,220)
    Btn.Image = TOGGLE_ICON
    Btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Btn.BorderSizePixel = 0
    corner(Btn,8); stroke(Btn,2,THEME.GREEN,0)

    -- drag + block camera
    local function block(on)
        local name="UFO_BlockLook_Toggle"
        if on then
            CAS:BindActionAtPriority(name,function() return Enum.ContextActionResult.Sink end,false,9000,
                Enum.UserInputType.MouseMovement,Enum.UserInputType.Touch,Enum.UserInputType.MouseButton1)
        else pcall(function() CAS:UnbindAction(name) end) end
    end
    local dragging=false; local start; local startPos
    Btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Vector2.new(Btn.Position.X.Offset, Btn.Position.Y.Offset); block(true)
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; block(false) end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start; Btn.Position=UDim2.fromOffset(startPos.X+d.X,startPos.Y+d.Y)
        end
    end)
end

-- (Re)bind toggle actions (กันผูกซ้ำ)
do
    local Btn = ToggleGui:FindFirstChild("Button")
    if getgenv().UFO_ToggleClick then pcall(function() getgenv().UFO_ToggleClick:Disconnect() end) end
    if getgenv().UFO_ToggleKey   then pcall(function() getgenv().UFO_ToggleKey:Disconnect() end) end
    getgenv().UFO_ToggleClick = Btn.MouseButton1Click:Connect(function() setOpen(not getgenv().UFO_ISOPEN) end)
    getgenv().UFO_ToggleKey   = UIS.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==Enum.KeyCode.RightShift then setOpen(not getgenv().UFO_ISOPEN) end end)
end

-- ====== ลบ "เฉพาะ" UI หลักเก่าก่อนสร้างใหม่ (ไม่ยุ่ง Toggle) ======
pcall(function() local old = CoreGui:FindFirstChild("UFO_HUB_X_UI"); if old then old:Destroy() end end)

-- ====== MAIN UI (เหมือนเดิม) ======
local GUI=Instance.new("ScreenGui")
GUI.Name="UFO_HUB_X_UI"
GUI.IgnoreGuiInset=true
GUI.ResetOnSpawn=false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder = 100000
GUI.Parent = CoreGui

local Win=Instance.new("Frame",GUI) Win.Name="Win"
Win.Size=UDim2.fromOffset(SIZE.WIN_W,SIZE.WIN_H)
Win.AnchorPoint=Vector2.new(0.5,0.5); Win.Position=UDim2.new(0.5,0,0.5,0)
Win.BackgroundColor3=THEME.BG_WIN; Win.BorderSizePixel=0
corner(Win,SIZE.RADIUS); stroke(Win,3,THEME.GREEN,0)

do local sc=Instance.new("UIScale",Win)
   local function fit() local v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
       sc.Scale=math.clamp(math.min(v.X/860,v.Y/540),0.72,1.0) end
   fit(); RunS.RenderStepped:Connect(fit)
end

local Header=Instance.new("Frame",Win)
Header.Size=UDim2.new(1,0,0,SIZE.HEAD_H)
Header.BackgroundColor3=THEME.BG_HEAD; Header.BorderSizePixel=0
corner(Header,SIZE.RADIUS)
local Accent=Instance.new("Frame",Header)
Accent.AnchorPoint=Vector2.new(0.5,1); Accent.Position=UDim2.new(0.5,0,1,0)
Accent.Size=UDim2.new(1,-20,0,1); Accent.BackgroundColor3=THEME.MINT; Accent.BackgroundTransparency=0.35
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
BtnClose.MouseButton1Click:Connect(function() setOpen(false) end)

-- UFO icon
local UFO=Instance.new("ImageLabel",Win)
UFO.BackgroundTransparency=1; UFO.Image=IMG_UFO
UFO.Size=UDim2.fromOffset(168,168); UFO.AnchorPoint=Vector2.new(0.5,1)
UFO.Position=UDim2.new(0.5,0,0,84); UFO.ZIndex=4

-- === DRAG MAIN ONLY (ลากได้เฉพาะ UI หลักที่ Header; บล็อกกล้องระหว่างลาก) ===
do
    local dragging = false
    local startInputPos: Vector2
    local startWinOffset: Vector2
    local blockDrag = false

    -- กันเผลอลากตอนกดปุ่ม X
    BtnClose.MouseButton1Down:Connect(function() blockDrag = true end)
    BtnClose.MouseButton1Up:Connect(function() blockDrag = false end)

    local function blockCamera(on: boolean)
        local name = "UFO_BlockLook_MainDrag"
        if on then
            CAS:BindActionAtPriority(name, function()
                return Enum.ContextActionResult.Sink
            end, false, 9000,
            Enum.UserInputType.MouseMovement,
            Enum.UserInputType.Touch,
            Enum.UserInputType.MouseButton1)
        else
            pcall(function() CAS:UnbindAction(name) end)
        end
    end

    Header.InputBegan:Connect(function(input)
        if blockDrag then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInputPos  = input.Position
            startWinOffset = Vector2.new(Win.Position.X.Offset, Win.Position.Y.Offset)
            blockCamera(true)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    blockCamera(false)
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - startInputPos
        Win.Position = UDim2.new(0.5, startWinOffset.X + delta.X, 0.5, startWinOffset.Y + delta.Y)
    end)
end
-- === END DRAG MAIN ONLY ===

-- BODY
local Body=Instance.new("Frame",Win)
Body.BackgroundColor3=THEME.BG_INNER; Body.BorderSizePixel=0
Body.Position=UDim2.new(0,SIZE.GAP_OUT,0,SIZE.HEAD_H+SIZE.GAP_OUT)
Body.Size=UDim2.new(1,-SIZE.GAP_OUT*2,1,-(SIZE.HEAD_H+SIZE.GAP_OUT*2))
corner(Body,12); stroke(Body,0.5,THEME.MINT,0.35)

-- === LEFT (แทนที่บล็อกก่อนหน้าได้เลย) ================================
local LeftShell = Instance.new("Frame", Body)
LeftShell.BackgroundColor3 = THEME.BG_PANEL
LeftShell.BorderSizePixel  = 0
LeftShell.Position         = UDim2.new(0, SIZE.GAP_IN, 0, SIZE.GAP_IN)
LeftShell.Size             = UDim2.new(SIZE.LEFT_RATIO, -(SIZE.BETWEEN/2), 1, -SIZE.GAP_IN*2)
LeftShell.ClipsDescendants = true
corner(LeftShell, 10)
stroke(LeftShell, 1.2, THEME.GREEN, 0)
stroke(LeftShell, 0.45, THEME.MINT, 0.35)

local LeftScroll = Instance.new("ScrollingFrame", LeftShell)
LeftScroll.BackgroundTransparency = 1
LeftScroll.Size                   = UDim2.fromScale(1,1)
LeftScroll.ScrollBarThickness     = 0
LeftScroll.ScrollingDirection     = Enum.ScrollingDirection.Y
LeftScroll.AutomaticCanvasSize    = Enum.AutomaticSize.None
LeftScroll.ElasticBehavior        = Enum.ElasticBehavior.Never
LeftScroll.ScrollingEnabled       = true
LeftScroll.ClipsDescendants       = true

local padL = Instance.new("UIPadding", LeftScroll)
padL.PaddingTop    = UDim.new(0, 8)
padL.PaddingLeft   = UDim.new(0, 8)
padL.PaddingRight  = UDim.new(0, 8)
padL.PaddingBottom = UDim.new(0, 8)

local LeftList = Instance.new("UIListLayout", LeftScroll)
LeftList.Padding   = UDim.new(0, 8)
LeftList.SortOrder = Enum.SortOrder.LayoutOrder

-- ===== คุม Canvas + กันเด้งกลับตอนคลิกแท็บ =====
local function refreshLeftCanvas()
    local contentH = LeftList.AbsoluteContentSize.Y + padL.PaddingTop.Offset + padL.PaddingBottom.Offset
    LeftScroll.CanvasSize = UDim2.new(0, 0, 0, contentH)
end

local function clampTo(yTarget)
    local contentH = LeftList.AbsoluteContentSize.Y + padL.PaddingTop.Offset + padL.PaddingBottom.Offset
    local viewH    = LeftScroll.AbsoluteSize.Y
    local maxY     = math.max(0, contentH - viewH)
    LeftScroll.CanvasPosition = Vector2.new(0, math.clamp(yTarget or 0, 0, maxY))
end

-- ✨ จำตำแหน่งล่าสุดไว้ใช้ “ทุกครั้ง” ที่มีการจัดเลย์เอาต์ใหม่
local lastY = 0

LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    refreshLeftCanvas()
    clampTo(lastY) -- ใช้ค่าเดิมที่จำไว้ ไม่อ่านจาก CanvasPosition ที่อาจโดนรีเซ็ต
end)

task.defer(refreshLeftCanvas)

-- name/icon = ชื่อ/ไอคอนฝั่งขวา, setFns = ฟังก์ชันเซ็ต active, btn = ปุ่มที่ถูกกด
local function onTabClick(name, icon, setFns, btn)
    -- บันทึกตำแหน่งปัจจุบัน “ไว้ก่อน” ที่เลย์เอาต์จะขยับ
    lastY = LeftScroll.CanvasPosition.Y

    setFns()
    showRight(name, icon)

    task.defer(function()
        refreshLeftCanvas()
        clampTo(lastY) -- คืนตำแหน่งเดิมเสมอ

        -- ถ้าปุ่มอยู่นอกจอ ค่อยเลื่อนเข้าเฟรมอย่างพอดี (จะปรับ lastY ด้วย)
        if btn and btn.Parent then
            local viewH   = LeftScroll.AbsoluteSize.Y
            local btnTop  = btn.AbsolutePosition.Y - LeftScroll.AbsolutePosition.Y
            local btnBot  = btnTop + btn.AbsoluteSize.Y
            local pad     = 8
            local y = LeftScroll.CanvasPosition.Y
            if btnTop < 0 then
                y = y + (btnTop - pad)
            elseif btnBot > viewH then
                y = y + (btnBot - viewH) + pad
            end
            lastY = y
            clampTo(lastY)
        end
    end)
end

-- === ผูกคลิกแท็บทั้ง 7 (เหมือนเดิม) ================================
task.defer(function()
    repeat task.wait() until
        btnPlayer and btnHome and btnQuest and btnShop and btnUpdate and btnServer and btnSettings

    btnPlayer.MouseButton1Click:Connect(function()
        onTabClick("Player", ICON_PLAYER, function()
            setPlayerActive(true); setHomeActive(false); setQuestActive(false)
            setShopActive(false); setUpdateActive(false); setServerActive(false); setSettingsActive(false)
        end, btnPlayer)
    end)

    btnHome.MouseButton1Click:Connect(function()
        onTabClick("Home", ICON_HOME, function()
            setPlayerActive(false); setHomeActive(true); setQuestActive(false)
            setShopActive(false); setUpdateActive(false); setServerActive(false); setSettingsActive(false)
        end, btnHome)
    end)

    btnQuest.MouseButton1Click:Connect(function()
        onTabClick("Quest", ICON_QUEST, function()
            setPlayerActive(false); setHomeActive(false); setQuestActive(true)
            setShopActive(false); setUpdateActive(false); setServerActive(false); setSettingsActive(false)
        end, btnQuest)
    end)

    btnShop.MouseButton1Click:Connect(function()
        onTabClick("Shop", ICON_SHOP, function()
            setPlayerActive(false); setHomeActive(false); setQuestActive(false)
            setShopActive(true); setUpdateActive(false); setServerActive(false); setSettingsActive(false)
        end, btnShop)
    end)

    btnUpdate.MouseButton1Click:Connect(function()
        onTabClick("Update", ICON_UPDATE, function()
            setPlayerActive(false); setHomeActive(false); setQuestActive(false)
            setShopActive(false); setUpdateActive(true); setServerActive(false); setSettingsActive(false)
        end, btnUpdate)
    end)

    btnServer.MouseButton1Click:Connect(function()
        onTabClick("Server", ICON_SERVER, function()
            setPlayerActive(false); setHomeActive(false); setQuestActive(false)
            setShopActive(false); setUpdateActive(false); setServerActive(true); setSettingsActive(false)
        end, btnServer)
    end)

    btnSettings.MouseButton1Click:Connect(function()
        onTabClick("Settings", ICON_SETTINGS, function()
            setPlayerActive(false); setHomeActive(false); setQuestActive(false)
            setShopActive(false); setUpdateActive(false); setServerActive(false); setSettingsActive(true)
        end, btnSettings)
    end)
end)
-- ===================================================================

-- RIGHT
local RightShell=Instance.new("Frame",Body)
RightShell.BackgroundColor3=THEME.BG_PANEL; RightShell.BorderSizePixel=0
RightShell.Position=UDim2.new(SIZE.LEFT_RATIO,SIZE.BETWEEN,0,SIZE.GAP_IN)
RightShell.Size=UDim2.new(1-SIZE.LEFT_RATIO,-SIZE.GAP_IN-SIZE.BETWEEN,1,-SIZE.GAP_IN*2)
corner(RightShell,10); stroke(RightShell,1.2,THEME.GREEN,0); stroke(RightShell,0.45,THEME.MINT,0.35)

local RightScroll=Instance.new("ScrollingFrame",RightShell)
RightScroll.BackgroundTransparency=1
RightScroll.Size=UDim2.fromScale(1,1)
RightScroll.ScrollBarThickness=0
RightScroll.ScrollingDirection=Enum.ScrollingDirection.Y
RightScroll.AutomaticCanvasSize = Enum.AutomaticSize.None  -- ★ คุมเอง (แก้บัคเด้ง/ล้น)

local padR=Instance.new("UIPadding",RightScroll)
padR.PaddingTop=UDim.new(0,12)
padR.PaddingLeft=UDim.new(0,12)
padR.PaddingRight=UDim.new(0,12)
padR.PaddingBottom=UDim.new(0,12)

local RightList=Instance.new("UIListLayout",RightScroll)
RightList.Padding=UDim.new(0,10) -- << แก้บรรทัดนี้จาก UDim.New เป็น UDim.new
RightList.SortOrder = Enum.SortOrder.LayoutOrder
RightList.VerticalAlignment = Enum.VerticalAlignment.Top

-- อัปเดต CanvasSize ให้พอดีกับเนื้อหา
local function refreshRightCanvas()
    local h = RightList.AbsoluteContentSize.Y + padR.PaddingTop.Offset + padR.PaddingBottom.Offset
    RightScroll.CanvasSize = UDim2.new(0,0,0,h)
end
RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshRightCanvas)
task.defer(refreshRightCanvas)

-- Tabs
local function makeTabButton(parent, label, iconId)
    local holder = Instance.new("Frame", parent) holder.BackgroundTransparency=1 holder.Size = UDim2.new(1,0,0,38)
    local b = Instance.new("TextButton", holder) b.AutoButtonColor=false b.Text="" b.Size=UDim2.new(1,0,1,0) b.BackgroundColor3=THEME.BG_INNER corner(b,8)
    local st = stroke(b,1,THEME.MINT,0.35)
    local ic = Instance.new("ImageLabel", b) ic.BackgroundTransparency=1 ic.Image="rbxassetid://"..tostring(iconId) ic.Size=UDim2.fromOffset(22,22) ic.Position=UDim2.new(0,10,0.5,-11)
    local tx = Instance.new("TextLabel", b) tx.BackgroundTransparency=1 tx.TextColor3=THEME.TEXT tx.Font=Enum.Font.GothamMedium tx.TextSize=15 tx.TextXAlignment=Enum.TextXAlignment.Left tx.Position=UDim2.new(0,38,0,0) tx.Size=UDim2.new(1,-46,1,0) tx.Text = label
    local flash=Instance.new("Frame",b) flash.BackgroundColor3=THEME.GREEN flash.BackgroundTransparency=1 flash.BorderSizePixel=0 flash.AnchorPoint=Vector2.new(0.5,0.5) flash.Position=UDim2.new(0.5,0,0.5,0) flash.Size=UDim2.new(0,0,0,0) corner(flash,12)
    b.MouseButton1Down:Connect(function() TS:Create(b, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1,-2)}):Play() end)
    b.MouseButton1Up:Connect(function() TS:Create(b, TweenInfo.new(0.10, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1,0)}):Play() end)
    local function setActive(on)
        if on then b.BackgroundColor3=THEME.HILITE st.Color=THEME.GREEN st.Transparency=0 st.Thickness=2 flash.BackgroundTransparency=0.35 flash.Size=UDim2.new(0,0,0,0)
            TS:Create(flash, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1}):Play()
        else b.BackgroundColor3=THEME.BG_INNER st.Color=THEME.MINT st.Transparency=0.35 st.Thickness=1 end
    end
    return b, setActive
end

-- ===== REPLACE showRight (exact layout like original image reference) =====
do
    if not getgenv().UFO_RIGHT then getgenv().UFO_RIGHT = {} end
    local RSTATE = getgenv().UFO_RIGHT

    local function killRight()
        for _,c in ipairs(RightScroll:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        if RSTATE.timerConn then pcall(function() RSTATE.timerConn:Disconnect() end) end
        RSTATE.timerConn = nil
    end

    local function rightHeader(titleText, iconId)
        local row = Instance.new("Frame")
        row.Name = "RightHeader"
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1,0,0,28)
        row.Parent = RightScroll

        local icon = Instance.new("ImageLabel")
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://"..tostring(iconId or "")
        icon.Size = UDim2.fromOffset(20,20)
        icon.Position = UDim2.new(0,0,0.5,-10)
        icon.Parent = row

    local head = Instance.new("TextLabel")
        head.BackgroundTransparency = 1
        head.Font = Enum.Font.GothamBold
        head.TextSize = 18
        head.TextXAlignment = Enum.TextXAlignment.Left
        head.TextColor3 = THEME.TEXT
        head.Position = UDim2.new(0,26,0,0)
        head.Size = UDim2.new(1,-26,1,0)
        head.Text = titleText
        head.Parent = row
    end

    -- ===== เนื้อหาแท็บ Player (จัดกลางตามภาพอ้างอิง) =====
    function renderPlayerPane()
        local AV_SIZE   = 160   -- ขนาดกรอบรูป
        local NAME_W,  NAME_H  = 240, 40
        local LEVEL_W, LEVEL_H = 200, 30
        local TIMER_W, TIMER_H = 180, 26
        local GAP_Y = 10

        -- ช่วยคำนวณให้วางกลางแนวนอนของ RightScroll
        local function centerX(w)
            return math.floor((RightScroll.AbsoluteSize.X - w)/2)
        end

        -- (1) กรอบรูปผู้เล่น (โปร่งพื้น + เส้นเขียว)
        local avatarBox = Instance.new("Frame", RightScroll)
        avatarBox.BackgroundTransparency = 1
        avatarBox.Size = UDim2.fromOffset(AV_SIZE, AV_SIZE)
        corner(avatarBox, 10)
        stroke(avatarBox, 1.5, THEME.GREEN, 0)

        local avatar = Instance.new("ImageLabel", avatarBox)
        avatar.BackgroundTransparency = 1
        avatar.Size = UDim2.new(1, -8, 1, -8)
        avatar.Position = UDim2.new(0,4,0,4)

        pcall(function()
            local plr = Players.LocalPlayer
            local id  = plr and plr.UserId or 0
            local img, ready = Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
            if ready then avatar.Image = img end
        end)

        -- (2) กรอบชื่อ (โปร่งพื้น + เส้นเขียว)
        local nameBox = Instance.new("Frame", RightScroll)
        nameBox.BackgroundTransparency = 1
        nameBox.Size = UDim2.fromOffset(NAME_W, NAME_H)
        corner(nameBox, 10)
        stroke(nameBox, 1.3, THEME.GREEN, 0)

        local nameLbl = Instance.new("TextLabel", nameBox)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 20
        nameLbl.TextColor3 = THEME.TEXT
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.Size = UDim2.fromScale(1,1)
        nameLbl.Text = (Players.LocalPlayer and Players.LocalPlayer.DisplayName) or "Player"

        -- (3) กรอบ Level (โปร่งพื้น + เส้นเขียว)
        local lvlBox = Instance.new("Frame", RightScroll)
        lvlBox.BackgroundTransparency = 1
        lvlBox.Size = UDim2.fromOffset(LEVEL_W, LEVEL_H)
        corner(lvlBox, 10)
        stroke(lvlBox, 1.2, THEME.GREEN, 0)

        local lvlLbl = Instance.new("TextLabel", lvlBox)
        lvlLbl.BackgroundTransparency = 1
        lvlLbl.Font = Enum.Font.Gotham
        lvlLbl.TextSize = 16
        lvlLbl.TextColor3 = THEME.TEXT
        lvlLbl.TextXAlignment = Enum.TextXAlignment.Center
        lvlLbl.Size = UDim2.fromScale(1,1)
        lvlLbl.Text = "Level 1"

        -- (4) ตัวเลขเวลา (ไม่มีกรอบ/พื้น)
        local timerLbl = Instance.new("TextLabel", RightScroll)
        timerLbl.BackgroundTransparency = 1
        timerLbl.Font = Enum.Font.GothamBlack
        timerLbl.TextSize = 20
        timerLbl.TextColor3 = Color3.fromRGB(255,255,255)
        timerLbl.TextXAlignment = Enum.TextXAlignment.Center
        timerLbl.Size = UDim2.fromOffset(TIMER_W, TIMER_H)
        timerLbl.Text = "00:00.00"

        -- จัดตำแหน่งแนวตั้งตามลำดับ: รูป → ชื่อ → Level → เวลา
        local function relayout()
            local baseY = 46
            avatarBox.Position = UDim2.fromOffset(centerX(AV_SIZE), baseY)
            nameBox.Position   = UDim2.fromOffset(centerX(NAME_W),  baseY + AV_SIZE + GAP_Y)
            lvlBox.Position    = UDim2.fromOffset(centerX(LEVEL_W), baseY + AV_SIZE + GAP_Y + NAME_H + GAP_Y)
            timerLbl.Position  = UDim2.fromOffset(centerX(TIMER_W), baseY + AV_SIZE + GAP_Y + NAME_H + GAP_Y + LEVEL_H + GAP_Y)
        end

        relayout()
        RightScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)

        -- จับเวลาจริงแบบนาฬิกา
        if RSTATE.timerConn then pcall(function() RSTATE.timerConn:Disconnect() end) end
        local t0 = time()
        RSTATE.timerConn = RunS.Heartbeat:Connect(function()
            local elapsed = time() - t0
            if elapsed < 0 then elapsed = 0 end
            local mins = math.floor(elapsed / 60)
            local secs = math.floor(elapsed % 60)
            local cs   = math.floor((elapsed - math.floor(elapsed)) * 100)
            timerLbl.Text = string.format("%02d:%02d.%02d", mins % 60, secs, cs)
        end)
    end

    -- ===== เก็บ/คืนตำแหน่งสกอร์ลฝั่งขวาแยกตามแท็บ =====
    if not getgenv().UFO_RIGHT then getgenv().UFO_RIGHT = {} end
    local RSTATE = getgenv().UFO_RIGHT
    RSTATE.scroll     = RSTATE.scroll or {}   -- { [tabName] = y }
    RSTATE.currentTab = RSTATE.currentTab

    local function clampRightY(y)
        local contentH = RightList.AbsoluteContentSize.Y + padR.PaddingTop.Offset + padR.PaddingBottom.Offset
        local viewH    = RightScroll.AbsoluteSize.Y
        local maxY     = math.max(0, contentH - viewH)
        return math.clamp(y or 0, 0, maxY)
    end

    function showRight(titleText, iconId)
        -- เซฟตำแหน่งของแท็บก่อนหน้า
        if RSTATE.currentTab then
            RSTATE.scroll[RSTATE.currentTab] = RightScroll.CanvasPosition.Y
        end

        -- ล้างคอนเทนต์เดิม
        for _,c in ipairs(RightScroll:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end

        -- สร้างหัวเรื่อง
        rightHeader(titleText, iconId)

        -- เนื้อหาตามแท็บ
        if titleText == "Player" then
            renderPlayerPane()
        else
            -- แท็บอื่นยังคงไม่มีคอนเทนต์เพิ่มเติม (ใช้หัวเรื่องอย่างเดียวตามเดิม)
        end

        -- คืนตำแหน่งสกอร์ลของแท็บนี้
        RSTATE.currentTab = titleText
        task.defer(function()
            -- อัปเดต Canvas แล้วค่อยตั้งค่า CanvasPosition
            local h = RightList.AbsoluteContentSize.Y + padR.PaddingTop.Offset + padR.PaddingBottom.Offset
            RightScroll.CanvasSize = UDim2.new(0,0,0,h)
            RightScroll.CanvasPosition = Vector2.new(0, clampRightY(RSTATE.scroll[titleText] or 0))
        end)
    end
end
-- ===== END REPLACE showRight =====
