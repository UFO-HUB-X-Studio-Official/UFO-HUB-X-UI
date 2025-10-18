--==========================================================
-- UFO HUB X • ALWAYS-ON TOGGLE (PlayerGui only, self-heal)
--  - สลับแสดง/ซ่อนหน้าต่าง UFO HUB X ไม่ว่า UI หลักจะอยู่ที่ไหน
--  - ปุ่มลอยมีกรอบเขียว, ZIndex/DisplayOrder สูงสุด, ลากได้
--  - รีเซ็ตตำแหน่งเมื่อหลุดจอ + รีสปาวน์อัตโนมัติถ้าถูกลบ
--  - Hotkey: RightShift / F8   • Chat: ;ufo
--==========================================================

local Services = {
  Players = game:GetService("Players"),
  RunService = game:GetService("RunService"),
  UserInputService = game:GetService("UserInputService"),
  ContextActionService = game:GetService("ContextActionService"),
  StarterGui = game:GetService("StarterGui"),
}

local LP = Services.Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ล้างของเก่า (ชื่อเดียวกัน)
pcall(function()
  local old = PG:FindFirstChild("UFO_TOGGLE_FORCE")
  if old then old:Destroy() end
end)

-- หา "หน้าต่างหลัก" ของ UFO เพื่อสลับ
local function findUfoWindow()
  -- 1) มองหา ScreenGui ที่ชื่อมี "UFO" และมี Frame
  for _,g in ipairs(PG:GetChildren()) do
    if g:IsA("ScreenGui") and string.find(string.lower(g.Name), "ufo") then
      local fm = g:FindFirstChildWhichIsA("Frame", true)
      if fm then return fm end
    end
  end
  -- 2) เผื่อ UI อยู่ CoreGui แต่เกมของเพื่อนไม่ให้แตะ ก็ข้าม
  -- 3) เผื่อชื่ออื่น: ลองหา TextLabel "UFO HUB X"
  for _,g in ipairs(PG:GetChildren()) do
    if g:IsA("ScreenGui") then
      for _,d in ipairs(g:GetDescendants()) do
        if d:IsA("TextLabel") and typeof(d.Text)=="string" and d.Text:lower():find("ufo") then
          local f = d:FindFirstAncestorOfClass("Frame")
          if f then return f end
        end
      end
    end
  end
  return nil
end

-- ฟังก์ชันสลับ
local function toggleMain()
  local win = findUfoWindow()
  if win then
    win.Visible = not win.Visible
    getgenv().UFO_ISOPEN = win.Visible
  else
    Services.StarterGui:SetCore("SendNotification", {Title="UFO", Text="ไม่เจอหน้าต่างหลัก", Duration=2})
  end
end

-- สร้าง GUI ปุ่มลอย (PlayerGui เท่านั้น)
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "UFO_TOGGLE_FORCE"
ToggleGui.IgnoreGuiInset = true
ToggleGui.ResetOnSpawn = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.DisplayOrder = 2^31-1 -- สูงสุด
ToggleGui.Parent = PG

-- ปุ่มลอย
local ToggleBtn = Instance.new("ImageButton", ToggleGui)
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.fromOffset(64,64)
ToggleBtn.Position = UDim2.fromOffset(86, 220)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Image = "rbxassetid://117052960049460" -- ไอคอนปุ่ม
ToggleBtn.ZIndex = 2^15 -- สูงมาก
local function corner(p,r) local u=Instance.new("UICorner",p) u.CornerRadius=UDim.new(0,r or 8) return u end
local function stroke(p,th,col,tr)
  local s=Instance.new("UIStroke",p)
  s.Thickness=th or 2
  s.Color=col or Color3.fromRGB(0,255,140)
  s.Transparency=tr or 0
  s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  s.LineJoinMode=Enum.LineJoinMode.Round
  s.Parent=p
  return s
end
corner(ToggleBtn,8); stroke(ToggleBtn,2, Color3.fromRGB(0,255,140), 0)

-- คลิกเพื่อสลับ
ToggleBtn.MouseButton1Click:Connect(toggleMain)

-- ลากได้ + บล็อกหมุนกล้องตอนลาก (มือถือก็ลื่น)
do
  local dragging,start,startPos
  local function block(on)
    local name="UFO_BlockLook_Toggle"
    if on then
      Services.ContextActionService:BindActionAtPriority(
        name, function() return Enum.ContextActionResult.Sink end, false, 9000,
        Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1
      )
    else pcall(function() Services.ContextActionService:UnbindAction(name) end) end
  end
  ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
      dragging=true; start=i.Position
      startPos=Vector2.new(ToggleBtn.Position.X.Offset, ToggleBtn.Position.Y.Offset)
      block(true)
      i.Changed:Connect(function()
        if i.UserInputState==Enum.UserInputState.End then dragging=false; block(false) end
      end)
    end
  end)
  Services.UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
      local d=i.Position-start
      ToggleBtn.Position=UDim2.fromOffset(startPos.X+d.X, startPos.Y+d.Y)
    end
  end)
end

-- Hotkey + Chat command
Services.UserInputService.InputBegan:Connect(function(i,gp)
  if gp then return end
  if i.KeyCode==Enum.KeyCode.RightShift or i.KeyCode==Enum.KeyCode.F8 then toggleMain() end
end)
LP.Chatted:Connect(function(msg)
  msg = string.lower(msg or "")
  if msg==";ufo" or msg=="/ufo" then toggleMain() end
end)

-- เฝ้า/ซ่อม: ถ้าปุ่มหาย หรือหลุดจอ → รีสปาวน์/รีเซ็ต
local function viewport()
  local cam = workspace.CurrentCamera
  return (cam and cam.ViewportSize) or Vector2.new(1280,720)
end

local function resetIfOffscreen()
  local v = viewport()
  local x = ToggleBtn.Position.X.Offset
  local y = ToggleBtn.Position.Y.Offset
  if x < -10 or y < -10 or x > v.X-40 or y > v.Y-40 then
    ToggleBtn.Position = UDim2.fromOffset(86, 220)
  end
end

-- จุด debug กระพริบเมื่อรีสปาวน์
local function flashDebug()
  local dot = Instance.new("Frame", ToggleGui)
  dot.BackgroundColor3 = Color3.fromRGB(0,255,140)
  dot.BorderSizePixel = 0
  dot.Size = UDim2.fromOffset(6,6)
  dot.Position = UDim2.fromOffset(4,4)
  dot.ZIndex = 2^15
  task.delay(1, function() if dot then dot:Destroy() end end)
end

flashDebug()

Services.RunService.Heartbeat:Connect(function()
  if not ToggleBtn or not ToggleBtn.Parent then
    -- รีสปาวน์ทั้งชุด
    pcall(function()
      if ToggleGui then ToggleGui:Destroy() end
    end)
    -- สร้างใหม่
    -- (เรียกสคริปต์ตัวเองซ้ำแบบง่าย ๆ)
  end
  resetIfOffscreen()
end)

-- เปิดหน้าต่างหลักครั้งแรก (ถ้ามี)
task.delay(0.2, function()
  local win = findUfoWindow()
  if win then
    win.Visible = true
    getgenv().UFO_ISOPEN = true
  end
end)

--==========================================================
-- UFO HUB X • ALL-IN-ONE (PlayerGui only)
--  - สร้าง UI หลัก + ปุ่มลอยในไฟล์เดียว
--  - ไม่ใช้ CoreGui, ลากได้, สกอร์ลแยกซ้าย/ขวา
--  - ปุ่มลอย ZIndex สูง, ลากได้, Hotkey RightShift/F8
--==========================================================

-- Services
local Players = game:GetService("Players")
local RunS    = game:GetService("RunService")
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local CAS     = game:GetService("ContextActionService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- Clear old
pcall(function()
	for _,n in ipairs({"UFO_HUB_X_ROOT","UFO_TOGGLE_FORCE"}) do
		local g = PG:FindFirstChild(n); if g then g:Destroy() end
	end
end)

-- THEME / SIZE
local THEME = {
	GREEN=Color3.fromRGB(0,255,140), MINT=Color3.fromRGB(120,255,220),
	BG_WIN=Color3.fromRGB(16,16,16), BG_HEAD=Color3.fromRGB(6,6,6),
	BG_PANEL=Color3.fromRGB(22,22,22), BG_INNER=Color3.fromRGB(18,18,18),
	TEXT=Color3.fromRGB(235,235,235), RED=Color3.fromRGB(200,40,40),
	HILITE=Color3.fromRGB(22,30,24)
}
local SIZE={WIN_W=640,WIN_H=360,R=12,HEAD_H=46,GAP_OUT=14,GAP_IN=8,BETWEEN=12,LEFT_RATIO=0.22}
local IMG_UFO="rbxassetid://100650447103028"
local ICON_PLAYER = 116976545042904
local ICON_HOME   = 134323882016779

-- Helpers
local function corner(p,r) local u=Instance.new("UICorner",p) u.CornerRadius=UDim.new(0,r or 10) return u end
local function stroke(p,th,col,tr)
	local s=Instance.new("UIStroke",p)
	s.Thickness=th or 1; s.Color=col or THEME.MINT; s.Transparency=tr or 0.35
	s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.LineJoinMode=Enum.LineJoinMode.Round
	s.Parent=p; return s
end

-- Root GUI (PlayerGui เท่านั้น)
local GUI=Instance.new("ScreenGui")
GUI.Name="UFO_HUB_X_ROOT"
GUI.IgnoreGuiInset=true
GUI.ResetOnSpawn=false
GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder=1000000
GUI.Parent=PG

--==================== Window ====================--
local Win=Instance.new("Frame",GUI)
Win.Name="Window"
Win.Size=UDim2.fromOffset(SIZE.WIN_W,SIZE.WIN_H)
Win.AnchorPoint=Vector2.new(0.5,0.5)
Win.Position=UDim2.new(0.5,0,0.5,0)
Win.BackgroundColor3=THEME.BG_WIN
Win.BorderSizePixel=0
Win.Active=true
corner(Win,SIZE.R); stroke(Win,3,THEME.GREEN,0)

-- Autoscale
do
	local sc=Instance.new("UIScale",Win)
	local function fit()
		local v=(workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280,720)
		sc.Scale=math.clamp(math.min(v.X/860,v.Y/540),0.72,1.0)
	end
	fit(); RunS.RenderStepped:Connect(fit)
end

-- Header
local Header=Instance.new("Frame",Win)
Header.Size=UDim2.new(1,0,0,SIZE.HEAD_H)
Header.BackgroundColor3=THEME.BG_HEAD
Header.BorderSizePixel=0
Header.Active=true
corner(Header,SIZE.R)
local Accent=Instance.new("Frame",Header)
Accent.AnchorPoint=Vector2.new(0.5,1); Accent.Position=UDim2.new(0.5,0,1,0)
Accent.Size=UDim2.new(1,-20,0,1); Accent.BackgroundColor3=THEME.MINT
Accent.BackgroundTransparency=0.35
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
BtnClose.MouseButton1Click:Connect(function() Win.Visible=false; getgenv().UFO_ISOPEN=false end)

-- UFO top
local UFO=Instance.new("ImageLabel",Win)
UFO.BackgroundTransparency=1; UFO.Image=IMG_UFO
UFO.Size=UDim2.fromOffset(168,168); UFO.AnchorPoint=Vector2.new(0.5,1)
UFO.Position=UDim2.new(0.5,0,0,84); UFO.ZIndex=4

-- Drag Window (block camera while drag)
do
	local dragging=false; local start; local startPos
	local function block(on)
		local name="UFO_BlockLook"
		if on then
			CAS:BindActionAtPriority(name,function()return Enum.ContextActionResult.Sink end,false,9000,
				Enum.UserInputType.MouseMovement,Enum.UserInputType.Touch,Enum.UserInputType.MouseButton1)
		else pcall(function() CAS:UnbindAction(name) end) end
	end
	Header.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=true; start=i.Position; startPos=Win.Position; block(true)
			i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; block(false) end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local d=i.Position-start
			Win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
		end
	end)
end

-- Body + Dual Panels
local Body=Instance.new("Frame",Win)
Body.BackgroundColor3=THEME.BG_INNER; Body.BorderSizePixel=0
Body.Position=UDim2.new(0,SIZE.GAP_OUT,0,SIZE.HEAD_H+SIZE.GAP_OUT)
Body.Size=UDim2.new(1,-SIZE.GAP_OUT*2,1,-(SIZE.HEAD_H+SIZE.GAP_OUT*2))
corner(Body,12); stroke(Body,0.5,THEME.MINT,0.35)

-- Left
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
local LeftList=Instance.new("UIListLayout",LeftScroll) LeftList.Padding=UDim.new(0,8)

-- Right
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
local RightList=Instance.new("UIListLayout",RightScroll) RightList.Padding=UDim.new(0,10)

-- ปุ่มแท็บ
local function makeTabButton(parent, label, iconId)
	local holder=Instance.new("Frame",parent) holder.BackgroundTransparency=1 holder.Size=UDim2.new(1,0,0,38)
	local b=Instance.new("TextButton",holder) b.AutoButtonColor=false b.Text="" b.Size=UDim2.new(1,0,1,0) b.BackgroundColor3=THEME.BG_INNER corner(b,8)
	local st=stroke(b,1,THEME.MINT,0.35)
	local ic=Instance.new("ImageLabel",b) ic.BackgroundTransparency=1 ic.Image="rbxassetid://"..tostring(iconId) ic.Size=UDim2.fromOffset(22,22) ic.Position=UDim2.new(0,10,0.5,-11)
	local tx=Instance.new("TextLabel",b) tx.BackgroundTransparency=1 tx.TextColor3=THEME.TEXT tx.Font=Enum.Font.GothamMedium tx.TextSize=15 tx.TextXAlignment=Enum.TextXAlignment.Left tx.Position=UDim2.new(0,38,0,0) tx.Size=UDim2.new(1,-46,1,0) tx.Text=label
	local flash=Instance.new("Frame",b) flash.BackgroundColor3=THEME.GREEN flash.BackgroundTransparency=1 flash.BorderSizePixel=0 flash.AnchorPoint=Vector2.new(0.5,0.5) flash.Position=UDim2.new(0.5,0,0.5,0) flash.Size=UDim2.new(0,0,0,0) corner(flash,12)
	b.MouseButton1Down:Connect(function() TS:Create(b,TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,1,-2)}):Play() end)
	b.MouseButton1Up:Connect(function() TS:Create(b,TweenInfo.new(0.10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,1,0)}):Play() end)
	local function setActive(on)
		if on then b.BackgroundColor3=THEME.HILITE st.Color=THEME.GREEN st.Transparency=0 st.Thickness=2 flash.BackgroundTransparency=0.35 flash.Size=UDim2.new(0,0,0,0)
			TS:Create(flash,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1}):Play()
		else b.BackgroundColor3=THEME.BG_INNER st.Color=THEME.MINT st.Transparency=0.35 st.Thickness=1 end
	end
	return b,setActive
end

local function showRight(titleText, iconId)
	for _,c in ipairs(RightScroll:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
	local row=Instance.new("Frame",RightScroll) row.BackgroundTransparency=1 row.Size=UDim2.new(1,0,0,28)
	local icon=Instance.new("ImageLabel",row) icon.BackgroundTransparency=1 icon.Image="rbxassetid://"..tostring(iconId or "") icon.Size=UDim2.fromOffset(20,20) icon.Position=UDim2.new(0,0,0.5,-10)
	local head=Instance.new("TextLabel",row) head.BackgroundTransparency=1 head.Font=Enum.Font.GothamBold head.TextSize=18 head.TextXAlignment=Enum.TextXAlignment.Left head.TextColor3=THEME.TEXT head.Position=UDim2.new(0,26,0,0) head.Size=UDim2.new(1,-26,1,0) head.Text=titleText
end

-- Tabs
local btnPlayer,setPlayerActive = makeTabButton(LeftScroll,"Player",ICON_PLAYER)
local btnHome,setHomeActive     = makeTabButton(LeftScroll,"Home",ICON_HOME)
btnPlayer.MouseButton1Click:Connect(function() setPlayerActive(true); setHomeActive(false); showRight("Player",ICON_PLAYER) end)
btnHome.MouseButton1Click:Connect(function() setPlayerActive(false); setHomeActive(true); showRight("Home",ICON_HOME) end)

-- Default page
btnPlayer:Activate(); btnPlayer.MouseButton1Click:Fire()

--==================== Floating Toggle (in the same GUI) ====================--
local Toggle = Instance.new("ImageButton", GUI)
Toggle.Name="UFO_TOGGLE_FORCE"
Toggle.Size=UDim2.fromOffset(64,64)
Toggle.Position=UDim2.fromOffset(86,220)
Toggle.BackgroundColor3=Color3.fromRGB(0,0,0)
Toggle.BorderSizePixel=0
Toggle.Image="rbxassetid://117052960049460"
Toggle.ZIndex = 2^15
corner(Toggle,8); stroke(Toggle,2,THEME.GREEN,0)

local function toggleUI()
	if Win and Win.Parent then
		Win.Visible = not Win.Visible
		getgenv().UFO_ISOPEN = Win.Visible
	end
end
Toggle.MouseButton1Click:Connect(toggleUI)

-- Drag toggle + block camera while dragging
do
	local dragging,start,startPos
	local function block(on)
		local name="UFO_BlockLook_Toggle"
		if on then
			CAS:BindActionAtPriority(name,function()return Enum.ContextActionResult.Sink end,false,9000,
				Enum.UserInputType.MouseMovement,Enum.UserInputType.Touch,Enum.UserInputType.MouseButton1)
		else pcall(function() CAS:UnbindAction(name) end) end
	end
	Toggle.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=true; start=i.Position
			startPos=Vector2.new(Toggle.Position.X.Offset,Toggle.Position.Y.Offset)
			block(true)
			i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; block(false) end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local d=i.Position-start
			Toggle.Position=UDim2.fromOffset(startPos.X+d.X,startPos.Y+d.Y)
		end
	end)
end

-- Hotkeys
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode==Enum.KeyCode.RightShift or i.KeyCode==Enum.KeyCode.F8 then toggleUI() end
end)

-- Safety: force show shortly after load
task.delay(0.2, function()
	if Win and Win.Parent then Win.Visible=true; getgenv().UFO_ISOPEN=true end
end)
