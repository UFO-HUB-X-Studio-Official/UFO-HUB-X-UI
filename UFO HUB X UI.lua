--==========================================================
-- UFO HUB X • PRO EDITION (All-in-One, Mobile+PC, Smooth)
--==========================================================
-- ฟีเจอร์:
--  • Drag ไม่ทำให้กล้อง/จอหัน (บล็อกอินพุตเกมระหว่างลาก)
--  • Scroll ซ้าย/ขวา (AutoCanvas)
--  • Toggle UI: ปุ่ม X / ปุ่มสี่เหลี่ยม / RightShift
--  • DPI/Viewport Adaptive (UIScale ไดนามิก + Clamp)
--  • Preload ภาพ ป้องกันกะพริบ
--  • AFK Shield (VirtualUser)
--  • UFO-Widgets API (เข้ากันได้กับ Kavo syntax)
--==========================================================

--== Clean up instances เดิม (ถ้ามี)
pcall(function()
    local CG = game:GetService("CoreGui")
    for _,n in ipairs({"UFO_HUB_X_UI","UFO_HUB_X_Toggle"}) do
        local g = CG:FindFirstChild(n); if g then g:Destroy() end
    end
end)

--== SERVICES
local CG  = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local RS  = game:GetService("RunService")
local CP  = game:GetService("ContentProvider")

--== THEME
local GREEN      = Color3.fromRGB(0,255,140)
local MINT_SOFT  = Color3.fromRGB(90,210,190)
local BG_WINDOW  = Color3.fromRGB(16,16,16)
local BG_HEADER  = Color3.fromRGB(6,6,6)
local BG_PANEL   = Color3.fromRGB(22,22,22)
local BG_INNER   = Color3.fromRGB(18,18,18)
local TEXT_WHITE = Color3.fromRGB(235,235,235)

--== ASSETS
local IMG_SMALL  = "rbxassetid://121069267171370"
local IMG_LARGE  = "rbxassetid://108408843188558"
local IMG_UFO    = "rbxassetid://100650447103028"

--== HELPERS
local function corner(gui, r) local c=Instance.new("UICorner",gui); c.CornerRadius=UDim.new(0,r or 10); return c end
local function stroke(gui, t, col, trans)
    local s=Instance.new("UIStroke",gui); s.Thickness=t or 1.2; s.Color=col or GREEN; s.Transparency=trans or 0.2
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.LineJoinMode=Enum.LineJoinMode.Round; return s
end
local function tween(o,t,goal,style,dir)
    local ti = TweenInfo.new(t or .18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tw = game:GetService("TweenService"):Create(o, ti, goal); tw:Play(); return tw
end
local function clampToViewport(px,py,w,h)
    local cam = workspace.CurrentCamera
    local v = cam and cam.ViewportSize or Vector2.new(1280,720)
    local nx = math.clamp(px, 4, v.X - (w or 0) - 4)
    local ny = math.clamp(py, 4, v.Y - (h or 0) - 4)
    return nx, ny
end

--== ROOT GUI
local GUI = Instance.new("ScreenGui")
GUI.Name="UFO_HUB_X_UI"; GUI.IgnoreGuiInset=true; GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder = 1_000_000; GUI.ResetOnSpawn=false; GUI.Parent=CG

--== WINDOW
local WIN_W, WIN_H = 640, 360
local Window = Instance.new("Frame", GUI)
Window.Name="Window"; Window.AnchorPoint=Vector2.new(0.5,0.5); Window.Position=UDim2.fromScale(0.5,0.5)
Window.Size=UDim2.fromOffset(WIN_W,WIN_H); Window.BackgroundColor3=BG_WINDOW; Window.BorderSizePixel=0
corner(Window,12); stroke(Window,3, GREEN, 0)

-- Glow
do local g=Instance.new("ImageLabel",Window)
    g.BackgroundTransparency=1; g.AnchorPoint=Vector2.new(0.5,0.5)
    g.Position=UDim2.fromScale(0.5,0.5); g.Size=UDim2.new(1.07,0,1.09,0)
    g.Image="rbxassetid://5028857084"; g.ImageColor3=GREEN; g.ImageTransparency=0.78
    g.ScaleType=Enum.ScaleType.Slice; g.SliceCenter=Rect.new(24,24,276,276); g.ZIndex=0
end

-- Adaptive scale (DPI / viewport)
local UIScale = Instance.new("UIScale", Window)
local function updateScale()
    local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    UIScale.Scale = math.clamp(math.min(v.X/860, v.Y/540), 0.66, 1.25)
end
updateScale()
RS.RenderStepped:Connect(updateScale)

--== HEADER + DRAG (block camera while dragging)
local Header = Instance.new("Frame", Window)
Header.Size=UDim2.new(1,0,0,46); Header.BackgroundColor3=BG_HEADER; Header.BorderSizePixel=0
corner(Header,12)

local Title = Instance.new("TextLabel", Header)
Title.BackgroundTransparency=1; Title.AnchorPoint=Vector2.new(0.5,0); Title.Position=UDim2.fromOffset(0,8)
Title.Size=UDim2.new(0.8,0,0,36); Title.Font=Enum.Font.GothamBold; Title.RichText=true; Title.TextScaled=true
Title.Text='<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'; Title.TextColor3=TEXT_WHITE

local BtnClose = Instance.new("TextButton", Header)
BtnClose.Size=UDim2.fromOffset(24,24); BtnClose.Position=UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3=Color3.fromRGB(200,40,40); BtnClose.Text="X"; BtnClose.BorderSizePixel=0
BtnClose.Font=Enum.Font.GothamBold; BtnClose.TextSize=13; BtnClose.TextColor3=Color3.new(1,1,1)
corner(BtnClose,6); stroke(BtnClose,1,Color3.fromRGB(255,0,0),0.1)

-- Drag (block camera/look with CAS while dragging)
do
    local dragging=false; local start; local startPos
    local function bindBlock(on)
        local name="UFO_BlockLook"
        if on then
            local fn=function() return Enum.ContextActionResult.Sink end
            if CAS.BindActionAtPriority then
                CAS:BindActionAtPriority(name, fn, false, 9000,
                    Enum.UserInputType.Touch,
                    Enum.UserInputType.MouseMovement,
                    Enum.UserInputType.MouseButton1,
                    Enum.UserInputType.MouseButton2,
                    Enum.KeyCode.Thumbstick2)
            else
                CAS:BindAction(name, fn, false, Enum.UserInputType.Touch, Enum.UserInputType.MouseMovement, Enum.UserInputType.MouseButton2)
            end
        else
            pcall(function() CAS:UnbindAction(name) end)
        end
    end
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Window.Position; bindBlock(true)
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; bindBlock(false) end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - start
            local ox = startPos.X.Offset + d.X; local oy = startPos.Y.Offset + d.Y
            local nx,ny = clampToViewport(ox, oy, Window.AbsoluteSize.X, Window.AbsoluteSize.Y)
            Window.Position = UDim2.new(startPos.X.Scale, nx, startPos.Y.Scale, ny)
        end
    end)
end

--== BODY + PANELS (scroll L/R)
local Body = Instance.new("Frame", Window)
Body.BackgroundTransparency=1; Body.Position=UDim2.fromOffset(0,46); Body.Size=UDim2.new(1,0,1,-46)

local Inner = Instance.new("Frame", Body)
Inner.BackgroundColor3=BG_INNER; Inner.BorderSizePixel=0; Inner.Position=UDim2.fromOffset(8,8)
Inner.Size=UDim2.new(1,-16,1,-16); corner(Inner,12)

local Content = Instance.new("Frame", Body)
Content.BackgroundColor3=BG_PANEL; Content.Position=UDim2.fromOffset(14,14)
Content.Size=UDim2.new(1,-28,1,-28); corner(Content,12); stroke(Content,0.7,GREEN,0.25)

local Columns = Instance.new("Frame", Content)
Columns.BackgroundTransparency=1; Columns.Position=UDim2.fromOffset(8,8); Columns.Size=UDim2.new(1,-16,1,-16)

local Left = Instance.new("Frame", Columns)
Left.BackgroundColor3=Color3.fromRGB(16,16,16); Left.Size=UDim2.new(0.22,-6,1,0); corner(Left,10); stroke(Left,1.2,GREEN,0.18)

local Right = Instance.new("Frame", Columns)
Right.BackgroundColor3=Color3.fromRGB(16,16,16); Right.Position=UDim2.new(0.22,12,0,0)
Right.Size=UDim2.new(0.78,-6,1,0); corner(Right,10); stroke(Right,1.2,GREEN,0.18)

local ScrollLeft = Instance.new("ScrollingFrame", Left)
ScrollLeft.Name="ScrollLeft"; ScrollLeft.Active=true; ScrollLeft.ScrollingDirection=Enum.ScrollingDirection.Y
ScrollLeft.AutomaticCanvasSize=Enum.AutomaticSize.Y; ScrollLeft.CanvasSize=UDim2.new(0,0,0,0)
ScrollLeft.BackgroundTransparency=1; ScrollLeft.Size=UDim2.new(1,-10,1,-10); ScrollLeft.Position=UDim2.fromOffset(5,5)
local LLayout = Instance.new("UIListLayout", ScrollLeft); LLayout.Padding=UDim.new(0,8); LLayout.SortOrder=Enum.SortOrder.LayoutOrder

local ScrollRight = Instance.new("ScrollingFrame", Right)
ScrollRight.Name="ScrollRight"; ScrollRight.Active=true; ScrollRight.ScrollingDirection=Enum.ScrollingDirection.Y
ScrollRight.AutomaticCanvasSize=Enum.AutomaticSize.Y; ScrollRight.CanvasSize=UDim2.new(0,0,0,0)
ScrollRight.BackgroundTransparency=1; ScrollRight.Size=UDim2.new(1,-10,1,-10); ScrollRight.Position=UDim2.fromOffset(5,5)
local RLayout = Instance.new("UIListLayout", ScrollRight); RLayout.Padding=UDim.new(0,8); RLayout.SortOrder=Enum.SortOrder.LayoutOrder

-- Demo images + preload
local imgL = Instance.new("ImageLabel", ScrollLeft)
imgL.Size=UDim2.new(1,0,0,220); imgL.BackgroundTransparency=1; imgL.Image=IMG_SMALL; imgL.ScaleType=Enum.ScaleType.Crop
local imgR = Instance.new("ImageLabel", ScrollRight)
imgR.Size=UDim2.new(1,0,0,260); imgR.BackgroundTransparency=1; imgR.Image=IMG_LARGE; imgR.ScaleType=Enum.ScaleType.Crop
task.spawn(function() pcall(function() CP:PreloadAsync({imgL,imgR}) end) end)

-- กันภาพอมสี
for _,o in ipairs(GUI:GetDescendants()) do
    if o:IsA("ImageLabel") or o:IsA("ImageButton") then o.ImageColor3 = Color3.new(1,1,1) end
end

--== CLOSE / TOGGLE
BtnClose.MouseButton1Click:Connect(function() Window.Visible=false end)

local ToggleGUI = Instance.new("ScreenGui", CG)
ToggleGUI.Name="UFO_HUB_X_Toggle"; ToggleGUI.IgnoreGuiInset=true; ToggleGUI.DisplayOrder=1_000_001
local ToggleBtn = Instance.new("ImageButton", ToggleGUI)
ToggleBtn.Name="ToggleUI"; ToggleBtn.Size=UDim2.fromOffset(64,64); ToggleBtn.Position=UDim2.fromOffset(80,200)
ToggleBtn.AutoButtonColor=false; ToggleBtn.BackgroundColor3=Color3.fromRGB(0,0,0); ToggleBtn.BorderSizePixel=0
ToggleBtn.Image="rbxassetid://117052960049460"; corner(ToggleBtn,8); stroke(ToggleBtn,2,GREEN,0)

local function showUI() GUI.Enabled=true; Window.Visible=true; GUI.DisplayOrder=1_000_000 end
local function hideUI() Window.Visible=false end
ToggleBtn.MouseButton1Click:Connect(function() if Window.Visible then hideUI() else showUI() end end)
UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightShift then if Window.Visible then hideUI() else showUI() end end end)

--== AFK SHIELD (ทำงานแม้ปิด UI)
do
    local Players=game:GetService("Players"); local VirtualUser=game:GetService("VirtualUser")
    local LP=Players.LocalPlayer
    if getgenv().UFO_AFK_SHIELD_CONN then pcall(function() getgenv().UFO_AFK_SHIELD_CONN:Disconnect() end) end
    getgenv().UFO_AFK_SHIELD_CONN = LP.Idled:Connect(function()
        VirtualUser:CaptureController()
        local cam=workspace.CurrentCamera; local pos=cam and cam.CFrame.Position or Vector3.new()
        VirtualUser:ClickButton2(Vector2.new(0,0), CFrame.new(pos))
    end)
end

--==========================================================
-- UFO-Widgets API (Kavo-like)
-- Usage:
--   local Lib = UFO.CreateLib("UFO HUB X", "DarkTheme")
--   local Tab = Lib:NewTab("Home")
--   local Sec = Tab:NewSection("Quick Controls")
--   Sec:NewButton("Hello","desc", function() end)
--   Sec:NewToggle("Auto","desc", function(state) end, true)
--   Sec:NewSlider("Speed","desc", 100, 16, function(v) end, 16)
--   Sec:NewDropdown("Mode","desc", {"A","B"}, function(choice) end)
--   Sec:NewKeybind("Toggle","desc", Enum.KeyCode.RightShift, function() end)
--   Sec:NewTextBox("Name","desc", function(text) end)
--   Lib:ToggleUI() -- สลับแสดง/ซ่อน
--==========================================================
UFO = {}
function UFO.CreateLib(title, theme)
    if title and typeof(title)=="string" then Title.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">'..title..'</font>' end
    local lib = { _tabs = {} }

    local TabBar = Instance.new("Frame", ScrollRight)
    TabBar.Size=UDim2.new(1,0,0,36); TabBar.BackgroundColor3=BG_INNER; TabBar.BorderSizePixel=0
    corner(TabBar,10); stroke(TabBar,1,GREEN,0.25)
    local TabsLayout = Instance.new("UIListLayout", TabBar)
    TabsLayout.FillDirection=Enum.FillDirection.Horizontal; TabsLayout.Padding=UDim.new(0,8)
    local TabsPad = Instance.new("UIPadding", TabBar); TabsPad.PaddingLeft=UDim.new(0,8); TabsPad.PaddingRight=UDim.new(0,8)

    local Pages = Instance.new("Folder", ScrollRight); Pages.Name="Pages"

    local function mkScroll(parent)
        local sf = Instance.new("ScrollingFrame", parent)
        sf.Active=true; sf.ScrollingDirection=Enum.ScrollingDirection.Y
        sf.AutomaticCanvasSize=Enum.AutomaticSize.Y; sf.CanvasSize=UDim2.new(0,0,0,0)
        sf.BackgroundTransparency=1; sf.Size=UDim2.new(1,-16,1,-16); sf.Position=UDim2.fromOffset(8,8)
        local ll = Instance.new("UIListLayout", sf); ll.Padding=UDim.new(0,8)
        return sf
    end
    local function styleBtn(btn)
        btn.BackgroundColor3=BG_INNER; btn.BorderSizePixel=0; btn.TextColor3=TEXT_WHITE
        btn.Font=Enum.Font.Gotham; btn.TextSize=14; btn.AutoButtonColor=false
        corner(btn,10); stroke(btn,1,GREEN,0.25)
    end
    local function mkSection(parent, titleText)
        local box = Instance.new("Frame", parent)
        box.BackgroundColor3=BG_INNER; box.BorderSizePixel=0; box.AutomaticSize=Enum.AutomaticSize.Y; box.Size=UDim2.new(1,0,0,10)
        corner(box,10); stroke(box,1,GREEN,0.25)
        local pad = Instance.new("UIPadding", box); pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,10); pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10)
        local title = Instance.new("TextLabel", box)
        title.BackgroundTransparency=1; title.Text=titleText or "Section"; title.Font=Enum.Font.GothamBold; title.TextSize=16; title.TextColor3=TEXT_WHITE
        title.Size=UDim2.new(1,0,0,20); title.TextXAlignment=Enum.TextXAlignment.Left
        local body = Instance.new("Frame", box); body.BackgroundTransparency=1; body.AutomaticSize=Enum.AutomaticSize.Y; body.Size=UDim2.new(1,0,0,10); body.Position=UDim2.fromOffset(0,26)
        local list = Instance.new("UIListLayout", body); list.Padding=UDim.new(0,6)
        return { Box=box, Body=body }
    end

    function lib:NewTab(name)
        local btn = Instance.new("TextButton", TabBar)
        btn.Text = name or ("Tab "..tostring(#self._tabs+1))
        btn.Size=UDim2.new(0, math.max(100, (#btn.Text*7)+22), 1, -8); btn.Position=UDim2.fromOffset(0,4)
        styleBtn(btn)

        local page = Instance.new("Frame", Pages)
        page.Name="Page_"..btn.Text; page.BackgroundTransparency=1; page.Size=UDim2.new(1,0,0,10); page.AutomaticSize=Enum.AutomaticSize.Y; page.Visible=false
        local scroll = mkScroll(page)

        local tab = { Button=btn, Page=page, Scroll=scroll, Sections={} }
        table.insert(self._tabs, tab)

        btn.MouseButton1Click:Connect(function()
            for _,t in ipairs(self._tabs) do t.Page.Visible=false; t.Button.TextColor3=TEXT_WHITE end
            page.Visible=true; btn.TextColor3=GREEN
        end)
        if #self._tabs==1 then btn:Activate(); btn.MouseButton1Click:Fire() end

        function tab:NewSection(titleText)
            local s = mkSection(scroll, titleText); table.insert(self.Sections, s)

            function s:NewButton(text, desc, cb)
                local b = Instance.new("TextButton", s.Body)
                b.Size=UDim2.new(1,0,0,36); b.Text=text or "Button"; styleBtn(b)
                if desc and desc~="" then
                    local d=Instance.new("TextLabel", b); d.BackgroundTransparency=1; d.Text=desc; d.Font=Enum.Font.Gotham; d.TextSize=12; d.TextColor3=Color3.fromRGB(200,200,200)
                    d.Size=UDim2.new(1,-20,0,14); d.Position=UDim2.fromOffset(10,20); d.TextXAlignment=Enum.TextXAlignment.Left
                end
                b.MouseButton1Click:Connect(function() if typeof(cb)=="function" then cb() end end)
                return b
            end

            function s:NewToggle(text, desc, cb, default)
                local holder=Instance.new("Frame", s.Body); holder.BackgroundTransparency=1; holder.Size=UDim2.new(1,0,0,38)
                local b=Instance.new("TextButton", holder); b.Size=UDim2.new(1,-46,1,0); b.Text=text or "Toggle"; styleBtn(b)
                if desc and desc~="" then local d=Instance.new("TextLabel", b); d.BackgroundTransparency=1; d.Text=desc; d.Font=Enum.Font.Gotham; d.TextSize=12; d.TextColor3=Color3.fromRGB(200,200,200); d.Size=UDim2.new(1,-20,0,14); d.Position=UDim2.fromOffset(10,20); d.TextXAlignment=Enum.TextXAlignment.Left end
                local knob=Instance.new("Frame", holder); knob.Size=UDim2.fromOffset(36,36); knob.Position=UDim2.new(1,-36,0,1); knob.BackgroundColor3=Color3.fromRGB(60,60,60); knob.BorderSizePixel=0; corner(knob,10); stroke(knob,1,GREEN,0.2)
                local dot=Instance.new("Frame", knob); dot.Size=UDim2.fromOffset(18,18); dot.Position=UDim2.fromOffset(9,9); dot.BackgroundColor3=Color3.fromRGB(120,120,120); dot.BorderSizePixel=0; corner(dot,9)
                local state = default==true
                local function render() knob.BackgroundColor3 = state and GREEN or Color3.fromRGB(60,60,60); dot.BackgroundColor3 = state and Color3.fromRGB(20,20,20) or Color3.fromRGB(120,120,120) end
                render()
                local function flip() state=not state; render(); if typeof(cb)=="function" then cb(state) end end
                b.MouseButton1Click:Connect(flip); knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then flip() end end)
                return {Set=function(_,v) state=not not v; render(); if cb then cb(state) end end, Get=function() return state end}
            end

            function s:NewSlider(text, desc, max, min, cb, default)
                max=max or 100; min=min or 0
                local holder=Instance.new("Frame", s.Body); holder.BackgroundColor3=BG_INNER; holder.BorderSizePixel=0; holder.Size=UDim2.new(1,0,0,56); corner(holder,10); stroke(holder,1,GREEN,0.25)
                local title=Instance.new("TextLabel", holder); title.BackgroundTransparency=1; title.Text=text or "Slider"; title.Font=Enum.Font.GothamBold; title.TextSize=14; title.TextColor3=TEXT_WHITE; title.Position=UDim2.fromOffset(10,6); title.Size=UDim2.new(1,-20,0,16); title.TextXAlignment=Enum.TextXAlignment.Left
                if desc and desc~="" then local d=Instance.new("TextLabel", holder); d.BackgroundTransparency=1; d.Text=desc; d.Font=Enum.Font.Gotham; d.TextSize=12; d.TextColor3=Color3.fromRGB(200,200,200); d.Position=UDim2.fromOffset(10,24); d.Size=UDim2.new(1,-20,0,14); d.TextXAlignment=Enum.TextXAlignment.Left end
                local bar=Instance.new("Frame", holder); bar.BackgroundColor3=Color3.fromRGB(60,60,60); bar.BorderSizePixel=0; bar.Position=UDim2.new(0,10,1,-12); bar.Size=UDim2.new(1,-20,0,6); corner(bar,3)
                local fill=Instance.new("Frame", bar); fill.BackgroundColor3=GREEN; fill.BorderSizePixel=0; fill.Size=UDim2.new(0,0,1,0); corner(fill,3)
                local val=default or min
                local function render() local pct=(val-min)/(max-min); fill.Size=UDim2.new(math.clamp(pct,0,1),0,1,0) end
                render()
                local dragging=false
                local function setFromX(x) local p=bar.AbsolutePosition.X; local w=bar.AbsoluteSize.X; local pct=math.clamp((x-p)/math.max(1,w),0,1); val=math.floor(min+pct*(max-min)+0.5); render(); if typeof(cb)=="function" then cb(val) end end
                bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(i.Position.X) end end)
                UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setFromX(i.Position.X) end end)
                UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
                return {Set=function(_,v) val=math.clamp(tonumber(v) or val,min,max); render(); if cb then cb(val) end end, Get=function() return val end}
            end

            function s:NewDropdown(text, desc, list, cb, defaultIndex)
                list = list or {}
                local holder=Instance.new("TextButton", s.Body); holder.Size=UDim2.new(1,0,0,36); holder.Text=""; styleBtn(holder)
                local label=Instance.new("TextLabel", holder); label.BackgroundTransparency=1; label.Text=text or "Dropdown"; label.Font=Enum.Font.GothamBold; label.TextSize=14; label.TextColor3=TEXT_WHITE; label.Size=UDim2.new(1,-28,1,0); label.Position=UDim2.fromOffset(10,0); label.TextXAlignment=Enum.TextXAlignment.Left
                if desc and desc~="" then
                    local d=Instance.new("TextLabel", holder); d.BackgroundTransparency=1; d.Text=desc; d.Font=Enum.Font.Gotham; d.TextSize=12; d.TextColor3=Color3.fromRGB(200,200,200)
                    d.Position=UDim2.fromOffset(10,18); d.Size=UDim2.new(1,-20,0,14); d.TextXAlignment=Enum.TextXAlignment.Left
                end
                local arrow=Instance.new("TextLabel", holder); arrow.BackgroundTransparency=1; arrow.Text="▼"; arrow.Font=Enum.Font.GothamBold; arrow.TextSize=16; arrow.TextColor3=TEXT_WHITE; arrow.Size=UDim2.fromOffset(16,16); arrow.Position=UDim2.new(1,-22,0.5,-8)

                local menu=Instance.new("Frame", holder); menu.Visible=false; menu.BackgroundColor3=BG_INNER; menu.BorderSizePixel=0; menu.Position=UDim2.new(0,0,1,6); menu.Size=UDim2.new(1,0,0,140)
                corner(menu,10); stroke(menu,1,GREEN,0.25)
                local srf = Instance.new("ScrollingFrame", menu); srf.Active=true; srf.AutomaticCanvasSize=Enum.AutomaticSize.Y; srf.CanvasSize=UDim2.new(0,0,0,0); srf.BackgroundTransparency=1; srf.Size=UDim2.new(1,-10,1,-10); srf.Position=UDim2.fromOffset(5,5)
                local ll = Instance.new("UIListLayout", srf); ll.Padding=UDim.new(0,6)

                local selected = (defaultIndex and list[defaultIndex]) or list[1]
                local function rebuild()
                    srf:ClearAllChildren()
                    for i,opt in ipairs(list) do
                        local b = Instance.new("TextButton", srf)
                        b.Size=UDim2.new(1,0,0,26); b.Text = tostring(opt); styleBtn(b)
                        b.MouseButton1Click:Connect(function()
                            selected=opt; menu.Visible=false
                            if typeof(cb)=="function" then cb(opt,i) end
                        end)
                    end
                end
                rebuild()
                if selected and cb then cb(selected, table.find(list, selected) or 1) end
                holder.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)

                return {
                    Refresh=function(_,newList) list=newList or {}; rebuild() end,
                    Get=function() return selected end
                }
            end

            function s:NewKeybind(text, desc, defaultKey, cb)
                local holder=Instance.new("TextButton", s.Body); holder.Size=UDim2.new(1,0,0,36); holder.Text=""; styleBtn(holder)
                local label=Instance.new("TextLabel", holder); label.BackgroundTransparency=1; label.Text=text or "Keybind"; label.Font=Enum.Font.GothamBold; label.TextSize=14; label.TextColor3=TEXT_WHITE; label.Size=UDim2.new(1,-100,1,0); label.Position=UDim2.fromOffset(10,0); label.TextXAlignment=Enum.TextXAlignment.Left
                local keyBtn=Instance.new("TextButton", holder); keyBtn.Size=UDim2.fromOffset(90,24); keyBtn.Position=UDim2.new(1,-100,0.5,-12); keyBtn.Text=(defaultKey and defaultKey.Name) or "Set Key"; styleBtn(keyBtn)

                local waiting=false
                keyBtn.MouseButton1Click:Connect(function() waiting=true; keyBtn.Text="Press..." end)
                UIS.InputBegan:Connect(function(i,gp)
                    if gp then return end
                    if waiting then
                        waiting=false
                        if i.KeyCode~=Enum.KeyCode.Unknown then
                            keyBtn.Text=i.KeyCode.Name
                            if typeof(cb)=="function" then cb(i.KeyCode) end
                        else
                            keyBtn.Text="Set Key"
                        end
                    end
                end)

                return { Set=function(_,kc) keyBtn.Text = kc and kc.Name or "Set Key" end }
            end

            function s:NewTextBox(text, desc, cb)
                local holder=Instance.new("Frame", s.Body); holder.BackgroundTransparency=1; holder.Size=UDim2.new(1,0,0,46)
                local label=Instance.new("TextLabel", holder); label.BackgroundTransparency=1; label.Text=text or "TextBox"; label.Font=Enum.Font.GothamBold; label.TextSize=14; label.TextColor3=TEXT_WHITE; label.Size=UDim2.new(1,-160,1,0); label.Position=UDim2.fromOffset(0,0); label.TextXAlignment=Enum.TextXAlignment.Left
                local box=Instance.new("TextBox", holder); box.Size=UDim2.new(0,150,0,30); box.Position=UDim2.new(1,-150,0.5,-15); box.PlaceholderText=desc or ""; box.Text=""; box.Font=Enum.Font.Gotham; box.TextSize=14; box.TextColor3=TEXT_WHITE; box.BackgroundColor3=BG_INNER; box.BorderSizePixel=0; corner(box,8); stroke(box,1,GREEN,0.25)
                box.FocusLost:Connect(function(enter) if enter and typeof(cb)=="function" then cb(box.Text) end end)
                return box
            end

            return s
        end -- tab:NewSection
        return tab
    end -- lib:NewTab

    function lib:ToggleUI()
        if Window.Visible then
            Window.Visible=false
        else
            GUI.Enabled=true
            Window.Visible=true
        end
    end

    return lib
end -- UFO.CreateLib
