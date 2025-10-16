--[[ UFO HUB X • Ultra (Fixed / Full-width Buttons / Thin Borders) ]]

-------------------- CONFIG --------------------
local CFG = {
  MOUNT = "CoreGui",
  WIN_W = 640, WIN_H = 360,
  SCALE_MIN = 0.72, SCALE_MAX = 1.0,
  TAP_THRESHOLD = 6,
  HOTKEY = Enum.KeyCode.RightShift,
  TOGGLE_IMAGE = "rbxassetid://117052960049460",
  UFO_IMG = "rbxassetid://100650447103028",
  GLOW_IMG = "rbxassetid://5028857084",
  ICON_DEFAULT = "rbxassetid://112510739340023",
}

local THEME = {
  GREEN = {ACCENT=Color3.fromRGB(0,255,140), MINT=Color3.fromRGB(120,255,220)},
  RED   = {ACCENT=Color3.fromRGB(255,70,70),  MINT=Color3.fromRGB(255,140,140)},
  GOLD  = {ACCENT=Color3.fromRGB(255,210,70), MINT=Color3.fromRGB(255,230,130)},
  WHITE = {ACCENT=Color3.fromRGB(230,230,230),MINT=Color3.fromRGB(200,200,200)},
}
local UI = {
  BG_WINDOW=Color3.fromRGB(16,16,16),
  BG_HEADER=Color3.fromRGB(6,6,6),
  BG_PANEL =Color3.fromRGB(22,22,22),
  BG_INNER =Color3.fromRGB(18,18,18),
  TEXT     =Color3.fromRGB(235,235,235),
  RED      =Color3.fromRGB(200,40,40),
}
local ACCENT = THEME.GREEN

-------------------- SERVICES --------------------
local S = setmetatable({}, {__index=function(_,k) return game:GetService(k) end})
local Players, UIS, CAS, RunS = S.Players, S.UserInputService, S.ContextActionService, S.RunService
local LP = Players.LocalPlayer

-------------------- MOUNT TARGET --------------------
local function getMount()
  if CFG.MOUNT == "PlayerGui" then
    local pg = LP and LP:FindFirstChildOfClass("PlayerGui") or (LP and LP:WaitForChild("PlayerGui"))
    return pg or S.CoreGui
  else
    return S.CoreGui
  end
end
local MOUNT = getMount()

-------------------- PURGE --------------------
pcall(function()
  for _, n in ipairs({"UFOX_UI_ULTRA","UFOX_TOGGLE_ULTRA"}) do
    local g = MOUNT:FindFirstChild(n)
    if g then g:Destroy() end
  end
end)

-------------------- HELPERS --------------------
local function corner(g,r) local c=Instance.new("UICorner",g); c.CornerRadius=UDim.new(0,r or 10); return c end
local function stroke(g,t,c,tr)
  local s=Instance.new("UIStroke",g)
  s.Thickness=t or 1; s.Color=c; s.Transparency=tr or 0.35
  s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.LineJoinMode=Enum.LineJoinMode.Round
  return s
end
local function gradient(g,c1,c2,rot)
  local gr=Instance.new("UIGradient",g); gr.Color=ColorSequence.new(c1,c2); gr.Rotation=rot or 0; return gr
end

-------------------- ROOT --------------------
local GUI = Instance.new("ScreenGui")
GUI.Name="UFOX_UI_ULTRA"; GUI.IgnoreGuiInset=true
GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; GUI.ResetOnSpawn=false; GUI.DisplayOrder=100000
GUI.Parent = MOUNT

local Window = Instance.new("Frame", GUI)
Window.Name="Window"; Window.AnchorPoint=Vector2.new(0.5,0.5); Window.Position=UDim2.new(0.5,0,0.5,0)
Window.Size=UDim2.fromOffset(CFG.WIN_W, CFG.WIN_H); Window.BackgroundColor3=UI.BG_WINDOW; Window.BorderSizePixel=0
corner(Window,12); local Border = stroke(Window,3,ACCENT.ACCENT,0)

-- Glow
do local Glow=Instance.new("ImageLabel",Window)
  Glow.BackgroundTransparency=1; Glow.AnchorPoint=Vector2.new(0.5,0.5)
  Glow.Position=UDim2.new(0.5,0,0.5,0); Glow.Size=UDim2.new(1.07,0,1.09,0)
  Glow.Image=CFG.GLOW_IMG; Glow.ImageColor3=ACCENT.ACCENT; Glow.ImageTransparency=0.78
  Glow.ScaleType=Enum.ScaleType.Slice; Glow.SliceCenter=Rect.new(24,24,276,276); Glow.ZIndex=0
end

-- Autoscale
local UIScale=Instance.new("UIScale",Window)
local function fit()
  local cam=workspace.CurrentCamera
  local v=(cam and cam.ViewportSize) or Vector2.new(1280,720)
  UIScale.Scale=math.clamp(math.min(v.X/860, v.Y/540), CFG.SCALE_MIN, CFG.SCALE_MAX)
end
fit(); RunS.RenderStepped:Connect(fit)

-------------------- HEADER --------------------
local Header=Instance.new("Frame",Window)
Header.Name="Header"; Header.Size=UDim2.new(1,0,0,46); Header.BackgroundColor3=UI.BG_HEADER; Header.BorderSizePixel=0
corner(Header,12); gradient(Header, Color3.fromRGB(10,10,10), Color3.fromRGB(0,0,0), 0)

local HeadAccent=Instance.new("Frame",Header)
HeadAccent.AnchorPoint=Vector2.new(0.5,1); HeadAccent.Position=UDim2.new(0.5,0,1,0)
HeadAccent.Size=UDim2.new(1,-20,0,1); HeadAccent.BackgroundColor3=ACCENT.MINT; HeadAccent.BackgroundTransparency=0.35

local Title=Instance.new("TextLabel",Header)
Title.BackgroundTransparency=1; Title.AnchorPoint=Vector2.new(0.5,0)
Title.Position=UDim2.new(0.5,0,0,8); Title.Size=UDim2.new(0.8,0,0,36)
Title.Font=Enum.Font.GothamBold; Title.RichText=true; Title.TextScaled=true
Title.TextColor3=UI.TEXT; Title.ZIndex=61
Title.Text = string.format('<font color="#FFFFFF">%s</font> <font color="#00FF8C">%s</font>', "UFO", "HUB X") -- ✅ FIX

local BtnClose=Instance.new("TextButton",Header)
BtnClose.Name="Close"; BtnClose.Size=UDim2.new(0,24,0,24); BtnClose.Position=UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3=UI.RED; BtnClose.Text="X"; BtnClose.Font=Enum.Font.GothamBold; BtnClose.TextSize=13
BtnClose.TextColor3=Color3.new(1,1,1); BtnClose.BorderSizePixel=0; corner(BtnClose,6); stroke(BtnClose,1,Color3.fromRGB(255,0,0),0.1)
BtnClose.MouseButton1Click:Connect(function() Window.Visible=false; getgenv().UFO_ISOPEN=false end)

-- Drag + block camera
do
  local dragging,start,startPos
  local function block(on)
    local name="UFOX_BlockLook_Window"
    if on then
      CAS:BindActionAtPriority(name, function() return Enum.ContextActionResult.Sink end, false, 9000,
        Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1)
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
      Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
  end)
end

-- UFO deco
do
  local UFO=Instance.new("ImageLabel",Window)
  UFO.Name="UFO_Top"; UFO.BackgroundTransparency=1; UFO.Image=CFG.UFO_IMG
  UFO.Size=UDim2.new(0,168,0,168); UFO.AnchorPoint=Vector2.new(0.5,1); UFO.Position=UDim2.new(0.5,0,0,84); UFO.ZIndex=60
  local Halo=Instance.new("ImageLabel",Window)
  Halo.BackgroundTransparency=1; Halo.AnchorPoint=Vector2.new(0.5,0)
  Halo.Position=UDim2.new(0.5,0,0,0); Halo.Size=UDim2.new(0,200,0,60)
  Halo.Image=CFG.GLOW_IMG; Halo.ImageColor3=ACCENT.MINT; Halo.ImageTransparency=0.72; Halo.ZIndex=50
end

-------------------- BODY / PANELS --------------------
local Body=Instance.new("Frame",Window)
Body.BackgroundTransparency=1; Body.Position=UDim2.new(0,0,0,46); Body.Size=UDim2.new(1,0,1,-46)

local Inner=Instance.new("Frame",Body)
Inner.BackgroundColor3=UI.BG_INNER; Inner.BorderSizePixel=0
Inner.Position=UDim2.new(0,8,0,8); Inner.Size=UDim2.new(1,-16,1,-16); corner(Inner,12)

local Content=Instance.new("Frame",Body)
Content.BackgroundColor3=UI.BG_PANEL; Content.Position=UDim2.new(0,14,0,14); Content.Size=UDim2.new(1,-28,1,-28)
corner(Content,12); stroke(Content,0.35,ACCENT.MINT,0.35)

local Columns=Instance.new("Frame",Content)
Columns.BackgroundTransparency=1; Columns.Position=UDim2.new(0,8,0,8); Columns.Size=UDim2.new(1,-16,1,-16)

local Left=Instance.new("Frame",Columns)
Left.Name="Left"; Left.BackgroundColor3=Color3.fromRGB(16,16,16)
Left.Size=UDim2.new(0.22,-6,1,0); Left.ClipsDescendants=true; corner(Left,10)
stroke(Left,0.9,ACCENT.ACCENT,0); stroke(Left,0.35,ACCENT.MINT,0.35)

local Right=Instance.new("Frame",Columns)
Right.Name="Right"; Right.BackgroundColor3=Color3.fromRGB(16,16,16)
Right.Position=UDim2.new(0.22,12,0,0); Right.Size=UDim2.new(0.78,-6,1,0)
Right.ClipsDescendants=true; corner(Right,10)
stroke(Right,0.9,ACCENT.ACCENT,0); stroke(Right,0.35,ACCENT.MINT,0.35)

-- Scrolls (full width; hidden bars)
local function attachScroll(host)
  local inset=Instance.new("Frame",host)
  inset.Name="Inset"; inset.BackgroundTransparency=1; inset.BorderSizePixel=0; inset.ClipsDescendants=true
  inset.Position=UDim2.fromOffset(0,2); inset.Size=UDim2.new(1,0,1,-4); inset.ZIndex=1

  local sf=Instance.new("ScrollingFrame",inset)
  sf.Name="Scroll"; sf.Size=UDim2.fromScale(1,1); sf.BackgroundTransparency=1; sf.BorderSizePixel=0
  sf.ScrollingDirection=Enum.ScrollingDirection.Y; sf.AutomaticCanvasSize=Enum.AutomaticSize.Y; sf.CanvasSize=UDim2.new()
  sf.ScrollBarThickness=0; sf.ScrollBarImageTransparency=1; sf.VerticalScrollBarInset=Enum.ScrollBarInset.None

  local pad=Instance.new("UIPadding",sf)
  pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8)
  pad.PaddingLeft=UDim.new(0,0); pad.PaddingRight=UDim.new(0,0)

  local list=Instance.new("UIListLayout",sf)
  list.Padding=UDim.new(0,8); list.SortOrder=Enum.SortOrder.LayoutOrder
  return sf
end
local LeftScroll, RightScroll = attachScroll(Left), attachScroll(Right)

-- Right header (icon + text)
local RightTopIcon = Instance.new("ImageLabel", Right)
RightTopIcon.BackgroundTransparency=1; RightTopIcon.Visible=false; RightTopIcon.ZIndex=3
RightTopIcon.Size=UDim2.fromOffset(28,28); RightTopIcon.Position=UDim2.new(0,16,0,12)

local RightTopText = Instance.new("TextLabel", Right)
RightTopText.BackgroundTransparency=1; RightTopText.Visible=false; RightTopText.ZIndex=3
RightTopText.Position=UDim2.new(0,16+28+8,0,12); RightTopText.Size=UDim2.new(1,-(16+28+16),0,28)
RightTopText.Font=Enum.Font.GothamBold; RightTopText.TextSize=18; RightTopText.TextXAlignment=Enum.TextXAlignment.Left
RightTopText.TextColor3=UI.TEXT; RightTopText.Text=""

-------------------- Floating Toggle --------------------
do
  getgenv().UFO_ISOPEN = true
  local TG = Instance.new("ScreenGui")
  TG.Name="UFOX_TOGGLE_ULTRA"; TG.IgnoreGuiInset=true; TG.DisplayOrder=100001; TG.Parent=MOUNT

  local B = Instance.new("ImageButton", TG)
  B.Name="Toggle"; B.Size=UDim2.fromOffset(64,64); B.Position=UDim2.fromOffset(80,200)
  B.BackgroundColor3=Color3.fromRGB(0,0,0); B.BorderSizePixel=0; B.Image=CFG.TOGGLE_IMAGE
  corner(B,8); local TStroke = stroke(B,2,ACCENT.ACCENT,0)

  local function show() GUI.Enabled=true; Window.Visible=true; getgenv().UFO_ISOPEN=true end
  local function hide() Window.Visible=false; getgenv().UFO_ISOPEN=false end
  local function toggle() if getgenv().UFO_ISOPEN then hide() else show() end end
  B.MouseButton1Click:Connect(toggle)
  UIS.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==CFG.HOTKEY then toggle() end end)

  -- drag + block camera
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
      local d=i.Position-start; B.Position=UDim2.fromOffset(startPos.X+d.X,startPos.Y+d.Y)
    end
  end)
end

-------------------- Library API --------------------
local UFO = {}

function UFO:SetAccent(name)
  local t = THEME[name] or THEME.GREEN
  ACCENT = t
  Border.Color = t.ACCENT
  HeadAccent.BackgroundColor3 = t.MINT
  local TG = MOUNT:FindFirstChild("UFOX_TOGGLE_ULTRA")
  if TG and TG:FindFirstChild("Toggle") then
    local st = TG.Toggle:FindFirstChildOfClass("UIStroke") or stroke(TG.Toggle,2,t.ACCENT,0)
    st.Color = t.ACCENT
  end
end

function UFO:SetTitle(txtLeft, txtRight)
  Title.Text = string.format('<font color="#FFFFFF">%s</font> <font color="#00FF8C">%s</font>', txtLeft or "UFO", txtRight or "HUB X")
end

function UFO:ToggleUI(on)
  if on==nil then on = not Window.Visible end
  Window.Visible = on; getgenv().UFO_ISOPEN = on
end

function UFO:ShowRightHeader(text, iconId)
  RightTopIcon.Image = iconId or CFG.ICON_DEFAULT
  RightTopText.Text = text or ""
  RightTopIcon.Visible, RightTopText.Visible = true, true
end

-- ================= buildButton (ขนาดเหมือนในรูปที่ 2) =================
local function buildButton(parent, label, iconId, callback)
    local BTN_H = 52               -- ความสูงเพิ่มขึ้น (ดูแน่นขึ้น)
    local BTN_MARGIN_X = 12        -- ระยะซ้ายขวาให้ไม่ชิดเกินไป

    local b = Instance.new("TextButton", parent)
    b.Name = "Btn_" .. label:gsub("%s+", "")
    b.AutoButtonColor = false
    b.BackgroundColor3 = UI.BG_WINDOW
    b.Position = UDim2.new(0, BTN_MARGIN_X, 0, 0)
    b.Size = UDim2.new(1, -BTN_MARGIN_X * 2, 0, BTN_H)
    b.Text = ""
    corner(b, 8)

    -- 🔹 ขอบเขียวบางและเนียนกว่า
    local st = stroke(b, 0.8, ACCENT.ACCENT, 0.35)

    -- 🔸 ไอคอน
    local ic = Instance.new("ImageLabel", b)
    ic.BackgroundTransparency = 1
    ic.Image = iconId or CFG.ICON_DEFAULT
    ic.Size = UDim2.fromOffset(BTN_H - 12, BTN_H - 12)
    ic.Position = UDim2.new(0, 10, 0.5, -(BTN_H - 12) / 2)
    ic.ZIndex = 2

    -- 🔸 ข้อความ
    local tx = Instance.new("TextLabel", b)
    tx.BackgroundTransparency = 1
    tx.Position = UDim2.new(0, BTN_H + 8, 0, 0)
    tx.Size = UDim2.new(1, -(BTN_H + 18), 1, 0)
    tx.Font = Enum.Font.GothamMedium
    tx.TextSize = 16
    tx.TextXAlignment = Enum.TextXAlignment.Left
    tx.TextColor3 = UI.TEXT
    tx.Text = tostring(label)
    tx.ZIndex = 2

    -- 🔘 เอฟเฟกต์คลิก
    local isDown, downPos
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            isDown = true
            downPos = i.Position
            b.BackgroundColor3 = Color3.fromRGB(22, 30, 24)
            st.Thickness = 1.5
            st.Color = ACCENT.ACCENT
            st.Transparency = 0
        end
    end)

    b.InputEnded:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and isDown then
            isDown = false
            b.BackgroundColor3 = UI.BG_WINDOW
            st.Thickness = 0.8
            st.Color = ACCENT.ACCENT
            st.Transparency = 0.35
            if (i.Position - downPos).magnitude < (CFG.TAP_THRESHOLD or 8) then
                if typeof(callback) == "function" then
                    task.spawn(callback)
                end
            end
        end
    end)

    return b
end

function UFO:AddButton(label, iconId, callback)
  return buildButton(LeftScroll, label, iconId, function()
    if typeof(callback)=="function" then callback() end
  end)
end

function UFO:Destroy()
  pcall(function()
    for _, n in ipairs({"UFOX_UI_ULTRA","UFOX_TOGGLE_ULTRA"}) do
      local g = MOUNT:FindFirstChild(n); if g then g:Destroy() end
    end
  end)
end

-- expose
getgenv().UFO = UFO

-------------------- DEMO --------------------
UFO:SetAccent("GREEN")
UFO:SetTitle("UFO","HUB X")

UFO:AddButton("Player", "rbxassetid://112510739340023", function()
  UFO:ShowRightHeader("Player", "rbxassetid://112510739340023")
end)
