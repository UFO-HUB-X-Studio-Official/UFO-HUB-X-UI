--// UFO HUB X — Ultra One-File (UI เดิม 100% + ระบบใหม่ + ZIndex fix)
--   ใช้ได้กับ CoreGui บนตัวรันมือถือ/PC (Delta, Arceus X, ฯลฯ)

--== PURGE (ลบของเก่าแบบปลอดภัย) ==--
pcall(function()
    local cg = game:GetService("CoreGui")
    for _, n in ipairs({"UFOX_UI","UFOX_TOGGLE"}) do
        local g = cg:FindFirstChild(n); if g then g:Destroy() end
    end
end)

--== CONFIG / THEME ==--
local CFG = {
    WIN_W = 640, WIN_H = 360,
    SCALE_MIN = 0.72, SCALE_MAX = 1.0,

    -- ปุ่มซ้าย “ทรงเดิม”
    BTN_HEIGHT   = 52,
    BTN_SIDE_PAD = 8,
    BTN_GAP      = 8,

    -- toggle / hotkey
    HOTKEY = Enum.KeyCode.RightShift,
    TOGGLE_IMAGE = "rbxassetid://117052960049460",

    -- รูป
    UFO_IMG   = "rbxassetid://100650447103028",
    GLOW_IMG  = "rbxassetid://5028857084",
    ICON_DEF  = "rbxassetid://112510739340023",
    RIGHT_BG  = "rbxassetid://83753985156201", -- BG กรอบขวา (เอเลี่ยนใหญ่)
}

local UI = {
    GREEN      = Color3.fromRGB(0,255,140),
    MINT       = Color3.fromRGB(120,255,220),
    TEXT       = Color3.fromRGB(235,235,235),
    RED        = Color3.fromRGB(200,40,40),
    BG_WINDOW  = Color3.fromRGB(16,16,16),
    BG_HEADER  = Color3.fromRGB(6,6,6),
    BG_PANEL   = Color3.fromRGB(22,22,22),
    BG_INNER   = Color3.fromRGB(18,18,18),
}

--== SERVICES ==--
local S = setmetatable({}, {__index=function(_,k) return game:GetService(k) end})
local UIS, CAS, RunS = S.UserInputService, S.ContextActionService, S.RunService
local CoreGui = S.CoreGui

--== HELPERS ==--
local function corner(g,r) local c=Instance.new("UICorner",g); c.CornerRadius=UDim.new(0,r or 10); return c end
local function stroke(g,t,c,tr)
    local s=Instance.new("UIStroke",g); s.Thickness=t or 1; s.Color=c or UI.MINT
    s.Transparency=tr or 0.35; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.LineJoinMode=Enum.LineJoinMode.Round
    return s
end
local function gradient(g,c1,c2,rot)
    local d=Instance.new("UIGradient",g); d.Color=ColorSequence.new(c1,c2); d.Rotation=rot or 0; return d
end

--== ROOT ==--
local GUI = Instance.new("ScreenGui")
GUI.Name="UFOX_UI"; GUI.IgnoreGuiInset=true; GUI.DisplayOrder=100000
GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; GUI.ResetOnSpawn=false; GUI.Parent=CoreGui

local Window = Instance.new("Frame", GUI)
Window.Name="Window"; Window.AnchorPoint=Vector2.new(0.5,0.5); Window.Position=UDim2.new(0.5,0,0.5,0)
Window.Size=UDim2.fromOffset(CFG.WIN_W, CFG.WIN_H); Window.BackgroundColor3=UI.BG_WINDOW; Window.BorderSizePixel=0
corner(Window,12); local Border=stroke(Window,3,UI.GREEN,0)

-- Glow
do local g=Instance.new("ImageLabel",Window)
    g.BackgroundTransparency=1; g.AnchorPoint=Vector2.new(0.5,0.5)
    g.Position=UDim2.new(0.5,0,0.5,0); g.Size=UDim2.new(1.07,0,1.09,0)
    g.Image=CFG.GLOW_IMG; g.ImageColor3=UI.GREEN; g.ImageTransparency=0.78
    g.ScaleType=Enum.ScaleType.Slice; g.SliceCenter=Rect.new(24,24,276,276); g.ZIndex=0
end

-- Autoscale
local UIScale=Instance.new("UIScale",Window)
local function fit()
    local cam=workspace.CurrentCamera; local v=(cam and cam.ViewportSize) or Vector2.new(1280,720)
    UIScale.Scale = math.clamp(math.min(v.X/860,v.Y/540), CFG.SCALE_MIN, CFG.SCALE_MAX)
end
fit(); RunS.RenderStepped:Connect(fit)

--== HEADER ==--
local Header=Instance.new("Frame",Window)
Header.Size=UDim2.new(1,0,0,46); Header.BackgroundColor3=UI.BG_HEADER; Header.BorderSizePixel=0
corner(Header,12); gradient(Header, Color3.fromRGB(10,10,10), Color3.fromRGB(0,0,0), 0)

local HeadAccent=Instance.new("Frame",Header)
HeadAccent.AnchorPoint=Vector2.new(0.5,1); HeadAccent.Position=UDim2.new(0.5,0,1,0)
HeadAccent.Size=UDim2.new(1,-20,0,1); HeadAccent.BackgroundColor3=UI.MINT; HeadAccent.BackgroundTransparency=0.35

local Title=Instance.new("TextLabel",Header)
Title.BackgroundTransparency=1; Title.AnchorPoint=Vector2.new(0.5,0)
Title.Position=UDim2.new(0.5,0,0,8); Title.Size=UDim2.new(0.8,0,0,36)
Title.Font=Enum.Font.GothamBold; Title.RichText=true; Title.TextScaled=true; Title.TextColor3=UI.TEXT; Title.ZIndex=61
Title.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'

local BtnClose=Instance.new("TextButton",Header)
BtnClose.Size=UDim2.new(0,24,0,24); BtnClose.Position=UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3=UI.RED; BtnClose.Text="X"; BtnClose.Font=Enum.Font.GothamBold; BtnClose.TextSize=13
BtnClose.TextColor3=Color3.new(1,1,1); BtnClose.BorderSizePixel=0; corner(BtnClose,6); stroke(BtnClose,1,Color3.fromRGB(255,0,0),0.1)
BtnClose.MouseButton1Click:Connect(function() Window.Visible=false; getgenv().UFO_ISOPEN=false end)

-- Drag + block camera
do
    local dragging, start, startPos
    local function block(on)
        local name="UFOX_BlockLook_Window"
        if on then
            CAS:BindActionAtPriority(name,function() return Enum.ContextActionResult.Sink end,false,9000,
                Enum.UserInputType.MouseMovement,Enum.UserInputType.Touch,Enum.UserInputType.MouseButton1)
        else pcall(function() CAS:UnbindAction(name) end) end
    end
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Window.Position; block(true)
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; block(false) end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            Window.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

-- UFO deco (เหมือนเดิม)
do
    local UFO=Instance.new("ImageLabel",Window)
    UFO.BackgroundTransparency=1; UFO.Image=CFG.UFO_IMG
    UFO.Size=UDim2.new(0,168,0,168); UFO.AnchorPoint=Vector2.new(0.5,1); UFO.Position=UDim2.new(0.5,0,0,84); UFO.ZIndex=60
    local Halo=Instance.new("ImageLabel",Window)
    Halo.BackgroundTransparency=1; Halo.AnchorPoint=Vector2.new(0.5,0)
    Halo.Position=UDim2.new(0.5,0,0,0); Halo.Size=UDim2.new(0,200,0,60)
    Halo.Image=CFG.GLOW_IMG; Halo.ImageColor3=UI.MINT; Halo.ImageTransparency=0.72; Halo.ZIndex=50
end

--== BODY ==--
local Body=Instance.new("Frame",Window)
Body.BackgroundTransparency=1; Body.Position=UDim2.new(0,0,0,46); Body.Size=UDim2.new(1,0,1,-46)

local Inner=Instance.new("Frame",Body)
Inner.BackgroundColor3=UI.BG_INNER; Inner.BorderSizePixel=0
Inner.Position=UDim2.new(0,8,0,8); Inner.Size=UDim2.new(1,-16,1,-16); corner(Inner,12)

local Content=Instance.new("Frame",Body)
Content.BackgroundColor3=UI.BG_PANEL; Content.Position=UDim2.new(0,14,0,14); Content.Size=UDim2.new(1,-28,1,-28)
corner(Content,12); stroke(Content,0.5,UI.MINT,0.35)

local Columns=Instance.new("Frame",Content)
Columns.BackgroundTransparency=1; Columns.Position=UDim2.new(0,8,0,8); Columns.Size=UDim2.new(1,-16,1,-16)

-- LEFT panel
local Left=Instance.new("Frame",Columns)
Left.Name="Left"; Left.BackgroundColor3=Color3.fromRGB(16,16,16)
Left.Size=UDim2.new(0.22,-6,1,0); Left.ClipsDescendants=true; corner(Left,10)
stroke(Left,1.2,UI.GREEN,0); stroke(Left,0.45,UI.MINT,0.35)

-- RIGHT panel
local Right=Instance.new("Frame",Columns)
Right.Name="Right"; Right.BackgroundColor3=Color3.fromRGB(16,16,16)
Right.Position=UDim2.new(0.22,12,0,0); Right.Size=UDim2.new(0.78,-6,1,0)
Right.ClipsDescendants=true; corner(Right,10)
stroke(Right,1.2,UI.GREEN,0); stroke(Right,0.45,UI.MINT,0.35)

--== Right Header (ชื่อ + ไอคอน) ==--
local RH_Icon=Instance.new("ImageLabel",Right)
RH_Icon.BackgroundTransparency=1; RH_Icon.Size=UDim2.fromOffset(24,24)
RH_Icon.Position=UDim2.new(0,18,0,14); RH_Icon.Visible=false; RH_Icon.ZIndex=5

local RH_Text=Instance.new("TextLabel",Right)
RH_Text.BackgroundTransparency=1; RH_Text.Position=UDim2.new(0,50,0,12)
RH_Text.Size=UDim2.new(1,-80,0,28); RH_Text.Font=Enum.Font.GothamBold; RH_Text.TextSize=18
RH_Text.TextXAlignment=Enum.TextXAlignment.Left; RH_Text.TextColor3=UI.TEXT
RH_Text.Text=""; RH_Text.Visible=false; RH_Text.ZIndex=5

--== Right Background (เอเลี่ยนใหญ่) อยู่ “ใต้สุด” ==--
local RightBG = Instance.new("ImageLabel", Right)
RightBG.Name="RightBG"; RightBG.BackgroundTransparency=1
RightBG.Position=UDim2.fromOffset(0,0); RightBG.Size=UDim2.fromScale(1,1)
RightBG.Image=CFG.RIGHT_BG; RightBG.ScaleType=Enum.ScaleType.Fit
RightBG.ZIndex=0 -- ใต้สุด

--== Scroll containers (ซ่อนสกอร์ลบาร์) ==--
local function makeScroll(host)
    local inset=Instance.new("Frame",host)
    inset.BackgroundTransparency=1; inset.ClipsDescendants=true
    inset.Position=UDim2.fromOffset(2,2); inset.Size=UDim2.new(1,-4,1,-4)

    local sc=Instance.new("ScrollingFrame",inset)
    sc.Name = host.Name.."Scroll"
    sc.BackgroundTransparency=1; sc.BorderSizePixel=0; sc.Size=UDim2.fromScale(1,1)
    sc.ScrollingDirection=Enum.ScrollingDirection.Y; sc.AutomaticCanvasSize=Enum.AutomaticSize.Y; sc.CanvasSize=UDim2.new()
    sc.ScrollBarThickness=0; sc.ScrollBarImageTransparency=1; sc.VerticalScrollBarInset=Enum.ScrollBarInset.None
    local pad=Instance.new("UIPadding",sc)
    pad.PaddingTop=UDim.new(0,CFG.BTN_GAP); pad.PaddingBottom=UDim.new(0,CFG.BTN_GAP)
    pad.PaddingLeft=UDim.new(0,CFG.BTN_SIDE_PAD); pad.PaddingRight=UDim.new(0,CFG.BTN_SIDE_PAD)
    local list=Instance.new("UIListLayout",sc); list.Padding=UDim.new(0,CFG.BTN_GAP); list.SortOrder=Enum.SortOrder.LayoutOrder
    return sc
end
local LeftScroll = makeScroll(Left)
local RightScroll = makeScroll(Right)
RightScroll.ZIndex = 2 -- อยู่กลาง (เหนือ BG แต่ใต้ Header)

--== BUTTON (ซ้าย) ทรงเดิม ==--
local function addButton(label, iconId, onClick)
    local b=Instance.new("TextButton",LeftScroll)
    b.Name="Btn_"..label:gsub("%s+",""); b.AutoButtonColor=false; b.Text=""
    b.Size=UDim2.new(1,0,0,CFG.BTN_HEIGHT); b.BackgroundColor3=UI.BG_WINDOW; corner(b,8)
    local st=stroke(b,0.6,UI.MINT,0.35)

    local ic=Instance.new("ImageLabel",b)
    ic.BackgroundTransparency=1; ic.Image=iconId or CFG.ICON_DEF
    ic.Size=UDim2.fromOffset(CFG.BTN_HEIGHT-12, CFG.BTN_HEIGHT-12)
    ic.Position=UDim2.new(0,8,0.5,-(CFG.BTN_HEIGHT-12)/2)

    local tx=Instance.new("TextLabel",b)
    tx.BackgroundTransparency=1; tx.Position=UDim2.new(0,CFG.BTN_HEIGHT+4,0,0)
    tx.Size=UDim2.new(1,-(CFG.BTN_HEIGHT+12),1,0); tx.Font=Enum.Font.GothamMedium
    tx.TextSize=16; tx.TextXAlignment=Enum.TextXAlignment.Left; tx.TextColor3=UI.TEXT; tx.Text=label

    local down,p0
    b.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            down=true; p0=i.Position; b.BackgroundColor3=Color3.fromRGB(22,30,24); st.Thickness=1.2; st.Color=UI.GREEN
        end
    end)
    b.InputEnded:Connect(function(i)
        if down and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
            down=false; b.BackgroundColor3=UI.BG_WINDOW; st.Thickness=0.6; st.Color=UI.MINT
            if (i.Position - p0).magnitude < 7 then if typeof(onClick)=="function" then task.spawn(onClick) end end
        end
    end)
    return b
end

--== API เล็ก ๆ ==--
local UFO = {}
function UFO:SetTitle(l,r) Title.Text=('<font color="#FFFFFF">%s</font> <font color="#00FF8C">%s</font>'):format(l or "UFO", r or "HUB X") end
function UFO:ShowRightHeader(text, iconId)
    RH_Icon.Image = iconId or CFG.ICON_DEF; RH_Text.Text = text or ""
    RH_Icon.Visible, RH_Text.Visible = true, true
    RH_Icon.ZIndex, RH_Text.ZIndex = 5, 5                -- ย้ำชั้นให้บนสุดของกรอบขวา
    if RightBG then RightBG.ZIndex = 0 end               -- BG ใต้สุด
    if RightScroll then RightScroll.ZIndex = 2 end       -- เนื้อหาอยู่กลาง
end
function UFO:AddButton(label, iconId, cb) return addButton(label, iconId, cb) end
function UFO:ToggleUI(on) if on==nil then on=not Window.Visible end; Window.Visible=on; getgenv().UFO_ISOPEN=on end
getgenv().UFO = UFO

--== FLOATING TOGGLE + HOTKEY (ลากได้) ==--
do
    getgenv().UFO_ISOPEN = true
    local TG=Instance.new("ScreenGui", CoreGui); TG.Name="UFOX_TOGGLE"; TG.IgnoreGuiInset=true; TG.DisplayOrder=100001
    local B=Instance.new("ImageButton",TG); B.Name="Toggle"; B.Size=UDim2.fromOffset(64,64); B.Position=UDim2.fromOffset(80,200)
    B.BackgroundColor3=Color3.new(0,0,0); B.BorderSizePixel=0; B.Image=CFG.TOGGLE_IMAGE; corner(B,8); stroke(B,2,UI.GREEN,0)
    local function show() GUI.Enabled=true; Window.Visible=true; getgenv().UFO_ISOPEN=true end
    local function hide() Window.Visible=false; getgenv().UFO_ISOPEN=false end
    local function toggle() if getgenv().UFO_ISOPEN then hide() else show() end end
    B.MouseButton1Click:Connect(toggle)
    UIS.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==CFG.HOTKEY then toggle() end end)

    local dragging,start,startPos
    local function block(on)
        local name="UFOX_BlockLook_Toggle"
        if on then CAS:BindActionAtPriority(name,function() return Enum.ContextActionResult.Sink end,false,9000,
            Enum.UserInputType.MouseMovement,Enum.UserInputType.Touch,Enum.UserInputType.MouseButton1)
        else pcall(function() CAS:UnbindAction(name) end) end
    end
    B.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Vector2.new(B.Position.X.Offset, B.Position.Y.Offset); block(true)
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; block(false) end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start; B.Position=UDim2.fromOffset(startPos.X+d.X, startPos.Y+d.Y)
        end
    end)
end
--[[ UFO HUB X • Left Button Active Highlight (drop-in)
     ทำให้ปุ่มฝั่งซ้ายที่ถูกเลือกอยู่ มีขอบเขียวหนา/สว่าง และยกเลิกปุ่มอื่นอัตโนมัติ
     ใช้กับ UI เวอร์ชันที่สร้าง ScreenGui ชื่อ "UFOX_UI" (ที่เราทำให้อยู่ก่อนหน้า)
]]

local GREEN = Color3.fromRGB(0,255,140)
local MINT  = Color3.fromRGB(120,255,220)
local BG    = Color3.fromRGB(16,16,16) -- พื้นปุ่มตอนปกติ
local BG_ON = Color3.fromRGB(22,30,24) -- พื้นปุ่มตอน Active

local CoreGui = game:GetService("CoreGui")
local GUI = CoreGui:WaitForChild("UFOX_UI", 5)
if not GUI then return warn("❌ ไม่พบ UFOX_UI — รันสคริปต์หลักก่อน") end

-- หา ScrollingFrame ของแผงซ้าย (Left)
local LeftScroll
for _, v in ipairs(GUI:GetDescendants()) do
	if v:IsA("ScrollingFrame") and v.Parent and v.Parent.Name=="Inset" and v.Parent.Parent and v.Parent.Parent.Name=="Left" then
		LeftScroll = v; break
	end
end
if not LeftScroll then return warn("⚠️ ไม่พบ LeftScroll") end

-- สร้าง/ดึง UIStroke ให้ปุ่ม
local function ensureStroke(btn)
	local st = btn:FindFirstChildOfClass("UIStroke")
	if not st then
		st = Instance.new("UIStroke"); st.Parent = btn
		st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		st.LineJoinMode = Enum.LineJoinMode.Round
	end
	return st
end

-- ใส่สไตล์ปุ่มตามสถานะ
local function style(btn, active)
	local st = ensureStroke(btn)
	if active then
		st.Color = GREEN; st.Thickness = 2;   st.Transparency = 0
		btn.BackgroundColor3 = BG_ON
		btn:SetAttribute("UFO_Active", true)
	else
		st.Color = MINT;  st.Thickness = 0.6; st.Transparency = 0.35
		btn.BackgroundColor3 = BG
		btn:SetAttribute("UFO_Active", false)
	end
end

-- setActive: ทำให้ปุ่มเดียว Active ที่เหลือเป็นปกติ
local function setActive(target)
	for _, c in ipairs(LeftScroll:GetChildren()) do
		if c:IsA("TextButton") then
			style(c, c==target)
		end
	end
end

-- ผูกอีเวนต์ให้ทุกปุ่มปัจจุบัน + ปุ่มที่ถูกสร้างใหม่ในอนาคต
local function hook(btn)
	if not btn or not btn:IsA("TextButton") then return end
	ensureStroke(btn)
	-- สไตล์ตั้งต้น (ไม่ Active)
	if btn:GetAttribute("UFO_Active")==nil then style(btn, false) end
	-- คลิกแล้วกำหนด Active เฉพาะปุ่มนั้น
	btn.MouseButton1Click:Connect(function() setActive(btn) end)
end

for _, c in ipairs(LeftScroll:GetChildren()) do hook(c) end
LeftScroll.ChildAdded:Connect(hook)

-- อยากให้ปุ่มแรก Active ตั้งแต่เริ่มใช้งาน ก็ปลดคอมเมนต์บรรทัดนี้:
-- for _, c in ipairs(LeftScroll:GetChildren()) do if c:IsA("TextButton") then setActive(c) break end end

print("✅ UFO HUB X: Button Active Highlight พร้อมใช้งาน")

--== DEMO ปุ่มซ้าย (ตัวอย่างใช้งาน) ==--
UFO:SetTitle("UFO","HUB X")

UFO:AddButton("Player","rbxassetid://112510739340023", function()
    UFO:ShowRightHeader("Player","rbxassetid://112510739340023")
end)

UFO:AddButton("Quest","rbxassetid://72473476254744", function()
    UFO:ShowRightHeader("Quest","rbxassetid://72473476254744")
end)

UFO:AddButton("Shop","rbxassetid://139824330037901", function()
    UFO:ShowRightHeader("Shop","rbxassetid://139824330037901")
end)
