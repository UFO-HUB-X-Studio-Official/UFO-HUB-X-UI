--==========================================================
-- UFO HUB X • tuned layout (title higher, UFO lower)
-- (Full file with AFK Always-On integrated)
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
BtnClose.MouseButton1Click:Connect(function() GUI.Enabled = false end)

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
    local UFO_Y_OFFSET   = 84  -- ⬇️ ยานลงมาใกล้กรอบ
    local TITLE_Y_OFFSET = 8   -- ⬆️ ชื่อขึ้นไปอีกนิด

    -- UFO
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

    -- TITLE
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

-- toggle show/hide (RightShift)
do local vis=true
    UIS.InputBegan:Connect(function(i,gp)
        if not gp and i.KeyCode==Enum.KeyCode.RightShift then vis=not vis; GUI.Enabled=vis end
    end)
end
--==========================================================
-- UFO-Widgets API (self-contained, theme-aware)
-- Tabs / Sections / Button / Toggle / Slider / Dropdown / Keybind
--==========================================================
do
  if getgenv().UFO_WIDGETS then return end
  getgenv().UFO_WIDGETS = true

  local CoreGui = game:GetService("CoreGui")
  local UIS     = game:GetService("UserInputService")
  local TS      = game:GetService("TweenService")

  -- 1) หา/เดาหน้าต่างหลัก (Window) อัตโนมัติ
  local GUI = CoreGui:FindFirstChild("UFO_HUB_X_UI")
  local WindowRef = rawget(getfenv(), "Window")  -- ถ้าไฟล์เพื่อนมีตัวแปร Window อยู่แล้ว
  local Window = (typeof(WindowRef)=="Instance" and WindowRef) or nil
  if (not GUI) then
    for _,g in ipairs(CoreGui:GetChildren()) do
      if g:IsA("ScreenGui") and (g.Name:lower():find("ufo") or g.Name:lower():find("hub")) then GUI=g break end
    end
  end
  if (not Window) and GUI then
    local biggest, area = nil, 0
    for _,f in ipairs(GUI:GetDescendants()) do
      if f:IsA("Frame") and f.Visible then
        local s=f.AbsoluteSize; local a=s.X*s.Y
        if a>area then area,a=f,a end
      end
    end
    Window = biggest
  end
  if not Window then
    warn("[UFO-Widgets] ไม่เจอหน้าต่างหลัก จะสร้างแผงของตัวเองใน CoreGui")
    GUI = GUI or Instance.new("ScreenGui", CoreGui)
    GUI.Name = "UFO_HUB_X_UI"
    Window = Instance.new("Frame", GUI)
    Window.Size = UDim2.fromOffset(640,360)
    Window.Position = UDim2.fromScale(0.5,0.5)
    Window.AnchorPoint = Vector2.new(0.5,0.5)
    Window.BackgroundColor3 = Color3.fromRGB(16,16,16)
    Window.BorderSizePixel=0
    local c=Instance.new("UICorner",Window); c.CornerRadius=UDim.new(0,12)
  end

  -- 2) Theme (ดึงโทนจาก UI เดิมถ้ามี ไม่มีก็ใช้ค่าเริ่มต้น)
  local THEME = {
    fg         = Color3.fromRGB(235,235,235),
    accent     = Color3.fromRGB(0,255,140),
    accent2    = Color3.fromRGB(120,255,220),
    panel      = Color3.fromRGB(22,22,22),
    panel2     = Color3.fromRGB(16,16,16),
    borderSoft = Color3.fromRGB(120,255,220),
    danger     = Color3.fromRGB(200,40,40),
  }

  -- 3) สร้างพื้นที่ Widgets (ติดตั้งทับ “ฝั่งขวา” ถ้าเดาเจอ / ไม่งั้นจะวางพาเนลของเราเอง)
  local Host = Window:FindFirstChild("UFO_WidgetsHost")
  if not Host then
    Host = Instance.new("Frame", Window)
    Host.Name = "UFO_WidgetsHost"
    -- ลองจับฝั่งขวา: ถ้าใน Window มี Frame ขนาดใหญ่ฝั่งขวา ให้ยึดตำแหน่งนั้น
    local target = nil; local bestX = -math.huge
    for _,f in ipairs(Window:GetDescendants()) do
      if f:IsA("Frame") and f.Visible then
        if f.AbsolutePosition.X > bestX and f.AbsoluteSize.X > 150 and f.AbsoluteSize.Y > 120 then
          bestX = f.AbsolutePosition.X; target = f
        end
      end
    end
    if target and target.Parent == Window then
      Host.BackgroundTransparency = 1
      Host.Position = target.Position; Host.Size = target.Size
    else
      -- วางเป็นแผงในตัว Window (ปลอดภัยทุกกรณี)
      Host.BackgroundTransparency=1
      Host.AnchorPoint=Vector2.new(0,0); Host.Position=UDim2.fromOffset(18,60)
      Host.Size=UDim2.fromOffset(math.max(360, Window.AbsoluteSize.X-200), Window.AbsoluteSize.Y-78)
    end
  end

  -- 4) โครง TabBar + Content
  local Root = Instance.new("Frame", Host)
  Root.Name="UFO_Controls"; Root.BackgroundTransparency=1; Root.Size=UDim2.new(1,0,1,0)

  local TabBar = Instance.new("Frame", Root)
  TabBar.Name="TabBar"; TabBar.BackgroundColor3 = THEME.panel2; TabBar.Size=UDim2.new(1,0,0,36)
  TabBar.BorderSizePixel=0
  do local c=Instance.new("UICorner",TabBar); c.CornerRadius=UDim.new(0,10) end
  do local s=Instance.new("UIStroke",TabBar); s.Color=THEME.accent; s.Transparency=0.6; s.Thickness=1 end

  local TabsLayout = Instance.new("UIListLayout", TabBar)
  TabsLayout.FillDirection = Enum.FillDirection.Horizontal
  TabsLayout.Padding = UDim.new(0,8); TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
  TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

  local TabsPad = Instance.new("UIPadding", TabBar)
  TabsPad.PaddingLeft = UDim.new(0,10); TabsPad.PaddingRight = UDim.new(0,10)

  local Content = Instance.new("Frame", Root)
  Content.Name="Content"; Content.BackgroundColor3 = THEME.panel; Content.Size=UDim2.new(1,0,1,-44)
  Content.Position = UDim2.new(0,0,0,44); Content.BorderSizePixel=0
  do local c=Instance.new("UICorner",Content); c.CornerRadius=UDim.new(0,12) end
  do local s=Instance.new("UIStroke",Content); s.Color=THEME.borderSoft; s.Transparency=0.35; s.Thickness=1 end

  local function mkScroll(parent)
    local sf = Instance.new("ScrollingFrame", parent)
    sf.Name="Scroll"; sf.Active=true; sf.ScrollingDirection=Enum.ScrollingDirection.Y
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.BackgroundTransparency=1; sf.BorderSizePixel=0; sf.Size=UDim2.new(1,-16,1,-16); sf.Position=UDim2.fromOffset(8,8)
    local list = Instance.new("UIListLayout", sf)
    list.Padding = UDim.new(0,8); list.SortOrder=Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", sf); pad.PaddingTop=UDim.new(0,6); pad.PaddingBottom=UDim.new(0,8)
    return sf
  end

  -- 5) API ภายใน
  local UFO = {}
  UFO.Tabs = {}
  UFO.Theme = THEME

  function UFO:SetTheme(colors)
    for k,v in pairs(colors or {}) do if self.Theme[k] then self.Theme[k]=v end end
    -- (เบา ๆ: ไม่รีสกินเดิมทั้งหน้าในทันที เพื่อลดโค้ด)
  end

  local function styleButton(btn)
    btn.BackgroundColor3 = THEME.panel2; btn.BorderSizePixel=0; btn.TextColor3 = THEME.fg
    btn.Font = Enum.Font.Gotham; btn.TextSize=14
    local c=Instance.new("UICorner", btn); c.CornerRadius=UDim.new(0,10)
    local s=Instance.new("UIStroke", btn); s.Color=THEME.accent; s.Transparency=0.35; s.Thickness=1
    btn.AutoButtonColor=false
    btn.MouseEnter:Connect(function() TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.panel}):Play() end)
    btn.MouseLeave:Connect(function() TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.panel2}):Play() end)
  end

  local function mkSection(parent, title)
    local box = Instance.new("Frame", parent)
    box.BackgroundColor3 = THEME.panel2; box.BorderSizePixel=0; box.Size=UDim2.new(1,0,0,10)
    box.AutomaticSize = Enum.AutomaticSize.Y
    do local c=Instance.new("UICorner",box); c.CornerRadius=UDim.new(0,10) end
    do local s=Instance.new("UIStroke",box); s.Color=THEME.accent; s.Transparency=0.6; s.Thickness=1 end
    local vpad = Instance.new("UIPadding", box); vpad.PaddingTop=UDim.new(0,8); vpad.PaddingBottom=UDim.new(0,10); vpad.PaddingLeft=UDim.new(0,10); vpad.PaddingRight=UDim.new(0,10)

    local titleLabel = Instance.new("TextLabel", box)
    titleLabel.BackgroundTransparency=1; titleLabel.Text=title or "Section"
    titleLabel.Font=Enum.Font.GothamBold; titleLabel.TextSize=16; titleLabel.TextColor3=THEME.fg
    titleLabel.Size = UDim2.new(1, -8, 0, 20); titleLabel.TextXAlignment=Enum.TextXAlignment.Left

    local body = Instance.new("Frame", box)
    body.BackgroundTransparency=1; body.Size=UDim2.new(1,0,0,10); body.AutomaticSize=Enum.AutomaticSize.Y
    body.Position = UDim2.new(0,0,0,26)

    local list = Instance.new("UIListLayout", body)
    list.Padding = UDim.new(0,6); list.SortOrder=Enum.SortOrder.LayoutOrder

    return {
      Body = body,
      Title = titleLabel,
      Box = box
    }
  end

  -- 6) PUBLIC API
  function UFO.CreateLib(title)
    local lib = {}
    lib._title = title or "UFO HUB X"
    lib._tabs = {}

    function lib:NewTab(name)
      name = name or ("Tab "..tostring(#self._tabs+1))
      local btn = Instance.new("TextButton", TabBar)
      btn.Size = UDim2.new(0, math.max(90, (#name*7)+22), 1, -8)
      btn.Position = UDim2.new(0,0,0,4)
      btn.Text = name
      styleButton(btn)

      local page = Instance.new("Frame", Content)
      page.Name = "Page_"..name; page.BackgroundTransparency=1; page.Size=UDim2.new(1,0,1,0); page.Visible=false
      local scroll = mkScroll(page)

      local tabObj = { Button = btn, Page = page, Scroll = scroll, Sections = {} }
      table.insert(self._tabs, tabObj)

      btn.MouseButton1Click:Connect(function()
        for _,t in ipairs(self._tabs) do t.Page.Visible=false; TS:Create(t.Button, TweenInfo.new(0.15), {TextColor3=THEME.fg}):Play() end
        page.Visible=true
        TS:Create(btn, TweenInfo.new(0.15), {TextColor3=THEME.accent}):Play()
      end)

      -- ทำให้แท็บแรกเปิดอัตโนมัติ
      if #self._tabs==1 then btn:Activate(); btn.MouseButton1Click:Fire() end

      function tabObj:NewSection(title)
        local sec = mkSection(scroll, title)
        table.insert(self.Sections, sec)
        -- Widgets API:
        function sec:NewButton(text, desc, callback)
          local b = Instance.new("TextButton", sec.Body)
          b.Size = UDim2.new(1,0,0,36); b.Text = (text or "Button")
          styleButton(b)
          if desc and desc ~= "" then
            local d = Instance.new("TextLabel", b)
            d.BackgroundTransparency=1; d.Text = desc; d.Font=Enum.Font.Gotham; d.TextSize=12
            d.TextColor3 = Color3.fromRGB(200,200,200); d.TextXAlignment=Enum.TextXAlignment.Left
            d.Position = UDim2.new(0,10,0,20); d.Size = UDim2.new(1,-20,0,14)
          end
          b.MouseButton1Click:Connect(function() if typeof(callback)=="function" then callback() end end)
          return b
        end

        function sec:NewToggle(text, desc, callback, default)
          local holder = Instance.new("Frame", sec.Body)
          holder.BackgroundTransparency=1; holder.Size=UDim2.new(1,0,0,38)

          local b = Instance.new("TextButton", holder)
          b.Size = UDim2.new(1,-46,1,0); b.Position=UDim2.new(0,0,0,0)
          b.Text = text or "Toggle"; styleButton(b)

          if desc and desc ~="" then
            local d = Instance.new("TextLabel", b)
            d.BackgroundTransparency=1; d.Text = desc; d.Font=Enum.Font.Gotham; d.TextSize=12
            d.TextColor3 = Color3.fromRGB(200,200,200); d.TextXAlignment=Enum.TextXAlignment.Left
            d.Position = UDim2.new(0,10,0,20); d.Size = UDim2.new(1,-20,0,14)
          end

          local knob = Instance.new("Frame", holder)
          knob.Size=UDim2.fromOffset(36,36); knob.Position=UDim2.new(1,-36,0,1)
          knob.BackgroundColor3 = Color3.fromRGB(60,60,60); knob.BorderSizePixel=0
          local kc=Instance.new("UICorner",knob); kc.CornerRadius=UDim.new(0,10)
          local ks=Instance.new("UIStroke",knob); ks.Color=THEME.accent; ks.Transparency=0.25

          local dot = Instance.new("Frame", knob)
          dot.Size=UDim2.fromOffset(18,18); dot.Position=UDim2.fromOffset(9,9)
          dot.BackgroundColor3 = Color3.fromRGB(120,120,120); dot.BorderSizePixel=0
          local dc=Instance.new("UICorner",dot); dc.CornerRadius=UDim.new(0,9)

          local state = default and true or false
          local function render()
            TS:Create(knob, TweenInfo.new(0.15), {BackgroundColor3 = state and THEME.accent or Color3.fromRGB(60,60,60)}):Play()
            TS:Create(dot, TweenInfo.new(0.15), {BackgroundColor3 = state and Color3.fromRGB(20,20,20) or Color3.fromRGB(120,120,120)}):Play()
          end
          render()

          local function flip()
            state = not state; render()
            if typeof(callback)=="function" then callback(state) end
          end

          b.MouseButton1Click:Connect(flip)
          knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then flip() end end)

          return {
            Set = function(_, v) state = not not v; render() end,
            Get = function() return state end,
          }
        end

        function sec:NewSlider(text, desc, max, min, callback, default)
          max = max or 100; min = min or 0
          local holder = Instance.new("Frame", sec.Body)
          holder.BackgroundColor3 = THEME.panel2; holder.BorderSizePixel=0
          holder.Size=UDim2.new(1,0,0,56)
          local c=Instance.new("UICorner",holder); c.CornerRadius=UDim.new(0,10)
          local s=Instance.new("UIStroke",holder); s.Color=THEME.accent; s.Transparency=0.35

          local title = Instance.new("TextLabel", holder)
          title.BackgroundTransparency=1; title.Text = text or "Slider"
          title.Font=Enum.Font.GothamBold; title.TextSize=14; title.TextColor3=THEME.fg
          title.Position=UDim2.fromOffset(10,6); title.Size=UDim2.new(1,-20,0,16); title.TextXAlignment=Enum.TextXAlignment.Left

          if desc and desc ~="" then
            local d = Instance.new("TextLabel", holder)
            d.BackgroundTransparency=1; d.Text = desc; d.Font=Enum.Font.Gotham; d.TextSize=12
            d.TextColor3 = Color3.fromRGB(200,200,200); d.TextXAlignment=Enum.TextXAlignment.Left
            d.Position = UDim2.new(0,10,0,24); d.Size = UDim2.new(1,-20,0,14)
          end

          local bar = Instance.new("Frame", holder)
          bar.BackgroundColor3 = Color3.fromRGB(60,60,60); bar.BorderSizePixel=0
          bar.Position = UDim2.new(0,10,1,-12); bar.Size=UDim2.new(1,-20,0,6)
          local bc=Instance.new("UICorner",bar); bc.CornerRadius=UDim.new(0,3)

          local fill = Instance.new("Frame", bar)
          fill.BackgroundColor3 = THEME.accent; fill.BorderSizePixel=0
          fill.Size = UDim2.new(0,0,1,0)
          local fc=Instance.new("UICorner",fill); fc.CornerRadius=UDim.new(0,3)

          local val = default or min
          local function render()
            local pct = (val-min)/(max-min)
            fill.Size = UDim2.new(math.clamp(pct,0,1),0,1,0)
          end
          render()

          local dragging=false
          local function setFromX(x)
            local absPos = bar.AbsolutePosition.X
            local width  = bar.AbsoluteSize.X
            local pct = math.clamp((x-absPos)/math.max(1,width), 0, 1)
            val = math.floor(min + pct*(max-min)+0.5)
            render()
            if typeof(callback)=="function" then callback(val) end
          end

          bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
              dragging=true; setFromX(i.Position.X)
            end
          end)
          UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement) then
              setFromX(i.Position.X)
            end
          end)
          UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
          end)

          return {
            Set = function(_,v) val=math.clamp(tonumber(v) or val, min, max); render(); if callback then callback(val) end end,
            Get = function() return val end,
          }
        end

        function sec:NewDropdown(text, list, callback, defaultIndex)
          list = list or {}
          local holder = Instance.new("TextButton", sec.Body)
          holder.Size=UDim2.new(1,0,0,36); holder.Text="" ; styleButton(holder)

          local label = Instance.new("TextLabel", holder)
          label.BackgroundTransparency=1; label.Text = text or "Dropdown"
          label.Font=Enum.Font.GothamBold; label.TextSize=14; label.TextColor3=THEME.fg
          label.Size=UDim2.new(1,-28,1,0); label.Position=UDim2.fromOffset(10,0); label.TextXAlignment=Enum.TextXAlignment.Left

          local arrow = Instance.new("TextLabel", holder)
          arrow.BackgroundTransparency=1; arrow.Size=UDim2.fromOffset(16,16); arrow.Position=UDim2.new(1,-22,0.5,-8)
          arrow.Font=Enum.Font.GothamBold; arrow.TextSize=16; arrow.Text="▼"; arrow.TextColor3=THEME.fg

          local open=false
          local selected = defaultIndex and list[defaultIndex] or list[1]

          local menu = Instance.new("Frame", holder)
          menu.Visible=false; menu.BackgroundColor3=THEME.panel2; menu.BorderSizePixel=0
          menu.Position=UDim2.new(0,0,1,6); menu.Size=UDim2.new(1,0,0, math.min(#list*28, 160))
          local mc=Instance.new("UICorner",menu); mc.CornerRadius=UDim.new(0,10)
          local ms=Instance.new("UIStroke",menu); ms.Color=THEME.accent; ms.Transparency=0.35
          local scroll = mkScroll(menu); scroll.Size=UDim2.new(1,-10,1,-10); scroll.Position=UDim2.fromOffset(5,5)

          local function rebuild()
            scroll:ClearAllChildren()
            for i,opt in ipairs(list) do
              local b = Instance.new("TextButton", scroll)
              b.Size=UDim2.new(1,0,0,26); b.Text = tostring(opt); styleButton(b)
              b.MouseButton1Click:Connect(function()
                selected = opt; menu.Visible=false; open=false
                if callback then callback(selected, i) end
              end)
            end
          end
          rebuild()
          if callback and selected then callback(selected, table.find(list, selected) or 1) end

          holder.MouseButton1Click:Connect(function()
            open = not open; menu.Visible=open
          end)

          return {
            Refresh = function(_, newList)
              list = newList or {}; rebuild()
            end,
            Get = function() return selected end
          }
        end

        function sec:NewKeybind(text, desc, callback, defaultKeyCode)
          local holder = Instance.new("TextButton", sec.Body)
          holder.Size=UDim2.new(1,0,0,36); holder.Text=""; styleButton(holder)

          local label = Instance.new("TextLabel", holder)
          label.BackgroundTransparency=1; label.Text = text or "Keybind"
          label.Font=Enum.Font.GothamBold; label.TextSize=14; label.TextColor3=THEME.fg
          label.Size=UDim2.new(1,-100,1,0); label.Position=UDim2.fromOffset(10,0); label.TextXAlignment=Enum.TextXAlignment.Left

          local keyBtn = Instance.new("TextButton", holder)
          keyBtn.Size=UDim2.new(0,90,0,24); keyBtn.Position=UDim2.new(1,-100,0.5,-12)
          keyBtn.Text = (defaultKeyCode and defaultKeyCode.Name) or "Set Key"
          styleButton(keyBtn)

          local waiting=false
          keyBtn.MouseButton1Click:Connect(function()
            waiting=true; keyBtn.Text="Press..."
          end)

          UIS.InputBegan:Connect(function(i,gp)
            if gp then return end
            if waiting then
              waiting=false
              if i.KeyCode and i.KeyCode ~= Enum.KeyCode.Unknown then
                keyBtn.Text = i.KeyCode.Name
                if callback then callback(i.KeyCode) end
              else
                keyBtn.Text="Set Key"
              end
            end
          end)

          return {
            Set = function(_,kc) keyBtn.Text = kc and kc.Name or "Set Key" end
          }
        end

        return sec
      end

      return tabObj
    end

    return lib
  end

  --========================================================
  -- ⭐ ตัวอย่างใช้งานทันที (ถ้าไม่ต้องการ ลบส่วนนี้ออกได้)
  --========================================================
  local Library = UFO.CreateLib("UFO HUB X")
  local TabHome = Library:NewTab("Home")
  local S1 = TabHome:NewSection("Quick Controls")

  S1:NewButton("Hello", "ทดสอบปุ่ม", function()
    print("Hello from UFO-Widgets!")
  end)

  S1:NewToggle("AFK Shield", "เปิด/ปิดกันเตะ", function(state)
    if getgenv().UFO_AFK_SHIELD then
      getgenv().UFO_AFK_SHIELD.enabled = state and true or false
    end
    print("AFK:", state)
  end, true)

  S1:NewSlider("WalkSpeed", "ปรับความเร็วเดิน (เฉพาะเกมที่อนุญาต)", 100, 16, function(v)
    local lp=game:GetService("Players").LocalPlayer
    local ch=lp.Character or lp.CharacterAdded:Wait()
    local hum=ch:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
  end, 16)

  S1:NewDropdown("Select Mode", {"Normal","Pro","Alien"}, function(choice)
    print("Mode:", choice)
  end, 1)

  S1:NewKeybind("Toggle UI (RightShift)", "ตั้งคีย์สลับ UI", function(key)
    -- ตัวอย่าง: กดคีย์ที่ตั้งไว้ → ซ่อน/โชว์หน้าต่างหลัก
    UIS.InputBegan:Connect(function(i,gp)
      if gp then
--==========================================================
-- AFK SHIELD (Always-On) • ทำงานแม้ปิด/ซ่อน UI • ตลอดที่อยู่ในเกม
--==========================================================
do
    local Players            = game:GetService("Players")
    local UserInputService   = game:GetService("UserInputService")
    local LocalPlayer        = Players.LocalPlayer
    local VirtualUser        = game:GetService("VirtualUser")

    -- ป้องกันโหลดซ้ำ / cleanup คอนเนกชันเดิมถ้ามี
    getgenv().UFO_AFK_SHIELD = getgenv().UFO_AFK_SHIELD or {}
    local Shield = getgenv().UFO_AFK_SHIELD

    if Shield.conn then pcall(function() Shield.conn:Disconnect() end) end
    if Shield.keepaliveLoop then Shield.keepaliveLoop = false end

    Shield.enabled = true

    -- เมื่อ Roblox มองว่า Idle → ส่งอินพุตจำลองปลุกทันที (เบา/ไม่รบกวน)
    Shield.conn = LocalPlayer.Idled:Connect(function()
        if Shield.enabled then
            VirtualUser:CaptureController()
            local cam = workspace.CurrentCamera
            local pos = cam and cam.CFrame.Position or Vector3.new()
            VirtualUser:ClickButton2(Vector2.new(0,0), CFrame.new(pos))
        end
    end)

    -- ติดตามอินพุตจริงจากผู้เล่น เพื่อไม่แทรกตอนเล่นอยู่
    local lastRealInput = os.clock()
    UserInputService.InputBegan:Connect(function() lastRealInput = os.clock() end)
    UserInputService.InputChanged:Connect(function() lastRealInput = os.clock() end)

    -- ประกันเพิ่ม: ถ้าเงียบเกิน ~9 นาที ให้สะกิดเอง 1 ครั้ง
    Shield.keepaliveLoop = true
    task.spawn(function()
        while Shield.keepaliveLoop and Shield.enabled do
            task.wait(30) -- เช็คทุก 30 วิ (ภาระต่ำ)
            if os.clock() - lastRealInput > 540 then -- ~9 นาที
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
-- END
--==========================================================
--==========================================================
-- UFO HUB X • Toggle + Persist + Smart Default Gap
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

-- แก้ปุ่ม X ให้ซ่อนเฉพาะหน้าต่าง
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

-- Toggle GUI ใหม่
local OLD = CoreGui:FindFirstChild("UFO_HUB_X_Toggle")
if OLD then OLD:Destroy() end

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "UFO_HUB_X_Toggle"
ToggleGui.IgnoreGuiInset = true
ToggleGui.ResetOnSpawn   = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.Parent = CoreGui

-- ---------- Persist helpers ----------
local FILE = "UFO_HUB_X_Toggle.json"
local function canFS()
    return (typeof(writefile)=="function" and typeof(readfile)=="function" and typeof(isfile)=="function")
end
local function loadPos()
    if canFS() and isfile(FILE) then
        local ok, data = pcall(function() return Http:JSONDecode(readfile(FILE)) end)
        if ok and typeof(data)=="table" and data.x and data.y then
            return data.x, data.y, true -- true = loaded
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

-- ---------- Smart default placement (ไม่ชิด UI) ----------
local BTN_W, BTN_H = 64, 64
local GAP = 48 -- ระยะห่างขั้นต่ำจากกรอบ UI (ปรับได้)
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

-- คำนวณเริ่มต้นแบบฉลาด (ถ้าไม่มีตำแหน่งเดิม)
if not loaded then
    -- ใช้ตำแหน่งจริงของหน้าต่าง
    task.wait() -- ให้ AbsolutePosition/Size อัปเดต
    local winPos = WINDOW.AbsolutePosition
    local winSize = WINDOW.AbsoluteSize
    -- วาง “ซ้ายมือของหน้าต่าง” และเลื่อนลงมานิดให้ดูสวย
    px = (winPos.X - BTN_W - GAP)
    py = (winPos.Y + math.floor(winSize.Y*0.15))
    px, py = clamp(px, py)
end

-- ---------- สร้างปุ่ม ----------
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

local corner = Instance.new("UICorner", ToggleBtn)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", ToggleBtn)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0,255,140)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.LineJoinMode    = Enum.LineJoinMode.Round

ToggleBtn.MouseEnter:Connect(function() stroke.Thickness = 3 end)
ToggleBtn.MouseLeave:Connect(function() stroke.Thickness = 2 end)

-- กด -> Toggle เฉพาะ WINDOW
ToggleBtn.MouseButton1Click:Connect(function()
    WINDOW.Visible = not WINDOW.Visible
end)

-- คีย์ลัด RightShift -> Toggle
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        WINDOW.Visible = not WINDOW.Visible
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
