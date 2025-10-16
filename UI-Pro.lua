-- UFO HUB X • Clean Select + TopLeft Tag + Dual Scroll + Floating Toggle (PlayerGui)

-- PURGE
pcall(function()
    local PG = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    for _,n in ipairs({"UFO_HUB_X_UI","UFO_HUB_X_Toggle"}) do local g=PG:FindFirstChild(n); if g then g:Destroy() end end
end)

-- THEME
local GREEN=Color3.fromRGB(0,255,140)
local MINT=Color3.fromRGB(120,255,220)
local MINT_SOFT=Color3.fromRGB(90,210,190)
local BG_WINDOW=Color3.fromRGB(16,16,16)
local BG_HEADER=Color3.fromRGB(6,6,6)
local BG_PANEL=Color3.fromRGB(22,22,22)
local BG_INNER=Color3.fromRGB(18,18,18)
local TEXT_WHITE=Color3.fromRGB(235,235,235)
local DANGER_RED=Color3.fromRGB(200,40,40)

local WIN_W,WIN_H=640,360
local GAP_OUTER=14; local GAP_BETWEEN=12
local LEFT_RATIO=0.22; local RIGHT_RATIO=0.78

local IMG_UFO      = "rbxassetid://100650447103028"
local IMG_ALIEN_BG = "rbxassetid://83753985156201"
local ICON_PLAYER  = "rbxassetid://116976545042904"

local function corner(g,r)local c=Instance.new("UICorner",g); c.CornerRadius=UDim.new(0,r or 10); return c end
local function stroke(g,t,c,tr)local s=Instance.new("UIStroke",g); s.Thickness=t or 1; s.Color=c or MINT; s.Transparency=tr or 0.35; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.LineJoinMode=Enum.LineJoinMode.Round; return s end
local function gradient(g,c1,c2,r)local gr=Instance.new("UIGradient",g); gr.Color=ColorSequence.new(c1,c2); gr.Rotation=r or 0; return gr end

local Players=game:GetService("Players"); local LP=Players.LocalPlayer
local PG=LP:WaitForChild("PlayerGui")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local RunS=game:GetService("RunService")

-- ROOT
local GUI=Instance.new("ScreenGui")
GUI.Name="UFO_HUB_X_UI"; GUI.IgnoreGuiInset=true; GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn=false; GUI.DisplayOrder=100000; GUI.Parent=PG

-- WINDOW
local Window=Instance.new("Frame",GUI)
Window.AnchorPoint=Vector2.new(0.5,0.5); Window.Position=UDim2.new(0.5,0,0.5,0)
Window.Size=UDim2.fromOffset(WIN_W,WIN_H); Window.BackgroundColor3=BG_WINDOW; Window.BorderSizePixel=0
corner(Window,12); stroke(Window,3,GREEN,0)

-- Glow
do local Glow=Instance.new("ImageLabel",Window)
Glow.BackgroundTransparency=1; Glow.AnchorPoint=Vector2.new(0.5,0.5)
Glow.Position=UDim2.new(0.5,0,0.5,0); Glow.Size=UDim2.new(1.07,0,1.09,0)
Glow.Image="rbxassetid://5028857084"; Glow.ImageColor3=GREEN; Glow.ImageTransparency=0.78
Glow.ScaleType=Enum.ScaleType.Slice; Glow.SliceCenter=Rect.new(24,24,276,276); Glow.ZIndex=0 end

-- Autoscale
local UIScale=Instance.new("UIScale",Window)
local function fit() local cam=workspace.CurrentCamera; local v=(cam and cam.ViewportSize) or Vector2.new(1280,720)
    UIScale.Scale=math.clamp(math.min(v.X/860,v.Y/540),0.72,1.0) end
fit(); RunS.RenderStepped:Connect(fit)

-- HEADER
local Header=Instance.new("Frame",Window)
Header.Size=UDim2.new(1,0,0,46); Header.BackgroundColor3=BG_HEADER; Header.BorderSizePixel=0
corner(Header,12); gradient(Header,Color3.fromRGB(10,10,10),Color3.fromRGB(0,0,0),0)

local HeadAccent=Instance.new("Frame",Header)
HeadAccent.AnchorPoint=Vector2.new(0.5,1); HeadAccent.Position=UDim2.new(0.5,0,1,0)
HeadAccent.Size=UDim2.new(1,-20,0,1); HeadAccent.BackgroundColor3=MINT; HeadAccent.BackgroundTransparency=0.35

-- เอา "จุดเขียวเล็กๆ" ออก (ไม่มีการสร้าง Dot แล้ว)

local BtnClose=Instance.new("TextButton",Header)
BtnClose.Size=UDim2.new(0,24,0,24); BtnClose.Position=UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3=DANGER_RED; BtnClose.Text="X"; BtnClose.Font=Enum.Font.GothamBold
BtnClose.TextSize=13; BtnClose.TextColor3=Color3.new(1,1,1); corner(BtnClose,6); stroke(BtnClose,1,Color3.fromRGB(255,0,0),0.1)

-- UFO + Title
do
    local UFO=Instance.new("ImageLabel",Window)
    UFO.BackgroundTransparency=1; UFO.Image=IMG_UFO
    UFO.Size=UDim2.new(0,168,0,168); UFO.AnchorPoint=Vector2.new(0.5,1); UFO.Position=UDim2.new(0.5,0,0,84); UFO.ZIndex=60
    local Halo=Instance.new("ImageLabel",Window)
    Halo.BackgroundTransparency=1; Halo.AnchorPoint=Vector2.new(0.5,0)
    Halo.Position=UDim2.new(0.5,0,0,0); Halo.Size=UDim2.new(0,200,0,60)
    Halo.Image="rbxassetid://5028857084"; Halo.ImageColor3=MINT_SOFT; Halo.ImageTransparency=0.72; Halo.ZIndex=50
    local Title=Instance.new("TextLabel",Header)
    Title.BackgroundTransparency=1; Title.AnchorPoint=Vector2.new(0.5,0)
    Title.Position=UDim2.new(0.5,0,0,8); Title.Size=UDim2.new(0.8,0,0,36)
    Title.Font=Enum.Font.GothamBold; Title.RichText=true; Title.TextScaled=true
    Title.Text='<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'; Title.TextColor3=TEXT_WHITE; Title.ZIndex=61
end

-- Drag window + block camera
do
    local dragging,start,startPos
    local function block(on)
        local name="UFO_BlockLook_Window"
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
            Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- BODY
local Body=Instance.new("Frame",Window)
Body.BackgroundTransparency=1; Body.Position=UDim2.new(0,0,0,46); Body.Size=UDim2.new(1,0,1,-46)

local Inner=Instance.new("Frame",Body)
Inner.BackgroundColor3=BG_INNER; Inner.BorderSizePixel=0
Inner.Position=UDim2.new(0,8,0,8); Inner.Size=UDim2.new(1,-16,1,-16); corner(Inner,12)

local Content=Instance.new("Frame",Body)
Content.BackgroundColor3=BG_PANEL; Content.Position=UDim2.new(0,GAP_OUTER,0,GAP_OUTER)
Content.Size=UDim2.new(1,-GAP_OUTER*2,1,-GAP_OUTER*2); corner(Content,12); stroke(Content,0.5,MINT,0.35)

local Columns=Instance.new("Frame",Content)
Columns.BackgroundTransparency=1; Columns.Position=UDim2.new(0,8,0,8); Columns.Size=UDim2.new(1,-16,1,-16)

-- LEFT
local Left=Instance.new("Frame",Columns)
Left.BackgroundColor3=Color3.fromRGB(16,16,16); Left.Size=UDim2.new(LEFT_RATIO,-GAP_BETWEEN/2,1,0)
Left.ClipsDescendants=true; corner(Left,10); stroke(Left,1.2,GREEN,0); stroke(Left,0.45,MINT,0.35)

-- RIGHT
local Right=Instance.new("Frame",Columns)
Right.BackgroundColor3=Color3.fromRGB(16,16,16)
Right.Position=UDim2.new(LEFT_RATIO,GAP_BETWEEN,0,0)
Right.Size=UDim2.new(RIGHT_RATIO,-GAP_BETWEEN/2,1,0)
Right.ClipsDescendants=true; corner(Right,10); stroke(Right,1.2,GREEN,0); stroke(Right,0.45,MINT,0.35)

-- BG fixed (ไม่เลื่อน)
local RightBG=Instance.new("ImageLabel",Right)
RightBG.BackgroundTransparency=1; RightBG.Image=IMG_ALIEN_BG
RightBG.Size=UDim2.fromScale(1,1); RightBG.ScaleType=Enum.ScaleType.Fit; RightBG.ZIndex=1

-- SCROLLS (ซ้าย/ขวา)
local function attachScroll(host)
    local sf=Instance.new("ScrollingFrame",host)
    sf.Name="Scroll"; sf.Size=UDim2.fromScale(1,1); sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollingDirection=Enum.ScrollingDirection.Y; sf.AutomaticCanvasSize=Enum.AutomaticSize.Y; sf.CanvasSize=UDim2.new()
    sf.ScrollBarThickness=6; sf.ScrollBarImageTransparency=1
    local pad=Instance.new("UIPadding",sf); pad.PaddingTop=UDim.new(0,8); pad.PaddingBottom=UDim.new(0,8); pad.PaddingLeft=UDim.new(0,8); pad.PaddingRight=UDim.new(0,8)
    local list=Instance.new("UIListLayout",sf); list.Padding=UDim.new(0,8); list.SortOrder=Enum.SortOrder.LayoutOrder
    return sf
end
local LeftScroll=attachScroll(Left)
local RightScroll=attachScroll(Right); RightScroll.ZIndex=2  -- เนื้อหาขวาที่เลื่อน

-- ===== “TAG” มุมซ้ายบนของกรอบขวา (ไม่มีกรอบ/เอฟเฟกต์) =====
local TopTagIcon=Instance.new("ImageLabel",Right)
TopTagIcon.BackgroundTransparency=1; TopTagIcon.Image=ICON_PLAYER
TopTagIcon.Size=UDim2.fromOffset(32,32); TopTagIcon.Position=UDim2.new(0,16,0,12)
TopTagIcon.Visible=false; TopTagIcon.ZIndex=3

local TopTagText=Instance.new("TextLabel",Right)
TopTagText.BackgroundTransparency=1; TopTagText.Position=UDim2.new(0,16+32+6,0,12)
TopTagText.Size=UDim2.new(0,200,0,32); TopTagText.Font=Enum.Font.GothamMedium
TopTagText.TextSize=16; TopTagText.TextXAlignment=Enum.TextXAlignment.Left; TopTagText.TextColor3=TEXT_WHITE
TopTagText.Text="Player"; TopTagText.Visible=false; TopTagText.ZIndex=3

-- ===== ปุ่ม PLAYER (ซ้าย) — เอฟเฟกต์แบบไม่บังไอคอน/ตัวหนังสือ =====
local BTN_H=44
local BtnPlayer=Instance.new("TextButton",LeftScroll)
BtnPlayer.Name="Btn_Player"; BtnPlayer.Size=UDim2.new(1,0,0,BTN_H)
BtnPlayer.BackgroundColor3=BG_WINDOW; BtnPlayer.Text=""; corner(BtnPlayer,8)
local BtnStroke=stroke(BtnPlayer,1,MINT,0.35)  -- ใช้เส้นขอบเป็นหลัก

local PIcon=Instance.new("ImageLabel",BtnPlayer)
PIcon.BackgroundTransparency=1; PIcon.Image=ICON_PLAYER
PIcon.Size=UDim2.fromOffset(BTN_H-10,BTN_H-10); PIcon.Position=UDim2.new(0,8,0.5,-(BTN_H-10)/2)

local PText=Instance.new("TextLabel",BtnPlayer)
PText.BackgroundTransparency=1; PText.Position=UDim2.new(0,BTN_H+4,0,0)
PText.Size=UDim2.new(1,-(BTN_H+12),1,0); PText.Font=Enum.Font.GothamMedium
PText.TextSize=16; PText.TextXAlignment=Enum.TextXAlignment.Left; PText.TextColor3=TEXT_WHITE
PText.Text="Player"

-- ฟังก์ชันสถานะ Active: เปลี่ยน "ขอบ" + พื้นจางเล็กน้อย (ไม่ทับองค์ประกอบ)
local function setBtnActive(on)
    if on then
        BtnPlayer.BackgroundColor3 = Color3.fromRGB(22,30,24)
        BtnStroke.Color = GREEN; BtnStroke.Thickness = 2; BtnStroke.Transparency = 0
    else
        BtnPlayer.BackgroundColor3 = BG_WINDOW
        BtnStroke.Color = MINT; BtnStroke.Thickness = 1; BtnStroke.Transparency = 0.35
    end
end
setBtnActive(false)

-- คลิกแล้ว: ทำ Active + โชว์ TopTag (ไม่มีการ์ด/กรอบเพิ่ม)
BtnPlayer.MouseButton1Click:Connect(function()
    setBtnActive(true)
    TopTagIcon.Image = ICON_PLAYER
    TopTagText.Text = "Player"
    TopTagIcon.Visible = true
    TopTagText.Visible = true
end)

-- ===== ปุ่ม MAIN (หน้าหลัก) =====
local BTN_H=44
local BtnMain=Instance.new("TextButton",LeftScroll)
BtnMain.Name="Btn_Main"; BtnMain.Size=UDim2.new(1,0,0,BTN_H)
BtnMain.BackgroundColor3=BG_WINDOW; BtnMain.Text=""; corner(BtnMain,8)
local BtnStroke2=stroke(BtnMain,1,MINT,0.35)

local MIcon=Instance.new("ImageLabel",BtnMain)
MIcon.BackgroundTransparency=1; MIcon.Image="rbxassetid://134323882016779"
MIcon.Size=UDim2.fromOffset(BTN_H-10,BTN_H-10); MIcon.Position=UDim2.new(0,8,0.5,-(BTN_H-10)/2)

local MText=Instance.new("TextLabel",BtnMain)
MText.BackgroundTransparency=1; MText.Position=UDim2.new(0,BTN_H+4,0,0)
MText.Size=UDim2.new(1,-(BTN_H+12),1,0); MText.Font=Enum.Font.GothamMedium
MText.TextSize=16; MText.TextXAlignment=Enum.TextXAlignment.Left; MText.TextColor3=TEXT_WHITE
MText.Text="Main"

-- เอฟเฟกต์ Active แบบเดียวกับ Player
local function setBtnMainActive(on)
    if on then
        BtnMain.BackgroundColor3 = Color3.fromRGB(22,30,24)
        BtnStroke2.Color = GREEN; BtnStroke2.Thickness = 2; BtnStroke2.Transparency = 0
    else
        BtnMain.BackgroundColor3 = BG_WINDOW
        BtnStroke2.Color = MINT; BtnStroke2.Thickness = 1; BtnStroke2.Transparency = 0.35
    end
end
setBtnMainActive(false)

-- ===== ปุ่ม QUEST (ขวา Main/Player) =====
local BTN_H=44
local BtnQuest=Instance.new("TextButton",LeftScroll)
BtnQuest.Name="Btn_Quest"; BtnQuest.Size=UDim2.new(1,0,0,BTN_H)
BtnQuest.BackgroundColor3=BG_WINDOW; BtnQuest.Text=""
corner(BtnQuest,8)
local BtnQuestStroke=stroke(BtnQuest,1,MINT,0.35)

local QIcon=Instance.new("ImageLabel",BtnQuest)
QIcon.BackgroundTransparency=1
QIcon.Image="rbxassetid://72473476254744"
QIcon.Size=UDim2.fromOffset(BTN_H-10,BTN_H-10)
QIcon.Position=UDim2.new(0,8,0.5,-(BTN_H-10)/2)

local QText=Instance.new("TextLabel",BtnQuest)
QText.BackgroundTransparency=1
QText.Position=UDim2.new(0,BTN_H+4,0,0)
QText.Size=UDim2.new(1,-(BTN_H+12),1,0)
QText.Font=Enum.Font.GothamMedium
QText.TextSize=16
QText.TextXAlignment=Enum.TextXAlignment.Left
QText.TextColor3=TEXT_WHITE
QText.Text="Quest"

-- ฟังก์ชันสถานะปุ่ม Quest
local function setBtnQuestActive(on)
    if on then
        BtnQuest.BackgroundColor3 = Color3.fromRGB(22,30,24)
        BtnQuestStroke.Color = GREEN
        BtnQuestStroke.Thickness = 2
        BtnQuestStroke.Transparency = 0
    else
        BtnQuest.BackgroundColor3 = BG_WINDOW
        BtnQuestStroke.Color = MINT
        BtnQuestStroke.Thickness = 1
        BtnQuestStroke.Transparency = 0.35
    end
end
setBtnQuestActive(false)

-- ===== ปุ่ม SHOP (ซ้าย) =====
local BTN_H=44
local BtnShop=Instance.new("TextButton",LeftScroll)
BtnShop.Name="Btn_Shop"
BtnShop.Size=UDim2.new(1,0,0,BTN_H)
BtnShop.BackgroundColor3=BG_WINDOW
BtnShop.Text=""
corner(BtnShop,8)
local BtnShopStroke=stroke(BtnShop,1,MINT,0.35)

local SIcon=Instance.new("ImageLabel",BtnShop)
SIcon.BackgroundTransparency=1
SIcon.Image="rbxassetid://139824330037901"
SIcon.Size=UDim2.fromOffset(BTN_H-10,BTN_H-10)
SIcon.Position=UDim2.new(0,8,0.5,-(BTN_H-10)/2)

local SText=Instance.new("TextLabel",BtnShop)
SText.BackgroundTransparency=1
SText.Position=UDim2.new(0,BTN_H+4,0,0)
SText.Size=UDim2.new(1,-(BTN_H+12),1,0)
SText.Font=Enum.Font.GothamMedium
SText.TextSize=16
SText.TextXAlignment=Enum.TextXAlignment.Left
SText.TextColor3=TEXT_WHITE
SText.Text="Shop"

-- ===== ฟังก์ชัน Active ของปุ่ม Shop =====
local function setBtnShopActive(on)
    if on then
        BtnShop.BackgroundColor3 = Color3.fromRGB(22,30,24)
        BtnShopStroke.Color = GREEN
        BtnShopStroke.Thickness = 2
        BtnShopStroke.Transparency = 0
    else
        BtnShop.BackgroundColor3 = BG_WINDOW
        BtnShopStroke.Color = MINT
        BtnShopStroke.Thickness = 1
        BtnShopStroke.Transparency = 0.35
    end
end
setBtnShopActive(false)

-- ===== ปุ่ม SERVER =====
local BTN_H=44
local BtnServer=Instance.new("TextButton",LeftScroll)
BtnServer.Name="Btn_Server"
BtnServer.Size=UDim2.new(1,0,0,BTN_H)
BtnServer.BackgroundColor3=BG_WINDOW
BtnServer.Text=""
corner(BtnServer,8)
local BtnServerStroke=stroke(BtnServer,1,MINT,0.35)

local ServerIcon=Instance.new("ImageLabel",BtnServer)
ServerIcon.BackgroundTransparency=1
ServerIcon.Image="rbxassetid://77839913086023"
ServerIcon.Size=UDim2.fromOffset(BTN_H-10,BTN_H-10)
ServerIcon.Position=UDim2.new(0,8,0.5,-(BTN_H-10)/2)

local ServerText=Instance.new("TextLabel",BtnServer)
ServerText.BackgroundTransparency=1
ServerText.Position=UDim2.new(0,BTN_H+4,0,0)
ServerText.Size=UDim2.new(1,-(BTN_H+12),1,0)
ServerText.Font=Enum.Font.GothamMedium
ServerText.TextSize=16
ServerText.TextXAlignment=Enum.TextXAlignment.Left
ServerText.TextColor3=TEXT_WHITE
ServerText.Text="Server"

-- เอฟเฟกต์ Active
local function setBtnServerActive(on)
	if on then
		BtnServer.BackgroundColor3 = Color3.fromRGB(22,30,24)
		BtnServerStroke.Color = GREEN
		BtnServerStroke.Thickness = 2
		BtnServerStroke.Transparency = 0
	else
		BtnServer.BackgroundColor3 = BG_WINDOW
		BtnServerStroke.Color = MINT
		BtnServerStroke.Thickness = 1
		BtnServerStroke.Transparency = 0.35
	end
end
setBtnServerActive(false)

-- ===== ปุ่ม UPDATE =====
local BTN_H=44
local BtnUpdate=Instance.new("TextButton",LeftScroll)
BtnUpdate.Name="Btn_Update"
BtnUpdate.Size=UDim2.new(1,0,0,BTN_H)
BtnUpdate.BackgroundColor3=BG_WINDOW
BtnUpdate.Text=""
corner(BtnUpdate,8)
local BtnUpdateStroke=stroke(BtnUpdate,1,MINT,0.35)

local UpdateIcon=Instance.new("ImageLabel",BtnUpdate)
UpdateIcon.BackgroundTransparency=1
UpdateIcon.Image="rbxassetid://134419329246667" -- ไอคอน Update
UpdateIcon.Size=UDim2.fromOffset(BTN_H-10,BTN_H-10)
UpdateIcon.Position=UDim2.new(0,8,0.5,-(BTN_H-10)/2)

local UpdateText=Instance.new("TextLabel",BtnUpdate)
UpdateText.BackgroundTransparency=1
UpdateText.Position=UDim2.new(0,BTN_H+4,0,0)
UpdateText.Size=UDim2.new(1,-(BTN_H+12),1,0)
UpdateText.Font=Enum.Font.GothamMedium
UpdateText.TextSize=16
UpdateText.TextXAlignment=Enum.TextXAlignment.Left
UpdateText.TextColor3=TEXT_WHITE
UpdateText.Text="Update"

-- เอฟเฟกต์ Active (เหมือน Server ทุกอย่าง)
local function setBtnUpdateActive(on)
	if on then
		BtnUpdate.BackgroundColor3 = Color3.fromRGB(22,30,24)
		BtnUpdateStroke.Color = GREEN
		BtnUpdateStroke.Thickness = 2
		BtnUpdateStroke.Transparency = 0
	else
		BtnUpdate.BackgroundColor3 = BG_WINDOW
		BtnUpdateStroke.Color = MINT
		BtnUpdateStroke.Thickness = 1
		BtnUpdateStroke.Transparency = 0.35
	end
end
setBtnUpdateActive(false)

-- ===== ปุ่ม SETTINGS =====
local BTN_H = 44
local BtnSettings = Instance.new("TextButton", LeftScroll)
BtnSettings.Name = "Btn_Settings"
BtnSettings.Size = UDim2.new(1, 0, 0, BTN_H)
BtnSettings.BackgroundColor3 = BG_WINDOW
BtnSettings.Text = ""
corner(BtnSettings, 8)
local BtnSettingsStroke = stroke(BtnSettings, 1, MINT, 0.35)

local SIcon = Instance.new("ImageLabel", BtnSettings)
SIcon.BackgroundTransparency = 1
SIcon.Image = "rbxassetid://72289858646360"
SIcon.Size = UDim2.fromOffset(BTN_H - 10, BTN_H - 10)
SIcon.Position = UDim2.new(0, 8, 0.5, -(BTN_H - 10) / 2)

local SText = Instance.new("TextLabel", BtnSettings)
SText.BackgroundTransparency = 1
SText.Position = UDim2.new(0, BTN_H + 4, 0, 0)
SText.Size = UDim2.new(1, -(BTN_H + 12), 1, 0)
SText.Font = Enum.Font.GothamMedium
SText.TextSize = 16
SText.TextXAlignment = Enum.TextXAlignment.Left
SText.TextColor3 = TEXT_WHITE
SText.Text = "Settings"

-- ฟังก์ชันตั้งค่า Active
local function setBtnSettingsActive(on)
    if on then
        BtnSettings.BackgroundColor3 = Color3.fromRGB(22, 30, 24)
        BtnSettingsStroke.Color = GREEN
        BtnSettingsStroke.Thickness = 2
        BtnSettingsStroke.Transparency = 0
    else
        BtnSettings.BackgroundColor3 = BG_WINDOW
        BtnSettingsStroke.Color = MINT
        BtnSettingsStroke.Thickness = 1
        BtnSettingsStroke.Transparency = 0.35
    end
end
setBtnSettingsActive(false)

-- ========== THEME: core colors ==========
local THEME = {
	GREEN = {
		ACCENT = Color3.fromRGB(60,255,140),
		NEON   = Color3.fromRGB(0,255,120),
		BORDER = Color3.fromRGB(30,180,120),
	},
	RED = {
		ACCENT = Color3.fromRGB(255,70,70),
		NEON   = Color3.fromRGB(255,30,30),
		BORDER = Color3.fromRGB(200,40,40),
	},
	GOLD = {
		ACCENT = Color3.fromRGB(255,210,70),
		NEON   = Color3.fromRGB(255,190,40),
		BORDER = Color3.fromRGB(200,150,40),
	}
}

-- ========== find window & content ==========
local CoreGui = game:GetService("CoreGui")
local GUI = CoreGui:WaitForChild("UFO_HUB_X_UI")
local Window = GUI:WaitForChild("Window") or GUI:FindFirstChildWhichIsA("Frame")
local Content = Window:FindFirstChild("Content") or Window:FindFirstChild("RightPane") or Window

-- ===== helper =====
local function corner(p,r) local u=Instance.new("UICorner",p) u.CornerRadius=UDim.new(0,r) return u end
local function stroke(p,th,color,alpha)
	local s=Instance.new("UIStroke",p)
	s.Thickness=th; s.Color=color; s.Transparency=alpha or 0
	return s
end

-- ========== ROW: UI COLOR SYSTEM (ตำแหน่ง/ขนาดให้เหมือนภาพ) ==========
-- NOTE: แถวนี้จะ “โชว์เฉพาะตอนหน้า Settings” เพราะเราเปิด/ปิดด้วย __UFO_ShowSettings แล้ว
local row = Instance.new("Frame")
row.Name = "Row_UIColorSystem"
row.Parent = Content
row.BackgroundColor3 = Color3.fromRGB(10,10,10)
row.Size = UDim2.new(0, 820, 0, 44)             -- ความยาว “เท่ากล่องขาวยาว” ในภาพ
row.Position = UDim2.new(0, 70, 0, 260)          -- ย้ายตัวเลขได้เล็กน้อยถ้าไม่ตรงหน้าจอนาย
row.BorderSizePixel = 0
corner(row, 8)
stroke(row, 1.5, THEME.GREEN.BORDER, 0)          -- default = เขียว

-- Title แดง (ช่องซ้ายบอกชื่อฟีเจอร์ + ไอคอน)
local title = Instance.new("Frame", row)
title.BackgroundColor3 = THEME.RED.NEON
title.BorderSizePixel = 0
title.Position = UDim2.new(0,0,0,0)
title.Size = UDim2.new(0, 120, 1, 0)
corner(title, 8)

local icon = Instance.new("ImageLabel", title)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://128875018380566"      -- ไอคอนเขียว (default แสดงธีมปัจจุบัน)
icon.Size = UDim2.fromOffset(24,24)
icon.Position = UDim2.new(0,10,0.5,-12)

local titleText = Instance.new("TextLabel", title)
titleText.BackgroundTransparency = 1
titleText.Text = "UI COLOR SYSTEM"
titleText.Font = Enum.Font.GothamMedium
titleText.TextSize = 14
titleText.TextColor3 = Color3.fromRGB(0,0,0)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Position = UDim2.new(0, 40, 0, 0)
titleText.Size = UDim2.new(1, -44, 1, 0)

-- กล่องหลัก (พื้นดำขอบเขียว) สำหรับรายละเอียด/สวิตช์
local body = Instance.new("Frame", row)
body.BackgroundTransparency = 1
body.Size = UDim2.new(1, -130, 1, 0)
body.Position = UDim2.new(0, 130, 0, 0)

-- สวิตช์เปิด/ปิด (ใช้รูปที่นายกำหนด)
local switch = Instance.new("ImageButton", body)
switch.Name = "Switch"
switch.BackgroundTransparency = 1
switch.Image = "rbxassetid://102713893228795"    -- ON
switch.Size = UDim2.fromOffset(70, 28)
switch.Position = UDim2.new(1, -82, 0.5, -14)

local switchState = true
local function setSwitch(on)
	switchState = on and true or false
	switch.Image = on and "rbxassetid://102713893228795" or "rbxassetid://136780249528523"
end
setSwitch(true)

-- ปุ่มเปิด “หน้าต่างเลือกธีม” (แบบดรอปดาวน์)
local openPicker = Instance.new("TextButton", body)
openPicker.Text = "Select Theme"
openPicker.Font = Enum.Font.GothamSemibold
openPicker.TextSize = 14
openPicker.TextColor3 = Color3.fromRGB(200,255,220)
openPicker.BackgroundColor3 = Color3.fromRGB(15,15,15)
openPicker.AutoButtonColor = false
openPicker.Size = UDim2.new(0, 160, 0, 32)
openPicker.Position = UDim2.new(0, 10, 0.5, -16)
corner(openPicker, 8)
stroke(openPicker, 1, THEME.GREEN.BORDER, 0.2)

-- ========== POPUP: เลือก Green / Red / Gold ==========
local popup = Instance.new("Frame", Content)
popup.Visible = false
popup.ZIndex = 10
popup.BackgroundColor3 = Color3.fromRGB(8,8,8)
popup.Size = UDim2.new(0, 240, 0, 130)
popup.Position = UDim2.new(0, row.Position.X.Offset + 130, 0, row.Position.Y.Offset + 48)
corner(popup, 10)
stroke(popup, 1.5, THEME.GREEN.BORDER, 0)

local function makeItem(txt, color, y, iconId)
	local b = Instance.new("TextButton", popup)
	b.Text = txt
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.TextColor3 = Color3.fromRGB(230,230,230)
	b.BackgroundColor3 = Color3.fromRGB(18,18,18)
	b.AutoButtonColor = false
	b.Size = UDim2.new(1, -16, 0, 34)
	b.Position = UDim2.new(0, 8, 0, y)
	corner(b, 8)
	stroke(b, 1, color.BORDER, 0.2)

	local ic = Instance.new("ImageLabel", b)
	ic.BackgroundTransparency = 1
	ic.Image = iconId
	ic.Size = UDim2.fromOffset(20,20)
	ic.Position = UDim2.new(0, 10, 0.5, -10)

	local t = Instance.new("TextLabel", b)
	t.BackgroundTransparency = 1
	t.Text = txt
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 14
	t.TextColor3 = color.ACCENT
	t.Position = UDim2.new(0, 40, 0, 0)
	t.Size = UDim2.new(1, -40, 1, 0)

	return b
end

local itemGreen = makeItem("Green", THEME.GREEN, 8,  "rbxassetid://128875018380566")
local itemRed   = makeItem("Red",   THEME.RED,   46, "rbxassetid://105482197505036")
local itemGold  = makeItem("Gold",  THEME.GOLD,  84, "rbxassetid://126750100387992")

-- ========== APPLY THEME ==========
local function applyTheme(palette)
	-- สีขอบหลักของแถว
	row.UIStroke.Color     = palette.BORDER
	-- ปุ่ม Select
	openPicker.UIStroke.Color = palette.BORDER
	openPicker.TextColor3      = palette.ACCENT
	-- (ถ้านายมีของอื่น ๆ เช่น เส้นกรอบใหญ่ใน Settings ให้เปลี่ยนตรงนี้เพิ่มได้)
end
applyTheme(THEME.GREEN)

-- ========== EVENTS ==========
openPicker.MouseButton1Click:Connect(function()
	if not switchState then return end           -- ปิดอยู่ = ห้ามเปิดเลือกสี
	popup.Visible = not popup.Visible
end)

local function choose(palette, whichIcon)
	applyTheme(palette)
	icon.Image = whichIcon
	popup.Visible = false
end

itemGreen.MouseButton1Click:Connect(function() choose(THEME.GREEN,"rbxassetid://128875018380566") end)
itemRed.MouseButton1Click:Connect(function()   choose(THEME.RED,  "rbxassetid://105482197505036") end)
itemGold.MouseButton1Click:Connect(function()  choose(THEME.GOLD, "rbxassetid://126750100387992") end)

switch.MouseButton1Click:Connect(function()
	setSwitch(not switchState)
	popup.Visible = false
end)

-- ปิด popup เมื่อคลิกที่อื่น
Content.InputBegan:Connect(function(i)
	if popup.Visible and i.UserInputType == Enum.UserInputType.MouseButton1 then
		popup.Visible = false
	end
end)

-- ===== RESET + ACTIVATE (เวอร์ชันกันหลงสถานะ) =====
local function setAllInactive()
    setBtnMainActive(false)
    setBtnActive(false)          -- player
    setBtnQuestActive(false)
    setBtnShopActive(false)
    setBtnSettingsActive(false)
    setBtnServerActive(false)
	setBtnUpdateActive(false)
end

local function activate(which)
    setAllInactive()

    if which == "main" then
        setBtnMainActive(true)
        TopTagIcon.Image = "rbxassetid://134323882016779"
        TopTagText.Text  = "Main"

    elseif which == "player" then
        setBtnActive(true)
        TopTagIcon.Image = ICON_PLAYER
        TopTagText.Text  = "Player"

    elseif which == "quest" then
        setBtnQuestActive(true)
        TopTagIcon.Image = "rbxassetid://72473476254744"
        TopTagText.Text  = "Quest"

    elseif which == "settings" then
    setBtnSettingsActive(true)
    TopTagIcon.Image = "rbxassetid://72289858646360"
    TopTagText.Text  = "Settings"
    createThemeController() -- << เรียกสร้างแถว + โมดัลเฉพาะตอนเปิด Settings

    elseif which == "settings" then
        setBtnSettingsActive(true)
        TopTagIcon.Image = "rbxassetid://72289858646360"
        TopTagText.Text  = "Settings"

    elseif which == "server" then
        setBtnServerActive(true)
        TopTagIcon.Image = "rbxassetid://77839913086023"
        TopTagText.Text  = "Server"

	elseif which == "update" then
	setBtnUpdateActive(true)
	TopTagIcon.Image = "rbxassetid://134419329246667"
	TopTagText.Text  = "Update"
    end

	-- ก่อนจบ if ของแต่ละเคส
if which == "settings" then
    _G.__UFO_ShowSettings(true)   -- แสดงกรอบใหญ่
else
    _G.__UFO_ShowSettings(false)  -- ซ่อนกรอบใหญ่เมื่อไปหน้าอื่น
	end

    TopTagIcon.Visible = true
    TopTagText.Visible = true
end

-- ===== คลิกปุ่ม =====
BtnMain.MouseButton1Click:Connect(function()   activate("main")      end)
BtnPlayer.MouseButton1Click:Connect(function() activate("player")    end)
BtnQuest.MouseButton1Click:Connect(function()  activate("quest")     end)
BtnShop.MouseButton1Click:Connect(function()   activate("shop")      end)
BtnServer.MouseButton1Click:Connect(function() activate("server")     end)
BtnUpdate.MouseButton1Click:Connect(function() activate("update")     end)
BtnSettings.MouseButton1Click:Connect(function() activate("settings") end)


-- ===== กำจัดเอฟเฟกต์ค้างตอนเลื่อน + ปิดสีขาวออโต้ =====
local UIS = game:GetService("UserInputService")

-- ปิด AutoButtonColor (กันวาบสีขาวของ Roblox)
for _,b in ipairs({BtnMain, BtnPlayer, BtnQuest, BtnShop, BtnServer, BtnSettings, BtnUpdate}) do
    if b and b:IsA("TextButton") then
        b.AutoButtonColor = false
    end
end

-- ตัวช่วย: แยก "แตะเพื่อกด" ออกจาก "เลื่อน"
local function hookTap(btn, onTap)
    local startPos = nil
    local movedTooFar = false
    local THRESH = 12 -- px: เกินนี้ถือว่าเลื่อน, ไม่ใช่กด

    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            startPos = i.Position
            movedTooFar = false
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if startPos and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
            local dx = (i.Position - startPos).X
            local dy = (i.Position - startPos).Y
            if math.abs(dx) > THRESH or math.abs(dy) > THRESH then
                movedTooFar = true -- กลายเป็นการเลื่อน
            end
        end
    end)

    btn.InputEnded:Connect(function(i)
        if startPos and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1) then
            local wasTap = not movedTooFar
            startPos = nil
            movedTooFar = false
            if wasTap then
                onTap()
            end
        end
    end)

    -- กันเผื่อหลุดเมาส์/นิ้วออกนอกปุ่มระหว่างลาก
    btn.MouseLeave:Connect(function()
        startPos = nil
        movedTooFar = false
    end)
end

-- ===== ผูกปุ่มใหม่ให้ทำงานเฉพาะ “แตะจริงๆ” เท่านั้น =====
hookTap(BtnMain,     function() activate("main")     end)
hookTap(BtnPlayer,   function() activate("player")   end)
hookTap(BtnQuest,    function() activate("quest")    end)
hookTap(BtnShop,     function() activate("shop")     end)
hookTap(BtnServer,   function() activate("server")   end)
hookTap(BtnUpdate,   function() activate("update")   end)
hookTap(BtnSettings, function() activate("settings") end)


-- BODY: Toggle Open/Close
local function showUI() GUI.Enabled=true; Window.Visible=true; getgenv().UFO_ISOPEN=true end
local function hideUI() Window.Visible=false; getgenv().UFO_ISOPEN=false end
getgenv().UFO_ISOPEN=true
BtnClose.MouseButton1Click:Connect(hideUI)

-- === Bridge: Show/Hide Settings window ===
_G.__UFO_ShowSettings = function(on)
    local CoreGui = game:GetService("CoreGui")
    local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
    if not gui then return end

    -- เปิด/ปิดหน้าต่างหลัก
    gui.Enabled = true
    local win = gui:FindFirstChildWhichIsA("Frame")
    if win then win.Visible = on end

    -- sync flag ให้ปุ่มลอย/RightShift ใช้ร่วมกันได้
    getgenv().UFO_ISOPEN = on and true or false
end

-- ปุ่มลอย (PlayerGui แยก)
local ToggleGui=Instance.new("ScreenGui")
ToggleGui.Name="UFO_HUB_X_Toggle"; ToggleGui.IgnoreGuiInset=true
ToggleGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ToggleGui.DisplayOrder=100001
ToggleGui.ResetOnSpawn=false; ToggleGui.Parent=PG

local ToggleBtn=Instance.new("ImageButton",ToggleGui)
ToggleBtn.Size=UDim2.fromOffset(64,64); ToggleBtn.Position=UDim2.fromOffset(80,200)
ToggleBtn.BackgroundColor3=Color3.fromRGB(0,0,0); ToggleBtn.BorderSizePixel=0; ToggleBtn.Image=IMG_ALIEN_BG
corner(ToggleBtn,8); local s=Instance.new("UIStroke",ToggleBtn); s.Thickness=2; s.Color=GREEN
ToggleBtn.MouseButton1Click:Connect(function() if getgenv().UFO_ISOPEN then hideUI() else showUI() end end)

-- ลากปุ่มลอย + block camera
do
    local dragging=false; local start; local startPos
    local function bindBlock(on)
        local name="UFO_BlockLook_Toggle"
        if on then
            CAS:BindActionAtPriority(name,function() return Enum.ContextActionResult.Sink end,false,9000,
                Enum.UserInputType.MouseMovement,Enum.UserInputType.Touch,Enum.UserInputType.MouseButton1)
        else pcall(function() CAS:UnbindAction(name) end) end
    end
    ToggleBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Vector2.new(ToggleBtn.Position.X.Offset, ToggleBtn.Position.Y.Offset); bindBlock(true)
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; bindBlock(false) end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start; ToggleBtn.Position=UDim2.fromOffset(startPos.X+d.X,startPos.Y+d.Y)
        end
    end)
end

-- Hotkeys (ถ้ามีคีย์บอร์ด)
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightShift or i.KeyCode==Enum.KeyCode.T then
        if getgenv().UFO_ISOPEN then hideUI() else showUI() end
    end
end)
