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

----------------------------------------------------------------
-- LEFT (ปุ่มแท็บ) + RIGHT (คอนเทนต์) — เวอร์ชันครบ + แก้บัคสกอร์ลแยกแท็บ
----------------------------------------------------------------

-- ========== LEFT ==========
local LeftShell=Instance.new("Frame",Body)
LeftShell.BackgroundColor3=THEME.BG_PANEL; LeftShell.BorderSizePixel=0
LeftShell.Position=UDim2.new(0,SIZE.GAP_IN,0,SIZE.GAP_IN)
LeftShell.Size=UDim2.new(SIZE.LEFT_RATIO,-(SIZE.BETWEEN/2),1,-SIZE.GAP_IN*2)
LeftShell.ClipsDescendants=true
corner(LeftShell,10); stroke(LeftShell,1.2,THEME.GREEN,0); stroke(LeftShell,0.45,THEME.MINT,0.35)

local LeftScroll=Instance.new("ScrollingFrame",LeftShell)
LeftScroll.BackgroundTransparency=1
LeftScroll.Size=UDim2.fromScale(1,1)
LeftScroll.ScrollBarThickness=0
LeftScroll.ScrollingDirection=Enum.ScrollingDirection.Y
LeftScroll.AutomaticCanvasSize=Enum.AutomaticSize.None
LeftScroll.ElasticBehavior=Enum.ElasticBehavior.Never
LeftScroll.ScrollingEnabled=true
LeftScroll.ClipsDescendants=true

local padL=Instance.new("UIPadding",LeftScroll)
padL.PaddingTop=UDim.new(0,8); padL.PaddingLeft=UDim.new(0,8); padL.PaddingRight=UDim.new(0,8); padL.PaddingBottom=UDim.new(0,8)
local LeftList=Instance.new("UIListLayout",LeftScroll); LeftList.Padding=UDim.new(0,8); LeftList.SortOrder=Enum.SortOrder.LayoutOrder

local function refreshLeftCanvas()
    local contentH = LeftList.AbsoluteContentSize.Y + padL.PaddingTop.Offset + padL.PaddingBottom.Offset
    LeftScroll.CanvasSize = UDim2.new(0,0,0,contentH)
end
local lastLeftY = 0
LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    refreshLeftCanvas()
    local viewH = LeftScroll.AbsoluteSize.Y
    local maxY  = math.max(0, LeftScroll.CanvasSize.Y.Offset - viewH)
    LeftScroll.CanvasPosition = Vector2.new(0, math.clamp(lastLeftY,0,maxY))
end)
task.defer(refreshLeftCanvas)

-- สร้างปุ่มแท็บ
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
        if on then
            b.BackgroundColor3=THEME.HILITE; st.Color=THEME.GREEN; st.Transparency=0; st.Thickness=2
            flash.BackgroundTransparency=0.35; flash.Size=UDim2.new(0,0,0,0)
            TS:Create(flash, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1}):Play()
        else
            b.BackgroundColor3=THEME.BG_INNER; st.Color=THEME.MINT; st.Transparency=0.35; st.Thickness=1
        end
    end
    return b, setActive
end

local btnPlayer,  setPlayerActive   = makeTabButton(LeftScroll, "Player",  ICON_PLAYER)
local btnHome,    setHomeActive     = makeTabButton(LeftScroll, "Home",    ICON_HOME)
local btnQuest,   setQuestActive    = makeTabButton(LeftScroll, "Quest",   ICON_QUEST)
local btnShop,    setShopActive     = makeTabButton(LeftScroll, "Shop",    ICON_SHOP)
local btnUpdate,  setUpdateActive   = makeTabButton(LeftScroll, "Update",  ICON_UPDATE)
local btnServer,  setServerActive   = makeTabButton(LeftScroll, "Server",  ICON_SERVER)
local btnSettings,setSettingsActive = makeTabButton(LeftScroll, "Settings",ICON_SETTINGS)

-- ========== RIGHT ==========
local RightShell=Instance.new("Frame",Body)
RightShell.BackgroundColor3=THEME.BG_PANEL; RightShell.BorderSizePixel=0
RightShell.Position=UDim2.new(SIZE.LEFT_RATIO,SIZE.BETWEEN,0,SIZE.GAP_IN)
RightShell.Size=UDim2.new(1-SIZE.LEFT_RATIO,-SIZE.GAP_IN-SIZE.BETWEEN,1,-SIZE.GAP_IN*2)
corner(RightShell,10); stroke(RightShell,1.2,THEME.GREEN,0); stroke(RightShell,0.45,THEME.MINT,0.35)

local RightScroll=Instance.new("ScrollingFrame",RightShell)
RightScroll.BackgroundTransparency=1; RightScroll.Size=UDim2.fromScale(1,1)
RightScroll.ScrollBarThickness=0; RightScroll.ScrollingDirection=Enum.ScrollingDirection.Y
RightScroll.AutomaticCanvasSize=Enum.AutomaticSize.None   -- คุมเองเพื่อกันเด้ง/จำ Y ได้
RightScroll.ElasticBehavior=Enum.ElasticBehavior.Never

local padR=Instance.new("UIPadding",RightScroll)
padR.PaddingTop=UDim.new(0,12); padR.PaddingLeft=UDim.new(0,12); padR.PaddingRight=UDim.new(0,12); padR.PaddingBottom=UDim.new(0,12)
local RightList=Instance.new("UIListLayout",RightScroll); RightList.Padding=UDim.new(0,10); RightList.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshRightCanvas()
    local contentH = RightList.AbsoluteContentSize.Y + padR.PaddingTop.Offset + padR.PaddingBottom.Offset
    RightScroll.CanvasSize = UDim2.new(0,0,0,contentH)
end
RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    local yBefore = RightScroll.CanvasPosition.Y
    refreshRightCanvas()
    local viewH = RightScroll.AbsoluteSize.Y
    local maxY  = math.max(0, RightScroll.CanvasSize.Y.Offset - viewH)
    RightScroll.CanvasPosition = Vector2.new(0, math.clamp(yBefore,0,maxY))
end)
-- ================= RIGHT: Modular per-tab (drop-in) =================
-- ใส่หลังจากสร้าง RightShell เสร็จ (และก่อนผูกปุ่มกด)

-- 1) เก็บ/ใช้ state กลาง
if not getgenv().UFO_RIGHT then getgenv().UFO_RIGHT = {} end
local RSTATE = getgenv().UFO_RIGHT
RSTATE.frames   = RSTATE.frames   or {}
RSTATE.builders = RSTATE.builders or {}
RSTATE.scrollY  = RSTATE.scrollY  or {}
RSTATE.current  = RSTATE.current

-- 2) ถ้ามี RightScroll เก่าอยู่ ให้ลบทิ้ง
pcall(function()
    local old = RightShell:FindFirstChildWhichIsA("ScrollingFrame")
    if old then old:Destroy() end
end)

-- 3) สร้าง ScrollingFrame ต่อแท็บ  (PATCHED: ใช้ AutomaticCanvasSize=Y, ไม่มีเส้นขาว)
local function makeTabFrame(tabName)
    local root = Instance.new("Frame")
    root.Name = "RightTab_"..tabName
    root.BackgroundTransparency = 1
    root.Size = UDim2.fromScale(1,1)
    root.Visible = false
    root.Parent = RightShell

    local sf = Instance.new("ScrollingFrame", root)
    sf.Name = "Scroll"
    sf.BackgroundTransparency = 1
    sf.Size = UDim2.fromScale(1,1)
    sf.ScrollingDirection = Enum.ScrollingDirection.Y
    sf.ScrollBarThickness = 0                     -- ซ่อนแถบสกรอลล์
    sf.ScrollBarImageTransparency = 1             -- ลบเงาสีขาว
    sf.ScrollBarImageColor3 = Color3.new(0,0,0)   -- กันเส้นขาวค้าง
    sf.BorderSizePixel = 0                        -- ไม่มีเส้นขอบ
    sf.ClipsDescendants = true                    -- ป้องกันหลุดขอบตอนเลื่อน
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.ElasticBehavior = Enum.ElasticBehavior.Never

    local pad = Instance.new("UIPadding", sf)
    pad.PaddingTop    = UDim.new(0,12)
    pad.PaddingLeft   = UDim.new(0,12)
    pad.PaddingRight  = UDim.new(0,12)
    pad.PaddingBottom = UDim.new(0,12)

    local list = Instance.new("UIListLayout", sf)
    list.Padding = UDim.new(0,10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.VerticalAlignment = Enum.VerticalAlignment.Top

    -- ไม่ต้องคำนวณ CanvasSize เองแล้ว (Auto ทำให้)
    RSTATE.frames[tabName] = {root=root, scroll=sf, list=list, built=false}
    return RSTATE.frames[tabName]
end
    
-- 4) ลงทะเบียนฟังก์ชันสร้างคอนเทนต์ต่อแท็บ (รองรับหลายตัว)
local function registerRight(tabName, builderFn)
    RSTATE.builders[tabName] = RSTATE.builders[tabName] or {}
    table.insert(RSTATE.builders[tabName], builderFn)
end

-- 5) หัวเรื่อง
local function addHeader(parentScroll, titleText, iconId)
    local row = Instance.new("Frame")
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1,0,0,28)
    row.Parent = parentScroll

    local icon = Instance.new("ImageLabel", row)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://"..tostring(iconId or "")
    icon.Size = UDim2.fromOffset(20,20)
    icon.Position = UDim2.new(0,0,0.5,-10)

    local head = Instance.new("TextLabel", row)
    head.BackgroundTransparency = 1
    head.Font = Enum.Font.GothamBold
    head.TextSize = 18
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.TextColor3 = THEME.TEXT
    head.Position = UDim2.new(0,26,0,0)
    head.Size = UDim2.new(1,-26,1,0)
    head.Text = titleText
end

-- 6) API หลัก
function showRight(titleText, iconId)
    local tab = titleText

    if RSTATE.current and RSTATE.frames[RSTATE.current] then
        RSTATE.scrollY[RSTATE.current] = RSTATE.frames[RSTATE.current].scroll.CanvasPosition.Y
        RSTATE.frames[RSTATE.current].root.Visible = false
    end

    local f = RSTATE.frames[tab] or makeTabFrame(tab)
    f.root.Visible = true

    if not f.built then
        addHeader(f.scroll, titleText, iconId)
        -- เรียกทุก builder ของแท็บนี้ (เรียงตามที่ register เข้ามา)
        local list = RSTATE.builders[tab] or {}
        for _, builder in ipairs(list) do
            pcall(builder, f.scroll)
        end
        f.built = true
    end

    task.defer(function()
        local y = RSTATE.scrollY[tab] or 0
        local viewH = f.scroll.AbsoluteSize.Y
        local maxY  = math.max(0, f.scroll.CanvasSize.Y.Offset - viewH)
        f.scroll.CanvasPosition = Vector2.new(0, math.clamp(y, 0, maxY))
    end)

    RSTATE.current = tab
end

-- 7) ตัวอย่างแท็บ (ลบเดโมรายการออกแล้ว)
registerRight("Player", function(scroll)
    -- วาง UI ของ Player ที่นี่ (ตอนนี้ปล่อยว่าง ไม่มี Item#)
end)

registerRight("Home", function(scroll) end)
registerRight("Quest", function(scroll) end)
registerRight("Shop", function(scroll) end)
registerRight("Update", function(scroll) end)
registerRight("Server", function(scroll) end)
registerRight("Settings", function(scroll) end)

-- ================= END RIGHT modular =================
 -- ===== Player tab (Right) — Profile ONLY (avatar + name, isolated) =====
registerRight("Player", function(scroll)
    local Players = game:GetService("Players")
    local Content = game:GetService("ContentProvider")
    local lp      = Players.LocalPlayer

    -- THEME
    local BASE = rawget(_G, "THEME") or {}
    local THEME = {
        BG_INNER = BASE.BG_INNER or Color3.fromRGB(0, 0, 0),
        GREEN    = BASE.GREEN    or BASE.ACCENT or Color3.fromRGB(25, 255, 125),
        WHITE    = Color3.fromRGB(255, 255, 255),
    }
    local function corner(ui, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 10)
        c.Parent = ui
        return c
    end
    local function stroke(ui, th, col)
        local s = Instance.new("UIStroke")
        s.Thickness = th or 1.5
        s.Color = col or THEME.GREEN
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = ui
        return s
    end

    -- สร้าง layout กลางถ้ายังไม่มี (ไม่ลบของแท็บอื่น)
    local vlist = scroll:FindFirstChildOfClass("UIListLayout")
    if not vlist then
        vlist = Instance.new("UIListLayout")
        vlist.Padding = UDim.new(0, 12)
        vlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
        vlist.VerticalAlignment   = Enum.VerticalAlignment.Top
        vlist.SortOrder           = Enum.SortOrder.LayoutOrder
        vlist.Parent = scroll
    end
    scroll.ScrollingDirection  = Enum.ScrollingDirection.Y
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- ลบเฉพาะบล็อกโปรไฟล์ของตัวเอง (กันซ้ำ)
    local old = scroll:FindFirstChild("Section_Profile")
    if old then old:Destroy() end

    -- ===== Section: Profile =====
    local section = Instance.new("Frame")
    section.Name = "Section_Profile"
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.LayoutOrder = 10
    section.Parent = scroll

    local layout = Instance.new("UIListLayout", section)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment   = Enum.VerticalAlignment.Top
    layout.Padding             = UDim.new(0, 10)

    -- Avatar
    local avatarWrap = Instance.new("Frame", section)
    avatarWrap.BackgroundColor3 = THEME.BG_INNER
    avatarWrap.Size = UDim2.fromOffset(150, 150)
    corner(avatarWrap, 12)
    stroke(avatarWrap, 1.6, THEME.GREEN)

    local avatarImg = Instance.new("ImageLabel", avatarWrap)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Size = UDim2.fromScale(1, 1)
    avatarImg.ImageTransparency = 1

    task.spawn(function()
        if lp then
            local ok, url = pcall(function()
                return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            end)
            if ok and url then
                pcall(function() Content:PreloadAsync({url}) end)
                avatarImg.Image = url
                avatarImg.ImageTransparency = 0
            end
        end
    end)

    -- Name
    local nameBar = Instance.new("Frame", section)
    nameBar.BackgroundColor3 = THEME.BG_INNER
    nameBar.Size = UDim2.fromOffset(220, 36)
    corner(nameBar, 8)
    stroke(nameBar, 1.3, THEME.GREEN)

    local nameLbl = Instance.new("TextLabel", nameBar)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Size = UDim2.fromScale(1, 1)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 16
    nameLbl.TextColor3 = THEME.WHITE
    nameLbl.TextXAlignment = Enum.TextXAlignment.Center
    nameLbl.TextYAlignment = Enum.TextYAlignment.Center
    nameLbl.Text = (lp and lp.DisplayName) or "Player"
end)
-- ===== UFO HUB X • Player Tab — MODEL A LEGACY 2.3.9j (TAP-FIX + METAL SQUARE KNOB) =====
-- เปลี่ยน knob กลม -> สี่เหลี่ยมแนวตั้งเมทัลลิก

registerRight("Player", function(scroll)
    local Players=game:GetService("Players")
    local RunService=game:GetService("RunService")
    local UserInputService=game:GetService("UserInputService")
    local TweenService=game:GetService("TweenService")
    local PhysicsService=game:GetService("PhysicsService")
    local lp=Players.LocalPlayer

    -- ---------- SAFE STATE / CONNECTION MANAGER ----------
    _G.UFOX = _G.UFOX or {}
    _G.UFOX.tempConns = _G.UFOX.tempConns or {}
    _G.UFOX.uiConns   = _G.UFOX.uiConns   or {}
    _G.UFOX.movers    = _G.UFOX.movers    or {}
    _G.UFOX.gui       = _G.UFOX.gui or nil
    _G.UFOX.noclipPulse = _G.UFOX.noclipPulse or nil

    local function keepTemp(c) table.insert(_G.UFOX.tempConns,c) return c end
    local function keepUI(c)   table.insert(_G.UFOX.uiConns,c)   return c end
    local function disconnectAll(list) for i=#list,1,-1 do local c=list[i] pcall(function() c:Disconnect() end) list[i]=nil end end
    local function cleanupRuntime()
        disconnectAll(_G.UFOX.tempConns)
        if _G.UFOX.noclipPulse then pcall(function() _G.UFOX.noclipPulse:Disconnect() end) _G.UFOX.noclipPulse=nil end
        if _G.UFOX.gui then pcall(function() _G.UFOX.gui:Destroy() end) _G.UFOX.gui=nil end
        local ch=lp.Character
        if ch then
            for _,n in ipairs({"UFO_BP","UFO_AO","UFO_Att"}) do local i=ch:FindFirstChild(n,true); if i then pcall(function() i:Destroy() end) end end
            for _,p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide=true; p.CanTouch=true; p.CanQuery=true
                    pcall(function() PhysicsService:SetPartCollisionGroup(p,"Default") end)
                end
            end
            local hrp=ch:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Velocity=Vector3.zero; hrp.RotVelocity=Vector3.zero end
        end
        _G.UFOX.movers={}
    end
    disconnectAll(_G.UFOX.uiConns)

    -- ---------- THEME / HELPERS ----------
    local THEME={GREEN=Color3.fromRGB(25,255,125),RED=Color3.fromRGB(255,40,40),WHITE=Color3.fromRGB(255,255,255),BLACK=Color3.fromRGB(0,0,0),
                 GREY=Color3.fromRGB(180,180,185), DARK=Color3.fromRGB(60,60,65)}
    local function corner(ui,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=ui end
    local function stroke(ui,th,col) local s=Instance.new("UIStroke") s.Thickness=th or 2 s.Color=col or THEME.GREEN s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=ui end
    local function tween(o,p,d) TweenService:Create(o,TweenInfo.new(d or 0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
    local function guiRoot() return lp:WaitForChild("PlayerGui") end

    -- ---------- CONFIG ----------
    local hoverHeight, BASE_MOVE, BASE_STRAFE, BASE_ASCEND = 6,150,100,100
    local dampFactor=4000
    local S_MIN,S_MAX=0.0,2.0
    local MIN_MULT,MAX_MULT=0.9,3.0

    -- ---------- STATE ----------
    local flightOn=false
    local hold={fwd=false,back=false,left=false,right=false,up=false,down=false}
    local savedAnimate
    local sensTarget,sensApplied=0,0

    local firstRun = (_G.UFOX_sensRel == nil)
    local currentRel = _G.UFOX_sensRel or 0
    local visRel     = currentRel
    local sliderCenterLabel

    -- slider drag/tap state
    local dragging=false
    local maybeDrag=false
    local downX=nil
    local RSdragConn, EndDragConn
    local lastTouchX
    local DRAG_THRESHOLD = 5  -- px

    local function speeds()
        local norm=(S_MAX>0) and (sensApplied/S_MAX) or 0
        local mult=MIN_MULT+(MAX_MULT-MIN_MULT)*math.clamp(norm,0,1)
        return BASE_MOVE*mult,BASE_STRAFE*mult,BASE_ASCEND*mult
    end
    local function getHRP()
        local c=lp.Character
        return c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid"), c
    end

    -- ---------- NOCLIP ----------
    local function setPartsClip(char,noclip)
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide=not noclip; p.CanTouch=not noclip; p.CanQuery=not noclip
                if not noclip then pcall(function() PhysicsService:SetPartCollisionGroup(p,"Default") end) end
            end
        end
    end
    local function forceNoclipLoop(enable)
        if _G.UFOX.noclipPulse then _G.UFOX.noclipPulse:Disconnect() _G.UFOX.noclipPulse=nil end
        if not enable then return end
        _G.UFOX.noclipPulse=keepTemp(RunService.Stepped:Connect(function()
            local _,_,char=getHRP(); if not char then return end
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false; p.CanTouch=false; p.CanQuery=false end
            end
        end))
    end

    -- ---------- JOYPAD ----------
    local function createPad()
        if _G.UFOX.gui then _G.UFOX.gui:Destroy() end
        local gui=Instance.new("ScreenGui")
        gui.Name="UFO_FlyPad"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
        gui.DisplayOrder=999999; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=guiRoot()
        _G.UFOX.gui=gui
        local SIZE,GAP=64,10
        local pad=Instance.new("Frame",gui); pad.AnchorPoint=Vector2.new(0,1); pad.Position=UDim2.new(0,100,1,-140)
        pad.Size=UDim2.fromOffset(SIZE*3+GAP*2,SIZE*3+GAP*2); pad.BackgroundTransparency=1
        local function btn(p,x,y,t)
            local b=Instance.new("TextButton",p); b.Size=UDim2.fromOffset(SIZE,SIZE); b.Position=UDim2.new(0,x,0,y)
            b.BackgroundColor3=THEME.BLACK; b.Text=t; b.Font=Enum.Font.GothamBold; b.TextSize=28
            b.TextColor3=THEME.WHITE; b.AutoButtonColor=false; corner(b,10); stroke(b,2,THEME.GREEN); return b
        end
        local f=btn(pad,SIZE+GAP,0,"🔼")
        local bb=btn(pad,SIZE+GAP,SIZE*2+GAP*2,"🔽")
        local l=btn(pad,0,SIZE+GAP,"◀️")
        local r=btn(pad,(SIZE+GAP)*2,SIZE+GAP,"▶️")
        local rw=Instance.new("Frame",gui); rw.AnchorPoint=Vector2.new(1,0.5); rw.Position=UDim2.new(1,-120,0.5,0)
        rw.Size=UDim2.fromOffset(64,64*2+GAP); rw.BackgroundTransparency=1
        local u=btn(rw,0,0,"⬆️"); local d=btn(rw,0,64+GAP,"⬇️")
        local function bind(but,key)
            keepUI(but.InputBegan:Connect(function(io)
                if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then hold[key]=true end
            end))
            keepUI(but.InputEnded:Connect(function(io)
                if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then hold[key]=false end
            end))
        end
        bind(f,"fwd"); bind(bb,"back"); bind(l,"left"); bind(r,"right"); bind(u,"up"); bind(d,"down")
    end

    -- ---------- FLIGHT ----------
    local function startFly()
        cleanupRuntime()
        local hrp,hum,char=getHRP(); if not hrp or not hum then return end
        flightOn=true; hum.AutoRotate=false
        local an=char:FindFirstChild("Animate"); if an and an:IsA("LocalScript") then an.Enabled=false; savedAnimate=an end
        hrp.Anchored=false; hum.PlatformStand=false

        local bp=Instance.new("BodyPosition",hrp); bp.Name="UFO_BP"; bp.MaxForce=Vector3.new(1e7,1e7,1e7)
        bp.P=9e4; bp.D=dampFactor; bp.Position=hrp.Position+Vector3.new(0,hoverHeight,0)
        local att=Instance.new("Attachment",hrp); att.Name="UFO_Att"
        local ao=Instance.new("AlignOrientation",hrp); ao.Name="UFO_AO"
        ao.Attachment0=att; ao.Responsiveness=240; ao.MaxAngularVelocity=math.huge; ao.RigidityEnabled=true
        ao.Mode=Enum.OrientationAlignmentMode.OneAttachment
        _G.UFOX.movers={bp=bp,ao=ao,att=att}

        createPad(); setPartsClip(char,true); forceNoclipLoop(true)

        keepTemp(RunService.Heartbeat:Connect(function(dt)
            sensApplied=sensApplied+(sensTarget-sensApplied)*math.clamp(dt*10,0,1)
            local cam=workspace.CurrentCamera; if not cam then return end
            local camCF=cam.CFrame; local fwd=camCF.LookVector
            local rightH=Vector3.new(camCF.RightVector.X,0,camCF.RightVector.Z); rightH=(rightH.Magnitude>0) and rightH.Unit or Vector3.new()
            local MOVE,STRAFE,ASC=speeds(); local pos=bp.Position
            if hold.fwd  then pos+=fwd*(MOVE*dt) end
            if hold.back then pos-=fwd*(MOVE*dt) end
            if hold.left then pos-=rightH*(STRAFE*dt) end
            if hold.right then pos+=rightH*(STRAFE*dt) end
            if hold.up   then pos+=Vector3.new(0,ASC*dt,0) end
            if hold.down then pos-=Vector3.new(0,ASC*dt,0) end
            bp.Position=pos
            ao.CFrame=CFrame.lookAt(hrp.Position,hrp.Position+camCF.LookVector,Vector3.new(0,1,0))
        end))
    end

    local function stopFly()
        flightOn=false
        local hrp,hum,char=getHRP(); if char then setPartsClip(char,false) end
        cleanupRuntime()
        if hum then hum.AutoRotate=true end
        if savedAnimate then savedAnimate.Enabled=true; savedAnimate=nil end
        hold={fwd=false,back=false,left=false,right=false,up=false,down=false}
    end

    -- ---------- HOTKEYS / SENS ----------
    local function applyRel(rel,instant)
        rel=math.clamp(rel,0,1)
        currentRel=rel
        _G.UFOX_sensRel = currentRel
        sensTarget=S_MIN+(S_MAX-S_MIN)*rel
        if sliderCenterLabel then sliderCenterLabel.Text=string.format("%d%%",math.floor(rel*100+0.5)) end
        if instant then sensApplied=sensTarget end
    end
    keepUI(UserInputService.InputBegan:Connect(function(io,gp)
        if gp then return end
        local k=io.KeyCode
        if k==Enum.KeyCode.W then hold.fwd=true end
        if k==Enum.KeyCode.S then hold.back=true end
        if k==Enum.KeyCode.A then hold.left=true end
        if k==Enum.KeyCode.D then hold.right=true end
        if k==Enum.KeyCode.Space or k==Enum.KeyCode.E then hold.up=true end
        if k==Enum.KeyCode.LeftShift or k==Enum.KeyCode.Q then hold.down=true end
        if k==Enum.KeyCode.F then if flightOn then stopFly() else startFly() end end
        if k==Enum.KeyCode.LeftBracket then applyRel(currentRel-0.05,true)
        elseif k==Enum.KeyCode.RightBracket then applyRel(currentRel+0.05,true) end
    end))
    keepUI(UserInputService.InputEnded:Connect(function(io,gp)
        if gp then return end
        local k=io.KeyCode
        if k==Enum.KeyCode.W then hold.fwd=false end
        if k==Enum.KeyCode.S then hold.back=false end
        if k==Enum.KeyCode.A then hold.left=false end
        if k==Enum.KeyCode.D then hold.right=false end
        if k==Enum.KeyCode.Space or k==Enum.KeyCode.E then hold.up=false end
        if k==Enum.KeyCode.LeftShift or k==Enum.KeyCode.Q then hold.down=false end
    end))
    keepUI(UserInputService.InputChanged:Connect(function(io)
        if io.UserInputType==Enum.UserInputType.MouseWheel then
            applyRel(currentRel + math.clamp(io.Position.Z,-1,1)*0.05, true)
        elseif io.UserInputType==Enum.UserInputType.Touch then
            lastTouchX = io.Position.X
        end
    end))

    -- ---------- UI BUILD ----------
    for _,n in ipairs({"Section_FlightHeader","Row_FlightToggle","Row_Sens"}) do local o=scroll:FindFirstChild(n); if o then o:Destroy() end end
    local vlist=scroll:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout",scroll)
    vlist.Padding=UDim.new(0,12); vlist.SortOrder=Enum.SortOrder.LayoutOrder
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local nextOrder=10; for _,ch in ipairs(scroll:GetChildren()) do if ch:IsA("GuiObject") and ch~=vlist then nextOrder=math.max(nextOrder,(ch.LayoutOrder or 0)+1) end end

    local header=Instance.new("TextLabel",scroll)
    header.Name="Section_FlightHeader"; header.BackgroundTransparency=1; header.Size=UDim2.new(1,0,0,36)
    header.Font=Enum.Font.GothamBold; header.TextSize=16; header.TextColor3=THEME.WHITE
    header.TextXAlignment=Enum.TextXAlignment.Left; header.Text="Flight Mode 🛸"; header.LayoutOrder=nextOrder

    local row=Instance.new("Frame",scroll); row.Name="Row_FlightToggle"; row.Size=UDim2.new(1,-6,0,46)
    row.BackgroundColor3=THEME.BLACK; corner(row,12); stroke(row,2.2,THEME.GREEN); row.LayoutOrder=nextOrder+1
    local lab=Instance.new("TextLabel",row); lab.BackgroundTransparency=1; lab.Size=UDim2.new(1,-140,1,0); lab.Position=UDim2.new(0,16,0,0)
    lab.Font=Enum.Font.GothamBold; lab.TextSize=13; lab.TextColor3=THEME.WHITE; lab.TextXAlignment=Enum.TextXAlignment.Left; lab.Text="Flight Mode"
    local sw=Instance.new("Frame",row); sw.AnchorPoint=Vector2.new(1,0.5); sw.Position=UDim2.new(1,-12,0.5,0)
    sw.Size=UDim2.fromOffset(52,26); sw.BackgroundColor3=THEME.BLACK; corner(sw,13)
    local swStroke=Instance.new("UIStroke",sw); swStroke.Thickness=1.8; swStroke.Color=THEME.RED
    local knob=Instance.new("Frame",sw); knob.Size=UDim2.fromOffset(22,22); knob.Position=UDim2.new(0,2,0.5,-11); knob.BackgroundColor3=THEME.WHITE; corner(knob,11)
    local btn=Instance.new("TextButton",sw); btn.BackgroundTransparency=1; btn.Size=UDim2.fromScale(1,1); btn.Text=""
    local on=false
    local function setState(v)
        on=v
        if v then swStroke.Color=THEME.GREEN; tween(knob,{Position=UDim2.new(1,-24,0.5,-11)},0.1); startFly()
        else     swStroke.Color=THEME.RED;   tween(knob,{Position=UDim2.new(0,2,0.5,-11)},0.1); stopFly() end
    end
    keepUI(btn.MouseButton1Click:Connect(function() setState(not on) end))

    -- ---------- SLIDER (tap-to-set + drag threshold) ----------
    local sRow=Instance.new("Frame",scroll); sRow.Name="Row_Sens"; sRow.Size=UDim2.new(1,-6,0,70)
    sRow.BackgroundColor3=THEME.BLACK; corner(sRow,12); stroke(sRow,2.2,THEME.GREEN); sRow.LayoutOrder=nextOrder+2
    local sLab=Instance.new("TextLabel",sRow); sLab.BackgroundTransparency=1; sLab.Position=UDim2.new(0,16,0,4)
    sLab.Size=UDim2.new(1,-32,0,24); sLab.Font=Enum.Font.GothamBold; sLab.TextSize=13; sLab.TextColor3=THEME.WHITE; sLab.TextXAlignment=Enum.TextXAlignment.Left; sLab.Text="Sensitivity"
    local bar=Instance.new("Frame",sRow); bar.Position=UDim2.new(0,16,0,34); bar.Size=UDim2.new(1,-32,0,16)
    bar.BackgroundColor3=THEME.BLACK; corner(bar,8); stroke(bar,1.8,THEME.GREEN); bar.Active=true
    local fill=Instance.new("Frame",bar); fill.BackgroundColor3=THEME.GREEN; corner(fill,8); fill.Size=UDim2.fromScale(0,1)

    -- ==== NEW: สี่เหลี่ยมแนวตั้งเมทัลลิก ====
    local knobShadow=Instance.new("Frame",bar)
    knobShadow.Size=UDim2.fromOffset(18,34); knobShadow.AnchorPoint=Vector2.new(0.5,0.5)
    knobShadow.Position=UDim2.new(0,0,0.5,2); knobShadow.BackgroundColor3=THEME.DARK
    knobShadow.BorderSizePixel=0; knobShadow.BackgroundTransparency=0.45; knobShadow.ZIndex=2

    local knobBtn=Instance.new("ImageButton",bar)
    knobBtn.AutoButtonColor=false; knobBtn.BackgroundColor3=THEME.GREY
    knobBtn.Size=UDim2.fromOffset(16,32)          -- สี่เหลี่ยมยาวแนวตั้ง
    knobBtn.AnchorPoint=Vector2.new(0.5,0.5)
    knobBtn.Position=UDim2.new(0,0,0.5,0)
    knobBtn.BorderSizePixel=0; knobBtn.ZIndex=3
    local kStroke=Instance.new("UIStroke",knobBtn); kStroke.Thickness=1.2; kStroke.Color=Color3.fromRGB(210,210,215)
    local kGrad=Instance.new("UIGradient",knobBtn)
    kGrad.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(236,236,240)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(182,182,188)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(216,216,222))
    }
    kGrad.Rotation=90
    -- ======================================

    local centerVal=Instance.new("TextLabel",bar); centerVal.BackgroundTransparency=1; centerVal.Size=UDim2.fromScale(1,1)
    centerVal.Font=Enum.Font.GothamBlack; centerVal.TextSize=16; centerVal.TextColor3=THEME.WHITE; centerVal.TextStrokeTransparency=0.2; centerVal.Text="0%"
    sliderCenterLabel=centerVal

    local function relFrom(x) return (x - bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X) end
    local function syncVisual(now)
        if now then visRel=currentRel else visRel = visRel + (currentRel - visRel)*0.30 end
        visRel = math.clamp(visRel,0,1)
        fill.Size=UDim2.fromScale(visRel,1)
        knobBtn.Position=UDim2.new(visRel,0,0.5,0)     -- อัปเดตให้ใช้ anchor กลาง, ไม่มี offset
        knobShadow.Position=UDim2.new(visRel,0,0.5,2)
        centerVal.Text=string.format("%d%%",math.floor(visRel*100+0.5))
    end

    -- drag/tap logic (เหมือนเดิม)
    local function stopDrag()
        dragging=false; maybeDrag=false; downX=nil
        if RSdragConn then RSdragConn:Disconnect() RSdragConn=nil end
        if EndDragConn then EndDragConn:Disconnect() EndDragConn=nil end
        scroll.ScrollingEnabled=true
    end
    local function beginDragLoop()
        dragging=true; maybeDrag=false
        RSdragConn = keepTemp(RunService.RenderStepped:Connect(function()
            local mx = UserInputService:GetMouseLocation().X
            local x = lastTouchX or mx
            if dragging then
                local r = relFrom(x)
                applyRel(r,false)
            end
            syncVisual(false)
        end))
        EndDragConn = keepTemp(UserInputService.InputEnded:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then stopDrag() end
        end))
    end
    local function onPress(px)
        maybeDrag=true; dragging=false; downX=px
        scroll.ScrollingEnabled=false
        applyRel(relFrom(px), true); syncVisual(true)
    end
    local function onMove(mx)
        if not maybeDrag then return end
        if downX==nil then downX=mx end
        if math.abs(mx - downX) >= DRAG_THRESHOLD then beginDragLoop() end
    end
    keepUI(UserInputService.InputChanged:Connect(function(io)
        if io.UserInputType==Enum.UserInputType.MouseMovement or io.UserInputType==Enum.UserInputType.Touch then
            local x = (io.UserInputType==Enum.UserInputType.Touch) and io.Position.X or UserInputService:GetMouseLocation().X
            if io.UserInputType==Enum.UserInputType.Touch then lastTouchX=x end
            onMove(x)
        end
    end))
    keepUI(UserInputService.InputEnded:Connect(function(io)
        if maybeDrag and (io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch) then stopDrag() end
    end))
    local function onPressFromInput(io) onPress(io.Position.X) end
    keepUI(bar.InputBegan:Connect(function(io)
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then onPressFromInput(io) end
    end))
    keepUI(knobBtn.InputBegan:Connect(function(io)
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then onPressFromInput(io) end
    end))

    -- ---------- INIT ----------
    if firstRun then applyRel(0,true) else applyRel(currentRel,true) end
    syncVisual(true)
end)
-- ===== UFO HUB X • Player — SPEED & JUMP • Model A V1 (FULL BAR + LEGACY-SMOOTH DRAG + TAP) =====
-- Full-width bar • Thin vertical metal knob • Tap-to-set + drag only after 5px • 500 cap • per-slider smooth

registerRight("Player", function(scroll)
    local Players=game:GetService("Players")
    local UIS=game:GetService("UserInputService")
    local RS=game:GetService("RunService")
    local TweenService=game:GetService("TweenService")
    local lp=Players.LocalPlayer

    -- ---------- STATE ----------
    _G.UFOX_RJ = _G.UFOX_RJ or { uiConns={}, tempConns={}, remember={}, defaults={} }
    local RJ=_G.UFOX_RJ
    local function keepUI(c) table.insert(RJ.uiConns,c) return c end
    local function keepTmp(c) table.insert(RJ.tempConns,c) return c end
    local function disconnectAll(t) for i=#t,1,-1 do local c=t[i]; pcall(function() c:Disconnect() end); t[i]=nil end end
    local function stopAllTemp() disconnectAll(RJ.tempConns); scroll.ScrollingEnabled=true end

    disconnectAll(RJ.uiConns)

    -- remember (เริ่ม 0%)
    RJ.remember.enabled = (RJ.remember.enabled==nil) and false or RJ.remember.enabled
    RJ.remember.infJump = (RJ.remember.infJump==nil) and false or RJ.remember.infJump
    RJ.remember.runRel  = (RJ.remember.runRel==nil)  and 0 or RJ.remember.runRel
    RJ.remember.jumpRel = (RJ.remember.jumpRel==nil) and 0 or RJ.remember.jumpRel

    local RUN_MIN,RUN_MAX   = 16,500
    local JUMP_MIN,JUMP_MAX = 50,500
    local runRel,  jumpRel  = RJ.remember.runRel, RJ.remember.jumpRel
    local masterOn,infJumpOn= RJ.remember.enabled, RJ.remember.infJump

    RJ.defaults = RJ.defaults or { WalkSpeed=nil, JumpPower=nil, UseJumpPower=nil, JumpHeight=nil }

    local function getHum() local ch=lp.Character return ch and ch:FindFirstChildOfClass("Humanoid") end
    local function lerp(a,b,t) return a+(b-a)*t end
    local function mapRel(r,mn,mx) r=math.clamp(r,0,1) return lerp(mn,mx,r) end

    local function snapshotDefaults()
        local h=getHum(); if not h then return end
        if RJ.defaults.WalkSpeed==nil    then RJ.defaults.WalkSpeed=h.WalkSpeed end
        if RJ.defaults.UseJumpPower==nil then RJ.defaults.UseJumpPower=h.UseJumpPower end
        if RJ.defaults.JumpPower==nil    then RJ.defaults.JumpPower=h.JumpPower end
        if RJ.defaults.JumpHeight==nil   then RJ.defaults.JumpHeight=h.JumpHeight end
    end

    local function applyStats()
        local h=getHum(); if not h then return end
        if masterOn then
            snapshotDefaults()
            local ws=math.floor(mapRel(runRel, RUN_MIN, RUN_MAX)+0.5)
            local jp=math.floor(mapRel(jumpRel,JUMP_MIN,JUMP_MAX)+0.5)
            pcall(function()
                if h.UseJumpPower then h.JumpPower=jp else h.JumpHeight = 7 + (jp-50)*0.25 end
                h.WalkSpeed=ws
            end)
        else
            pcall(function()
                if RJ.defaults.WalkSpeed then h.WalkSpeed=RJ.defaults.WalkSpeed end
                if RJ.defaults.UseJumpPower~=nil then
                    if RJ.defaults.UseJumpPower then
                        if RJ.defaults.JumpPower  then h.JumpPower = RJ.defaults.JumpPower end
                    else
                        if RJ.defaults.JumpHeight then h.JumpHeight = RJ.defaults.JumpHeight end
                    end
                end
            end)
        end
    end

    -- Infinite Jump
    stopAllTemp()
    local function bindInfJump()
        stopAllTemp()
        if not infJumpOn then return end
        keepTmp(UIS.JumpRequest:Connect(function()
            local h=getHum(); if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
        end))
    end
    keepUI(lp.CharacterAdded:Connect(function()
        RJ.defaults={WalkSpeed=nil,JumpPower=nil,UseJumpPower=nil,JumpHeight=nil}
        task.defer(function() applyStats(); bindInfJump() end)
    end))

    -- ---------- THEME ----------
    local THEME={
        GREEN=Color3.fromRGB(25,255,125), RED=Color3.fromRGB(255,40,40),
        WHITE=Color3.fromRGB(255,255,255), BLACK=Color3.fromRGB(0,0,0),
        GREY =Color3.fromRGB(180,180,185), DARK=Color3.fromRGB(60,60,65)
    }
    local function corner(ui,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12); c.Parent=ui end
    local function stroke(ui,th,col) local s=Instance.new("UIStroke") s.Thickness=th or 2; s.Color=col or THEME.GREEN; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=ui end
    local function tween(o,p,d) TweenService:Create(o,TweenInfo.new(d or 0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end

    -- rebuild UI base
    for _,n in ipairs({"RJ_Header","RJ_Master","RJ_Run","RJ_Jump","RJ_Inf"}) do local o=scroll:FindFirstChild(n); if o then o:Destroy() end end
    local vlist=scroll:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout",scroll)
    vlist.Padding=UDim.new(0,12); vlist.SortOrder=Enum.SortOrder.LayoutOrder
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local baseOrder=1000; for _,ch in ipairs(scroll:GetChildren()) do if ch:IsA("GuiObject") and ch~=vlist then baseOrder=math.max(baseOrder,(ch.LayoutOrder or 0)+1) end end

    -- Header
    local header=Instance.new("TextLabel",scroll)
    header.Name="RJ_Header"; header.LayoutOrder=baseOrder
    header.BackgroundTransparency=1; header.Size=UDim2.new(1,0,0,32)
    header.Font=Enum.Font.GothamBold; header.TextSize=16; header.TextColor3=THEME.WHITE
    header.TextXAlignment=Enum.TextXAlignment.Left
    header.Text="Fast Run & High Jump 🏃‍♂️💨🦘"

    -- Master toggle
    local master=Instance.new("Frame",scroll); master.Name="RJ_Master"; master.LayoutOrder=baseOrder+1
    master.Size=UDim2.new(1,-6,0,46); master.BackgroundColor3=THEME.BLACK; corner(master,12); stroke(master,2.2,THEME.GREEN)
    local mLab=Instance.new("TextLabel",master); mLab.BackgroundTransparency=1; mLab.Size=UDim2.new(1,-140,1,0); mLab.Position=UDim2.new(0,16,0,0)
    mLab.Font=Enum.Font.GothamBold; mLab.TextSize=13; mLab.TextColor3=THEME.WHITE; mLab.TextXAlignment=Enum.TextXAlignment.Left; mLab.Text="Enable Fast Run & High Jump"
    local mSw=Instance.new("Frame",master); mSw.AnchorPoint=Vector2.new(1,0.5); mSw.Position=UDim2.new(1,-12,0.5,0)
    mSw.Size=UDim2.fromOffset(52,26); mSw.BackgroundColor3=THEME.BLACK; corner(mSw,13); stroke(mSw,1.8, masterOn and THEME.GREEN or THEME.RED)
    local mKnob=Instance.new("Frame",mSw); mKnob.Size=UDim2.fromOffset(22,22); mKnob.Position=UDim2.new(masterOn and 1 or 0, masterOn and -24 or 2, 0.5,-11); mKnob.BackgroundColor3=THEME.WHITE; corner(mKnob,11)
    local mBtn=Instance.new("TextButton",mSw); mBtn.BackgroundTransparency=1; mBtn.Size=UDim2.fromScale(1,1); mBtn.Text=""
    local function setMaster(v) masterOn=v; RJ.remember.enabled=v; local st=mSw:FindFirstChildOfClass("UIStroke"); if st then st.Color=v and THEME.GREEN or THEME.RED end; tween(mKnob,{Position=UDim2.new(v and 1 or 0, v and -24 or 2, 0.5,-11)},0.08); applyStats() end
    keepUI(mBtn.MouseButton1Click:Connect(function() setMaster(not masterOn) end))

    -- ========= Slider (FULL bar + tap-to-set + 5px threshold + smooth render loop) =========
    local function buildSlider(name, order, title, getRel, setRel)
        local row=Instance.new("Frame",scroll) row.Name=name row.LayoutOrder=order
        row.Size=UDim2.new(1,-6,0,70) row.BackgroundColor3=THEME.BLACK corner(row,12) stroke(row,2.2,THEME.GREEN)

        local lab=Instance.new("TextLabel",row)
        lab.BackgroundTransparency=1 lab.Position=UDim2.new(0,16,0,4) lab.Size=UDim2.new(1,-32,0,24)
        lab.Font=Enum.Font.GothamBold lab.TextSize=13 lab.TextColor3=THEME.WHITE lab.TextXAlignment=Enum.TextXAlignment.Left
        lab.Text=title

        local bar=Instance.new("Frame",row)
        bar.Position=UDim2.new(0,16,0,34); bar.Size=UDim2.new(1,-32,0,16)
        bar.BackgroundColor3=THEME.BLACK; corner(bar,8); stroke(bar,1.8,THEME.GREEN); bar.Active=true; bar.ZIndex=1

        local fill=Instance.new("Frame",bar); fill.BackgroundColor3=THEME.GREEN; corner(fill,8); fill.ZIndex=1
        local knobShadow=Instance.new("Frame",bar); knobShadow.Size=UDim2.fromOffset(18,34); knobShadow.AnchorPoint=Vector2.new(0.5,0.5); knobShadow.BackgroundColor3=THEME.DARK; knobShadow.BorderSizePixel=0; knobShadow.BackgroundTransparency=0.45; knobShadow.ZIndex=2
        local knob=Instance.new("ImageButton",bar); knob.AutoButtonColor=false; knob.BackgroundColor3=THEME.GREY; knob.Size=UDim2.fromOffset(16,32); knob.AnchorPoint=Vector2.new(0.5,0.5); knob.BorderSizePixel=0; knob.ZIndex=3
        stroke(knob,1.2,Color3.fromRGB(210,210,215))
        local grad=Instance.new("UIGradient",knob); grad.Color=ColorSequence.new{ ColorSequenceKeypoint.new(0.00,Color3.fromRGB(236,236,240)), ColorSequenceKeypoint.new(0.50,Color3.fromRGB(182,182,188)), ColorSequenceKeypoint.new(1.00,Color3.fromRGB(216,216,222)) }; grad.Rotation=90

        local centerVal=Instance.new("TextLabel",bar); centerVal.BackgroundTransparency=1; centerVal.Size=UDim2.fromScale(1,1); centerVal.Font=Enum.Font.GothamBlack; centerVal.TextSize=16; centerVal.TextColor3=THEME.WHITE; centerVal.TextXAlignment=Enum.TextXAlignment.Center; centerVal.ZIndex=1

        local hit=Instance.new("TextButton",bar); hit.BackgroundTransparency=1; hit.Size=UDim2.fromScale(1,1); hit.Text=""; hit.ZIndex=4

        -- per-slider smooth visual
        local visRel=getRel()
        local function relFrom(x) return (x - bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X) end
        local function setRelClamped(r) r=math.clamp(r,0,1); setRel(r); end
        local function syncVisual(now)
            if not now then visRel = visRel + (getRel() - visRel)*0.30 else visRel=getRel() end
            visRel=math.clamp(visRel,0,1)
            fill.Size=UDim2.fromScale(visRel,1)
            knob.Position=UDim2.new(visRel,0,0.5,0)
            knobShadow.Position=UDim2.new(visRel,0,0.5,2)
            centerVal.Text=string.format("%d%%", math.floor(visRel*100+0.5))
        end
        local function instantVisual() visRel=getRel(); syncVisual(true) end

        -- drag state (legacy style)
        local DRAG_THRESHOLD=5
        local dragging=false; local maybeDrag=false; local downX=nil
        local rsConn,endConn,chgConn

        local function endDrag()
            if rsConn  then rsConn:Disconnect()  rsConn=nil end
            if endConn then endConn:Disconnect() endConn=nil end
            if chgConn then chgConn:Disconnect() chgConn=nil end
            dragging=false; maybeDrag=false; downX=nil; scroll.ScrollingEnabled=true
            applyStats()
        end

        local function beginDragLoop()
            dragging=true; maybeDrag=false
            rsConn=keepTmp(RS.RenderStepped:Connect(function()
                -- ระหว่างลาก ทำ visual lerp ให้ลื่น
                visRel = visRel + (getRel() - visRel)*0.30
                fill.Size=UDim2.fromScale(visRel,1)
                knob.Position=UDim2.new(visRel,0,0.5,0)
                knobShadow.Position=UDim2.new(visRel,0,0.5,2)
                centerVal.Text=string.format("%d%%", math.floor(visRel*100+0.5))
            end))
            endConn=keepTmp(UIS.InputEnded:Connect(function(io)
                if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then endDrag() end
            end))
            chgConn=keepTmp(UIS.InputChanged:Connect(function(io)
                if not dragging then return end
                if io.UserInputType==Enum.UserInputType.MouseMovement then
                    setRelClamped(relFrom(UIS:GetMouseLocation().X))
                elseif io.UserInputType==Enum.UserInputType.Touch then
                    setRelClamped(relFrom(io.Position.X))
                end
            end))
        end

        local function onPress(px)
            stopAllTemp()
            scroll.ScrollingEnabled=false
            -- tap: เซ็ตทันทีแบบนิ่ม ๆ (ไม่ลากจนกว่าจะขยับเกิน threshold)
            setRelClamped(relFrom(px)); instantVisual(); applyStats()
            maybeDrag=true; dragging=false; downX=px
        end

        local function onMove(mx)
            if not maybeDrag then return end
            if downX==nil then downX=mx end
            if math.abs(mx-downX) >= DRAG_THRESHOLD then
                beginDragLoop()
            end
        end

        -- listen for move while maybe-drag
        keepUI(UIS.InputChanged:Connect(function(io)
            if not maybeDrag then return end
            if io.UserInputType==Enum.UserInputType.MouseMovement then onMove(UIS:GetMouseLocation().X)
            elseif io.UserInputType==Enum.UserInputType.Touch then onMove(io.Position.X) end
        end))
        keepUI(UIS.InputEnded:Connect(function(io)
            if maybeDrag and (io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch) then
                endDrag() -- tap only, ไม่เข้าสู่โหมดลาก
            end
        end))

        -- start from bar/knob/tap overlay
        local function pressFrom(io) onPress(io.Position.X) end
        keepUI(bar.InputBegan:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then pressFrom(io) end
        end))
        keepUI(knob.InputBegan:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then pressFrom(io) end
        end))
        keepUI(hit.InputBegan:Connect(function(io)
            if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then pressFrom(io) end
        end))

        -- init visuals
        instantVisual()
        return row
    end

    -- สไลเดอร์
    buildSlider("RJ_Run",  baseOrder+2, "Run Speed",
        function() return runRel end,
        function(r) runRel=math.clamp(r,0,1); RJ.remember.runRel=runRel end)

    buildSlider("RJ_Jump", baseOrder+3, "Jump Power",
        function() return jumpRel end,
        function(r) jumpRel=math.clamp(r,0,1); RJ.remember.jumpRel=jumpRel end)

    -- Infinite Jump toggle
    local inf=Instance.new("Frame",scroll); inf.Name="RJ_Inf"; inf.LayoutOrder=baseOrder+4
    inf.Size=UDim2.new(1,-6,0,46); inf.BackgroundColor3=THEME.BLACK; corner(inf,12); stroke(inf,2.2,THEME.GREEN)
    local iLab=Instance.new("TextLabel",inf); iLab.BackgroundTransparency=1; iLab.Size=UDim2.new(1,-140,1,0); iLab.Position=UDim2.new(0,16,0,0)
    iLab.Font=Enum.Font.GothamBold; iLab.TextSize=13; iLab.TextColor3=THEME.WHITE; iLab.TextXAlignment=Enum.TextXAlignment.Left; iLab.Text="Infinite Jump"
    local iSw=Instance.new("Frame",inf); iSw.AnchorPoint=Vector2.new(1,0.5); iSw.Position=UDim2.new(1,-12,0.5,0)
    iSw.Size=UDim2.fromOffset(52,26); iSw.BackgroundColor3=THEME.BLACK; corner(iSw,13); stroke(iSw,1.8, infJumpOn and THEME.GREEN or THEME.RED)
    local iKnob=Instance.new("Frame",iSw); iKnob.Size=UDim2.fromOffset(22,22); iKnob.Position=UDim2.new(infJumpOn and 1 or 0, infJumpOn and -24 or 2, 0.5,-11)
    iKnob.BackgroundColor3=THEME.WHITE; corner(iKnob,11)
    local iBtn=Instance.new("TextButton",iSw); iBtn.BackgroundTransparency=1; iBtn.Size=UDim2.fromScale(1,1); iBtn.Text=""
    local function setInf(v) infJumpOn=v; RJ.remember.infJump=v; local st=iSw:FindFirstChildOfClass("UIStroke"); if st then st.Color = v and THEME.GREEN or THEME.RED end; tween(iKnob,{Position=UDim2.new(v and 1 or 0, v and -24 or 2, 0.5,-11)},0.08); bindInfJump() end
    keepUI(iBtn.MouseButton1Click:Connect(function() setInf(not infJumpOn) end))

    applyStats(); bindInfJump()
end)
-- ===== UFO HUB X • Player — AFK 💤 (MODEL A LEGACY, full systems) =====
-- 1) Black Screen (Performance AFK)  [toggle]
-- 2) White Screen (Performance AFK)  [toggle]
-- 3) AFK Anti-Kick (20 min)          [toggle default ON]
-- 4) Activity Watcher (5 min → enable #3) [toggle default ON]
--  • หน้าตา/ขนาด/กรอบสวิตช์ = แบบ A Legacy เดิมทั้งหมด

registerRight("Player", function(scroll)
    local Players       = game:GetService("Players")
    local TweenService  = game:GetService("TweenService")
    local UIS           = game:GetService("UserInputService")
    local RunService    = game:GetService("RunService")
    local VirtualUser   = game:GetService("VirtualUser")
    local lp            = Players.LocalPlayer

    -- ===== THEME / HELPERS (A Legacy) =====
    local THEME = {
        GREEN = Color3.fromRGB(25,255,125),
        RED   = Color3.fromRGB(255,40,40),
        WHITE = Color3.fromRGB(255,255,255),
        BLACK = Color3.fromRGB(0,0,0),
        TEXT  = Color3.fromRGB(255,255,255),
    }
    local function corner(ui,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=ui end
    local function stroke(ui,th,col) local s=Instance.new("UIStroke") s.Thickness=th or 2.2 s.Color=col or THEME.GREEN s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=ui end
    local function tween(o,p) TweenService:Create(o, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play() end

    -- ===== STATE =====
    _G.UFOX_AFK = _G.UFOX_AFK or {
        blackOn=false, whiteOn=false, antiIdleOn=true, watcherOn=true,
        lastInput=tick(), antiIdleLoop=nil, idleHooked=false,
        gui=nil,
    }
    local S = _G.UFOX_AFK

    -- ===== CLEAN preview section if exists =====
    local old = scroll:FindFirstChild("Section_AFK_Preview"); if old then old:Destroy() end
    local old2 = scroll:FindFirstChild("Section_AFK_Full");    if old2 then old2:Destroy() end

    -- list/canvas เหมือนเดิม
    local vlist = scroll:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", scroll)
    vlist.Padding = UDim.new(0,12); vlist.SortOrder = Enum.SortOrder.LayoutOrder
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local nextOrder = 10
    for _,ch in ipairs(scroll:GetChildren()) do
        if ch:IsA("GuiObject") and ch~=vlist then nextOrder = math.max(nextOrder, (ch.LayoutOrder or 0)+1) end
    end

    -- ====== Header ======
    local header = Instance.new("TextLabel", scroll)
    header.Name = "Section_AFK_Full"
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1,0,0,36)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextColor3 = THEME.TEXT
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Text = "AFK 💤"
    header.LayoutOrder = nextOrder

    -- ===== Overlay (Black/White full-screen) =====
    local function ensureGui()
        if S.gui and S.gui.Parent then return S.gui end
        local gui = Instance.new("ScreenGui")
        gui.Name="UFOX_AFK_GUI"
        gui.IgnoreGuiInset=true
        gui.ResetOnSpawn=false
        gui.DisplayOrder=999999
        gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        gui.Parent = lp:WaitForChild("PlayerGui")
        S.gui = gui
        return gui
    end
    local function clearOverlay(name)
        if S.gui then local f=S.gui:FindFirstChild(name); if f then f:Destroy() end end
    end
    local function showBlack(v)
        clearOverlay("WhiteOverlay")
        clearOverlay("BlackOverlay")
        if not v then return end
        local gui=ensureGui()
        local black=Instance.new("Frame", gui)
        black.Name="BlackOverlay"; black.BackgroundColor3=Color3.new(0,0,0)
        black.Size=UDim2.fromScale(1,1); black.ZIndex=200; black.Active=true
    end
    local function showWhite(v)
        clearOverlay("BlackOverlay")
        clearOverlay("WhiteOverlay")
        if not v then return end
        local gui=ensureGui()
        local white=Instance.new("Frame", gui)
        white.Name="WhiteOverlay"; white.BackgroundColor3=Color3.new(1,1,1)
        white.Size=UDim2.fromScale(1,1); white.ZIndex=200; white.Active=true
    end
    local function syncOverlays()
        if S.blackOn then S.whiteOn=false; showWhite(false); showBlack(true)
        elseif S.whiteOn then S.blackOn=false; showBlack(false); showWhite(true)
        else showBlack(false); showWhite(false) end
    end

    -- ===== Anti-Kick core =====
    local function pulseOnce()
        local cam = workspace.CurrentCamera
        local cf  = cam and cam.CFrame or CFrame.new()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0), cf)
        end)
    end
    local function startAntiIdle()
        if S.antiIdleLoop then return end
        S.antiIdleLoop = task.spawn(function()
            while S.antiIdleOn do
                pulseOnce()
                for i=1,540 do  -- ~9 นาที (< 20)
                    if not S.antiIdleOn then break end
                    task.wait(1)
                end
            end
            S.antiIdleLoop=nil
        end)
    end
    if not S.idleHooked then
        S.idleHooked = true
        lp.Idled:Connect(function()
            if S.antiIdleOn then pulseOnce() end
        end)
    end

    -- ===== Watcher (5 นาทีไม่ขยับ → เปิด #3) =====
    local INACTIVE = 5*60
    local function markInput() S.lastInput = tick() end
    UIS.InputBegan:Connect(markInput)
    UIS.InputChanged:Connect(function(io) if io.UserInputType ~= Enum.UserInputType.MouseWheel then markInput() end end)
    if S.watcherConn then pcall(function() S.watcherConn:Disconnect() end) S.watcherConn=nil end
    local function startWatcher()
        if S.watcherConn then return end
        S.watcherConn = RunService.Heartbeat:Connect(function()
            if not S.watcherOn then return end
            if tick() - S.lastInput >= INACTIVE then
                S.antiIdleOn = true
                if not S.antiIdleLoop then startAntiIdle() end
                pulseOnce()
                S.lastInput = tick()
            end
        end)
    end

    -- ===== UI Row helper (A Legacy switch) =====
    local function makeRow(textLabel, defaultOn, onToggle)
        local row = Instance.new("Frame", scroll)
        row.Size = UDim2.new(1,-6,0,46)
        row.BackgroundColor3 = THEME.BLACK
        corner(row,12); stroke(row,2.2,THEME.GREEN)
        row.LayoutOrder = header.LayoutOrder + 1

        local lab = Instance.new("TextLabel", row)
        lab.BackgroundTransparency = 1
        lab.Size = UDim2.new(1,-160,1,0)
        lab.Position = UDim2.new(0,16,0,0)
        lab.Font = Enum.Font.GothamBold
        lab.TextSize = 13
        lab.TextColor3 = THEME.WHITE
        lab.TextXAlignment = Enum.TextXAlignment.Left
        lab.Text = textLabel

        local sw = Instance.new("Frame", row)
        sw.AnchorPoint = Vector2.new(1,0.5)
        sw.Position = UDim2.new(1,-12,0.5,0)
        sw.Size = UDim2.fromOffset(52,26)
        sw.BackgroundColor3 = THEME.BLACK
        corner(sw,13)
        local swStroke = Instance.new("UIStroke", sw)
        swStroke.Thickness = 1.8
        swStroke.Color = defaultOn and THEME.GREEN or THEME.RED

        local knob = Instance.new("Frame", sw)
        knob.Size = UDim2.fromOffset(22,22)
        knob.Position = UDim2.new(defaultOn and 1 or 0, defaultOn and -24 or 2, 0.5, -11)
        knob.BackgroundColor3 = THEME.WHITE
        corner(knob,11)

        local state = defaultOn
        local function setState(v, instant)
            state = v
            swStroke.Color = v and THEME.GREEN or THEME.RED
            tween(knob, {Position = UDim2.new(v and 1 or 0, v and -24 or 2, 0.5, -11)})
            if onToggle then onToggle(v) end
        end
        local btn = Instance.new("TextButton", sw)
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.fromScale(1,1)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.MouseButton1Click:Connect(function() setState(not state, false) end)

        return setState
    end

    -- ===== Rows + bindings =====
    local setBlack = makeRow("Black Screen (Performance AFK)", S.blackOn, function(v)
        S.blackOn = v; if v then S.whiteOn=false end; syncOverlays()
    end)

    local setWhite = makeRow("White Screen (Performance AFK)", S.whiteOn, function(v)
        S.whiteOn = v; if v then S.blackOn=false end; syncOverlays()
    end)

    local setAnti  = makeRow("AFK Anti-Kick (20 min)", S.antiIdleOn, function(v)
        S.antiIdleOn = v
        if v then startAntiIdle() end
    end)

    local setWatch = makeRow("Activity Watcher (5 min → enable #3)", S.watcherOn, function(v)
        S.watcherOn = v
    end)

    -- ===== Init =====
    syncOverlays()
    if S.antiIdleOn then startAntiIdle() end
    startWatcher()
end)
-- ===== UFO HUB X • Settings — Language Picker (MODEL A V1) =====
-- • เปลี่ยนภาษาได้ทันที, มีช่องค้นหา, มีรายการ “ทุกภาษาใน Roblox Enum.LanguageCode”
-- • โครง i18n กลาง (_G.UFOX_I18N) สำหรับผูกข้อความที่จะต้องแปลในอนาคต
-- • ใช้สไตล์เดียวกับ A LEGACY: กรอบดำเส้นเขียว ขนาดแถว 46px

-- ---------- i18n core (หนึ่งครั้งทั่วระบบ) ----------
do
    _G.UFOX_I18N = _G.UFOX_I18N or {
        current = "en",      -- ค่าตั้งต้น
        dict    = {},        -- dict[key][lang] = text
        labels  = {},        -- { {obj=TextLabel, key="..."} , ... }
        evt     = Instance.new("BindableEvent")
    }
    local I=_G.UFOX_I18N

    function I.setLanguage(code:string)
        I.current = code
        I.evt:Fire(code)
        -- อัปเดตข้อความทุก label ที่ผูกไว้
        for _,rec in ipairs(I.labels) do
            local key, obj = rec.key, rec.obj
            local pack = I.dict[key]
            if obj and obj.Parent and pack then
                local txt = pack[code] or pack.en or obj:GetAttribute("I18N_Default") or obj.Text
                obj.Text = txt
            end
        end
    end

    function I.register(key:string, lang:string, text:string)
        I.dict[key] = I.dict[key] or {}
        I.dict[key][lang] = text
    end

    -- ผูก TextLabel กับ key (จะอัปเดตอัตโนมัติเมื่อเปลี่ยนภาษา)
    function I.bind(obj:TextLabel, key:string, defaultText:string?)
        table.insert(I.labels, {obj=obj, key=key})
        if defaultText then obj:SetAttribute("I18N_Default", defaultText) end
        -- แสดงข้อความตามภาษาปัจจุบัน
        local pack = I.dict[key]
        if pack then
            obj.Text = pack[I.current] or pack.en or defaultText or obj.Text
        elseif defaultText then
            obj.Text = defaultText
        end
        -- ฟัง event เปลี่ยนภาษา
        I.evt.Event:Connect(function(code)
            if not obj or not obj.Parent then return end
            local p = I.dict[key]
            if p then obj.Text = p[code] or p.en or obj:GetAttribute("I18N_Default") or obj.Text end
        end)
    end

    -- ✨ ตัวอย่างคีย์ไว้ก่อน (เดี๋ยวคุณค่อยเพิ่มคีย์จริงๆ ของทุกระบบที่ต้องแปล)
    I.register("settings.header.language",     "en", "Language 🌐")
    I.register("settings.header.language",     "th", "ภาษา 🌐")
    I.register("settings.row.language",        "en", "Language")
    I.register("settings.row.language",        "th", "เลือกภาษา")
    I.register("settings.search.placeholder",  "en", "Search language…")
    I.register("settings.search.placeholder",  "th", "ค้นหาภาษา…")
    I.register("settings.note.applied",        "en", "Applied instantly")
    I.register("settings.note.applied",        "th", "เปลี่ยนทันที")
end

-- ---------- Settings tab: Language Picker UI ----------
registerRight("Settings", function(scroll)
    local UIS = game:GetService("UserInputService")
    local THEME = {
        GREEN=Color3.fromRGB(25,255,125), RED=Color3.fromRGB(255,40,40),
        WHITE=Color3.fromRGB(255,255,255), BLACK=Color3.fromRGB(0,0,0),
        MINT =Color3.fromRGB(120,255,220)
    }
    local function corner(ui,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=ui end
    local function stroke(ui,th,col,tr)
        local s=Instance.new("UIStroke"); s.Thickness=th or 2.2; s.Color=col or THEME.GREEN
        s.Transparency=tr or 0; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=ui
    end
    local I = _G.UFOX_I18N

    -- เคลียร์ของเดิม (เฉพาะส่วนของ Settings Language)
    for _,n in ipairs({"Lang_Header","Lang_Row","Lang_Drop","Lang_Note"}) do
        local o=scroll:FindFirstChild(n); if o then o:Destroy() end
    end

    -- layout/canvas ตามมาตรฐานแท็บ
    local vlist = scroll:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", scroll)
    vlist.Padding = UDim.new(0,12); vlist.SortOrder = Enum.SortOrder.LayoutOrder
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local nextOrder = 10
    for _,ch in ipairs(scroll:GetChildren()) do
        if ch:IsA("GuiObject") and ch~=vlist then nextOrder = math.max(nextOrder, (ch.LayoutOrder or 0)+1) end
    end

    -- ===== Header =====
    local header = Instance.new("TextLabel", scroll)
    header.Name="Lang_Header"; header.BackgroundTransparency=1
    header.Size=UDim2.new(1,0,0,36); header.LayoutOrder=nextOrder
    header.Font=Enum.Font.GothamBold; header.TextSize=16; header.TextColor3=THEME.WHITE
    header.TextXAlignment=Enum.TextXAlignment.Left
    _G.UFOX_I18N.bind(header, "settings.header.language", "Language 🌐")

    -- ===== Row: Language (ปุ่มเปิด dropdown ทางขวา) =====
    local row = Instance.new("Frame", scroll)
    row.Name="Lang_Row"; row.LayoutOrder=nextOrder+1
    row.Size=UDim2.new(1,-6,0,46); row.BackgroundColor3=THEME.BLACK
    corner(row,12); stroke(row,2.2,THEME.GREEN)

    local lab = Instance.new("TextLabel", row)
    lab.BackgroundTransparency=1; lab.Size=UDim2.new(1,-160,1,0); lab.Position=UDim2.new(0,16,0,0)
    lab.Font=Enum.Font.GothamBold; lab.TextSize=13; lab.TextColor3=THEME.WHITE; lab.TextXAlignment=Enum.TextXAlignment.Left
    _G.UFOX_I18N.bind(lab, "settings.row.language", "Language")

    local chip = Instance.new("TextButton", row) -- ปุ่มตัวเลือกปัจจุบัน (ขวา)
    chip.AutoButtonColor=false; chip.AnchorPoint=Vector2.new(1,0.5); chip.Position=UDim2.new(1,-12,0.5,0)
    chip.Size=UDim2.fromOffset(160,26); chip.Text=""; chip.BackgroundColor3=Color3.fromRGB(20,20,20)
    corner(chip,13); stroke(chip,1.8,THEME.MINT,0.35)

    local chipTxt = Instance.new("TextLabel", chip)
    chipTxt.BackgroundTransparency=1; chipTxt.Size=UDim2.fromScale(1,1)
    chipTxt.Font=Enum.Font.GothamBold; chipTxt.TextSize=12; chipTxt.TextColor3=THEME.WHITE
    chipTxt.TextXAlignment=Enum.TextXAlignment.Center; chipTxt.TextYAlignment=Enum.TextYAlignment.Center

    local function codeToNice(c)
        -- ชื่อสวยๆ เฉพาะที่รู้จัก (เพิ่มได้เรื่อยๆ)
        local map = {
            en="English", th="ไทย", es="Español", ja="日本語", ko="한국어", zh_cn="简体中文",
            zh_tw="繁體中文", fr="Français", de="Deutsch", ru="Русский", pt_br="Português (Brasil)",
            ar="العربية", hi="हिन्दी", id="Bahasa Indonesia", ms="Bahasa Melayu", vi="Tiếng Việt",
            tr="Türkçe", it="Italiano", pl="Polski", nl="Nederlands"
        }
        return map[string.lower(c)] or c
    end
    local function refreshChip() chipTxt.Text = codeToNice(I.current).."  ("..I.current..")" end
    refreshChip()
    I.evt.Event:Connect(refreshChip)

    -- ===== Dropdown (ค้นหา + รายการภาษา) =====
    local drop = Instance.new("Frame", scroll)
    drop.Name="Lang_Drop"; drop.Visible=false; drop.BackgroundTransparency=1; drop.LayoutOrder=nextOrder+2
    drop.Size=UDim2.new(1,-6,0,220) -- สูงพอให้เลื่อน
    -- กล่องจริง
    local box = Instance.new("Frame", drop)
    box.Size=UDim2.new(1,0,1,0); box.BackgroundColor3=Color3.fromRGB(12,12,12)
    corner(box,12); stroke(box,2.0,THEME.GREEN,0)

    -- ช่องค้นหา
    local search = Instance.new("TextBox", box)
    search.PlaceholderText = "" -- จะใส่ผ่าน i18n ด้านล่าง
    search.ClearTextOnFocus = false
    search.Font=Enum.Font.Gotham; search.TextSize=13; search.TextColor3=THEME.WHITE
    search.BackgroundColor3=Color3.fromRGB(18,18,18)
    search.Size=UDim2.new(1,-20,0,28); search.Position=UDim2.new(0,10,0,10)
    corner(search,8); stroke(search,1.2,THEME.MINT,0.35)

    local ph = Instance.new("TextLabel", search)
    ph.BackgroundTransparency=1; ph.TextColor3=Color3.fromRGB(160,160,160); ph.Font=Enum.Font.Gotham
    ph.TextSize=12; ph.TextXAlignment=Enum.TextXAlignment.Left; ph.TextYAlignment=Enum.TextYAlignment.Center
    ph.Size=UDim2.fromScale(1,1); ph.Text = "Search language…"
    ph.ZIndex = search.ZIndex - 1
    ph.Visible = (search.Text == "")
    search:GetPropertyChangedSignal("Text"):Connect(function() ph.Visible = (search.Text == "") end)
    _G.UFOX_I18N.bind(ph, "settings.search.placeholder", "Search language…")

    -- รายการเลื่อน
    local listWrap = Instance.new("ScrollingFrame", box)
    listWrap.BackgroundTransparency=1; listWrap.Position=UDim2.new(0,10,0,48)
    listWrap.Size=UDim2.new(1,-20,1,-58)
    listWrap.ScrollBarThickness=0; listWrap.AutomaticCanvasSize=Enum.AutomaticSize.Y
    listWrap.ScrollingDirection=Enum.ScrollingDirection.Y; listWrap.ElasticBehavior=Enum.ElasticBehavior.Never
    local pad = Instance.new("UIPadding", listWrap); pad.PaddingTop=UDim.new(0,6); pad.PaddingBottom=UDim.new(0,10)
    local v = Instance.new("UIListLayout", listWrap); v.Padding=UDim.new(0,6); v.SortOrder=Enum.SortOrder.LayoutOrder

    -- โหลด “ทุกภาษา” จาก Roblox Enum.LanguageCode
    local all = {}
    for _,it in ipairs(Enum.LanguageCode:GetEnumItems()) do
        local code = string.lower(it.Name) -- เช่น "en", "th", "pt_br" ...
        table.insert(all, {code=code, name=(codeToNice(code) or it.Name)})
    end
    table.sort(all, function(a,b) return a.name:lower() < b.name:lower() end)

    local itemButtons = {}  -- เก็บไว้เพื่อ filter
    local function makeItem(lang)
        local b = Instance.new("TextButton", listWrap)
        b.AutoButtonColor=false; b.Size=UDim2.new(1,-0,0,30); b.Text=""
        b.BackgroundColor3=Color3.fromRGB(18,18,18); corner(b,8); stroke(b,1.1,THEME.MINT,0.35)
        local t = Instance.new("TextLabel", b)
        t.BackgroundTransparency=1; t.Size=UDim2.fromScale(1,1)
        t.Font=Enum.Font.Gotham; t.TextSize=12; t.TextColor3=THEME.WHITE
        t.TextXAlignment=Enum.TextXAlignment.Left; t.Text = string.format("%s  (%s)", lang.name, lang.code)
        t.Position=UDim2.new(0,10,0,0)

        b.MouseButton1Click:Connect(function()
            _G.UFOX_I18N.setLanguage(lang.code)
            drop.Visible=false
        end)
        table.insert(itemButtons, {btn=b, text=t.Text:lower()})
    end
    for _,L in ipairs(all) do makeItem(L) end

    -- filter ค้นหา
    local function applyFilter()
        local q = (search.Text or ""):lower()
        for _,rec in ipairs(itemButtons) do
            rec.btn.Visible = (q == "" or string.find(rec.text, q, 1, true) ~= nil)
        end
    end
    search:GetPropertyChangedSignal("Text"):Connect(applyFilter)

    -- หมายเหตุเล็กๆ ใต้แถว
    local note = Instance.new("TextLabel", scroll)
    note.Name="Lang_Note"; note.BackgroundTransparency=1; note.LayoutOrder=nextOrder+3
    note.TextXAlignment=Enum.TextXAlignment.Left; note.Font=Enum.Font.Gotham; note.TextSize=12
    note.TextColor3=Color3.fromRGB(190,190,190); note.Size=UDim2.new(1,-6,0,18)
    _G.UFOX_I18N.bind(note, "settings.note.applied", "Applied instantly")

    -- เปิด/ปิด dropdown
    chip.MouseButton1Click:Connect(function()
        drop.Visible = not drop.Visible
        if drop.Visible then search:CaptureFocus() end
    end)
    -- ปิดเมื่อคลิกนอก
    UIS.InputBegan:Connect(function(io,gp)
        if not drop.Visible or gp then return end
        if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then
            local p = io.Position
            local abs = box.AbsolutePosition
            local sz  = box.AbsoluteSize
            local inside = (p.X>=abs.X and p.X<=abs.X+sz.X and p.Y>=abs.Y and p.Y<=abs.Y+sz.Y)
            if not inside and io.UserInputType==Enum.UserInputType.MouseButton1 then
                drop.Visible=false
            end
        end
    end)
end)
---- ========== ผูกปุ่มแท็บ + เปิดแท็บแรก ==========
local tabs = {
    {btn = btnPlayer,   set = setPlayerActive,   name = "Player",   icon = ICON_PLAYER},
    {btn = btnHome,     set = setHomeActive,     name = "Home",     icon = ICON_HOME},
    {btn = btnQuest,    set = setQuestActive,    name = "Quest",    icon = ICON_QUEST},
    {btn = btnShop,     set = setShopActive,     name = "Shop",     icon = ICON_SHOP},
    {btn = btnUpdate,   set = setUpdateActive,   name = "Update",   icon = ICON_UPDATE},
    {btn = btnServer,   set = setServerActive,   name = "Server",   icon = ICON_SERVER},
    {btn = btnSettings, set = setSettingsActive, name = "Settings", icon = ICON_SETTINGS},
}

local function activateTab(t)
    -- จดตำแหน่งสกอร์ลซ้ายไว้ก่อน (กันเด้ง)
    lastLeftY = LeftScroll.CanvasPosition.Y
    for _,x in ipairs(tabs) do x.set(x == t) end
    showRight(t.name, t.icon)
    task.defer(function()
        refreshLeftCanvas()
        local viewH = LeftScroll.AbsoluteSize.Y
        local maxY  = math.max(0, LeftScroll.CanvasSize.Y.Offset - viewH)
        LeftScroll.CanvasPosition = Vector2.new(0, math.clamp(lastLeftY,0,maxY))
        -- ถ้าปุ่มอยู่นอกเฟรม ค่อยเลื่อนให้อยู่พอดี
        local btn = t.btn
        if btn and btn.Parent then
            local top = btn.AbsolutePosition.Y - LeftScroll.AbsolutePosition.Y
            local bot = top + btn.AbsoluteSize.Y
            local pad = 8
            if top < 0 then
                LeftScroll.CanvasPosition = LeftScroll.CanvasPosition + Vector2.new(0, top - pad)
            elseif bot > viewH then
                LeftScroll.CanvasPosition = LeftScroll.CanvasPosition + Vector2.new(0, (bot - viewH) + pad)
            end
            lastLeftY = LeftScroll.CanvasPosition.Y
        end
    end)
end

for _,t in ipairs(tabs) do
    t.btn.MouseButton1Click:Connect(function() activateTab(t) end)
end

-- เปิดด้วยแท็บแรก
activateTab(tabs[1])
    
-- ===== Start visible & sync toggle to this UI =====
setOpen(true)

-- ===== Rebind close buttons inside this UI (กันกรณีชื่อ X หลายตัว) =====
for _,o in ipairs(GUI:GetDescendants()) do
    if o:IsA("TextButton") and (o.Text or ""):upper()=="X" then
        o.MouseButton1Click:Connect(function() setOpen(false) end)
    end
end

-- ===== Auto-rebind ถ้า UI หลักถูกสร้างใหม่ภายหลัง =====
local function hookContainer(container)
    if not container then return end
    container.ChildAdded:Connect(function(child)
        if child.Name=="UFO_HUB_X_UI" then
            task.wait() -- ให้ลูกพร้อม
            for _,o in ipairs(child:GetDescendants()) do
                if o:IsA("TextButton") and (o.Text or ""):upper()=="X" then
                    o.MouseButton1Click:Connect(function() setOpen(false) end)
                end
            end
        end
    end)
end
hookContainer(CoreGui)
local pg = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
hookContainer(pg)

end -- <<== จบ _G.UFO_ShowMainUI() (โค้ด UI หลักของคุณแบบ 100%)

------------------------------------------------------------
-- 2) Toast chain (2-step) • โผล่ Step2 พร้อมกับ UI หลัก แล้วเลือนหาย
------------------------------------------------------------
do
    -- ล้าง Toast เก่า (ถ้ามี)
    pcall(function()
        local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        for _,n in ipairs({"UFO_Toast_Test","UFO_Toast_Test_2"}) do
            local g = pg:FindFirstChild(n); if g then g:Destroy() end
        end
    end)

    -- CONFIG
    local EDGE_RIGHT_PAD, EDGE_BOTTOM_PAD = 2, 2
    local TOAST_W, TOAST_H = 320, 86
    local RADIUS, STROKE_TH = 10, 2
    local GREEN = Color3.fromRGB(0,255,140)
    local BLACK = Color3.fromRGB(10,10,10)
    local LOGO_STEP1 = "rbxassetid://89004973470552"
    local LOGO_STEP2 = "rbxassetid://83753985156201"
    local TITLE_TOP, MSG_TOP = 12, 34
    local BAR_LEFT, BAR_RIGHT_PAD, BAR_H = 68, 12, 10
    local LOAD_TIME = 2.0

    local TS = game:GetService("TweenService")
    local RunS = game:GetService("RunService")
    local PG = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

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
        box.Position = UDim2.new(1, -EDGE_RIGHT_PAD, 1, -(EDGE_BOTTOM_PAD - 24))
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
        logo.Position = UDim2.new(0, 8, 0.5, -2)
        logo.Parent = box
        return logo
    end

    -- Step 1 (progress)
    local gui1 = makeToastGui("UFO_Toast_Test")
    local box1 = buildBox(gui1)
    buildLogo(box1, LOGO_STEP1)
    buildTitle(box1)
    local msg1 = buildMsg(box1, "Initializing... please wait")

    local barWidth = TOAST_W - BAR_LEFT - BAR_RIGHT_PAD
    local track = Instance.new("Frame"); track.BackgroundColor3 = Color3.fromRGB(25,25,25); track.BorderSizePixel = 0
    track.Position = UDim2.fromOffset(BAR_LEFT, TOAST_H - (BAR_H + 12))
    track.Size = UDim2.fromOffset(barWidth, BAR_H); track.Parent = box1
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, BAR_H // 2)

    local fill = Instance.new("Frame"); fill.BackgroundColor3 = GREEN; fill.BorderSizePixel = 0
    fill.Size = UDim2.fromOffset(0, BAR_H); fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, BAR_H // 2)

    local pct = Instance.new("TextLabel")
    pct.BackgroundTransparency = 1; pct.Font = Enum.Font.GothamBold; pct.TextSize = 12
    pct.TextColor3 = Color3.new(1,1,1); pct.TextStrokeTransparency = 0.15; pct.TextStrokeColor3 = Color3.new(0,0,0)
    pct.TextXAlignment = Enum.TextXAlignment.Center; pct.TextYAlignment = Enum.TextYAlignment.Center
    pct.AnchorPoint = Vector2.new(0.5,0.5); pct.Position = UDim2.fromScale(0.5,0.5); pct.Size = UDim2.fromScale(1,1)
    pct.Text = "0%"; pct.ZIndex = 20; pct.Parent = track

    tween(box1, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out,
        {Position = UDim2.new(1, -EDGE_RIGHT_PAD, 1, -EDGE_BOTTOM_PAD)}):Play()

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
        task.wait(0.25)
        local out1 = tween(box1, 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut,
            {Position = UDim2.new(1, -EDGE_RIGHT_PAD, 1, -(EDGE_BOTTOM_PAD - 24))})
        out1:Play(); out1.Completed:Wait(); gui1:Destroy()

        -- Step 2 (no progress) + เปิด UI หลักพร้อมกัน
        local gui2 = makeToastGui("UFO_Toast_Test_2")
        local box2 = buildBox(gui2)
        buildLogo(box2, LOGO_STEP2)
        buildTitle(box2)
        buildMsg(box2, "Download UI completed. ✅")
        tween(box2, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out,
            {Position = UDim2.new(1, -EDGE_RIGHT_PAD, 1, -EDGE_BOTTOM_PAD)}):Play()

        -- เปิด UI หลัก "พร้อมกัน" กับ Toast ขั้นที่ 2
        if _G.UFO_ShowMainUI then pcall(_G.UFO_ShowMainUI) end

        -- ให้ผู้ใช้เห็นข้อความครบ แล้วค่อยเลือนลง (ปรับเวลาได้ตามใจ)
        task.wait(1.2)
        local out2 = tween(box2, 0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut,
            {Position = UDim2.new(1, -EDGE_RIGHT_PAD, 1, -(EDGE_BOTTOM_PAD - 24))})
        out2:Play(); out2.Completed:Wait(); gui2:Destroy()
    end)
end
