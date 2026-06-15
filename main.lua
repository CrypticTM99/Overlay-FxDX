-- name: OverlayFxDX-v1.0.1-TESTING
-- description: (Stable version, for now) for COOPDX 1.5.1, What does it do?: Overlays , with a fading menu , mobile support is added and functional on 1.3+ Android APK Tested by moi (myself) . 


if gGlobalSyncTable == nil then gGlobalSyncTable = {} end
if gGlobalSyncTable.overlay_mode == nil then gGlobalSyncTable.overlay_mode = 0 end

local prevPeriod = false
local prevComma = false  -- again, these arent needed, left from testing.

local list_timer = 0
local list_alpha = 0


local function screen()
    return djui_hud_get_screen_width(), djui_hud_get_screen_height()
end

local function rect(r,g,b,a)
    local w,h = screen()
    djui_hud_set_color(r,g,b,a)
    djui_hud_render_rect(0,0,w,h)
end

local function off() end


local function n64()
    local w,h = screen()
    rect(20,20,40,30)

    djui_hud_set_color(0,0,0,40)
    for y=0,h,3 do
        djui_hud_render_rect(0,y,w,1)
    end
end


local function bw()
    rect(120,120,120,35)
end


local function ps1()
    local w,h = screen()
    rect(90,60,120,25)

    djui_hud_set_color(0,0,0,50)
    for y=0,h,8 do
        djui_hud_render_rect(0,y,w,2)
    end
end


local function vhs()
    local w,h = screen()
    rect(30,30,30,20)

    djui_hud_set_color(255,255,255,10)
    for i=1,25 do
        djui_hud_render_rect(0, math.random(0,h), w, 1)
    end
end


local function green()
    rect(40,120,40,35)
end


local function invert()
    rect(255,255,255,20)
end


local function glitch()       -- here is the list of different overlays, add yours here if you'd like.
    local w,h = screen()

    for i=1,20 do
        djui_hud_set_color(math.random(0,255),0,math.random(0,255),40)
        djui_hud_render_rect(math.random(0,w),math.random(0,h),120,2)
    end
end


local function crt()
    local w,h = screen()

    rect(10,10,20,35)

    djui_hud_set_color(0,0,0,45)
    for y=0,h,2 do
        djui_hud_render_rect(0,y,w,1)
    end
end


local function blur()
    local w,h = screen()

    for i=1,6 do
        djui_hud_set_color(255,255,255,10)
        djui_hud_render_rect(
            math.random(-5,5),
            math.random(-5,5),
            w,
            h
        )
    end
end


local function draw_overlay()
    local m = gGlobalSyncTable.overlay_mode

    if m == 0 then off()
    elseif m == 1 then n64()
    elseif m == 2 then bw()
    elseif m == 3 then ps1()
    elseif m == 4 then vhs()
    elseif m == 5 then green()
    elseif m == 6 then invert()
    elseif m == 7 then glitch()
    elseif m == 8 then crt()
    elseif m == 9 then blur() -- NEW
    end
end


local function trigger_list()
    list_timer = 90
end

local function cycle_overlay(dir)
    gGlobalSyncTable.overlay_mode = gGlobalSyncTable.overlay_mode + dir

    if gGlobalSyncTable.overlay_mode > 9 then
        gGlobalSyncTable.overlay_mode = 0
    end

    if gGlobalSyncTable.overlay_mode < 0 then
        gGlobalSyncTable.overlay_mode = 9
    end

    trigger_list()
end

--Note: prevPeriod and prevComma are left here from testing buttons on multiple layouts, this isnt needed for the mod to work for you
hook_event(HOOK_UPDATE, function()
    local p = gMarioStates[0]
    if not p or not p.controller then return end

    if list_timer > 0 then
        list_timer = list_timer - 1
    end

    if list_timer > 0 then
        list_alpha = math.min(list_alpha + 20, 180)
    else
        list_alpha = math.max(list_alpha - 15, 0)
    end

    if (p.controller.buttonPressed & L_TRIG) ~= 0 then
        cycle_overlay(1)
    end

    local period = (p.controller.buttonPressed & X_BUTTON) ~= 0
    local comma = (p.controller.buttonPressed & Y_BUTTON) ~= 0

    if period and not prevPeriod then
        cycle_overlay(1)
    end

    if comma and not prevComma then
        cycle_overlay(-1)
    end

    prevPeriod = period
    prevComma = comma
end)

-- this is where you can add your own overlays if you would like, feel free to change it up.
-- keep in mind this is ONLY for the names (left corner of hud)
local overlay_names = {
    "OFF/NORMAL",
    "N64 CRT",
    "WASHED COLORS",
    "RETRO v1 (CRT)",
    "VHS",
    "GREEN",
    "LOW-RES",
    "GLITCH",
    "CRT (DARK)",
    "BLUR"
}

-- this is a basic hud addition for the cycle overlay
hook_event(HOOK_ON_HUD_RENDER, function()

    draw_overlay()

    local w, h = screen()

    local box_x = 20
    local box_y = (h * 0.76) + 35

    djui_hud_set_color(0,0,0,140)
    djui_hud_render_rect(box_x, box_y, 260, 40)

    djui_hud_set_color(255,255,255,255)
    djui_hud_print_text(
        "L = Cycle Overlay | Mode: " .. overlay_names[gGlobalSyncTable.overlay_mode + 1],
        box_x + 10,
        box_y + 12,
        0.6
    )

    local btn_w = 120
    local btn_h = 50
    local btn_x = w - btn_w - 20
    local btn_y = h - btn_h - 20

    djui_hud_set_color(0,0,0,160)
    djui_hud_render_rect(btn_x, btn_y, btn_w, btn_h)

    djui_hud_set_color(255,255,255,255)
    djui_hud_print_text("OVERLAY", btn_x + 25, btn_y + 18, 0.7)

    local mx = djui_hud_get_mouse_x and djui_hud_get_mouse_x() or -1
    local my = djui_hud_get_mouse_y and djui_hud_get_mouse_y() or -1

    if mx ~= -1 and my ~= -1 then
        if mx >= btn_x and mx <= btn_x + btn_w and my >= btn_y and my <= btn_y + btn_h then
            if (p and p.controller and (p.controller.buttonPressed & A_BUTTON) ~= 0) then
                cycle_overlay(1)
            end
        end
    end

    if list_alpha > 0 then
        local list_x = 20
        local list_y = 145

        djui_hud_set_color(0,0,0,list_alpha)
        djui_hud_render_rect(list_x, list_y, 180, 220)

        for i = 0, 9 do
            local y = list_y + 10 + (i * 18)

            if gGlobalSyncTable.overlay_mode == i then
                djui_hud_set_color(80,220,120,list_alpha)
            else
                djui_hud_set_color(200,200,200,list_alpha)
            end

            djui_hud_render_rect(list_x + 5, y, 170, 14)

            djui_hud_set_color(255,255,255,list_alpha)
            djui_hud_print_text(
                overlay_names[i + 1],
                list_x + 10,
                y + 3,
                0.7
            )
        end
    end
end)

--removal of DEBUG print from testing build