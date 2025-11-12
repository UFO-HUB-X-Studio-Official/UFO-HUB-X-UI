-- ==== UFO HUB X • One-shot Boot Guard (PER SESSION; no cooldown reopen) ====
-- วางบนสุดของไฟล์ก่อนโค้ดทั้งหมด
do
    local BOOT = getgenv().UFO_BOOT or { status = "idle" }  -- status: idle|running|done
    -- ถ้ากำลังบูต หรือเคยบูตเสร็จแล้ว → ไม่ให้รันอีก
    if BOOT.status == "running" or BOOT.status == "done" then
        return
    end
    BOOT.status = "running"
    getgenv().UFO_BOOT = BOOT
end
-- ===== UFO HUB X • Local Save (executor filesystem) — per map (PlaceId) =====
do
    local HttpService = game:GetService("HttpService")
    local MarketplaceService = game:GetService("MarketplaceService")

    local FS = {
        isfolder   = (typeof(isfolder)=="function") and isfolder   or function() return false end,
        makefolder = (typeof(makefolder)=="function") and makefolder or function() end,
        isfile     = (typeof(isfile)=="function") and isfile       or function() return false end,
        readfile   = (typeof(readfile)=="function") and readfile   or function() return nil end,
        writefile  = (typeof(writefile)=="function") and writefile or function() end,
    }

    local ROOT = "UFO HUB X"  -- โฟลเดอร์หลักในตัวรัน
    local function safeMakeRoot() pcall(function() if not FS.isfolder(ROOT) then FS.makefolder(ROOT) end end) end
    safeMakeRoot()

    local placeId  = tostring(game.PlaceId)
    local gameId   = tostring(game.GameId)
    local mapName  = "Unknown"
    pcall(function()
        local inf = MarketplaceService:GetProductInfo(game.PlaceId)
        if inf and inf.Name then mapName = inf.Name end
    end)

    local FILE = string.format("%s/%s.json", ROOT, placeId)
    local _cache = nil
    local _dirty = false
    local _debounce = false

    local function _load()
        if _cache then return _cache end
        local ok, txt = pcall(function()
            if FS.isfile(FILE) then return FS.readfile(FILE) end
            return nil
        end)
        local data = nil
        if ok and txt and #txt > 0 then
            local ok2, t = pcall(function() return HttpService:JSONDecode(txt) end)
            data = ok2 and t or nil
        end
        if not data or type(data)~="table" then
            data = { __meta = { placeId = placeId, gameId = gameId, mapName = mapName, savedAt = os.time() } }
        end
        _cache = data
        return _cache
    end

    local function _flushNow()
        if not _cache then return end
        _cache.__meta = _cache.__meta or {}
        _cache.__meta.placeId = placeId
        _cache.__meta.gameId  = gameId
        _cache.__meta.mapName = mapName
        _cache.__meta.savedAt = os.time()
        local ok, json = pcall(function() return HttpService:JSONEncode(_cache) end)
        if ok and json then
            pcall(function()
                safeMakeRoot()
                FS.writefile(FILE, json)
            end)
        end
        _dirty = false
    end

    local function _scheduleFlush()
        if _debounce then return end
        _debounce = true
        task.delay(0.25, function()
            _debounce = false
            if _dirty then _flushNow() end
        end)
    end

    local Save = {}

    -- อ่านค่า: key = "Tab.Key" เช่น "RJ.enabled" / "A1.Reduce" / "AFK.Black"
    function Save.get(key, defaultValue)
        local db = _load()
        local v = db[key]
        if v == nil then return defaultValue end
        return v
    end

    -- เซ็ตค่า + เขียนไฟล์แบบดีบาวซ์
    function Save.set(key, value)
        local db = _load()
        db[key] = value
        _dirty = true
        _scheduleFlush()
    end

    -- ตัวช่วย: apply ค่าเซฟถ้ามี ไม่งั้นใช้ default แล้วเซฟกลับ
    function Save.apply(key, defaultValue, applyFn)
        local v = Save.get(key, defaultValue)
        if applyFn then
            local ok = pcall(applyFn, v)
            if ok and v ~= nil then Save.set(key, v) end
        end
        return v
    end

    -- ให้เรียกใช้ที่อื่นได้
    getgenv().UFOX_SAVE = Save
end
-- ===== [/Local Save] =====
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

-- 3) สร้าง ScrollingFrame ต่อแท็บ
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
    sf.ScrollBarThickness = 0      -- ← ซ่อนสกรอลล์บาร์ (เดิม 4)
    sf.ScrollingDirection = Enum.ScrollingDirection.Y
    sf.AutomaticCanvasSize = Enum.AutomaticSize.None
    sf.ElasticBehavior = Enum.ElasticBehavior.Never
    sf.CanvasSize = UDim2.new(0,0,0,600)  -- เลื่อนได้ตั้งแต่เริ่ม

    local pad = Instance.new("UIPadding", sf)
    pad.PaddingTop    = UDim.new(0,12)
    pad.PaddingLeft   = UDim.new(0,12)
    pad.PaddingRight  = UDim.new(0,12)
    pad.PaddingBottom = UDim.new(0,12)

    local list = Instance.new("UIListLayout", sf)
    list.Padding = UDim.new(0,10)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.VerticalAlignment = Enum.VerticalAlignment.Top

    local function refreshCanvas()
        local h = list.AbsoluteContentSize.Y + pad.PaddingTop.Offset + pad.PaddingBottom.Offset
        sf.CanvasSize = UDim2.new(0,0,0, math.max(h,600))
    end

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local yBefore = sf.CanvasPosition.Y
        refreshCanvas()
        local viewH = sf.AbsoluteSize.Y
        local maxY  = math.max(0, sf.CanvasSize.Y.Offset - viewH)
        sf.CanvasPosition = Vector2.new(0, math.clamp(yBefore, 0, maxY))
    end)

    task.defer(refreshCanvas)

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
 -- ===== UFO HUB X • Player Tab — MODEL A LEGACY 2.3.9j (TAP-FIX + METAL SQUARE KNOB) =====
-- เพิ่มระบบเซฟแบบ Runner (per-map) • ไม่เปลี่ยนหน้าตา/สีเดิม

registerRight("Player", function(scroll)
    local Players=game:GetService("Players")
    local RunService=game:GetService("RunService")
    local UserInputService=game:GetService("UserInputService")
    local TweenService=game:GetService("TweenService")
    local PhysicsService=game:GetService("PhysicsService")
    local HttpService=game:GetService("HttpService")
    local MarketplaceService=game:GetService("MarketplaceService")
    local lp=Players.LocalPlayer

    ----------------------------------------------------------------------
    -- SAVE (Runner FS if available; fallback to getgenv in-memory)
    ----------------------------------------------------------------------
    local function safePlaceName()
        local ok,info = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)
        local name = (ok and info and info.Name) or ("Place_"..tostring(game.PlaceId))
        -- sanitize filename chars
        name = name:gsub("[^%w%-%._ ]","_")
        return name
    end

    local SAVE_DIR = "UFO HUB X"
    local SAVE_FILE = SAVE_DIR.."/"..tostring(game.PlaceId).." - "..safePlaceName()..".json"

    local hasFS = (typeof(isfolder)=="function" and typeof(makefolder)=="function"
                and typeof(writefile)=="function" and typeof(readfile)=="function")
    if hasFS and not isfolder(SAVE_DIR) then pcall(makefolder, SAVE_DIR) end

    getgenv().UFOX_RAM = getgenv().UFOX_RAM or {} -- fallback per-session
    local RAM = getgenv().UFOX_RAM

    local function loadSave()
        if hasFS and pcall(function() return readfile(SAVE_FILE) end) then
            local ok,decoded = pcall(function()
                return HttpService:JSONDecode(readfile(SAVE_FILE))
            end)
            if ok and type(decoded)=="table" then return decoded end
        end
        return RAM[SAVE_FILE] or {}
    end
    local function writeSave(tbl)
        tbl = tbl or {}
        if hasFS then
            pcall(function()
                writefile(SAVE_FILE, HttpService:JSONEncode(tbl))
            end)
        end
        RAM[SAVE_FILE] = tbl
    end
    local function getSave(path, default)
        local data = loadSave()
        local cur = data
        for seg in string.gmatch(path, "[^%.]+") do
            cur = (type(cur)=="table") and cur[seg] or nil
        end
        if cur==nil then return default end
        return cur
    end
    local function setSave(path, value)
        local data = loadSave()
        local cur = data
        local last, prev
        for seg in string.gmatch(path, "[^%.]+") do
            prev = cur; last = seg
            if type(cur[seg])~="table" then cur[seg] = {} end
            cur = cur[seg]
        end
        -- write value to last key (handle 1 level path too)
        if last then
            -- climb again to parent
            cur = data
            local parent = data
            local key
            for seg in string.gmatch(path, "[^%.]+") do
                key = seg
                if type(parent[seg])~="table" then parent[seg] = {} end
                prev = parent
                parent = parent[seg]
            end
            prev[key] = value
        end
        writeSave(data)
    end
    ----------------------------------------------------------------------

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
        -- SAVE: sensitivity
        setSave("Player.SensRel", currentRel)
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
        if k==Enum.KeyCode.F then if flightOn then
            stopFly(); setSave("Player.FlightOn", false)
        else
            startFly(); setSave("Player.FlightOn", true)
        end end
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
        if v then swStroke.Color=THEME.GREEN; tween(knob,{Position=UDim2.new(1,-24,0.5,-11)},0.1); startFly(); setSave("Player.FlightOn", true)
        else     swStroke.Color=THEME.RED;   tween(knob,{Position=UDim2.new(0,2,0.5,-11)},0.1); stopFly();  setSave("Player.FlightOn", false) end
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

    -- ==== METAL SQUARE KNOB ====
    local knobShadow=Instance.new("Frame",bar)
    knobShadow.Size=UDim2.fromOffset(18,34); knobShadow.AnchorPoint=Vector2.new(0.5,0.5)
    knobShadow.Position=UDim2.new(0,0,0.5,2); knobShadow.BackgroundColor3=THEME.DARK
    knobShadow.BorderSizePixel=0; knobShadow.BackgroundTransparency=0.45; knobShadow.ZIndex=2

    local knobBtn=Instance.new("ImageButton",bar)
    knobBtn.AutoButtonColor=false; knobBtn.BackgroundColor3=THEME.GREY
    knobBtn.Size=UDim2.fromOffset(16,32)
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

    local centerVal=Instance.new("TextLabel",bar); centerVal.BackgroundTransparency=1; centerVal.Size=UDim2.fromScale(1,1)
    centerVal.Font=Enum.Font.GothamBlack; centerVal.TextSize=16; centerVal.TextColor3=THEME.WHITE; centerVal.TextStrokeTransparency=0.2; centerVal.Text="0%"
    sliderCenterLabel=centerVal

    local function relFrom(x) return (x - bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X) end
    local function syncVisual(now)
        if now then visRel=currentRel else visRel = visRel + (currentRel - visRel)*0.30 end
        visRel = math.clamp(visRel,0,1)
        fill.Size=UDim2.fromScale(visRel,1)
        knobBtn.Position=UDim2.new(visRel,0,0.5,0)
        knobShadow.Position=UDim2.new(visRel,0,0.5,2)
        centerVal.Text=string.format("%d%%",math.floor(visRel*100+0.5))
    end

    -- drag/tap logic (เหมือนเดิม)
    local RSdragConn, EndDragConn
    local dragging=false
    local maybeDrag=false
    local downX=nil
    local lastTouchX
    local DRAG_THRESHOLD = 5

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

    -- ---------- INIT (load saved) ----------
    local savedRel   = getSave("Player.SensRel", (_G.UFOX_sensRel or 0))
    local savedFlyOn = getSave("Player.FlightOn", false)
    if firstRun then applyRel(savedRel or 0,true) else applyRel(savedRel or currentRel,true) end
    syncVisual(true)
    if savedFlyOn then
        -- mirror UI state to ON without changing row style
        local swStroke = swStroke -- already RED; setState(true) will turn it GREEN & startFly()
        setState(true)
    end
end)
-- ===== UFO HUB X • Player — SPEED, JUMP & SWIM • Model A V1 + Runner Save (per-map) =====
-- Order: Run → Jump → Swim
-- Saves per GAME_ID/PLACE_ID into runner (getgenv().UFOX_SAVE). Keys:
--   RJ/<gameId>/<placeId>/{enabled,infJump,runRel,jumpRel,swimRel}

registerRight("Player", function(scroll)
    local Players=game:GetService("Players")
    local UIS=game:GetService("UserInputService")
    local RS=game:GetService("RunService")
    local TweenService=game:GetService("TweenService")
    local lp=Players.LocalPlayer

    -- ---------- SAVE (runner; per-map scope) ----------
    local SAVE = (getgenv and getgenv().UFOX_SAVE) or {
        get=function(_,_,d) return d end,
        set=function() end
    }
    local SCOPE = ("RJ/%d/%d"):format(tonumber(game.GameId) or 0, tonumber(game.PlaceId) or 0)
    local function K(k) return SCOPE.."/"..k end
    local function SaveGet(k, d) local ok,v = pcall(function() return SAVE.get(K(k), d) end); return ok and v or d end
    local function SaveSet(k, v) pcall(function() SAVE.set(K(k), v) end) end

    -- ---------- STATE ----------
    _G.UFOX_RJ = _G.UFOX_RJ or { uiConns={}, tempConns={}, remember={}, defaults={} }
    local RJ=_G.UFOX_RJ
    local function keepUI(c) table.insert(RJ.uiConns,c) return c end
    local function keepTmp(c) table.insert(RJ.tempConns,c) return c end
    local function disconnectAll(t) for i=#t,1,-1 do local c=t[i]; pcall(function() c:Disconnect() end); t[i]=nil end end
    local function stopAllTemp() disconnectAll(RJ.tempConns); scroll.ScrollingEnabled=true end
    disconnectAll(RJ.uiConns)

    -- restore from SAVE (fallback to previous remember / defaults)
    RJ.remember.enabled = SaveGet("enabled", (RJ.remember.enabled==nil) and false or RJ.remember.enabled)
    RJ.remember.infJump = SaveGet("infJump", (RJ.remember.infJump==nil) and false or RJ.remember.infJump)
    RJ.remember.runRel  = SaveGet("runRel",  (RJ.remember.runRel==nil)  and 0 or RJ.remember.runRel)
    RJ.remember.jumpRel = SaveGet("jumpRel", (RJ.remember.jumpRel==nil) and 0 or RJ.remember.jumpRel)
    RJ.remember.swimRel = SaveGet("swimRel", (RJ.remember.swimRel==nil) and 0 or RJ.remember.swimRel)

    local RUN_MIN,RUN_MAX   = 16,500
    local JUMP_MIN,JUMP_MAX = 50,500
    local SWIM_MIN,SWIM_MAX = 16,500
    local runRel, jumpRel, swimRel = RJ.remember.runRel, RJ.remember.jumpRel, RJ.remember.swimRel
    local masterOn, infJumpOn = RJ.remember.enabled, RJ.remember.infJump

    RJ.defaults = RJ.defaults or { WalkSpeed=nil, JumpPower=nil, UseJumpPower=nil, JumpHeight=nil }

    local function getHum() local ch=lp.Character return ch and ch:FindFirstChildOfClass("Humanoid") end
    local function lerp(a,b,t) return a+(b-a)*t end
    local function mapRel(r,mn,mx) r=math.clamp(r,0,1) return lerp(mn,mx,r) end

    local humStateConn
    local function snapshotDefaults()
        local h=getHum(); if not h then return end
        if RJ.defaults.WalkSpeed==nil    then RJ.defaults.WalkSpeed=h.WalkSpeed end
        if RJ.defaults.UseJumpPower==nil then RJ.defaults.UseJumpPower=h.UseJumpPower end
        if RJ.defaults.JumpPower==nil    then RJ.defaults.JumpPower=h.JumpPower end
        if RJ.defaults.JumpHeight==nil   then RJ.defaults.JumpHeight=h.JumpHeight end
    end
    local function currentTargetWalkSpeed(h)
        local usingSwim = (h:GetState()==Enum.HumanoidStateType.Swimming)
        local rel = usingSwim and swimRel or runRel
        return math.floor(mapRel(rel, usingSwim and SWIM_MIN or RUN_MIN, usingSwim and SWIM_MAX or RUN_MAX)+0.5)
    end
    local function applyStats()
        local h=getHum(); if not h then return end
        if masterOn then
            snapshotDefaults()
            local ws=currentTargetWalkSpeed(h)
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
    local function rehookHumanoid()
        if humStateConn then pcall(function() humStateConn:Disconnect() end) humStateConn=nil end
        local h=getHum(); if not h then return end
        humStateConn = keepUI(h.StateChanged:Connect(function(_,new)
            if new==Enum.HumanoidStateType.Swimming
            or new==Enum.HumanoidStateType.Running
            or new==Enum.HumanoidStateType.RunningNoPhysics
            or new==Enum.HumanoidStateType.Landed then
                applyStats()
            end
        end))
    end

    -- Inf Jump
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
        task.defer(function() rehookHumanoid(); applyStats(); bindInfJump() end)
    end))
    task.defer(function() rehookHumanoid() end)

    -- ---------- THEME ----------
    local THEME={GREEN=Color3.fromRGB(25,255,125), RED=Color3.fromRGB(255,40,40),
        WHITE=Color3.fromRGB(255,255,255), BLACK=Color3.fromRGB(0,0,0),
        GREY=Color3.fromRGB(180,180,185), DARK=Color3.fromRGB(60,60,65)}
    local function corner(ui,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12); c.Parent=ui end
    local function stroke(ui,th,col) local s=Instance.new("UIStroke") s.Thickness=th or 2; s.Color=col or THEME.GREEN; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=ui end
    local function tween(o,p,d) TweenService:Create(o,TweenInfo.new(d or 0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end

    -- rebuild
    for _,n in ipairs({"RJ_Header","RJ_Master","RJ_Run","RJ_Jump","RJ_Swim","RJ_Inf"}) do local o=scroll:FindFirstChild(n); if o then o:Destroy() end end
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
    header.Text="Fast Run, High Jump & Fast Swim 🏃‍♂️💨🦘🌊"

    -- Master
    local master=Instance.new("Frame",scroll); master.Name="RJ_Master"; master.LayoutOrder=baseOrder+1
    master.Size=UDim2.new(1,-6,0,46); master.BackgroundColor3=THEME.BLACK; corner(master,12); stroke(master,2.2,THEME.GREEN)
    local mLab=Instance.new("TextLabel",master); mLab.BackgroundTransparency=1; mLab.Size=UDim2.new(1,-140,1,0); mLab.Position=UDim2.new(0,16,0,0)
    mLab.Font=Enum.Font.GothamBold; mLab.TextSize=13; mLab.TextColor3=THEME.WHITE; mLab.TextXAlignment=Enum.TextXAlignment.Left; mLab.Text="Enable Run/Jump/Swim Boost"
    local mSw=Instance.new("Frame",master); mSw.AnchorPoint=Vector2.new(1,0.5); mSw.Position=UDim2.new(1,-12,0.5,0)
    mSw.Size=UDim2.fromOffset(52,26); mSw.BackgroundColor3=THEME.BLACK; corner(mSw,13); stroke(mSw,1.8, masterOn and THEME.GREEN or THEME.RED)
    local mKnob=Instance.new("Frame",mSw); mKnob.Size=UDim2.fromOffset(22,22); mKnob.Position=UDim2.new(masterOn and 1 or 0, masterOn and -24 or 2, 0.5,-11); mKnob.BackgroundColor3=THEME.WHITE; corner(mKnob,11)
    local mBtn=Instance.new("TextButton",mSw); mBtn.BackgroundTransparency=1; mBtn.Size=UDim2.fromScale(1,1); mBtn.Text=""

    local function setMaster(v)
        masterOn=v; RJ.remember.enabled=v; SaveSet("enabled", v)
        local st=mSw:FindFirstChildOfClass("UIStroke"); if st then st.Color=v and THEME.GREEN or THEME.RED end
        tween(mKnob,{Position=UDim2.new(v and 1 or 0, v and -24 or 2, 0.5,-11)},0.08)
        applyStats()
    end
    keepUI(mBtn.MouseButton1Click:Connect(function() setMaster(not masterOn) end))

    -- ===== Slider builder =====
    local function buildSlider(name, order, title, getRel, setRel, saveKey)
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
        local grad=Instance.new("UIGradient",knob); grad.Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0.00,Color3.fromRGB(236,236,240)),
            ColorSequenceKeypoint.new(0.50,Color3.fromRGB(182,182,188)),
            ColorSequenceKeypoint.new(1.00,Color3.fromRGB(216,216,222))
        }; grad.Rotation=90

        local centerVal=Instance.new("TextLabel",bar); centerVal.BackgroundTransparency=1; centerVal.Size=UDim2.fromScale(1,1)
        centerVal.Font=Enum.Font.GothamBlack; centerVal.TextSize=16; centerVal.TextColor3=THEME.WHITE; centerVal.TextXAlignment=Enum.TextXAlignment.Center; centerVal.ZIndex=1

        local hit=Instance.new("TextButton",bar); hit.BackgroundTransparency=1; hit.Size=UDim2.fromScale(1,1); hit.Text=""; hit.ZIndex=4

        local visRel=getRel()
        local function relFrom(x) return (x - bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X) end
        local function setRelClamped(r)
            r=math.clamp(r,0,1)
            setRel(r)
            SaveSet(saveKey, r)
        end
        local function instantVisual()
            visRel=getRel()
            fill.Size=UDim2.fromScale(visRel,1); knob.Position=UDim2.new(visRel,0,0.5,0); knobShadow.Position=UDim2.new(visRel,0,0.5,2)
            centerVal.Text=string.format("%d%%", math.floor(visRel*100+0.5))
        end

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
                visRel = visRel + (getRel() - visRel)*0.30
                fill.Size=UDim2.fromScale(visRel,1); knob.Position=UDim2.new(visRel,0,0.5,0); knobShadow.Position=UDim2.new(visRel,0,0.5,2)
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
            stopAllTemp(); scroll.ScrollingEnabled=false
            setRelClamped(relFrom(px)); instantVisual(); applyStats()
            maybeDrag=true; dragging=false; downX=px
        end
        local function onMove(mx)
            if not maybeDrag then return end
            if downX==nil then downX=mx end
            if math.abs(mx-downX) >= DRAG_THRESHOLD then beginDragLoop() end
        end

        keepUI(UIS.InputChanged:Connect(function(io)
            if not maybeDrag then return end
            if io.UserInputType==Enum.UserInputType.MouseMovement then onMove(UIS:GetMouseLocation().X)
            elseif io.UserInputType==Enum.UserInputType.Touch then onMove(io.Position.X) end
        end))
        keepUI(UIS.InputEnded:Connect(function(io)
            if maybeDrag and (io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch) then endDrag() end
        end))
        local function pressFrom(io) onPress(io.Position.X) end
        keepUI(bar.InputBegan:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then pressFrom(io) end end))
        keepUI(knob.InputBegan:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then pressFrom(io) end end))
        keepUI(hit.InputBegan:Connect(function(io)  if io.UserInputType==Enum.UserInputType.MouseButton1 or io.UserInputType==Enum.UserInputType.Touch then pressFrom(io) end end))

        instantVisual()
        return row
    end

    -- === Sliders in correct order: Run → Jump → Swim ===
    buildSlider("RJ_Run",  baseOrder+2, "Run Speed",
        function() return runRel end,
        function(r) runRel=math.clamp(r,0,1); RJ.remember.runRel=runRel; applyStats() end,
        "runRel")

    buildSlider("RJ_Jump", baseOrder+3, "Jump Power",
        function() return jumpRel end,
        function(r) jumpRel=math.clamp(r,0,1); RJ.remember.jumpRel=jumpRel; applyStats() end,
        "jumpRel")

    buildSlider("RJ_Swim", baseOrder+4, "Swim Speed",
        function() return swimRel end,
        function(r) swimRel=math.clamp(r,0,1); RJ.remember.swimRel=swimRel; applyStats() end,
        "swimRel")

    -- Infinite Jump
    local inf=Instance.new("Frame",scroll); inf.Name="RJ_Inf"; inf.LayoutOrder=baseOrder+5
    inf.Size=UDim2.new(1,-6,0,46); inf.BackgroundColor3=THEME.BLACK; corner(inf,12); stroke(inf,2.2,THEME.GREEN)
    local iLab=Instance.new("TextLabel",inf); iLab.BackgroundTransparency=1; iLab.Size=UDim2.new(1,-140,1,0); iLab.Position=UDim2.new(0,16,0,0)
    iLab.Font=Enum.Font.GothamBold; iLab.TextSize=13; iLab.TextColor3=THEME.WHITE; iLab.TextXAlignment=Enum.TextXAlignment.Left; iLab.Text="Infinite Jump"
    local iSw=Instance.new("Frame",inf); iSw.AnchorPoint=Vector2.new(1,0.5); iSw.Position=UDim2.new(1,-12,0.5,0)
    iSw.Size=UDim2.fromOffset(52,26); iSw.BackgroundColor3=THEME.BLACK; corner(iSw,13); stroke(iSw,1.8, infJumpOn and THEME.GREEN or THEME.RED)
    local iKnob=Instance.new("Frame",iSw); iKnob.Size=UDim2.fromOffset(22,22); iKnob.Position=UDim2.new(infJumpOn and 1 or 0, infJumpOn and -24 or 2, 0.5,-11)
    iKnob.BackgroundColor3=THEME.WHITE; corner(iKnob,11)
    local iBtn=Instance.new("TextButton",iSw); iBtn.BackgroundTransparency=1; iBtn.Size=UDim2.fromScale(1,1); iBtn.Text=""
    local function setInf(v)
        infJumpOn=v; RJ.remember.infJump=v; SaveSet("infJump", v)
        local st=iSw:FindFirstChildOfClass("UIStroke"); if st then st.Color = v and THEME.GREEN or THEME.RED end
        tween(iKnob,{Position=UDim2.new(v and 1 or 0, v and -24 or 2, 0.5,-11)},0.08)
        bindInfJump()
    end
    keepUI(iBtn.MouseButton1Click:Connect(function() setInf(not infJumpOn) end))

    -- apply current settings after build
    applyStats(); bindInfJump()
end)
--===== UFO HUB X • SERVER — Model A V1 (2 rows: change + live count) =====
registerRight("Server", function(scroll)
    local Players        = game:GetService("Players")
    local TeleportService= game:GetService("TeleportService")
    local HttpService    = game:GetService("HttpService")
    local TweenService   = game:GetService("TweenService")
    local lp             = Players.LocalPlayer

    -- THEME (A V1)
    local THEME = {
        GREEN = Color3.fromRGB(25,255,125),
        WHITE = Color3.fromRGB(255,255,255),
        BLACK = Color3.fromRGB(0,0,0),
        TEXT  = Color3.fromRGB(255,255,255),
        RED   = Color3.fromRGB(255,40,40),
        GREY  = Color3.fromRGB(70,70,75),
    }
    local function corner(ui,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=ui end
    local function stroke(ui,th,col) local s=Instance.new("UIStroke") s.Thickness=th or 2.2 s.Color=col or THEME.GREEN s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=ui end
    local function tween(o,p,d) TweenService:Create(o, TweenInfo.new(d or 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play() end

    -- A V1: single ListLayout on scroll
    local list = scroll:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0,12); list.SortOrder = Enum.SortOrder.LayoutOrder
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- Header (Server + emoji)
    local head = scroll:FindFirstChild("SV_Header") or Instance.new("TextLabel", scroll)
    head.Name="SV_Header"; head.BackgroundTransparency=1; head.Size=UDim2.new(1,0,0,36)
    head.Font=Enum.Font.GothamBold; head.TextSize=16; head.TextColor3=THEME.TEXT
    head.TextXAlignment=Enum.TextXAlignment.Left; head.Text="Server 🌐"; head.LayoutOrder = 10

    -- Clear same-name rows (A V1 rule, no wrappers)
    for _,n in ipairs({"S1_Change","S2_PlayerCount"}) do local o=scroll:FindFirstChild(n) if o then o:Destroy() end end

    -- Row factory (A V1)
    local function makeRow(name, label, order)
        local row = Instance.new("Frame", scroll)
        row.Name=name; row.Size=UDim2.new(1,-6,0,46); row.BackgroundColor3=THEME.BLACK
        row.LayoutOrder=order; corner(row,12); stroke(row,2.2,THEME.GREEN)

        local lab = Instance.new("TextLabel", row)
        lab.BackgroundTransparency=1; lab.Size=UDim2.new(1,-160,1,0); lab.Position=UDim2.new(0,16,0,0)
        lab.Font=Enum.Font.GothamBold; lab.TextSize=13; lab.TextColor3=THEME.WHITE
        lab.TextXAlignment=Enum.TextXAlignment.Left; lab.Text=label

        return row
    end

    ----------------------------------------------------------------
    -- (#1) Change Server — one-tap button (no toggle)
    ----------------------------------------------------------------
    local r1 = makeRow("S1_Change", "Change Server", 11)
    local btnWrap = Instance.new("Frame", r1)
    btnWrap.AnchorPoint=Vector2.new(1,0.5); btnWrap.Position=UDim2.new(1,-12,0.5,0)
    btnWrap.Size=UDim2.fromOffset(110,28); btnWrap.BackgroundColor3=THEME.BLACK; corner(btnWrap,8); stroke(btnWrap,1.8,THEME.GREEN)

    local btn = Instance.new("TextButton", btnWrap)
    btn.BackgroundTransparency=1; btn.Size=UDim2.fromScale(1,1)
    btn.Font=Enum.Font.GothamBold; btn.TextSize=13; btn.TextColor3=THEME.TEXT
    btn.Text="CHANGE"

    local busy=false
    local function setBusy(v)
        busy=v
        btn.Text = v and "HOPPING..." or "CHANGE"
        local st = btnWrap:FindFirstChildOfClass("UIStroke")
        if st then st.Color = v and THEME.GREY or THEME.GREEN end
    end

    local function findOtherPublicServer(placeId)
        -- Query public servers; pick a different JobId with free slots
        local cursor = nil
        for _=1,4 do -- up to 4 pages
            local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s")
                :format(placeId, cursor and ("&cursor="..HttpService:UrlEncode(cursor)) or "")
            local ok,res = pcall(function() return HttpService:GetAsync(url) end)
            if ok and res then
                local data = HttpService:JSONDecode(res)
                if data and data.data then
                    for _,sv in ipairs(data.data) do
                        local jobId = sv.id
                        local playing = tonumber(sv.playing) or 0
                        local maxp = tonumber(sv.maxPlayers) or Players.MaxPlayers
                        if jobId and jobId ~= game.JobId and playing < maxp then
                            return jobId
                        end
                    end
                end
                cursor = data and data.nextPageCursor or nil
                if not cursor then break end
            else
                break
            end
        end
        return nil
    end

    local function hop()
        if busy then return end
        setBusy(true)
        task.spawn(function()
            local targetJob = nil
            local okFind, errFind = pcall(function()
                targetJob = findOtherPublicServer(game.PlaceId)
            end)
            if targetJob then
                local ok,tpErr = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJob, lp)
                end)
                if not ok then
                    warn("TeleportToPlaceInstance failed:", tpErr)
                    TeleportService:Teleport(game.PlaceId, lp) -- fallback (may land same server)
                end
            else
                -- fallback: simple teleport to place (Roblox will pick a server)
                TeleportService:Teleport(game.PlaceId, lp)
            end
            -- ถ้าการเทเลพอร์ตไม่สำเร็จทันที ให้ปลด busy ผ่าน timeout
            task.delay(4, function() if busy then setBusy(false) end end)
        end)
    end

    btn.MouseButton1Click:Connect(hop)

    ----------------------------------------------------------------
    -- (#2) Live player count — real-time
    ----------------------------------------------------------------
    local r2 = makeRow("S2_PlayerCount", "Players in this server", 12)

    local countBox = Instance.new("Frame", r2)
    countBox.AnchorPoint=Vector2.new(1,0.5); countBox.Position=UDim2.new(1,-12,0.5,0)
    countBox.Size=UDim2.fromOffset(110,28); countBox.BackgroundColor3=THEME.BLACK; corner(countBox,8); stroke(countBox,1.8,THEME.GREEN)

    local countLabel = Instance.new("TextLabel", countBox)
    countLabel.BackgroundTransparency=1; countLabel.Size=UDim2.fromScale(1,1)
    countLabel.Font=Enum.Font.GothamBold; countLabel.TextSize=13; countLabel.TextColor3=THEME.TEXT
    countLabel.TextScaled=false; countLabel.Text="-- / --"

    local function updateCount()
        local current = #Players:GetPlayers()
        local maxp = Players.MaxPlayers
        countLabel.Text = string.format("%d / %d", current, maxp)
    end
    updateCount()
    Players.PlayerAdded:Connect(updateCount)
    Players.PlayerRemoving:Connect(updateCount)
end)
-- ===== [FULL PASTE] UFO HUB X • Server — System #2: Server ID 🔑
-- A V1 layout • black buttons • clean TextBox • UFO-style Quick Toast (EN)
registerRight("Server", function(scroll)
    local Players         = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")
    local TweenService    = game:GetService("TweenService")
    local lp              = Players.LocalPlayer

    -- THEME (A V1)
    local THEME = {
        GREEN = Color3.fromRGB(25,255,125),
        WHITE = Color3.fromRGB(255,255,255),
        BLACK = Color3.fromRGB(0,0,0),
        TEXT  = Color3.fromRGB(255,255,255),
        RED   = Color3.fromRGB(255,40,40),
        GREY  = Color3.fromRGB(60,60,65),
    }
    local function corner(ui,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=ui end
    local function stroke(ui,th,col) local s=Instance.new("UIStroke") s.Thickness=th or 2.2 s.Color=col or THEME.GREEN s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=ui end
    local function tween(o,p,d) TweenService:Create(o, TweenInfo.new(d or 0.08, Enum.EasingStyle.Quad,Enum.EasingDirection.Out), p):Play() end

    -- ========= UFO Quick Toast (EN) =========
    local function QuickToast(msg)
        local PG = Players.LocalPlayer:WaitForChild("PlayerGui")
        local old = PG:FindFirstChild("UFO_QuickToast"); if old then old:Destroy() end

        local gui = Instance.new("ScreenGui")
        gui.Name = "UFO_QuickToast"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 999999
        gui.Parent = PG

        local W,H = 320, 70
        local box = Instance.new("Frame")
        box.AnchorPoint = Vector2.new(1,1)
        box.Position = UDim2.new(1, -2, 1, -(2 - 24))
        box.Size = UDim2.fromOffset(W, H)
        box.BackgroundColor3 = Color3.fromRGB(10,10,10)
        box.BorderSizePixel = 0
        box.Parent = gui
        corner(box, 10)
        local st = Instance.new("UIStroke", box)
        st.Thickness = 2
        st.Color = THEME.GREEN
        st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.RichText = true
        title.Text = '<font color="#FFFFFF">UFO</font> <font color="#19FF7D">HUB X</font>'
        title.TextSize = 18
        title.TextColor3 = THEME.WHITE
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Position = UDim2.fromOffset(14, 10)
        title.Size = UDim2.fromOffset(W-24, 20)
        title.Parent = box

        local text = Instance.new("TextLabel")
        text.BackgroundTransparency = 1
        text.Font = Enum.Font.Gotham
        text.Text = msg
        text.TextSize = 13
        text.TextColor3 = Color3.fromRGB(200,200,200)
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Position = UDim2.fromOffset(14, 34)
        text.Size = UDim2.fromOffset(W-24, 24)
        text.Parent = box

        TweenService:Create(box, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, -2, 1, -2)}):Play()

        task.delay(1.25, function()
            local t = TweenService:Create(box, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
                {Position = UDim2.new(1, -2, 1, -(2 - 24))})
            t:Play(); t.Completed:Wait(); gui:Destroy()
        end)
    end
    -- ========================================

    local list = scroll:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0,12); list.SortOrder = Enum.SortOrder.LayoutOrder
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    if not scroll:FindFirstChild("SID_Header") then
        local head = Instance.new("TextLabel", scroll)
        head.Name="SID_Header"; head.BackgroundTransparency=1; head.Size=UDim2.new(1,0,0,36)
        head.Font=Enum.Font.GothamBold; head.TextSize=16; head.TextColor3=THEME.TEXT
        head.TextXAlignment=Enum.TextXAlignment.Left; head.Text="Server ID 🔑"
        head.LayoutOrder = 2000
    end

    local function makeRow(name, label, order)
        if scroll:FindFirstChild(name) then return scroll[name] end
        local row = Instance.new("Frame", scroll)
        row.Name=name; row.Size=UDim2.new(1,-6,0,46); row.BackgroundColor3=THEME.BLACK
        row.LayoutOrder=order; corner(row,12); stroke(row,2.2,THEME.GREEN)
        local lab=Instance.new("TextLabel", row)
        lab.BackgroundTransparency=1; lab.Size=UDim2.new(1,-180,1,0); lab.Position=UDim2.new(0,16,0,0)
        lab.Font=Enum.Font.GothamBold; lab.TextSize=13; lab.TextColor3=THEME.WHITE
        lab.TextXAlignment=Enum.TextXAlignment.Left; lab.Text=label
        return row
    end
    local function makeActionButton(parent, text)
        local btn = Instance.new("TextButton", parent)
        btn.AutoButtonColor=false; btn.Text=text; btn.Font=Enum.Font.GothamBold; btn.TextSize=13
        btn.TextColor3=THEME.WHITE; btn.BackgroundColor3=THEME.BLACK
        btn.Size=UDim2.fromOffset(120,28); btn.AnchorPoint=Vector2.new(1,0.5); btn.Position=UDim2.new(1,-12,0.5,0)
        corner(btn,10); stroke(btn,1.6,THEME.GREEN)
        btn.MouseEnter:Connect(function() tween(btn,{BackgroundColor3=THEME.GREY},0.08) end)
        btn.MouseLeave:Connect(function() tween(btn,{BackgroundColor3=THEME.BLACK},0.08) end)
        return btn
    end
    local function makeRightInput(parent, placeholder)
        local boxWrap = Instance.new("Frame", parent)
        boxWrap.AnchorPoint=Vector2.new(1,0.5); boxWrap.Position=UDim2.new(1,-12,0.5,0)
        boxWrap.Size=UDim2.fromOffset(300,28); boxWrap.BackgroundColor3=THEME.BLACK
        corner(boxWrap,10); stroke(boxWrap,1.6,THEME.GREEN)

        local tb = Instance.new("TextBox", boxWrap)
        tb.BackgroundTransparency=1; tb.Size=UDim2.fromScale(1,1); tb.Position=UDim2.new(0,8,0,0)
        tb.Font=Enum.Font.Gotham; tb.TextSize=13; tb.TextColor3=THEME.WHITE
        tb.ClearTextOnFocus=false
        tb.Text = ""
        tb.PlaceholderText = placeholder or "Paste JobId / VIP link / roblox:// link…"
        tb.PlaceholderColor3 = Color3.fromRGB(180,180,185)
        tb.TextXAlignment = Enum.TextXAlignment.Left
        return tb
    end

    local function trim(s) return (s or ""):gsub("^%s+",""):gsub("%s+$","") end
    local function parseInputToTeleport(infoText)
        local t = trim(infoText)
        local deep_place = t:match("[?&]placeId=(%d+)")
        local deep_job   = t:match("[?&]gameInstanceId=([%w%-]+)")
        local priv_code  = t:match("[?&]privateServerLinkCode=([%w%-%_]+)")
        local priv_place = t:match("[?&]placeId=(%d+)")
        local plain_job  = t:match("(%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x)")
        if not plain_job and deep_job and #deep_job >= 32 then plain_job = deep_job end
        if priv_code then
            return { mode="private", placeId = tonumber(priv_place) or game.PlaceId, code = priv_code }
        elseif deep_job or plain_job then
            local jobId = deep_job or plain_job
            return { mode="public", placeId = tonumber(deep_place) or game.PlaceId, jobId = jobId }
        else
            return nil, "Invalid input. Paste a JobId, VIP link (privateServerLinkCode=...), or a roblox:// link."
        end
    end

    local inputRow = makeRow("SID_Input", "Server ID / Link", 2001)
    local inputBox = inputRow:FindFirstChildWhichIsA("Frame") and inputRow:FindFirstChildWhichIsA("Frame"):FindFirstChildOfClass("TextBox")
    if not inputBox then
        inputBox = makeRightInput(inputRow, "e.g. JobId or VIP link or roblox://...")
    else
        if inputBox.Text == "TextBox" then inputBox.Text = "" end
    end

    local joinRow = makeRow("SID_Join", "Join by this Server", 2002)
    if not joinRow:FindFirstChildOfClass("TextButton") then
        local joinBtn = makeActionButton(joinRow, "Join")
        joinBtn.MouseButton1Click:Connect(function()
            local raw = inputBox.Text or ""
            local target, err = parseInputToTeleport(raw)
            if not target then QuickToast(err); return end
            if target.mode=="public" and tostring(target.jobId)==tostring(game.JobId) then
                QuickToast("You are already in this server."); return
            end
            local ok, msg = false, nil
            if target.mode=="private" then
                ok, msg = pcall(function() TeleportService:TeleportToPrivateServer(target.placeId, target.code, {lp}) end)
            else
                ok, msg = pcall(function() TeleportService:TeleportToPlaceInstance(target.placeId, target.jobId, lp) end)
            end
            if not ok then
                QuickToast("Teleport failed: "..tostring(msg))
            else
                local tip = (target.mode=="private") and ("Private code: "..string.sub(target.code,1,6).."…")
                                                   or  ("JobId: "..string.sub(target.jobId,1,8).."…")
                QuickToast("Teleporting…  "..tip)
            end
        end)
    end

    local copyRow = makeRow("SID_Copy", "Copy current Server ID", 2003)
    if not copyRow:FindFirstChildOfClass("TextButton") then
        local copyBtn = makeActionButton(copyRow, "Copy ID")
        copyBtn.MouseButton1Click:Connect(function()
            local id = tostring(game.JobId or "")
            local ok = pcall(function() setclipboard(id) end)
            if ok then QuickToast("Server ID copied ✅") else QuickToast("Current Server ID: "..id) end
            if inputBox and id~="" then inputBox.Text = id end
        end)
    end
end)
-- ===== UFO HUB X • Update Tab — Map Update 🗺️ =====
registerRight("Update", function(scroll)
    local Players = game:GetService("Players")
    local MarketplaceService = game:GetService("MarketplaceService")
    local RunService = game:GetService("RunService")

    -- CONFIG
    local MAP_SUFFIX = " — อัพเดต v1.0 ✍️"
    local NOTES_TEXT = "- เพิ่มจุดเกิดใหม่\n-A1\n-A2\n-A3\n-A4\n-A5\n-A6\n-A7\n-A8\n-A9"

    -- THEME
    local THEME = {
        GREEN=Color3.fromRGB(25,255,125), WHITE=Color3.fromRGB(255,255,255),
        BLACK=Color3.fromRGB(0,0,0), GREY=Color3.fromRGB(180,180,185)
    }
    local function corner(ui,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=ui end
    local function stroke(ui,th,col,trans) local s=Instance.new("UIStroke"); s.Thickness=th or 2.2; s.Color=col or THEME.GREEN; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Transparency=trans or 0; s.Parent=ui; return s end

    -- clear old
    for _,n in ipairs({"UP_Header","UP_Wrap"}) do local o=scroll:FindFirstChild(n); if o then o:Destroy() end end

    -- list defaults
    local list = scroll:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout",scroll)
    list.Padding = UDim.new(0,12); list.SortOrder = Enum.SortOrder.LayoutOrder
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local base = 3100

    -- title
    local head = Instance.new("TextLabel",scroll)
    head.Name="UP_Header"; head.LayoutOrder=base; head.BackgroundTransparency=1; head.Size=UDim2.new(1,0,0,32)
    head.Font=Enum.Font.GothamBlack; head.TextSize=16; head.TextColor3=THEME.WHITE; head.TextXAlignment=Enum.TextXAlignment.Left
    head.Text="Map Update 🗺️"

    -- wrap
    local wrap = Instance.new("Frame",scroll)
    wrap.Name="UP_Wrap"; wrap.LayoutOrder=base+1; wrap.Size=UDim2.new(1,-6,0,260)
    wrap.BackgroundColor3=THEME.BLACK; corner(wrap,12); stroke(wrap,2.2,THEME.GREEN)

    -- ===== Header (now BLACK)
    local header = Instance.new("Frame",wrap)
    header.BackgroundColor3 = THEME.BLACK   -- ← เปลี่ยนเป็นดำ
    header.Position = UDim2.new(0,12,0,12)
    header.Size = UDim2.new(1,-24,0,60)
    corner(header,10); stroke(header,1.6,THEME.GREEN,0)

    local icon = Instance.new("ImageLabel",header)
    icon.BackgroundTransparency=1
    icon.Size = UDim2.fromOffset(48,48)
    icon.Position = UDim2.new(0,8,0,6)
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Image = ("rbxthumb://type=GameIcon&id=%d&w=150&h=150"):format(game.GameId)

    local mapName = "Current Place"
    pcall(function()
        local inf = MarketplaceService:GetProductInfo(game.PlaceId)
        if inf and inf.Name then mapName = inf.Name end
    end)

    local nameLbl = Instance.new("TextLabel",header)
    nameLbl.BackgroundTransparency=1
    nameLbl.Position = UDim2.new(0,8+48+10,0,0)
    nameLbl.Size = UDim2.new(1,-(8+48+10+12),1,0)
    nameLbl.Font = Enum.Font.GothamBlack
    nameLbl.TextSize = 16
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextColor3 = THEME.WHITE       -- ← ตัวอักษรขาวให้ตัดกับพื้นดำ
    nameLbl.Text = mapName .. ((MAP_SUFFIX ~= "" and (" "..MAP_SUFFIX)) or "")

    -- ===== Notes (BLACK + no scrollbar visuals)
    local notesScroll = Instance.new("ScrollingFrame",wrap)
    notesScroll.Name = "UP_Notes"
    notesScroll.Position = UDim2.new(0,12,0,12+60+12)
    notesScroll.Size = UDim2.new(1,-24,1,-(12+60+12+12))
    notesScroll.BackgroundColor3 = THEME.BLACK  -- ← เปลี่ยนเป็นดำ
    notesScroll.BorderSizePixel = 0
    notesScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    notesScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
    notesScroll.CanvasSize = UDim2.new(0,0,0,0)
    notesScroll.Active = true
    -- ซ่อนเส้นสกรอลล์ทั้งหมด
    notesScroll.ScrollBarThickness = 0
    notesScroll.ScrollBarImageTransparency = 1
    corner(notesScroll,10); stroke(notesScroll,1.8,THEME.GREEN,0.15)

    local PAD_L, PAD_R, PAD_T, PAD_B = 14, 10, 10, 10
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0,PAD_L)
    pad.PaddingRight  = UDim.new(0,PAD_R)
    pad.PaddingTop    = UDim.new(0,PAD_T)
    pad.PaddingBottom = UDim.new(0,PAD_B)
    pad.Parent = notesScroll

    local label = Instance.new("TextLabel", notesScroll)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0,0,0,0)
    label.Size = UDim2.new(1,-(PAD_L+PAD_R), 0, 0)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = THEME.WHITE          -- ← ข้อความขาวบนพื้นดำ
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextWrapped = true
    label.RichText = true
    label.Text = NOTES_TEXT

    local function refreshNoteSize()
        local _ = label.TextBounds
        label.Size = UDim2.new(1,-(PAD_L+PAD_R), 0, label.TextBounds.Y)
        notesScroll.CanvasSize = UDim2.new(0,0,0, label.TextBounds.Y + PAD_T + PAD_B)
    end
    refreshNoteSize()
    label:GetPropertyChangedSignal("TextBounds"):Connect(refreshNoteSize)
    RunService.Heartbeat:Connect(refreshNoteSize)
end)
-- ===== [FULL PASTE] UFO HUB X • Update Tab — System #2: Social Links (A V1 + press effect + UFO toast) =====
registerRight("Update", function(scroll)
    -- ===== THEME (A V1) =====
    local THEME = {
        GREEN = Color3.fromRGB(25,255,125),
        WHITE = Color3.fromRGB(255,255,255),
        BLACK = Color3.fromRGB(0,0,0),
        TEXT  = Color3.fromRGB(255,255,255),
    }
    local function corner(ui,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 12); c.Parent=ui end
    local function stroke(ui,th,col) local s=Instance.new("UIStroke"); s.Thickness=th or 2.2; s.Color=col or THEME.GREEN; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=ui end
    local TS = game:GetService("TweenService")

    -- ===== UFO Quick Toast (EN) — title with white 'UFO' + green 'HUB X' =====
    local function QuickToast(msg)
        local PG = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local gui = Instance.new("ScreenGui")
        gui.Name = "UFO_QuickToast"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 999999
        gui.Parent = PG

        local W,H = 320, 70
        local box = Instance.new("Frame")
        box.Name = "Toast"
        box.AnchorPoint = Vector2.new(1,1)
        box.Position = UDim2.new(1, -2, 1, -(2 - 24))
        box.Size = UDim2.fromOffset(W, H)
        box.BackgroundColor3 = Color3.fromRGB(10,10,10)
        box.BorderSizePixel = 0
        box.Parent = gui
        corner(box, 10)
        local st = Instance.new("UIStroke", box)
        st.Thickness = 2
        st.Color = THEME.GREEN
        st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.RichText = true
        title.Text = '<font color="#FFFFFF">UFO</font> <font color="#19FF7D">HUB X</font>'
        title.TextSize = 18
        title.TextColor3 = THEME.WHITE
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Position = UDim2.fromOffset(14, 10)
        title.Size = UDim2.fromOffset(W-24, 20)
        title.Parent = box

        local text = Instance.new("TextLabel")
        text.BackgroundTransparency = 1
        text.Font = Enum.Font.Gotham
        text.Text = msg
        text.TextSize = 13
        text.TextColor3 = Color3.fromRGB(200,200,200)
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Position = UDim2.fromOffset(14, 34)
        text.Size = UDim2.fromOffset(W-24, 24)
        text.Parent = box

        TS:Create(box, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, -2, 1, -2)}):Play()

        task.delay(1.25, function()
            local t = TS:Create(box, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
                {Position = UDim2.new(1, -2, 1, -(2 - 24))})
            t:Play(); t.Completed:Wait(); gui:Destroy()
        end)
    end

    -- ===== A V1 RULE: one UIListLayout under `scroll` =====
    local list = scroll:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0, 12)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- dynamic base by current children (respects file/run order)
    local base = 10
    for _,ch in ipairs(scroll:GetChildren()) do
        if ch:IsA("GuiObject") and ch ~= list then
            base = math.max(base, (ch.LayoutOrder or 0) + 1)
        end
    end

    -- clear duplicates
    for _,n in ipairs({"SOC2_Header","SOC2_Row_YT","SOC2_Row_FB","SOC2_Row_DC","SOC2_Row_IG"}) do
        local o = scroll:FindFirstChild(n); if o then o:Destroy() end
    end

    -- data
    local DATA = {
        { key="YT", label="YouTube UFO HUB X",  color=Color3.fromRGB(220,30,30),
          link="https://youtube.com/@ufohubxstudio?si=XXFZ0rcJn9zva3x6" },
        { key="FB", label="Facebook UFO HUB X", color=Color3.fromRGB(40,120,255), link="" },
        { key="DC", label="Discord UFO HUB X",  color=Color3.fromRGB(88,101,242),
          link="https://discord.gg/A6Mqpfj3" },
        { key="IG", label="Instagram UFO HUB X",color=Color3.fromRGB(225,48,108), link="" },
    }

    -- header (single)
    local head = Instance.new("TextLabel", scroll)
    head.Name = "SOC2_Header"
    head.BackgroundTransparency = 1
    head.Size = UDim2.new(1, 0, 0, 36)
    head.Font = Enum.Font.GothamBold
    head.TextSize = 16
    head.TextColor3 = THEME.TEXT
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.Text = "Social update UFO HUB X 📣"
    head.LayoutOrder = base; base += 1

    -- press effect util (darken briefly)
    local function pressEffect(row, baseColor)
        local dark = Color3.fromRGB(
            math.max(math.floor(baseColor.R*255)-18,0),
            math.max(math.floor(baseColor.G*255)-18,0),
            math.max(math.floor(baseColor.B*255)-18,0)
        )
        TS:Create(row, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = dark}):Play()
        task.delay(0.08, function()
            TS:Create(row, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = baseColor}):Play()
        end)
    end

    -- row factory (no row icons; right-side plain ▶ only)
    local function makeRow(item, order)
        local row = Instance.new("Frame", scroll)
        row.Name = "SOC2_Row_"..item.key
        row.Size = UDim2.new(1, -6, 0, 46)
        row.LayoutOrder = order
        row.BackgroundColor3 = item.color
        corner(row, 12); stroke(row, 2.2, THEME.GREEN)

        local lab = Instance.new("TextLabel", row)
        lab.BackgroundTransparency = 1
        lab.Position = UDim2.new(0, 16, 0, 0)
        lab.Size = UDim2.new(1, -56, 1, 0) -- leave space for arrow
        lab.Font = Enum.Font.GothamBold
        lab.TextSize = 13
        lab.TextColor3 = THEME.WHITE
        lab.TextXAlignment = Enum.TextXAlignment.Left
        lab.Text = item.label

        -- plain arrow (no bg / no stroke)
        local arrow = Instance.new("TextLabel", row)
        arrow.BackgroundTransparency = 1
        arrow.AnchorPoint = Vector2.new(1,0.5)
        arrow.Position = UDim2.new(1, -14, 0.5, 0)
        arrow.Size = UDim2.fromOffset(18, 18)
        arrow.Font = Enum.Font.GothamBlack
        arrow.TextSize = 18
        arrow.TextColor3 = THEME.WHITE
        arrow.Text = "▶"

        -- click whole row
        local hit = Instance.new("TextButton", row)
        hit.BackgroundTransparency = 1
        hit.AutoButtonColor = false
        hit.Text = ""
        hit.Size = UDim2.fromScale(1,1)
        hit.MouseButton1Click:Connect(function()
            pressEffect(row, item.color)
            if item.link ~= "" then
                local ok=false
                if typeof(setclipboard)=="function" then ok = pcall(function() setclipboard(item.link) end) end
                QuickToast(item.label .. " — Link copied ✅")
                if not ok then print("[UFO HUB X] Clipboard not available; link: "..item.link) end
            else
                QuickToast(item.label .. " — No link set")
            end
        end)
    end

    -- build rows under header in dynamic order
    for _,it in ipairs(DATA) do makeRow(it, base); base += 1 end
end)
-- ===== [/FULL PASTE] =====
 --===== UFO HUB X • SETTINGS — UI FPS Monitor (MATCH ROBLOX REALTIME) + Runner Save =====
registerRight("Settings", function(scroll)
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Tween      = game:GetService("TweenService")
local Stats      = game:GetService("Stats")
local Http       = game:GetService("HttpService")
local MPS        = game:GetService("MarketplaceService")

--------------------------------------------------------------------------------------  
-- SAVE (per-map): ใช้ไฟล์ในตัวรัน "UFO HUB X/<PlaceId - PlaceName>.json" ถ้าไม่มี FS จะ fallback เป็น getgenv()  
--------------------------------------------------------------------------------------  
local function safePlaceName()  
    local ok,info = pcall(function() return MPS:GetProductInfo(game.PlaceId) end)  
    local n = (ok and info and info.Name) or ("Place_"..tostring(game.PlaceId))  
    return n:gsub("[^%w%-%._ ]","_")  
end  
local SAVE_DIR  = "UFO HUB X"  
local SAVE_FILE = SAVE_DIR.."/"..tostring(game.PlaceId).." - "..safePlaceName()..".json"  
local hasFS = (typeof(isfolder)=="function" and typeof(makefolder)=="function"  
            and typeof(writefile)=="function" and typeof(readfile)=="function")  
if hasFS and not isfolder(SAVE_DIR) then pcall(makefolder, SAVE_DIR) end  
getgenv().UFOX_RAM = getgenv().UFOX_RAM or {}  
local RAM = getgenv().UFOX_RAM  

local function loadSave()  
    if hasFS and pcall(function() return readfile(SAVE_FILE) end) then  
        local ok,dec = pcall(function() return Http:JSONDecode(readfile(SAVE_FILE)) end)  
        if ok and type(dec)=="table" then return dec end  
    end  
    return RAM[SAVE_FILE] or {}  
end  
local function writeSave(t)  
    t = t or {}  
    if hasFS then pcall(function() writefile(SAVE_FILE, Http:JSONEncode(t)) end) end  
    RAM[SAVE_FILE] = t  
end  
local function getSave(path, default)  
    local data = loadSave(); local cur = data  
    for seg in string.gmatch(path,"[^%.]+") do cur = (type(cur)=="table") and cur[seg] or nil end  
    return (cur==nil) and default or cur  
end  
local function setSave(path, value)  
    local data = loadSave()  
    local parent = data; local key  
    for seg in string.gmatch(path,"[^%.]+") do  
        key = seg  
        if not parent[seg] or type(parent[seg])~="table" then parent[seg] = {} end  
        parent = parent[seg]  
    end  
    -- เขียนค่าที่ระดับบนสุดของ path  
    local stack, p = {}, data  
    for seg in string.gmatch(path,"[^%.]+") do table.insert(stack, seg) end  
    for i=1,#stack-1 do p = p[stack[i]] end  
    p[stack[#stack]] = value  
    writeSave(data)  
end  
--------------------------------------------------------------------------------------  

-- ===== LOOK / LAYOUT =====  
local ICON_SIZE   = 28  
local TEXT_SIZE   = 16  
local ROW_HEIGHT  = 44  

local BOX_WIDTH   = 760  
local INNER_PAD   = 12  
local GAP_BETWEEN = 10  
local FIRST_SHIFT = 24  
local FOURTH_SHIFT= 10  
local LAST_BONUS  = 12  

local THEME = {  
    GREEN = Color3.fromRGB(25,255,125),  
    RED   = Color3.fromRGB(255,40,40),  
    WHITE = Color3.fromRGB(255,255,255),  
    BLACK = Color3.fromRGB(0,0,0),  
    TEXT  = Color3.fromRGB(255,255,255),  
    DIM   = Color3.fromRGB(160,200,160),  
}  
local function corner(ui,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=ui end  
local function stroke(ui,th,col) local s=Instance.new("UIStroke") s.Thickness=th or 2.0 s.Color=col or THEME.GREEN s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=ui end  
local function tween(o,p) Tween:Create(o, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play() end  

-- ===== STATE =====  
_G.UFOX_FPS = _G.UFOX_FPS or { enabled=false, frame=nil }  
local S = _G.UFOX_FPS  

-- ===== Settings panel wrapper =====  
local WRAP = "UFOX_WRAP_UIFPS_ONLY"  
local old = scroll:FindFirstChild(WRAP); if old then old:Destroy() end  
local wrap = Instance.new("Frame", scroll); wrap.Name=WRAP; wrap.BackgroundTransparency=1; wrap.AutomaticSize=Enum.AutomaticSize.Y; wrap.Size=UDim2.new(1,0,0,0)  
local maxOrder=0 for _,ch in ipairs(scroll:GetChildren()) do if ch:IsA("GuiObject") then maxOrder = math.max(maxOrder,(ch.LayoutOrder or 0)) end end  
wrap.LayoutOrder = maxOrder+1  
local list = Instance.new("UIListLayout", wrap); list.Padding=UDim.new(0,12); list.SortOrder=Enum.SortOrder.LayoutOrder  

local header = Instance.new("TextLabel", wrap)  
header.BackgroundTransparency=1; header.Size=UDim2.new(1,0,0,36)  
header.Font=Enum.Font.GothamBold; header.TextSize=16; header.TextColor3=THEME.TEXT  
header.TextXAlignment=Enum.TextXAlignment.Left; header.Text="UI FPS ⚡"; header.LayoutOrder=1  

local row = Instance.new("Frame", wrap)  
row.Size=UDim2.new(1,-6,0,46); row.BackgroundColor3=THEME.BLACK; corner(row,12); stroke(row,2.2,THEME.GREEN); row.LayoutOrder=2  
local lab = Instance.new("TextLabel", row)  
lab.BackgroundTransparency=1; lab.Size=UDim2.new(1,-160,1,0); lab.Position=UDim2.new(0,16,0,0)  
lab.Font=Enum.Font.GothamBold; lab.TextSize=13; lab.TextColor3=THEME.WHITE  
lab.TextXAlignment=Enum.TextXAlignment.Left; lab.Text="UI FPS Display"  

local sw = Instance.new("Frame", row); sw.AnchorPoint=Vector2.new(1,0.5); sw.Position=UDim2.new(1,-12,0.5,0)  
sw.Size=UDim2.fromOffset(52,26); sw.BackgroundColor3=THEME.BLACK; corner(sw,13)  
local swStroke = Instance.new("UIStroke", sw); swStroke.Thickness=1.8  
local knob=Instance.new("Frame", sw); knob.Size=UDim2.fromOffset(22,22); knob.BackgroundColor3=THEME.WHITE; corner(knob,11)  
knob.Position=UDim2.new(0,2,0.5,-11); swStroke.Color=THEME.RED  

-- สวิตช์ + เซฟ  
local function setSwitch(v)  
    S.enabled=v  
    swStroke.Color = v and THEME.GREEN or THEME.RED  
    tween(knob,{Position=UDim2.new(v and 1 or 0, v and -24 or 2, 0.5, -11)})  
    if S.frame then S.frame.Visible=v end  
    -- SAVE  
    setSave("Settings.UIFPS.Enabled", v)  
end  
local btn=Instance.new("TextButton", sw); btn.BackgroundTransparency=1; btn.Size=UDim2.fromScale(1,1); btn.Text=""  
btn.MouseButton1Click:Connect(function() setSwitch(not S.enabled) end)  

-- ===== Readers =====  
local function getPingMs()  
    local item = Stats.Network and Stats.Network:FindFirstChild("ServerStatsItem")  
    item = item and item:FindFirstChild("Data Ping")  
    if item then local n=tonumber(string.match(item:GetValueString(),"(%d+%.?%d*)")); return n or 0 end  
    return 0  
end  
local function getKbps(name)  
    local item = Stats.Network and Stats.Network:FindFirstChild("ServerStatsItem")  
    item = item and item:FindFirstChild(name)  
    if item then local n=tonumber(string.match(item:GetValueString(),"(%d+%.?%d*)")); return n or 0 end  
    return 0  
end  
local function getMemMBStable()  
    local ok,v = pcall(function() return Stats:GetTotalMemoryUsageMb() end)  
    if ok and v and v>0 then return v end  
    return 0  
end  

local ICONS = {  
    FPS      = "rbxassetid://116103940304617",  
    Ping     = "rbxassetid://125226433995402",  
    Memory   = "rbxassetid://131794120624488",  
    Upload   = "rbxassetid://125701675927454",  
    Download = "rbxassetid://134953518153703",  
}  

-- ===== HUD =====  
local function createFPSFrame()  
    if S.frame and S.frame.Parent then return S.frame end  

    local gui = Instance.new("ScreenGui")  
    gui.Name="UFOX_FPS_GUI"; gui.IgnoreGuiInset=true; gui.ResetOnSpawn=false; gui.DisplayOrder=1000001  
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling  
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")  

    local box = Instance.new("Frame", gui)  
    box.Name="FPSBox"; box.Size=UDim2.new(0,BOX_WIDTH,0,ROW_HEIGHT); box.Position=UDim2.new(0.5,-BOX_WIDTH/2,0,8)  
    box.BackgroundColor3=THEME.BLACK; box.BorderSizePixel=0; corner(box,10); stroke(box,2,THEME.GREEN)  

    local SLOT_W = math.floor((BOX_WIDTH - (INNER_PAD*2) - (GAP_BETWEEN*4)) / 5)  

    local function makeSlot(i, iconId, initText)  
        local shift = (i==1 and FIRST_SHIFT) or (i==4 and FOURTH_SHIFT) or 0  
        local bonus = (i==5) and LAST_BONUS or 0  
        local x = INNER_PAD + (i-1)*(SLOT_W + GAP_BETWEEN) + shift  

        local icon = Instance.new("ImageLabel", box); icon.BackgroundTransparency=1; icon.Image=iconId  
        icon.Size = UDim2.fromOffset(ICON_SIZE, ICON_SIZE); icon.Position = UDim2.new(0, x, 0.5, -ICON_SIZE/2)  

        local txt = Instance.new("TextLabel", box)  
        txt.BackgroundTransparency=1  
        txt.Position = UDim2.new(0, x + ICON_SIZE + 6, 0, 0)  
        txt.Size = UDim2.new(0, SLOT_W - (ICON_SIZE + 12) + bonus - shift, 1, 0)  
        txt.Font = Enum.Font.GothamBold; txt.TextSize = TEXT_SIZE; txt.TextColor3 = THEME.GREEN  
        txt.TextXAlignment = Enum.TextXAlignment.Left; txt.TextTruncate = Enum.TextTruncate.None; txt.Text = initText  
        return txt  
    end  

    local tFPS   = makeSlot(1, ICONS.FPS,      "FPS: --")  
    local tPing  = makeSlot(2, ICONS.Ping,     "Ping: --ms")  
    local tMem   = makeSlot(3, ICONS.Memory,   "Mem: --MB")  
    local tUp    = makeSlot(4, ICONS.Upload,   "Up: --Kbps")  
    local tDown  = makeSlot(5, ICONS.Download, "Down: --Kbps")  

    local lastMem = 0  
    local uiAcc, UI_RATE = 0, 0.10  
    RunService.Heartbeat:Connect(function(dt)  
        local fps = math.clamp(1 / math.max(dt, 1/10000), 1, 1000)  
        uiAcc += dt  
        if uiAcc >= UI_RATE then  
            uiAcc = 0  
            local ping  = getPingMs()  
            local up    = getKbps("Data Send Kbps")  
            local down  = getKbps("Data Receive Kbps")  
            local mem   = getMemMBStable(); if mem == 0 then mem = lastMem else lastMem = mem end  
            if S.enabled then  
                tFPS.Text  = string.format("FPS: %d",   math.floor(fps + 0.5))  
                tPing.Text = string.format("Ping: %dms", math.floor(ping + 0.5))  
                tMem.Text  = string.format("Mem: %dMB",  math.floor(mem + 0.5))  
                tUp.Text   = string.format("Up: %dKbps", math.floor(up + 0.5))  
                tDown.Text = string.format("Down: %dKbps", math.floor(down + 0.5))  
            end  
        end  
    end)  

    box.Visible = S.enabled  
    S.frame = box  
    return box  
end  

-- Build + Restore saved state  
createFPSFrame()  
local savedOn = getSave("Settings.UIFPS.Enabled", false)  
setSwitch(savedOn)

end)
--===== UFO HUB X • SETTINGS — Smoother 🚀 (A V1 • fixed 3 rows) + Runner Save (per-map) =====
registerRight("Settings", function(scroll)
    local TweenService = game:GetService("TweenService")
    local Lighting     = game:GetService("Lighting")
    local Players      = game:GetService("Players")
    local Http         = game:GetService("HttpService")
    local MPS          = game:GetService("MarketplaceService")
    local lp           = Players.LocalPlayer

    --=================== PER-MAP SAVE (file: UFO HUB X/<PlaceId - Name>.json; fallback RAM) ===================
    local function safePlaceName()
        local ok,info = pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
        local n = (ok and info and info.Name) or ("Place_"..tostring(game.PlaceId))
        return n:gsub("[^%w%-%._ ]","_")
    end
    local SAVE_DIR  = "UFO HUB X"
    local SAVE_FILE = SAVE_DIR .. "/" .. tostring(game.PlaceId) .. " - " .. safePlaceName() .. ".json"
    local hasFS = (typeof(isfolder)=="function" and typeof(makefolder)=="function"
                and typeof(readfile)=="function" and typeof(writefile)=="function")
    if hasFS and not isfolder(SAVE_DIR) then pcall(makefolder, SAVE_DIR) end
    getgenv().UFOX_RAM = getgenv().UFOX_RAM or {}
    local RAM = getgenv().UFOX_RAM

    local function loadSave()
        if hasFS and pcall(function() return readfile(SAVE_FILE) end) then
            local ok, data = pcall(function() return Http:JSONDecode(readfile(SAVE_FILE)) end)
            if ok and type(data)=="table" then return data end
        end
        return RAM[SAVE_FILE] or {}
    end
    local function writeSave(t)
        t = t or {}
        if hasFS then pcall(function() writefile(SAVE_FILE, Http:JSONEncode(t)) end) end
        RAM[SAVE_FILE] = t
    end
    local function getSave(path, default)
        local cur = loadSave()
        for seg in string.gmatch(path, "[^%.]+") do cur = (type(cur)=="table") and cur[seg] or nil end
        return (cur==nil) and default or cur
    end
    local function setSave(path, value)
        local data, p, keys = loadSave(), nil, {}
        for seg in string.gmatch(path, "[^%.]+") do table.insert(keys, seg) end
        p = data
        for i=1,#keys-1 do local k=keys[i]; if type(p[k])~="table" then p[k] = {} end; p = p[k] end
        p[keys[#keys]] = value
        writeSave(data)
    end
    --==========================================================================================================

    -- THEME (A V1)
    local THEME = {
        GREEN = Color3.fromRGB(25,255,125),
        WHITE = Color3.fromRGB(255,255,255),
        BLACK = Color3.fromRGB(0,0,0),
        TEXT  = Color3.fromRGB(255,255,255),
        RED   = Color3.fromRGB(255,40,40),
    }
    local function corner(ui,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 12) c.Parent=ui end
    local function stroke(ui,th,col) local s=Instance.new("UIStroke") s.Thickness=th or 2.2 s.Color=col or THEME.GREEN s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=ui end
    local function tween(o,p) TweenService:Create(o,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end

    -- Ensure ListLayout
    local list = scroll:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0,12); list.SortOrder = Enum.SortOrder.LayoutOrder
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- STATE
    _G.UFOX_SMOOTH = _G.UFOX_SMOOTH or { mode=0, plastic=false, _snap={}, _pp={} }
    local S = _G.UFOX_SMOOTH

    -- ===== restore from SAVE =====
    S.mode    = getSave("Settings.Smoother.Mode",    S.mode)      -- 0/1/2
    S.plastic = getSave("Settings.Smoother.Plastic", S.plastic)   -- boolean

    -- Header
    local head = scroll:FindFirstChild("A1_Header") or Instance.new("TextLabel", scroll)
    head.Name="A1_Header"; head.BackgroundTransparency=1; head.Size=UDim2.new(1,0,0,36)
    head.Font=Enum.Font.GothamBold; head.TextSize=16; head.TextColor3=THEME.TEXT
    head.TextXAlignment=Enum.TextXAlignment.Left; head.Text="Smoother 🚀"; head.LayoutOrder = 10

    -- Remove any old rows
    for _,n in ipairs({"A1_Reduce","A1_Remove","A1_Plastic"}) do local old=scroll:FindFirstChild(n); if old then old:Destroy() end end

    -- Row factory
    local function makeRow(name, label, order, onToggle)
        local row = Instance.new("Frame", scroll)
        row.Name=name; row.Size=UDim2.new(1,-6,0,46); row.BackgroundColor3=THEME.BLACK
        row.LayoutOrder=order; corner(row,12); stroke(row,2.2,THEME.GREEN)

        local lab=Instance.new("TextLabel", row)
        lab.BackgroundTransparency=1; lab.Size=UDim2.new(1,-160,1,0); lab.Position=UDim2.new(0,16,0,0)
        lab.Font=Enum.Font.GothamBold; lab.TextSize=13; lab.TextColor3=THEME.WHITE
        lab.TextXAlignment=Enum.TextXAlignment.Left; lab.Text=label

        local sw=Instance.new("Frame", row)
        sw.AnchorPoint=Vector2.new(1,0.5); sw.Position=UDim2.new(1,-12,0.5,0)
        sw.Size=UDim2.fromOffset(52,26); sw.BackgroundColor3=THEME.BLACK
        corner(sw,13)
        local swStroke=Instance.new("UIStroke", sw); swStroke.Thickness=1.8; swStroke.Color=THEME.RED

        local knob=Instance.new("Frame", sw)
        knob.Size=UDim2.fromOffset(22,22); knob.BackgroundColor3=THEME.WHITE
        knob.Position=UDim2.new(0,2,0.5,-11); corner(knob,11)

        local state=false
        local function setState(v)
            state=v
            swStroke.Color = v and THEME.GREEN or THEME.RED
            tween(knob, {Position=UDim2.new(v and 1 or 0, v and -24 or 2, 0.5, -11)})
            if onToggle then onToggle(v) end
        end
        local btn=Instance.new("TextButton", sw)
        btn.BackgroundTransparency=1; btn.Size=UDim2.fromScale(1,1); btn.Text=""
        btn.MouseButton1Click:Connect(function() setState(not state) end)

        return setState
    end

    -- ===== FX helpers (same as before) =====
    local FX = {ParticleEmitter=true, Trail=true, Beam=true, Smoke=true, Fire=true, Sparkles=true}
    local PP = {BloomEffect=true, ColorCorrectionEffect=true, DepthOfFieldEffect=true, SunRaysEffect=true, BlurEffect=true}

    local function capture(inst)
        if S._snap[inst] then return end
        local t={}; pcall(function()
            if inst:IsA("ParticleEmitter") then t.Rate=inst.Rate; t.Enabled=inst.Enabled
            elseif inst:IsA("Trail") then t.Enabled=inst.Enabled; t.Brightness=inst.Brightness
            elseif inst:IsA("Beam") then t.Enabled=inst.Enabled; t.Brightness=inst.Brightness
            elseif inst:IsA("Smoke") then t.Enabled=inst.Enabled; t.Opacity=inst.Opacity
            elseif inst:IsA("Fire") then t.Enabled=inst.Enabled; t.Heat=inst.Heat; t.Size=inst.Size
            elseif inst:IsA("Sparkles") then t.Enabled=inst.Enabled end
        end)
        S._snap[inst]=t
    end
    for _,d in ipairs(workspace:GetDescendants()) do if FX[d.ClassName] then capture(d) end end

    local function applyHalf()
        for i,t in pairs(S._snap) do if i.Parent then pcall(function()
            if i:IsA("ParticleEmitter") then i.Rate=(t.Rate or 10)*0.5
            elseif i:IsA("Trail") or i:IsA("Beam") then i.Brightness=(t.Brightness or 1)*0.5
            elseif i:IsA("Smoke") then i.Opacity=(t.Opacity or 1)*0.5
            elseif i:IsA("Fire") then i.Heat=(t.Heat or 5)*0.5; i.Size=(t.Size or 5)*0.7
            elseif i:IsA("Sparkles") then i.Enabled=false end
        end) end end
        for _,obj in ipairs(Lighting:GetChildren()) do
            if PP[obj.ClassName] then
                S._pp[obj]={Enabled=obj.Enabled, Intensity=obj.Intensity, Size=obj.Size}
                obj.Enabled=true; if obj.Intensity then obj.Intensity=(obj.Intensity or 1)*0.5 end
                if obj.ClassName=="BlurEffect" and obj.Size then obj.Size=math.floor((obj.Size or 0)*0.5) end
            end
        end
    end
    local function applyOff()
        for i,_ in pairs(S._snap) do if i.Parent then pcall(function() i.Enabled=false end) end end
        for _,obj in ipairs(Lighting:GetChildren()) do if PP[obj.ClassName] then obj.Enabled=false end end
    end
    local function restoreAll()
        for i,t in pairs(S._snap) do if i.Parent then for k,v in pairs(t) do pcall(function() i[k]=v end) end end end
        for obj,t in pairs(S._pp)   do if obj.Parent then for k,v in pairs(t) do pcall(function() obj[k]=v end) end end end
    end

    local function plasticMode(on)
        for _,p in ipairs(workspace:GetDescendants()) do
            if p:IsA("BasePart") and not p:IsDescendantOf(lp.Character) then
                if on then
                    if not p:GetAttribute("Mat0") then p:SetAttribute("Mat0",p.Material.Name); p:SetAttribute("Refl0",p.Reflectance) end
                    p.Material=Enum.Material.SmoothPlastic; p.Reflectance=0
                else
                    local m=p:GetAttribute("Mat0"); local r=p:GetAttribute("Refl0")
                    if m then pcall(function() p.Material=Enum.Material[m] end) p:SetAttribute("Mat0",nil) end
                    if r~=nil then p.Reflectance=r; p:SetAttribute("Refl0",nil) end
                end
            end
        end
    end

    -- ===== 3 switches (fixed orders 11/12/13) + SAVE =====
    local set50, set100, setPl

    set50  = makeRow("A1_Reduce", "Reduce Effects 50%", 11, function(v)
        if v then S.mode=1; applyHalf(); if set100 then set100(false) end
        else if S.mode==1 then S.mode=0; restoreAll() end end
        setSave("Settings.Smoother.Mode", S.mode)
    end)

    set100 = makeRow("A1_Remove", "Remove Effects 100%", 12, function(v)
        if v then S.mode=2; applyOff(); if set50 then set50(false) end
        else if S.mode==2 then S.mode=0; restoreAll() end end
        setSave("Settings.Smoother.Mode", S.mode)
    end)

    setPl   = makeRow("A1_Plastic","Plastic Map (Fast Mode)", 13, function(v)
        S.plastic=v; plasticMode(v)
        setSave("Settings.Smoother.Plastic", v)
    end)

    -- ===== Apply restored saved state to UI/World =====
    if S.mode==1 then set50(true)
    elseif S.mode==2 then set100(true)
    else set50(false); set100(false); restoreAll() end
    setPl(S.plastic)
end)
-- ===== UFO HUB X • Settings — AFK 💤 (MODEL A LEGACY, full systems) + Runner Save =====
-- 1) Black Screen (Performance AFK)  [toggle]
-- 2) White Screen (Performance AFK)  [toggle]
-- 3) AFK Anti-Kick (20 min)          [toggle default ON]
-- 4) Activity Watcher (5 min → enable #3) [toggle default ON]

registerRight("Settings", function(scroll)
    local Players       = game:GetService("Players")
    local TweenService  = game:GetService("TweenService")
    local UIS           = game:GetService("UserInputService")
    local RunService    = game:GetService("RunService")
    local VirtualUser   = game:GetService("VirtualUser")
    local Http          = game:GetService("HttpService")
    local MPS           = game:GetService("MarketplaceService")
    local lp            = Players.LocalPlayer

    -- ===== PER-MAP SAVE (runner) =====
    local function safePlaceName()
        local ok,info = pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
        local n = (ok and info and info.Name) or ("Place_"..tostring(game.PlaceId))
        return n:gsub("[^%w%-%._ ]","_")
    end
    local SAVE_DIR  = "UFO HUB X"
    local SAVE_FILE = SAVE_DIR.."/"..tostring(game.PlaceId).." - "..safePlaceName()..".json"
    local hasFS = (typeof(isfolder)=="function" and typeof(makefolder)=="function"
                and typeof(writefile)=="function" and typeof(readfile)=="function")
    if hasFS and not isfolder(SAVE_DIR) then pcall(makefolder, SAVE_DIR) end
    getgenv().UFOX_RAM = getgenv().UFOX_RAM or {}
    local RAM = getgenv().UFOX_RAM

    local function loadSave()
        if hasFS and pcall(function() return readfile(SAVE_FILE) end) then
            local ok,dec = pcall(function() return Http:JSONDecode(readfile(SAVE_FILE)) end)
            if ok and type(dec)=="table" then return dec end
        end
        return RAM[SAVE_FILE] or {}
    end
    local function writeSave(t)
        t = t or {}
        if hasFS then pcall(function() writefile(SAVE_FILE, Http:JSONEncode(t)) end) end
        RAM[SAVE_FILE] = t
    end
    local function getSave(path, default)
        local data = loadSave(); local cur = data
        for seg in string.gmatch(path,"[^%.]+") do cur = (type(cur)=="table") and cur[seg] or nil end
        return (cur==nil) and default or cur
    end
    local function setSave(path, value)
        local data = loadSave()
        local p = data
        local keys = {}
        for seg in string.gmatch(path,"[^%.]+") do table.insert(keys, seg) end
        for i=1,#keys-1 do
            local k = keys[i]
            if type(p[k])~="table" then p[k] = {} end
            p = p[k]
        end
        p[keys[#keys]] = value
        writeSave(data)
    end
    -- ===================================

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

    -- ===== STATE (defaults) =====
    _G.UFOX_AFK = _G.UFOX_AFK or {
        blackOn=false, whiteOn=false, antiIdleOn=true, watcherOn=true,
        lastInput=tick(), antiIdleLoop=nil, idleHooked=false,
        gui=nil, watcherConn=nil,
    }
    local S = _G.UFOX_AFK

    -- ==== Restore from save (per map) ====
    S.blackOn    = getSave("Settings.AFK.Black",     S.blackOn)
    S.whiteOn    = getSave("Settings.AFK.White",     S.whiteOn)
    S.antiIdleOn = getSave("Settings.AFK.AntiKick",  S.antiIdleOn)
    S.watcherOn  = getSave("Settings.AFK.Watcher",   S.watcherOn)

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

    -- ===== Header =====
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
                for i=1,540 do
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
                setSave("Settings.AFK.AntiKick", true)
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
        local function setState(v)
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
        btn.MouseButton1Click:Connect(function() setState(not state) end)

        return setState
    end

    -- ===== Rows + bindings (with SAVE) =====
    local setBlack = makeRow("Black Screen (Performance AFK)", S.blackOn, function(v)
        S.blackOn = v; if v then S.whiteOn=false end; syncOverlays()
        setSave("Settings.AFK.Black", v); if v==true then setSave("Settings.AFK.White", false) end
    end)

    local setWhite = makeRow("White Screen (Performance AFK)", S.whiteOn, function(v)
        S.whiteOn = v; if v then S.blackOn=false end; syncOverlays()
        setSave("Settings.AFK.White", v); if v==true then setSave("Settings.AFK.Black", false) end
    end)

    local setAnti  = makeRow("AFK Anti-Kick (20 min)", S.antiIdleOn, function(v)
        S.antiIdleOn = v; setSave("Settings.AFK.AntiKick", v)
        if v then startAntiIdle() end
    end)

    local setWatch = makeRow("Activity Watcher (5 min → enable #3)", S.watcherOn, function(v)
        S.watcherOn = v; setSave("Settings.AFK.Watcher", v)
    end)

    -- ===== Init =====
    syncOverlays()
    if S.antiIdleOn then startAntiIdle() end
    startWatcher()
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
-- ==== mark boot done (lock forever until reset) ====
do
    local B = getgenv().UFO_BOOT or {}
    B.status = "done"
    getgenv().UFO_BOOT = B
end
--==[ UFO HUB X • Auto Tab Tour + Download Overlay (transparent bg, logo on top, bar below, auto-close) ]==--
local CoreGui       = game:GetService("CoreGui")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local Players       = game:GetService("Players")

-- locate main UI (for clicking tabs)
local root = CoreGui:FindFirstChild("UFO_HUB_X_UI")
          or CoreGui:FindFirstChild("UFO_HUB_X")
          or CoreGui:WaitForChild("UFO_HUB_X_UI", 5)

local function findButtonByText(texts: {string})
	if not root then return nil end
	local map = {}
	for _,t in ipairs(texts) do map[string.lower(t)] = true end
	for _, inst in ipairs(root:GetDescendants()) do
		if inst:IsA("TextButton") or inst:IsA("ImageButton") then
			local t = inst:IsA("TextButton") and (inst.Text or "")
			         or (inst:FindFirstChildWhichIsA("TextLabel") and inst:FindFirstChildWhichIsA("TextLabel").Text or "")
			if map[string.lower(t)] then return inst end
		end
	end
	return nil
end

-- overlay (transparent; only the bar has black bg + green border)
local function createDownloadOverlay()
	local sg = Instance.new("ScreenGui")
	sg.Name = "UFO_HUB_X_DownloadOverlay"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder = 2_000_000
	sg.Parent = CoreGui

	-- full-screen blocker (prevent clicks on main UI)
	local blocker = Instance.new("TextButton")
	blocker.BackgroundTransparency = 1
	blocker.Text = ""
	blocker.AutoButtonColor = false
	blocker.Size = UDim2.fromScale(1,1)
	blocker.Parent = sg

	-- transparent container centered on screen
	local stack = Instance.new("Frame")
	stack.Name = "Stack"
	stack.AnchorPoint = Vector2.new(0.5,0.5)
	stack.Position = UDim2.fromScale(0.5,0.5)
	stack.Size = UDim2.fromScale(0.8,0.6) -- safe area
	stack.BackgroundTransparency = 1
	stack.Parent = sg
	local layout = Instance.new("UIListLayout", stack)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 22)

	-- TOP: logo (bigger) – stays above the bar
	local logo = Instance.new("ImageLabel")
	logo.Name = "Logo"
	logo.BackgroundTransparency = 1
	logo.Image = "rbxassetid://117052960049460"
	logo.Size = UDim2.fromScale(0.36, 0.36)  -- bigger
	logo.LayoutOrder = 1
	logo.Parent = stack
	local ar = Instance.new("UIAspectRatioConstraint", logo); ar.AspectRatio = 1

	-- BOTTOM: progress bar container (only this has black bg + green stroke)
	local barFrame = Instance.new("Frame")
	barFrame.Name = "BarFrame"
	barFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)   -- black bg (only here)
	barFrame.BorderSizePixel = 0
	barFrame.Size = UDim2.fromScale(0.52, 0.16)         -- tuned for phone
	barFrame.LayoutOrder = 2
	barFrame.Parent = stack
	Instance.new("UICorner", barFrame).CornerRadius = UDim.new(0, 8)
	local barStroke = Instance.new("UIStroke", barFrame)
	barStroke.Thickness = 2
	barStroke.Color = Color3.fromRGB(0,255,140)

	-- green fill
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.AnchorPoint = Vector2.new(0,0.5)
	fill.Position = UDim2.fromScale(0,0.5)
	fill.Size = UDim2.fromScale(0,1)
	fill.BackgroundColor3 = Color3.fromRGB(0,255,140)
	fill.BorderSizePixel = 0
	fill.Parent = barFrame
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 8)

	-- percent text (white with black outline) – centered on bar
	local num = Instance.new("TextLabel")
	num.Name = "Percent"
	num.BackgroundTransparency = 1
	num.AnchorPoint = Vector2.new(0.5,0.5)
	num.Position = UDim2.fromScale(0.5,0.5)
	num.Size = UDim2.fromScale(1,1)
	num.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	num.TextScaled = true
	num.Text = "0%"
	num.TextColor3 = Color3.fromRGB(255,255,255) -- white text
	num.TextStrokeColor3 = Color3.fromRGB(0,0,0) -- black outline
	num.TextStrokeTransparency = 0
	num.Parent = barFrame

	-- subtle fade-in (on bar only; stack starts visible)
	barFrame.BackgroundTransparency = 1
	fill.Visible = false
	num.TextTransparency = 1
	TweenService:Create(barFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
	task.delay(0.10, function() fill.Visible = true; num.TextTransparency = 0 end)

	return sg, stack, barFrame, num, fill
end

local function destroyOverlay(sg: ScreenGui, barFrame: Frame)
	if not sg or not sg.Parent then return end
	pcall(function()
		TweenService:Create(barFrame, TweenInfo.new(0.12), {BackgroundTransparency = 1}):Play()
	end)
	task.delay(0.14, function() if sg then sg:Destroy() end end)
end

-- counter 0..100 with fill animation
local function runCounter(label: TextLabel, fill: Frame, duration)
	duration = duration or 2.2
	for i = 0, 100 do
		label.Text = ("%d%%"):format(i)
		fill.Size = UDim2.fromScale(i/100, 1)
		RunService.Heartbeat:Wait()
		task.wait(duration/100)
	end
end

local function click(btn: Instance)
	if btn and btn.Activate then btn:Activate() end
	task.wait(0.10)
end

task.defer(function()
	local overlay, stack, barFrame, percentLabel, fill = createDownloadOverlay()

	-- walk tabs while counting (Home → Quest → Shop → Settings → Player)
	task.spawn(function()
		local home     = findButtonByText({"Home"})
		local quest    = findButtonByText({"Quest"})
		local shop     = findButtonByText({"Shop"})
		local settings = findButtonByText({"Settings","Setting","Update"})
		local player   = findButtonByText({"Player"})
		click(home); click(quest); click(shop); click(settings); click(player)
	end)

	runCounter(percentLabel, fill, 2.2)   -- animate 0→100

	destroyOverlay(overlay, barFrame)     -- auto-close so main UI is usable
end)
