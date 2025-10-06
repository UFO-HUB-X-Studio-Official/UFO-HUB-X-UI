--[[
  UFO HUB X Pro — PACK #1: Secure Loader + Global Config
  Single-file, ready-to-paste. (c) UFO-HUB-X Studio
  Responsibilities:
    - Anti-duplicate loader
    - Global Config (theme, servers, TTL, assets, hotkeys)
    - Key cache skeleton (_G/shared) with 48h TTL
    - Lightweight Event Bus
    - Boot Splash (logo + tween) + protected GUI attach
    - Hooks to show Key UI / Download UI / Launch MAIN (to be filled next packs)
]]

--========== SAFETY GUARDS ==========
local ok, err = pcall(function()
    -- Prevent double-load
    if rawget(_G, "UFOX_LOADER_ACTIVE") or (rawget(shared, "UFOX") and shared.UFOX.__active) then
        return  -- Already loaded; silently skip
    end
    _G.UFOX_LOADER_ACTIVE = true

    --========== SERVICES ==========
    local Players           = game:GetService("Players")
    local RunService        = game:GetService("RunService")
    local TweenService      = game:GetService("TweenService")
    local HttpService       = game:GetService("HttpService")
    local CoreGui           = game:GetService("CoreGui")
    local StarterGui        = game:GetService("StarterGui")
    local LocalPlayer       = Players.LocalPlayer

    --========== GLOBAL CONFIG ==========
    local UFOX = {
        VERSION = "Pro-0.1",
        THEME = {
            GREEN = Color3.fromRGB(0,255,140),
            BG    = Color3.fromRGB(16,16,16),
            FG    = Color3.fromRGB(230,230,230),
            RED   = Color3.fromRGB(255,64,64),
        },
        SERVERS = {
            PRIMARY = "https://ufo-hub-x-key-primary.example/",
            FAILOVER = {
                "https://ufo-hub-x-key-alt1.example/",
                "https://ufo-hub-x-key-alt2.example/",
            },
            TIMEOUT_SEC = 12,
        },
        KEY = {
            TTL_HOURS   = 48,
            CACHE_SCOPE = "per-uid",  -- per-uid/per-device planned
        },
        ASSETS = {
            LOGO_ID = "rbxassetid://112676905543996"; -- UFO logo (เปลี่ยนได้)
        },
        HOTKEYS = {
            TOGGLE_UI = Enum.KeyCode.RightControl,
        },
        FLAGS = {
            DEV_MODE = false,    -- true = ข้าม verify ชั่วคราว (dev เท่านั้น)
            QUIET    = false,    -- true = ลด log
        },
    }

    -- Expose config early
    shared.UFOX = shared.UFOX or {}
    for k,v in pairs(UFOX) do shared.UFOX[k] = v end
    shared.UFOX.__active = true

    --========== LIGHT LOGGER ==========
    local function log(...)
        if shared.UFOX.FLAGS and shared.UFOX.FLAGS.QUIET then return end
        print("[UFOX]", ...)
    end
    local function warnlog(...)
        warn("[UFOX]", ...)
    end
    local function notify(text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title="UFO HUB X Pro", Text=tostring(text), Duration=3})
        end)
        log(text)
    end

    --========== PROTECT GUI HELPERS ==========
    local function get_ui_parent()
        local okGetHui, hui = pcall(function()
            if gethui then return gethui() end
        end)
        if okGetHui and typeof(hui) == "Instance" then
            return hui
        end
        return CoreGui
    end

    local function protect_gui(g)
        pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(g)
            elseif get_hidden_gui or (gethui and gethui()) then
                -- some executors auto-protect under gethui
            end
        end)
    end

    --========== EVENT BUS ==========
    local Bus = Instance.new("BindableEvent")
    shared.UFOX.Bus = Bus
    function shared.UFOX.On(evt, fn)
        return Bus.Event:Connect(function(name, payload)
            if name == evt then
                pcall(fn, payload)
            end
        end)
    end
    function shared.UFOX.Emit(evt, payload)
        Bus:Fire(evt, payload)
    end

    --========== KEY CACHE SKELETON ==========
    shared.UFOX_STATE = shared.UFOX_STATE or {
        verified   = false,
        key        = nil,
        expires_at = 0,    -- os.time() when valid-until
        uid        = tostring(LocalPlayer and LocalPlayer.UserId or 0),
        place      = tostring(game and game.PlaceId or 0),
    }

    local function ttl_seconds()
        return math.floor((shared.UFOX.KEY.TTL_HOURS or 48) * 3600)
    end

    local function is_cache_valid()
        local st = shared.UFOX_STATE
        if not st or not st.verified then return false end
        return os.time() < (tonumber(st.expires_at) or 0)
    end

    local function set_verified(keyStr)
        local st = shared.UFOX_STATE
        st.verified = true
        st.key = keyStr or st.key
        st.expires_at = os.time() + ttl_seconds()
        -- mirror to _G (for compatibility withเก่าของโปรเจกต์)
        _G.UFO_SaveKeyState = {
            verified = st.verified,
            key = st.key,
            expires_at = st.expires_at,
            uid = st.uid,
            place = st.place,
        }
        log("Key verified; expires at:", st.expires_at)
    end

    local function clear_verification()
        local st = shared.UFOX_STATE
        st.verified = false
        st.expires_at = 0
        st.key = nil
        _G.UFO_SaveKeyState = nil
        log("Key cache cleared")
    end

    -- Import legacy cache if present
    pcall(function()
        if _G.UFO_SaveKeyState and type(_G.UFO_SaveKeyState)=="table" then
            local s = _G.UFO_SaveKeyState
            shared.UFOX_STATE.verified   = s.verified   or false
            shared.UFOX_STATE.key        = s.key        or nil
            shared.UFOX_STATE.expires_at = s.expires_at or 0
        end
    end)

    --========== SPLASH (BOOT) ==========
    local function create_splash()
        -- guard once
        if CoreGui:FindFirstChild("UFOX_Splash") then
            return CoreGui:FindFirstChild("UFOX_Splash")
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = "UFOX_Splash"
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 50000
        gui.ResetOnSpawn = false
        protect_gui(gui)
        gui.Parent = get_ui_parent()

        local bg = Instance.new("Frame")
        bg.Name = "Backdrop"
        bg.BackgroundColor3 = shared.UFOX.THEME.BG
        bg.BackgroundTransparency = 0.25
        bg.Size = UDim2.fromScale(1,1)
        bg.Parent = gui

        local logo = Instance.new("ImageLabel")
        logo.Name = "Logo"
        logo.BackgroundTransparency = 1
        logo.Image = shared.UFOX.ASSETS.LOGO_ID
        logo.Size = UDim2.fromOffset(256,256)
        logo.AnchorPoint = Vector2.new(0.5,0.5)
        logo.Position = UDim2.fromScale(0.5,0.5)
        logo.ImageTransparency = 1
        logo.Parent = gui

        -- subtle pop-in
        logo.Size = UDim2.fromOffset(230,230)
        TweenService:Create(logo, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(256,256), ImageTransparency = 0
        }):Play()

        return gui
    end

    local function destroy_splash(gui)
        if not gui or not gui.Parent then return end
        local logo = gui:FindFirstChild("Logo")
        local bg   = gui:FindFirstChild("Backdrop")
        pcall(function()
            if logo then
                TweenService:Create(logo, TweenInfo.new(0.25), {ImageTransparency = 1}):Play()
            end
            if bg then
                TweenService:Create(bg, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
            end
            task.delay(0.3, function()
                if gui and gui.Parent then
                    gui:Destroy()
                end
            end)
        end)
    end

    local splashGui = create_splash()

    --========== HOTKEY TOGGLE (wired later to UI root) ==========
    local uiRootRef = { ref = nil } -- จะชี้ไปที่ Main UI / Key UI root เมื่อมี
    local function set_ui_root(inst)
        uiRootRef.ref = inst
    end
    shared.UFOX.__set_ui_root = set_ui_root

    local inputConn
    local function bind_toggle()
        if inputConn then inputConn:Disconnect() end
        inputConn = game:GetService("UserInputService").InputBegan:Connect(function(io, gpe)
            if gpe then return end
            if io.KeyCode == shared.UFOX.HOTKEYS.TOGGLE_UI then
                local r = uiRootRef.ref
                if r and r:IsA("GuiBase2d") then
                    r.Enabled = not r.Enabled
                    notify(r.Enabled and "UI: ON" or "UI: OFF")
                end
            end
        end)
    end
    bind_toggle()

    --========== SERVER REQUEST (placeholder for next packs) ==========
    local function http_json(url, method, body, timeoutSec)
        -- We will fully implement in PACK #2 (failover/verify/getkey)
        -- For now, just a safe scaffold.
        local okReq, result = pcall(function()
            local req = (syn and syn.request) or (http and http.request) or request
            if not req then return nil, "No-request-fn" end
            local tmo = (timeoutSec or shared.UFOX.SERVERS.TIMEOUT_SEC or 12) * 1000
            local res = req({
                Url = url,
                Method = method or "GET",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body and HttpService:JSONEncode(body) or nil,
                Timeout = tmo,
            })
            return res
        end)
        if not okReq then
            return nil, "request-failed"
        end
        return result, nil
    end

    --========== FLOW HOOKS (UI stubs — will be replaced next packs) ==========
    local function show_key_ui()
        -- TEMP stub: emit event; real Key UI will attach and call __set_ui_root
        shared.UFOX.Emit("show_key_ui")
        notify("UFOX: Showing Key UI (stub) — แพ็กถัดไปจะได้ UI จริง")
    end

    local function show_download_ui()
        shared.UFOX.Emit("show_download_ui")
        notify("UFOX: Showing Download UI (stub)")
    end

    local function launch_main()
        shared.UFOX.Emit("launch_main")
        notify("UFOX: Launch MAIN (stub) — แพ็ก #4 จะใส่ Main UI Framework")
    end

    --========== DECISION: VERIFIED? ==========
    local function proceed_flow()
        if shared.UFOX.FLAGS.DEV_MODE then
            warnlog("DEV_MODE=true — bypass verify for development")
            set_verified("DEV-KEY")
        end

        if is_cache_valid() then
            -- Already verified → jump to MAIN
            destroy_splash(splashGui)
            launch_main()
        else
            -- Not verified → Key UI → Download → (verify then) Main
            -- (PACK #2 จะใส่ verify จริง + failover network)
            task.delay(0.25, function() show_key_ui() end)
            task.delay(0.30, function() destroy_splash(splashGui) end)
        end
    end

    --========== PUBLIC API (for later packs/UI modules) ==========
    shared.UFOX.API = shared.UFOX.API or {}
    local API = shared.UFOX.API

    function API.GetState()
        return table.clone(shared.UFOX_STATE)
    end

    function API.SetVerified(keyStr)
        set_verified(keyStr)
    end

    function API.ClearVerification()
        clear_verification()
    end

    function API.SetLogo(assetId)
        shared.UFOX.ASSETS.LOGO_ID = assetId
    end

    --========== BOOT ==========
    proceed_flow()

end)

if not ok then
    warn("[UFOX][LoaderError]", err)
end
--[[
  UFO HUB X Pro — PACK #2: Key System Integration
  Requirements: PACK #1 must be loaded first (shared.UFOX created)
  What you get:
    - Multi-server requester (primary + failover) + retry/timeout
    - /getkey (สร้างลิงก์กุญแจ + เปิด/คัดลอกได้)
    - /verify (ตรวจคีย์ด้วย uid/place) + แปลงเป็นสถานะเครื่องจักร (LOCKED/VERIFIED/EXPIRED)
    - อัปเดต cache TTL (ใช้ expires_at จากเซิร์ฟเวอร์ ถ้ามี)
    - API สาธารณะ: GetKeyLink(), OpenGetKey(), Verify(key), Status(), Debug_ForceVerify()
    - Event signals: "state_changed", "verify_ok", "verify_fail", "network_error"
]]

local ok, err = pcall(function()
    if not (shared and shared.UFOX) then
        warn("[UFOX][Pack2] PACK #1 not found. Load PACK #1 first.")
        return
    end

    --========== Short-hands ==========
    local U      = shared.UFOX
    local STATE  = shared.UFOX_STATE
    local Bus    = U.Bus
    local Http   = game:GetService("HttpService")
    local Players= game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")

    local function log(...) if not (U.FLAGS and U.FLAGS.QUIET) then print("[UFOX][P2]", ...) end end
    local function warnlog(...) warn("[UFOX][P2]", ...) end
    local function notify(text, dur)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title="UFO HUB X Pro", Text=tostring(text), Duration=dur or 3})
        end)
        log(text)
    end

    --========== Identity ==========
    local UID   = tostring(Players.LocalPlayer and Players.LocalPlayer.UserId or 0)
    local PLACE = tostring(game and game.PlaceId or 0)

    --========== State Machine ==========
    -- lock states: "LOCKED" (default), "VERIFIED", "EXPIRED"
    STATE.machine = STATE.machine or "LOCKED"

    local function set_machine(newState)
        if STATE.machine ~= newState then
            local prev = STATE.machine
            STATE.machine = newState
            Bus:Fire("state_changed", {prev = prev, now = newState})
        end
    end

    local function now() return os.time() end
    local function ttl_seconds()
        return math.floor((U.KEY.TTL_HOURS or 48) * 3600)
    end
    local function is_expired()
        return not STATE.expires_at or now() >= (tonumber(STATE.expires_at) or 0)
    end
    local function refresh_machine()
        if STATE.verified and not is_expired() then
            set_machine("VERIFIED")
        elseif STATE.verified and is_expired() then
            set_machine("EXPIRED")
        else
            set_machine("LOCKED")
        end
    end
    refresh_machine()

    --========== HTTP Requester (multi-server + retry) ==========
    local function get_request_fn()
        return (syn and syn.request) or (http and http.request) or request
    end

    local function encode_query(tbl)
        local arr = {}
        for k,v in pairs(tbl) do
            arr[#arr+1] = Http:UrlEncode(k).."="..Http:UrlEncode(tostring(v))
        end
        return table.concat(arr, "&")
    end

    local function http_try(url, method, body, timeoutSec)
        local req = get_request_fn()
        if not req then return nil, "no-request-fn" end
        local tmo = (timeoutSec or U.SERVERS.TIMEOUT_SEC or 12) * 1000
        local okReq, res = pcall(function()
            return req({
                Url = url,
                Method = method or "GET",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body and Http:JSONEncode(body) or nil,
                Timeout = tmo,
            })
        end)
        if not okReq or not res then return nil, "request-failed" end
        if tonumber(res.StatusCode) == 0 then
            -- บาง executor ให้ 0 ตอน error
            return nil, "status-0"
        end
        return res, nil
    end

    local function http_json(url, method, body, timeoutSec)
        local res, err = http_try(url, method, body, timeoutSec)
        if not res then return nil, err end
        local okj, data = pcall(function()
            if type(res.Body) == "string" and #res.Body > 0 then
                return Http:JSONDecode(res.Body)
            end
            return { ok = (res.StatusCode >= 200 and res.StatusCode < 300), status = res.StatusCode }
        end)
        if not okj then
            return nil, "json-decode"
        end
        return { status = res.StatusCode, headers = res.Headers, data = data }, nil
    end

    local function cycle_servers()
        local prim = U.SERVERS.PRIMARY
        local alts = U.SERVERS.FAILOVER or {}
        local list = { prim }
        for _,u in ipairs(alts) do list[#list+1] = u end
        return list
    end

    local function request_with_failover(path, query, method, body, retries)
        local qs = ""
        if query and next(query) then
            qs = "?" .. encode_query(query)
        end
        local lastErr
        retries = retries or 2
        for r=1,retries do
            for _,base in ipairs(cycle_servers()) do
                local url = (base .. path .. qs)
                log(("Try[%d] %s"):format(r, url))
                local res, err = http_json(url, method, body, U.SERVERS.TIMEOUT_SEC)
                if res and res.status and res.status >= 200 and res.status < 300 then
                    return res
                end
                lastErr = err or ("status-"..tostring(res and res.status))
            end
        end
        return nil, lastErr or "all-failed"
    end

    --========== Key API ==========
    local function build_getkey_url()
        -- มาตรฐาน: /getkey?uid=&place=
        local base = U.SERVERS.PRIMARY or ""
        local q = "?uid="..Http:UrlEncode(UID).."&place="..Http:UrlEncode(PLACE)
        return (base .. "getkey" .. q)
    end

    local function open_url(url)
        -- บาง executor มีฟังก์ชัน open; ถ้าไม่มีก็แค่คัดลอก
        local opened = false
        pcall(function()
            if syn and syn.open_url then syn.open_url(url); opened=true end
        end)
        if not opened then
            if setclipboard then
                setclipboard(url)
                notify("คัดลอกลิงก์รับคีย์แล้ว (ติดไว้ในคลิปบอร์ด) ✅", 4)
            else
                notify("ลิงก์รับคีย์: "..url, 6)
            end
        end
    end

    local function apply_verify_result(payload)
        -- payload คาดหวัง: { ok=true, key="...", expires_at=unix or nil, ttl_hours=number or nil }
        if not payload then return false, "no-payload" end
        if payload.ok ~= true then return false, "verify-false" end

        local keyStr = payload.key
        local expAt  = tonumber(payload.expires_at or 0)
        local ttlH   = tonumber(payload.ttl_hours or 0)

        -- decide expires
        local new_expires
        if expAt and expAt > 0 then
            new_expires = expAt
        elseif ttlH and ttlH > 0 then
            new_expires = now() + math.floor(ttlH * 3600)
        else
            new_expires = now() + ttl_seconds()
        end

        -- commit
        STATE.verified   = true
        STATE.key        = keyStr or STATE.key
        STATE.expires_at = new_expires
        _G.UFO_SaveKeyState = {
            verified = STATE.verified,
            key = STATE.key,
            expires_at = STATE.expires_at,
            uid = UID, place = PLACE
        }

        set_machine("VERIFIED")
        Bus:Fire("verify_ok", {key = STATE.key, expires_at = STATE.expires_at})
        notify("ยืนยันคีย์สำเร็จ ✅", 3)
        return true
    end

    local function verify_key(keyStr)
        if not keyStr or keyStr == "" then
            return false, "empty-key"
        end
        if U.FLAGS and U.FLAGS.DEV_MODE then
            warnlog("DEV_MODE=true — bypass verify; accept any key")
            return apply_verify_result({ ok=true, key=keyStr, ttl_hours=U.KEY.TTL_HOURS })
        end
        local res, err = request_with_failover("verify", {
            key   = keyStr,
            uid   = UID,
            place = PLACE
        }, "GET", nil, 2)
        if not res then
            Bus:Fire("network_error", {op="verify", err=err})
            notify("เครือข่ายผิดพลาด ขอลองใหม่อีกครั้ง", 3)
            return false, err or "network"
        end

        local okPayload = res.data
        if type(okPayload) ~= "table" then
            return false, "bad-response"
        end

        if okPayload.ok == true then
            return apply_verify_result(okPayload)
        else
            -- failed case with message
            local msg = okPayload.message or ("Verify failed (status "..tostring(res.status)..")")
            STATE.verified = false
            STATE.expires_at = 0
            set_machine("LOCKED")
            Bus:Fire("verify_fail", {message = msg})
            notify("คีย์ไม่ถูกต้อง ❌", 3)
            return false, msg
        end
    end

    local function status()
        refresh_machine()
        return {
            machine = STATE.machine,
            verified = STATE.verified,
            expires_at = STATE.expires_at,
            uid = UID, place = PLACE,
            ttl_left = (STATE.expires_at and (STATE.expires_at - now()) or 0)
        }
    end

    --========== Public API ==========
    U.API = U.API or {}

    function U.API.GetKeyLink()
        return build_getkey_url()
    end

    function U.API.OpenGetKey()
        local url = build_getkey_url()
        open_url(url)
        return url
    end

    function U.API.Verify(keyStr)
        return verify_key(keyStr)
    end

    function U.API.Status()
        return status()
    end

    function U.API.Debug_ForceVerify(keyStr)
        -- Dev helper — บังคับผ่านแบบออฟไลน์
        return apply_verify_result({ ok=true, key=keyStr or "DEV-KEY", ttl_hours=U.KEY.TTL_HOURS })
    end

    --========== Default wiring with Key UI stubs ==========
    -- ถ้าแพ็ก #3 ยังไม่มา เราจะช่วยให้ทางลัดใช้งานได้ก่อน
    -- ตัวอย่าง: กด Copy/Open GetKey เมื่อเหตุการณ์ "show_key_ui"
    U.On("show_key_ui", function()
        log("Key UI requested (stub) → provide getkey link utility")
        local url = build_getkey_url()
        if setclipboard then setclipboard(url) end
        notify("เปิด/คัดลอกลิงก์รับคีย์แล้ว — วางคีย์กลับเข้ามาเพื่อยืนยัน", 5)
    end)

    -- ถ้าเวลาหมดอายุก็อัปเดตสถานะทันที
    task.spawn(function()
        while task.wait(10) do
            local old = STATE.machine
            refresh_machine()
            if STATE.machine ~= old then
                Bus:Fire("state_changed", {prev=old, now=STATE.machine})
            end
        end
    end)

    log("PACK #2 loaded. Endpoints ready: /getkey /verify")

end)

if not ok then
    warn("[UFOX][P2][Error]", err)
end
