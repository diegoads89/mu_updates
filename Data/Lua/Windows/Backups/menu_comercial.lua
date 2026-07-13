imports("package.windows")
imports("package.controls.objects")
imports("package.systems.events")
imports("package.systems.guild")
imports("package.systems.invasion")
imports("package.systems.jewelbank")
imports("package.systems.quests")
imports("package.systems.rankings")
imports("package.systems.resets")

local menu_button_normal_sprite = {
    path = "Lua\\Texture\\simpleui.tga", u = 756.0, v = 646.0, uw = 82.0, vh = 84.0
}

local menu_button_over_sprite = {
    path = "Lua\\Texture\\simpleui.tga", u = 840.0, v = 646.0, uw = 82.0, vh = 84.0
}

local window = nil

local function close_menu()
    if window then
        window:close()
    end
end

local function run_menu_action(action)
    local result = true
    if action then
        result = action()
    end
    close_menu()
    return result
end

local function open_lua_window(window_id, before_open)
    if before_open then
        before_open()
    end
    return windows.toggle(window_id)
end

local function toggle_native_window(before_toggle, toggle_action)
    if before_toggle then
        before_toggle()
    end
    if toggle_action then
        return toggle_action()
    end
    return false
end

local function build_menu_button(id, x, y, text, color, on_click)
    local button = objects.create("button", id, {
        text = text,
        texture = menu_button_normal_sprite,
        over_texture = menu_button_normal_sprite,
        click_texture = menu_button_over_sprite,
        text_offset_y = 1
    })
    objects.set_rectangle(button, x, y, 40, 40)
    objects.set_style(button, {
        show_background = false,
        show_border = false,
        text_color = 0xFFF6F1E6,
        disabled_text_color = 0xFF888888,
        font = "bold"
    })
    objects.set_events(button, {
        on_click = function()
            return run_menu_action(on_click)
        end
    })
    return button
end

window = windows.create({
    id = "menu_comercial",
    title = "Menu Comercial",
    x = 240,
    y = 100,
    width = 216,
    height = 176,
    hotkey = { key = "F5", ctrl = true, alt = false, shift = false },
    fade_time = 0.15,
    closable = true,
    movable = true
})

if window then
    window:set_close_button_layout(196, 6, 14, 14)
    window:set_header_height(24)
    window:set_title_position(12, 5)
    window:set_title_align("left")

    local content = objects.create("panel", "menu_comercial_content")
    objects.set_rectangle(content, 8, 28, 200, 140)
    objects.set_style(content, {
        header_visible = false,
        show_background = false,
        show_border = false
    })

    local subtitle = objects.create("text", "menu_comercial_subtitle", {
        text = "Prueba de launcher Lua + MU"
    })
    objects.set_rectangle(subtitle, 0, 0, 196, 14)
    objects.set_style(subtitle, {
        text_color = 0xFFDDD4C8,
        font = "normal"
    })

    local buttonEventos = build_menu_button("menu_btn_eventos", 0, 20, "EV", 0xFF5E4B2D, function()
        open_lua_window("eventos", function()
            events.request_refresh()
        end)
    end)

    local buttonInvasion = build_menu_button("menu_btn_invasion", 50, 20, "IV", 0xFF3B4A63, function()
        open_lua_window("invasion", function()
            invasion.request_refresh()
        end)
    end)

    local buttonResets = build_menu_button("menu_btn_resets", 100, 20, "RS", 0xFF5B3F54, function()
        open_lua_window("windowsresets", function()
            resets.request_refresh()
        end)
    end)

    local buttonRankings = build_menu_button("menu_btn_rankings", 150, 20, "RK", 0xFF2F5B48, function()
        open_lua_window("rankings", function()
            rankings.request_refresh()
        end)
    end)

    local buttonQuestsLua = build_menu_button("menu_btn_quests_lua", 0, 70, "QL", 0xFF5C5038, function()
        open_lua_window("quests_panel", function()
            quests.request_refresh()
            quests.request_detail()
        end)
    end)

    local buttonQuestsNative = build_menu_button("menu_btn_quests_native", 50, 70, "QN", 0xFF6B3F33, function()
        return toggle_native_window(nil, quests.toggle_native_list)
    end)

    local buttonGuildNative = build_menu_button("menu_btn_guild_native", 100, 70, "GD", 0xFF395C6C, function()
        return toggle_native_window(function()
            guild.request_refresh()
        end, guild.toggle_native)
    end)

    local buttonJewelNative = build_menu_button("menu_btn_jewel_native", 150, 70, "JB", 0xFF5D5A32, function()
        return toggle_native_window(function()
            jewelbank.request_refresh()
        end, jewelbank.toggle_native)
    end)

    local closeButton = objects.create("button", "menu_btn_close", {
        text = "Cerrar"
    })
    objects.set_rectangle(closeButton, 50, 118, 100, 20)
    objects.set_events(closeButton, {
        on_click = function()
            window:close()
        end
    })

    window:add_obj(content)
    window:add_bound("menu_comercial_content", subtitle)
    window:add_bound("menu_comercial_content", buttonEventos)
    window:add_bound("menu_comercial_content", buttonInvasion)
    window:add_bound("menu_comercial_content", buttonResets)
    window:add_bound("menu_comercial_content", buttonRankings)
    window:add_bound("menu_comercial_content", buttonQuestsLua)
    window:add_bound("menu_comercial_content", buttonQuestsNative)
    window:add_bound("menu_comercial_content", buttonGuildNative)
    window:add_bound("menu_comercial_content", buttonJewelNative)
    window:add_bound("menu_comercial_content", closeButton)
end
