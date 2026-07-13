imports("package.windows")
imports("package.binding")
imports("package.controls.objects")
imports("package.systems.invasion")

local function create_item_list_bridge(def)
    local function get_rows()
        local rows = def.rows_provider()
        if type(rows) ~= "table" then
            return {}
        end

        return rows
    end

    local bridge = {}

    function bridge.get_rows()
        return get_rows()
    end

    function bridge.get_count()
        return #get_rows()
    end

    function bridge.build_items()
        local items = {}
        for _, row in ipairs(get_rows()) do
            items[#items + 1] = def.item_builder(row)
        end
        return items
    end

    function bridge.clear_selection()
        binding.set(def.selected_index_bind, -1)
        binding.set(def.selected_value_bind, -1)
    end

    function bridge.sync_selected(preferred_index)
        local rows = get_rows()
        if #rows == 0 then
            bridge.clear_selection()
            return nil
        end

        local selected_index = preferred_index
        if selected_index == nil then
            selected_index = tonumber(binding.get(def.selected_index_bind)) or -1
        end

        if selected_index < 0 or selected_index >= #rows then
            selected_index = 0
        end

        local row = rows[selected_index + 1]
        binding.set(def.selected_index_bind, selected_index)
        binding.set(def.selected_value_bind, def.selected_value_getter(row))
        return row
    end

    function bridge.get_selected()
        return bridge.sync_selected(nil)
    end

    return bridge
end

local function get_invasion_rows()
    local rows = invasion.get_rows()
    if type(rows) ~= "table" then
        return {}
    end

    return rows
end

local invasion_list_bridge
local monster_list_bridge

local function get_selected_invasion()
    return invasion_list_bridge.get_selected()
end

local function get_monster_rows()
    local invasion_row = get_selected_invasion()
    if not invasion_row or type(invasion_row.monsters) ~= "table" then
        return {}
    end

    return invasion_row.monsters
end

local function get_invasion_badge(row)
    if not row then
        return ""
    end

    if row.active then
        return "[ON]"
    end

    return "[WAIT]"
end

local function get_invasion_footer(row)
    if not row then
        return ""
    end

    if row.active then
        return "Tiempo restante: " .. (row.time or "--:--:--")
    end

    return "Estado actual: OFFLINE"
end

local function get_invasion_color(row)
    if not row then
        return 0xFFF0F0F0
    end

    if row.active then
        return 0xFF8BFF98
    end

    return 0xFFFFB0A0
end

local function build_invasion_item(row)
    return {
        item_index = -1,
        header = "Invasion",
        name = row.name or "Sin nombre",
        footer = get_invasion_footer(row),
        badge = get_invasion_badge(row),
        count = tonumber(row.monster_count) or 0,
        text_color = get_invasion_color(row)
    }
end

local function build_monster_item(row)
    local kills = tonumber(row and row.monster_kill) or 0
    local total = tonumber(row and row.monster_count) or 0
    local remaining = tonumber(row and row.remaining) or math.max(total - kills, 0)

    return {
        item_index = -1,
        header = "Monster",
        name = string.format("Monster #%d", tonumber(row and row.monster_index) or -1),
        footer = string.format("Kills: %d / %d", kills, total),
        badge = string.format("[%d]", remaining),
        count = total,
        text_color = remaining > 0 and 0xFFFFE0A0 or 0xFF89FF9E
    }
end

invasion_list_bridge = create_item_list_bridge({
    rows_provider = get_invasion_rows,
    item_builder = build_invasion_item,
    selected_index_bind = "invasion_panel.selected_index",
    selected_value_bind = "invasion_panel.selected_value",
    selected_value_getter = function(row)
        return row and row.index or -1
    end
})

monster_list_bridge = create_item_list_bridge({
    rows_provider = get_monster_rows,
    item_builder = build_monster_item,
    selected_index_bind = "invasion_panel.monster_selected_index",
    selected_value_bind = "invasion_panel.monster_selected_value",
    selected_value_getter = function(row)
        return row and row.monster_index or -1
    end
})

local function sync_monster_selection()
    if monster_list_bridge.get_count() == 0 then
        monster_list_bridge.clear_selection()
        return nil
    end

    return monster_list_bridge.sync_selected(nil)
end

local function sync_invasion_selection(preferred_index)
    local row = invasion_list_bridge.sync_selected(preferred_index)
    sync_monster_selection()
    return row
end

local function get_selected_invasion_name()
    local row = get_selected_invasion()
    return row and row.name or "Sin invasiones"
end

local function get_selected_invasion_time()
    local row = get_selected_invasion()
    return row and row.time or "--:--:--"
end

local function get_selected_invasion_status()
    local row = get_selected_invasion()
    if not row then
        return "Estado: Sin datos"
    end

    if row.active then
        return "Estado: Activa"
    end

    return "Estado: En espera"
end

local function get_selected_invasion_meta()
    local row = get_selected_invasion()
    if not row then
        return "Indice: -- | Monstruos: --"
    end

    return string.format(
        "Indice: %d | Monstruos: %d",
        tonumber(row.index) or -1,
        tonumber(row.monster_count) or 0
    )
end

local function get_selected_invasion_description()
    local row = get_selected_invasion()
    if not row then
        return "Selecciona una invasion en la lista lateral."
    end

    if row.active then
        return "La invasion se encuentra activa. El detalle inferior muestra el progreso por monstruo para este ciclo."
    end

    return "La invasion no esta activa actualmente. El sistema queda listo para extender horario, zonas, recompensas y reglas."
end

local function get_selected_invasion_footer()
    local row = get_selected_invasion()
    if not row then
        return "Sin informacion adicional."
    end

    if row.active then
        return "Monitorea aqui los objetivos pendientes y el tiempo restante."
    end

    return "Espera la siguiente actualizacion del sistema o la activacion de la invasion."
end

local function get_selected_monster_text()
    local row = monster_list_bridge.get_selected()
    if not row then
        return "Selecciona un monstruo en la lista inferior."
    end

    local kills = tonumber(row.monster_kill) or 0
    local total = tonumber(row.monster_count) or 0
    local remaining = tonumber(row.remaining) or math.max(total - kills, 0)

    return string.format(
        "Monster #%d | Kills: %d / %d | Restantes: %d",
        tonumber(row.monster_index) or -1,
        kills,
        total,
        remaining
    )
end

binding.set("invasion_panel.selected_index", -1)
binding.set("invasion_panel.selected_value", -1)
binding.set("invasion_panel.monster_selected_index", -1)
binding.set("invasion_panel.monster_selected_value", -1)
sync_invasion_selection(nil)

local window = windows.create({
    id = "invasion",
    title = invasion.get_title(),
    x = 290,
    y = 72,
    width = 472,
    height = 316,
    hotkey = { key = "F7", ctrl = true, alt = false, shift = false },
    closable = true,
    movable = true,
    on_open = function()
        invasion.request_refresh()
        sync_invasion_selection(nil)
    end,
    on_close = function()
        invasion_list_bridge.clear_selection()
        monster_list_bridge.clear_selection()
    end
})

if window then
    local contentRoot = objects.create("panel", "invasion_content")
    objects.set_rectangle(contentRoot, 0, 24, 472, 292)
    objects.set_style(contentRoot, {
        header_visible = false,
        show_background = false,
        show_border = false,
        padding_left = 0,
        padding_top = 0,
        padding_right = 0,
        padding_bottom = 0
    })

    local summary = objects.create("text", "summary", {
        text = invasion.get_summary(),
        font = "bold",
        align = "left"
    })
    objects.set_rectangle(summary, 12, 8, 324, 18)
    objects.set_style(summary, {
        text_color = 0xFFB8D7FF
    })
    objects.set_data_binding(summary, {
        bind = "invasion.summary"
    })

    local stats = objects.create("text", "stats", {
        text = "",
        align = "right",
        bind_text = function()
            return string.format(
                "Activas: %d / %d",
                tonumber(invasion.get_active_count()) or 0,
                tonumber(invasion.get_total_count()) or 0
            )
        end
    })
    objects.set_rectangle(stats, 338, 8, 122, 18)
    objects.set_style(stats, {
        text_color = 0xFFFFE8A0
    })

    local invasionListFrame = objects.create("panel", "invasion_list_frame")
    objects.set_rectangle(invasionListFrame, 12, 34, 126, 208)
    objects.set_style(invasionListFrame, {
        header_visible = false,
        show_background = true,
        show_border = true,
        background_color = 0x700A0A0A,
        border_color = 0xFF000000,
        padding_left = 0,
        padding_top = 0,
        padding_right = 0,
        padding_bottom = 0
    })

    local invasionList = objects.create("item_list", "invasion_list", {
        current_bind = "invasion_panel.selected_index",
        bind_items = function()
            return invasion_list_bridge.build_items()
        end,
        row_height = 48,
        model_size = 0,
        text_color = 0xFFF0F0F0,
        count_color = 0xFFE0E0E0,
        hover_color = 0xD0181E28,
        selected_color = 0xD04A2412
    })
    objects.set_rectangle(invasionList, 2, 2, 122, 204)
    objects.set_data_binding(invasionList, {
        current_bind = "invasion_panel.selected_index"
    })
    objects.set_events(invasionList, {
        on_item_selected = function(index)
            sync_invasion_selection(index)
        end
    })

    local detailPanel = objects.create("panel", "invasion_detail_panel")
    objects.set_rectangle(detailPanel, 150, 34, 310, 140)
    objects.set_style(detailPanel, {
        header_visible = false,
        show_background = true,
        show_border = true,
        background_color = 0xC0101014,
        border_color = 0xFF000000,
        padding_left = 0,
        padding_top = 0,
        padding_right = 0,
        padding_bottom = 0
    })

    local detailName = objects.create("text", "detail_name", {
        text = "Sin invasiones",
        font = "big",
        align = "left",
        bind_text = function()
            return get_selected_invasion_name()
        end
    })
    objects.set_rectangle(detailName, 12, 12, 286, 24)
    objects.set_style(detailName, {
        text_color = 0xFFFFD768
    })

    local detailTime = objects.create("text", "detail_time", {
        text = "--:--:--",
        font = "bold",
        align = "left",
        bind_text = function()
            return "Tiempo: " .. get_selected_invasion_time()
        end
    })
    objects.set_rectangle(detailTime, 12, 42, 176, 18)
    objects.set_style(detailTime, {
        text_color = 0xFFFFF6B4
    })

    local detailStatus = objects.create("text", "detail_status", {
        text = "Estado: --",
        font = "bold",
        align = "right",
        bind_text = function()
            return get_selected_invasion_status()
        end
    })
    objects.set_rectangle(detailStatus, 188, 42, 110, 18)
    objects.set_style(detailStatus, {
        text_color = 0xFF9AE8FF
    })

    local detailMeta = objects.create("text", "detail_meta", {
        text = "Indice: -- | Monstruos: --",
        align = "left",
        bind_text = function()
            return get_selected_invasion_meta()
        end
    })
    objects.set_rectangle(detailMeta, 12, 66, 286, 18)
    objects.set_style(detailMeta, {
        text_color = 0xFFD0D0D0
    })

    local detailDescriptionTitle = objects.create("label", "detail_description_title", {
        text = "Informacion de la Invasion",
        font = "bold",
        align = "left"
    })
    objects.set_rectangle(detailDescriptionTitle, 12, 92, 286, 18)
    objects.set_style(detailDescriptionTitle, {
        text_color = 0xFFFFA644,
        background_color = 0x6A000000
    })

    local detailDescription = objects.create("text", "detail_description", {
        text = "Selecciona una invasion en la lista lateral.",
        align = "left",
        bind_text = function()
            return get_selected_invasion_description()
        end
    })
    objects.set_rectangle(detailDescription, 12, 116, 286, 30)
    objects.set_style(detailDescription, {
        text_color = 0xFFF0F0F0
    })

    local detailFooter = objects.create("text", "detail_footer", {
        text = "Sin informacion adicional.",
        align = "left",
        bind_text = function()
            return get_selected_invasion_footer()
        end
    })
    objects.set_rectangle(detailFooter, 12, 146, 286, 18)
    objects.set_style(detailFooter, {
        text_color = 0xFFB0B0B0
    })

    local monsterPanel = objects.create("panel", "invasion_monster_panel")
    objects.set_rectangle(monsterPanel, 150, 182, 310, 60)
    objects.set_style(monsterPanel, {
        header_visible = false,
        show_background = true,
        show_border = true,
        background_color = 0xC0101014,
        border_color = 0xFF000000,
        padding_left = 0,
        padding_top = 0,
        padding_right = 0,
        padding_bottom = 0
    })

    local monstersTitle = objects.create("label", "monsters_title", {
        text = "Objetivos de Monstruos",
        font = "bold",
        align = "left"
    })
    objects.set_rectangle(monstersTitle, 12, 8, 286, 18)
    objects.set_style(monstersTitle, {
        text_color = 0xFFFFA644,
        background_color = 0x6A000000
    })

    local monstersList = objects.create("item_list", "monster_list", {
        current_bind = "invasion_panel.monster_selected_index",
        bind_items = function()
            return monster_list_bridge.build_items()
        end,
        row_height = 34,
        model_size = 0,
        text_color = 0xFFF0F0F0,
        count_color = 0xFFE0E0E0,
        hover_color = 0xD0181E28,
        selected_color = 0xD04A2412
    })
    objects.set_rectangle(monstersList, 12, 28, 286, 28)
    objects.set_data_binding(monstersList, {
        current_bind = "invasion_panel.monster_selected_index"
    })
    objects.set_events(monstersList, {
        on_item_selected = function(index)
            monster_list_bridge.sync_selected(index)
        end
    })

    local monsterHint = objects.create("text", "monster_hint", {
        text = "Selecciona un monstruo en la lista inferior.",
        align = "left",
        bind_text = function()
            return get_selected_monster_text()
        end
    })
    objects.set_rectangle(monsterHint, 150, 246, 310, 18)
    objects.set_style(monsterHint, {
        text_color = 0xFF9AE8FF
    })

    local refreshButton = objects.create("button", "refresh", {
        text = "Actualizar"
    })
    objects.set_rectangle(refreshButton, 150, 264, 100, 22)
    objects.set_events(refreshButton, {
        on_click = function()
            invasion.request_refresh()
            sync_invasion_selection(nil)
        end
    })

    local closeButton = objects.create("button", "close", {
        text = "Cerrar"
    })
    objects.set_rectangle(closeButton, 262, 264, 100, 22)
    objects.set_events(closeButton, {
        on_click = function()
            window:close()
        end
    })

    local emptyHint = objects.create("text", "empty_hint", {
        text = "No hay invasiones cargadas.",
        align = "center",
        bind_text = function()
            if invasion_list_bridge.get_count() > 0 then
                return ""
            end
            return "No hay invasiones cargadas."
        end
    })
    objects.set_rectangle(emptyHint, 16, 126, 118, 24)
    objects.set_style(emptyHint, {
        text_color = 0xFFFF7A7A
    })

    window:add_obj(contentRoot)
    window:add_bound("invasion_content", summary)
    window:add_bound("invasion_content", stats)
    window:add_bound("invasion_content", invasionListFrame)
    window:add_bound("invasion_list_frame", invasionList)
    window:add_bound("invasion_content", detailPanel)
    window:add_bound("invasion_content", monsterPanel)
    window:add_bound("invasion_detail_panel", detailName)
    window:add_bound("invasion_detail_panel", detailTime)
    window:add_bound("invasion_detail_panel", detailStatus)
    window:add_bound("invasion_detail_panel", detailMeta)
    window:add_bound("invasion_detail_panel", detailDescriptionTitle)
    window:add_bound("invasion_detail_panel", detailDescription)
    window:add_bound("invasion_detail_panel", detailFooter)
    window:add_bound("invasion_monster_panel", monstersTitle)
    window:add_bound("invasion_monster_panel", monstersList)
    window:add_bound("invasion_content", monsterHint)
    window:add_bound("invasion_content", refreshButton)
    window:add_bound("invasion_content", closeButton)
    window:add_bound("invasion_content", emptyHint)
end
