--==========================================================
-- UFO HUB X • 2 Columns Fixed + Image Crop + Thin Border + Soft Glow
-- ก๊อปวางแทนของเดิมได้เลย
--==========================================================

-- ลบของเดิม (กันซ้อน/ซ้ำ)
pcall(function() local g=game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI"); if g then g:Destroy() end end)

-- === THEME ===
local TITLE       = "UFO  HUB X"
local GREEN       = Color3.fromRGB(0,255,140)
local BG_WINDOW   = Color3.fromRGB(16,16,16)
local BG_HEADER   = Color3.fromRGB(0,0,0)
local BG_PANEL    = Color3.fromRGB(22,22,22)
local BG_INNER    = Color3.fromRGB(20,20,20)
local TEXT_WHITE  = Color3.fromRGB(235,235,235)

local WIN_W, WIN_H = 780, 440
local SIDEBAR_W    = 210

-- ใส่ Image ID ที่ต้องการ
local IMAGE_ID = 95486407220826
local IMG = "rbxassetid://"..tostring(IMAGE_ID)

-- === HELPERS ===
local function corner(o, r) local c=Instance.new("UICorner",o); c.CornerRadius=UDim.new(0,r or 10); return c end
local function stroke(o, t, col, mode)
    local s=Instance.new("UIStroke",o); s.Thickness=t or 1.5; s.Color=col or GREEN
    s.ApplyStrokeMode=mode or Enum.ApplyStrokeMode.Border; s.LineJoinMode=Enum.LineJoinMode.Round; return s
end

-- === ROOT GUI ===
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")

local GUI = Instance.new("ScreenGui", CoreGui)
GUI.Name="UFO_HUB_X_UI"; GUI.IgnoreGuiInset=true; GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; GUI.ResetOnSpawn=false

-- Window
local Window=Instance.new("Frame",GUI)
Window.Name="Window"; Window.AnchorPoint=Vector2.new(0.5,0.5); Window.Position=UDim2.new(0.5,0,0.5,0)
Window.Size=UDim2.fromOffset(WIN_W,WIN_H); Window.BackgroundColor3=BG_WINDOW; Window.BorderSizePixel=0
corner(Window,10); stroke(Window,1.5,GREEN)

-- Glow เบา ๆ รอบนอก
local Glow=Instance.new("ImageLabel",Window)
Glow.Name="Glow"; Glow.BackgroundTransparency=1; Glow.AnchorPoint=Vector2.new(0.5,0.5); Glow.Position=UDim2.new(0.5,0,0.5,0)
Glow.Size=UDim2.new(1.12,0,1.12,0); Glow.ZIndex=0; Glow.Image="rbxassetid://5028857084"
Glow.ImageColor3=GREEN; Glow.ImageTransparency=0.7; Glow.ScaleType=Enum.ScaleType.Slice; Glow.SliceCenter=Rect.new(24,24,276,276)

-- scale
local UIScale=Instance.new("UIScale",Window)
local function fit() local v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    UIScale.Scale=math.clamp(math.min(v.X/900, v.Y/560), 0.75, 1.0) end
fit(); RunS.RenderStepped:Connect(fit)

-- Header
local Header=Instance.new("Frame",Window)
Header.Size=UDim2.new(1,0,0,42); Header.BackgroundColor3=BG_HEADER; Header.BorderSizePixel=0; Header.ZIndex=2; corner(Header,10)

local TitleLbl=Instance.new("TextLabel",Header)
TitleLbl.BackgroundTransparency=1; TitleLbl.Position=UDim2.new(0,14,0,0); TitleLbl.Size=UDim2.new(1,-60,1,0)
TitleLbl.Font=Enum.Font.GothamBold; TitleLbl.Text=TITLE; TitleLbl.TextSize=16; TitleLbl.TextColor3=TEXT_WHITE
TitleLbl.TextXAlignment=Enum.TextXAlignment.Left

-- ปุ่ม X แดง
local btn=Instance.new("TextButton",Header)
btn.Size=UDim2.new(0,28,0,28); btn.Position=UDim2.new(1,-38,0.5,-14); btn.BackgroundColor3=Color3.fromRGB(200,40,40)
btn.Text="X"; btn.Font=Enum.Font.GothamBold; btn.TextSize=14; btn.TextColor3=Color3.new(1,1,1); btn.AutoButtonColor=false; btn.BorderSizePixel=0
corner(btn,6); stroke(btn,1.2,Color3.fromRGB(255,0,0)); btn.MouseEnter:Connect(function() btn.BackgroundColor3=Color3.fromRGB(255,60,60) end)
btn.MouseLeave:Connect(function() btn.BackgroundColor3=Color3.fromRGB(200,40,40) end)
btn.MouseButton1Click:Connect(function() GUI.Enabled=false end)

-- Drag
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
            local d=i.Position-start; Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- toggle RightShift
do local vis=true; UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightShift then vis=not vis; GUI.Enabled=vis end end) end

-- Body + Inner
local Body=Instance.new("Frame",Window); Body.BackgroundTransparency=1; Body.Position=UDim2.new(0,0,0,42); Body.Size=UDim2.new(1,0,1,-42)
local Inner=Instance.new("Frame",Body); Inner.Position=UDim2.new(0,10,0,10); Inner.Size=UDim2.new(1,-20,1,-20)
Inner.BackgroundColor3=BG_INNER; Inner.BorderSizePixel=0; corner(Inner,10)

-- Content (พาเนลใหญ่ด้านใน)
local Content=Instance.new("Frame",Body); Content.BackgroundColor3=BG_PANEL; Content.BorderSizePixel=0
Content.Position=UDim2.new(0,18,0,18); Content.Size=UDim2.new(1,-36,1,-36); corner(Content,10); stroke(Content,1,GREEN)

-- === สร้าง 2 คอลัมน์คงที่ ด้วย UIListLayout (ไม่ใช้ Grid แล้ว) ===
local Columns=Instance.new("Frame",Content)
Columns.BackgroundTransparency=1; Columns.Size=UDim2.new(1,-16,1,-16); Columns.Position=UDim2.new(0,8,0,8)

local list=Instance.new("UIListLayout",Columns)
list.FillDirection=Enum.FillDirection.Horizontal
list.HorizontalAlignment=Enum.HorizontalAlignment.Center
list.VerticalAlignment=Enum.VerticalAlignment.Center
list.Padding=UDim.new(0,14)
list.SortOrder=Enum.SortOrder.LayoutOrder

local function makeImagePane(parent)
    local pane=Instance.new("Frame",parent)
    pane.Size=UDim2.new(0.5,-7,1,0)  -- ครึ่งหนึ่งพอดี
    pane.BackgroundColor3=Color3.fromRGB(16,16,16); pane.BorderSizePixel=0; pane.ClipsDescendants=true
    corner(pane,10); stroke(pane,1,GREEN)

    local img=Instance.new("ImageLabel",pane)
    img.BackgroundTransparency=1; img.Size=UDim2.new(1,0,1,0); img.Image=IMG
    img.ScaleType=Enum.ScaleType.Crop   -- ครอบให้เต็ม ไม่มีแถบดำ
    return pane
end

local leftPane  = makeImagePane(Columns)
local rightPane = makeImagePane(Columns)

-- เสร็จ: มี 2 คอลัมน์เท่านั้น ภาพเต็มช่อง ไม่มีซ้ำ/ว่าง และมี Glow เบา ๆ + เส้นขอบบาง
