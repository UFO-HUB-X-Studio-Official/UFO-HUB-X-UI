--// 🛸 UFO HUB X – Ultra Clean Fix (All-in-One Version)
pcall(function()
    local cg = game:GetService("CoreGui")
    for _, n in ipairs({"UFOX_UI","UFOX_TOGGLE"}) do
        local g = cg:FindFirstChild(n)
        if g then g:Destroy() end
    end
end)

--== CONFIG ==--
local CFG = {
    WIN_W = 640, WIN_H = 360,
    SCALE_MIN = 0.72, SCALE_MAX = 1.0,
    BTN_HEIGHT = 52, BTN_SIDE_PAD = 8, BTN_GAP = 8,
    HOTKEY = Enum.KeyCode.RightShift,
    TOGGLE_IMAGE = "rbxassetid://117052960049460",
    UFO_IMG = "rbxassetid://100650447103028",
    GLOW_IMG = "rbxassetid://5028857084",
    ICON_DEF = "rbxassetid://112510739340023"
}

local UI = {
    GREEN = Color3.fromRGB(0,255,140),
    MINT  = Color3.fromRGB(120,255,220),
    TEXT  = Color3.fromRGB(235,235,235),
    RED   = Color3.fromRGB(200,40,40),
    BG_WINDOW = Color3.fromRGB(16,16,16),
    BG_HEADER = Color3.fromRGB(6,6,6),
    BG_PANEL  = Color3.fromRGB(22,22,22),
    BG_INNER  = Color3.fromRGB(18,18,18)
}

--== SERVICES ==--
local S = setmetatable({}, {__index=function(_,k)return game:GetService(k)end})
local UIS, CAS, RunS = S.UserInputService, S.ContextActionService, S.RunService
local CoreGui = S.CoreGui

--== HELPERS ==--
local function corner(g,r)local c=Instance.new("UICorner",g)c.CornerRadius=UDim.new(0,r or 10)return c end
local function stroke(g,t,c,tr)local s=Instance.new("UIStroke",g)s.Thickness=t or 1;s.Color=c or UI.MINT;s.Transparency=tr or 0.35;s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.LineJoinMode=Enum.LineJoinMode.Round;return s end
local function gradient(g,c1,c2,rot)local d=Instance.new("UIGradient",g)d.Color=ColorSequence.new(c1,c2)d.Rotation=rot or 0;return d end

--== ROOT ==--
local GUI=Instance.new("ScreenGui")
GUI.Name="UFOX_UI";GUI.IgnoreGuiInset=true;GUI.DisplayOrder=100000;GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;GUI.ResetOnSpawn=false;GUI.Parent=CoreGui

local Window=Instance.new("Frame",GUI)
Window.Name="Window";Window.AnchorPoint=Vector2.new(0.5,0.5);Window.Position=UDim2.new(0.5,0,0.5,0)
Window.Size=UDim2.fromOffset(CFG.WIN_W,CFG.WIN_H);Window.BackgroundColor3=UI.BG_WINDOW;Window.BorderSizePixel=0
corner(Window,12)local Border=stroke(Window,3,UI.GREEN,0)

-- Glow
do local g=Instance.new("ImageLabel",Window)
    g.BackgroundTransparency=1;g.AnchorPoint=Vector2.new(0.5,0.5)
    g.Position=UDim2.new(0.5,0,0.5,0);g.Size=UDim2.new(1.07,0,1.09,0)
    g.Image=CFG.GLOW_IMG;g.ImageColor3=UI.GREEN;g.ImageTransparency=0.78
    g.ScaleType=Enum.ScaleType.Slice;g.SliceCenter=Rect.new(24,24,276,276);g.ZIndex=0
end

-- Autoscale
local UIScale=Instance.new("UIScale",Window)
local function fit()
    local cam=workspace.CurrentCamera;local v=(cam and cam.ViewportSize)or Vector2.new(1280,720)
    UIScale.Scale=math.clamp(math.min(v.X/860,v.Y/540),CFG.SCALE_MIN,CFG.SCALE_MAX)
end
fit();RunS.RenderStepped:Connect(fit)

--== HEADER ==--
local Header=Instance.new("Frame",Window)
Header.Size=UDim2.new(1,0,0,46);Header.BackgroundColor3=UI.BG_HEADER;Header.BorderSizePixel=0
corner(Header,12);gradient(Header,Color3.fromRGB(10,10,10),Color3.fromRGB(0,0,0),0)

local HeadAccent=Instance.new("Frame",Header)
HeadAccent.AnchorPoint=Vector2.new(0.5,1);HeadAccent.Position=UDim2.new(0.5,0,1,0)
HeadAccent.Size=UDim2.new(1,-20,0,1);HeadAccent.BackgroundColor3=UI.MINT;HeadAccent.BackgroundTransparency=0.35

local Title=Instance.new("TextLabel",Header)
Title.BackgroundTransparency=1;Title.AnchorPoint=Vector2.new(0.5,0)
Title.Position=UDim2.new(0.5,0,0,8);Title.Size=UDim2.new(0.8,0,0,36)
Title.Font=Enum.Font.GothamBold;Title.RichText=true;Title.TextScaled=true;Title.TextColor3=UI.TEXT;Title.ZIndex=61
Title.Text='<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'

local BtnClose=Instance.new("TextButton",Header)
BtnClose.Size=UDim2.new(0,24,0,24);BtnClose.Position=UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3=UI.RED;BtnClose.Text="X";BtnClose.Font=Enum.Font.GothamBold;BtnClose.TextSize=13
BtnClose.TextColor3=Color3.new(1,1,1);BtnClose.BorderSizePixel=0;corner(BtnClose,6);stroke(BtnClose,1,Color3.fromRGB(255,0,0),0.1)
BtnClose.MouseButton1Click:Connect(function()Window.Visible=false;getgenv().UFO_ISOPEN=false end)

-- Drag header
do local dragging,start,startPos
    local function block(on)local name="UFOX_BlockLook_Window"
        if on then CAS:BindActionAtPriority(name,function()return Enum.ContextActionResult.Sink end,false,9000,Enum.UserInputType.MouseMovement,Enum.UserInputType.Touch,Enum.UserInputType.MouseButton1)
        else pcall(function()CAS:UnbindAction(name)end) end end
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true;start=i.Position;startPos=Window.Position;block(true)
            i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then dragging=false;block(false)end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start;Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- UFO icon
do local UFO=Instance.new("ImageLabel",Window)
    UFO.BackgroundTransparency=1;UFO.Image=CFG.UFO_IMG
    UFO.Size=UDim2.new(0,168,0,168);UFO.AnchorPoint=Vector2.new(0.5,1);UFO.Position=UDim2.new(0.5,0,0,84);UFO.ZIndex=60
    local Halo=Instance.new("ImageLabel",Window)
    Halo.BackgroundTransparency=1;Halo.AnchorPoint=Vector2.new(0.5,0)
    Halo.Position=UDim2.new(0.5,0,0,0);Halo.Size=UDim2.new(0,200,0,60)
    Halo.Image=CFG.GLOW_IMG;Halo.ImageColor3=UI.MINT;Halo.ImageTransparency=0.72;Halo.ZIndex=50
end

--== BODY ==--
local Body=Instance.new("Frame",Window)
Body.BackgroundTransparency=1;Body.Position=UDim2.new(0,0,0,46);Body.Size=UDim2.new(1,0,1,-46)

local Inner=Instance.new("Frame",Body)
Inner.BackgroundColor3=UI.BG_INNER;Inner.BorderSizePixel=0
Inner.Position=UDim2.new(0,8,0,8);Inner.Size=UDim2.new(1,-16,1,-16);corner(Inner,12)

local Content=Instance.new("Frame",Body)
Content.BackgroundColor3=UI.BG_PANEL;Content.Position=UDim2.new(0,14,0,14);Content.Size=UDim2.new(1,-28,1,-28)
corner(Content,12);stroke(Content,0.5,UI.MINT,0.35)

local Columns=Instance.new("Frame",Content)
Columns.BackgroundTransparency=1;Columns.Position=UDim2.new(0,8,0,8);Columns.Size=UDim2.new(1,-16,1,-16)

-- panels
local Left=Instance.new("Frame",Columns)
Left.Name="Left";Left.BackgroundColor3=Color3.fromRGB(16,16,16)
Left.Size=UDim2.new(0.22,-6,1,0);corner(Left,10);stroke(Left,1.2,UI.GREEN,0);stroke(Left,0.45,UI.MINT,0.35)
local Right=Instance.new("Frame",Columns)
Right.Name="Right";Right.BackgroundColor3=Color3.fromRGB(16,16,16)
Right.Position=UDim2.new(0.22,12,0,0);Right.Size=UDim2.new(0.78,-6,1,0)
corner(Right,10);stroke(Right,1.2,UI.GREEN,0);stroke(Right,0.45,UI.MINT,0.35)

-- Right header (fixed: no Label)
local RH_Icon=Instance.new("ImageLabel",Right)
RH_Icon.BackgroundTransparency=1;RH_Icon.Size=UDim2.fromOffset(24,24);RH_Icon.Position=UDim2.new(0,18,0,14);RH_Icon.Visible=false
local RH_Text=Instance.new("TextLabel",Right)
RH_Text.BackgroundTransparency=1;RH_Text.Position=UDim2.new(0,50,0,12)
RH_Text.Size=UDim2.new(1,-80,0,28);RH_Text.Font=Enum.Font.GothamBold;RH_Text.TextSize=18
RH_Text.TextXAlignment=Enum.TextXAlignment.Left;RH_Text.TextColor3=UI.TEXT;RH_Text.Text="";RH_Text.Visible=false

-- scrolls
local function makeScroll(host)
    local inset=Instance.new("Frame",host)
    inset.BackgroundTransparency=1;inset.ClipsDescendants=true
    inset.Position=UDim2.fromOffset(2,2);inset.Size=UDim2.new(1,-4,1,-4)
    local sc=Instance.new("ScrollingFrame",inset)
    sc.BackgroundTransparency=1;sc.BorderSizePixel=0;sc.Size=UDim2.fromScale(1,1)
    sc.ScrollingDirection=Enum.ScrollingDirection.Y;sc.AutomaticCanvasSize=Enum.AutomaticSize.Y;sc.CanvasSize=UDim2.new()
    sc.ScrollBarThickness=0;sc.ScrollBarImageTransparency=1
    local pad=Instance.new("UIPadding",sc)
    pad.PaddingTop=UDim.new(0,CFG.BTN_GAP);pad.PaddingLeft=UDim.new(0,CFG.BTN_SIDE_PAD)
    pad.PaddingRight=UDim.new(0,CFG.BTN_SIDE_PAD)
    local list=Instance.new("UIListLayout",sc);list.Padding=UDim.new(0,CFG.BTN_GAP)
    return sc
end
local LeftScroll=makeScroll(Left)
local RightScroll=makeScroll(Right)

-- buttons
local function addButton(label,iconId,onClick)
    local b=Instance.new("TextButton",LeftScroll)
    b.Text="";b.AutoButtonColor=false;b.Size=UDim2.new(1,0,0,CFG.BTN_HEIGHT)
    b.BackgroundColor3=UI.BG_WINDOW;corner(b,8)
    local st=stroke(b,0.6,UI.MINT,0.35)
    local ic=Instance.new("ImageLabel",b)
    ic.BackgroundTransparency=1;ic.Image=iconId or CFG.ICON_DEF
    ic.Size=UDim2.fromOffset(CFG.BTN_HEIGHT-12,CFG.BTN_HEIGHT-12)
    ic.Position=UDim2.new(0,8,0.5,-(CFG.BTN_HEIGHT-12)/2)
    local tx=Instance.new("TextLabel",b)
    tx.BackgroundTransparency=1;tx.Position=UDim2.new(0,CFG.BTN_HEIGHT+4,0,0)
    tx.Size=UDim2.new(1,-(CFG.BTN_HEIGHT+12),1,0)
    tx.Font=Enum.Font.GothamMedium;tx.TextSize=16;tx.TextXAlignment=Enum.TextXAlignment.Left
    tx.TextColor3=UI.TEXT;tx.Text=label
    local down,p0
    b.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            down=true;p0=i.Position;b.BackgroundColor3=Color3.fromRGB(22,30,24);st.Thickness=1.2;st.Color=UI.GREEN
        end
    end)
    b.InputEnded:Connect(function(i)
        if down and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
            down=false;b.BackgroundColor3=UI.BG_WINDOW;st.Thickness=0.6;st.Color=UI.MINT
            if (i.Position-p0).magnitude<7 and typeof(onClick)=="function" then task.spawn(onClick)end
        end
    end)
    return b
end

-- API
local UFO={}
function UFO:SetTitle(l,r)Title.Text=('<font color="#FFFFFF">%s</font> <font color="#00FF8C">%s</font>'):format(l or"UFO",r or"HUB X")end
function UFO:ShowRightHeader(t,i)RH_Icon.Image=i or CFG.ICON_DEF;RH_Text.Text=t or"";RH_Icon.Visible=true;RH_Text.Visible=true end
function UFO:AddButton(l,i,cb)return addButton(l,i,cb)end
function UFO:ToggleUI(on)if on==nil then on=not Window.Visible end;Window.Visible=on;getgenv().UFO_ISOPEN=on end
getgenv().UFO=UFO

-- Floating toggle (drag + click threshold)
do
    getgenv().UFO_ISOPEN = true

    local TG = Instance.new("ScreenGui", CoreGui)
    TG.Name = "UFOX_TOGGLE"
    TG.IgnoreGuiInset = true
    TG.DisplayOrder = 100001

    local B = Instance.new("ImageButton", TG)
    B.Name = "Toggle"
    B.Size = UDim2.fromOffset(64, 64)
    B.Position = UDim2.fromOffset(80, 200)
    B.BackgroundColor3 = Color3.new(0, 0, 0)
    B.BorderSizePixel = 0
    B.Image = CFG.TOGGLE_IMAGE
    B.AutoButtonColor = false
    B.Active = true           -- ช่วยเรื่องจับทัชบนมือถือ
    B.ZIndex = 999
    corner(B, 8)
    stroke(B, 2, UI.GREEN, 0)

    local function show() GUI.Enabled = true; Window.Visible = true; getgenv().UFO_ISOPEN = true end
    local function hide() Window.Visible = false; getgenv().UFO_ISOPEN = false end
    local function toggle() if getgenv().UFO_ISOPEN then hide() else show() end end

    -- แยก “คลิก” ออกจาก “ลาก” ด้วยระยะขยับ
    local dragging, startPos, startTouch, moved
    local DRAG_THRESHOLD = 8

    B.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            startTouch = i.Position
            startPos = Vector2.new(B.Position.X.Offset, B.Position.Y.Offset)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local delta = i.Position - startTouch
            if delta.Magnitude >= DRAG_THRESHOLD then
                moved = true
            end
            B.Position = UDim2.fromOffset(startPos.X + delta.X, startPos.Y + delta.Y)
        end
    end)

    B.InputEnded:Connect(function(i)
        if not dragging then return end
        dragging = false
        -- ถ้าแทบไม่ขยับ = นับเป็นคลิก (toggle)
        if (i.Position - startTouch).Magnitude < DRAG_THRESHOLD then
            toggle()
        end
    end)

    -- Hotkey
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == CFG.HOTKEY then toggle() end
    end)
end

--== DEMO ==
UFO:SetTitle("UFO","HUB X")
UFO:AddButton("Player","rbxassetid://112510739340023",function()UFO:ShowRightHeader("Player","rbxassetid://112510739340023")end)
UFO:AddButton("Quest","rbxassetid://72473476254744",function()UFO:ShowRightHeader("Quest","rbxassetid://72473476254744")end)
UFO:AddButton("Shop","rbxassetid://139824330037901",function()UFO:ShowRightHeader("Shop","rbxassetid://139824330037901")end)
print("✅ UFO HUB X Loaded Successfully (Ultra Clean Fix)")
