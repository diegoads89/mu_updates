imports("package.windows")
imports("package.binding")
imports("package.controls.objects")
imports("package.systems.events")

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

local function get_event_rows()
    local rows = events.get_rows()
    if type(rows) ~= "table" then
        return {}
    end

    return rows
end

local function get_event_count()
    return #get_event_rows()
end

local function get_event_header(row)
    if row and row.battle_ice3 then
        return "Special Event"
    end

    return "Event"
end

local function get_event_badge(row)
    if not row then
        return ""
    end

    if tonumber(row.type) == 0 then
        return "[Global]"
    end

    return "[Character]"
end

local function get_event_time_text(row)
    if not row or not row.time or row.time == "" then
        return "--:--:--"
    end

    return row.time
end

local function get_event_footer(row)
    if not row then
        return ""
    end

    if row.time_remaining == 0 then
        return "Disponible ahora"
    end

    if row.time_remaining < 0 then
        return "No disponible"
    end

    return "Horario: " .. get_event_time_text(row)
end

local function get_event_item_color(row)
    if not row then
        return 0xFFF0F0F0
    end

    if row.time_remaining == 0 then
        return 0xFF7DFF9A
    end

    if row.time_remaining < 0 then
        return 0xFFFF9A9A
    end

    return 0xFFF0F0F0
end

local function build_event_item(row)
    return {
        item_index = -1,
        header = get_event_header(row),
        name = row.name or "Evento",
        footer = get_event_footer(row),
        badge = get_event_badge(row),
        count = 0,
        text_color = get_event_item_color(row)
    }
end

-- Bridge canonico de lista compuesta:
-- rows del sistema -> items de item_list -> selected_index/value -> panel detalle.
local event_list_bridge = create_item_list_bridge({
    rows_provider = get_event_rows,
    item_builder = build_event_item,
    selected_index_bind = "event_time.selected_index",
    selected_value_bind = "event_time.selected_value",
    selected_value_getter = function(row)
        return row and row.index or -1
    end
})

local function get_selected_name()
    local row = event_list_bridge.get_selected()
    return row and row.name or "Sin eventos"
end

local function get_selected_time()
    local row = event_list_bridge.get_selected()
    return get_event_time_text(row)
end

local function get_selected_status()
    local row = event_list_bridge.get_selected()
    if not row then
        return "No hay eventos disponibles en esta categoria."
    end

    if row.time_remaining == 0 then
        return "Estado: ONLINE"
    end

    if row.time_remaining < 0 then
        return "Estado: OFFLINE"
    end

    return "Estado: Programado"
end

local function get_selected_meta()
    local row = event_list_bridge.get_selected()
    if not row then
        return "Indice: -- | Tipo: --"
    end

    return string.format("Indice: %d | Tipo: %d", tonumber(row.index) or -1, tonumber(row.type) or 0)
end

local function get_selected_description()
    local row = event_list_bridge.get_selected()
    if not row then
        return "Selecciona un evento en la lista lateral."
    end

    if row.battle_ice3 then
        return "Evento especial detectado. Aqui podras extender horarios, requisitos, recompensas y reglas."
    end

    return "Base del sistema Event Time. Este panel queda listo para extender requisitos, accesos, drops y detalles futuros."
end

local function get_selected_footer()
    local row = event_list_bridge.get_selected()
    if not row then
        return "Sin informacion adicional."
    end

    if row.time_remaining > 0 then
        return "Tiempo restante hasta su siguiente estado."
    end

    if row.time_remaining == 0 then
        return "El evento se encuentra disponible ahora."
    end

    return "El evento no se encuentra disponible actualmente."
end

binding.set("event_time.selected_index", -1)
binding.set("event_time.selected_value", -1)
event_list_bridge.sync_selected(nil)

local window = windows.create({
    id = "eventos",
    title = events.get_title(),
    x = 320,
    y = 80,
    width = 430,
    height = 270,
    hotkey = "H",
    closable = true,
    movable = true,
    on_open = function()
        events.request_refresh()
        event_list_bridge.sync_selected(nil)
    end,
    on_close = function()
        events.set_current_tab(0)
        event_list_bridge.clear_selection()
    end
})

if window then
    local contentRoot = objects.create("panel", "event_time_content")
    objects.set_rectangle(contentRoot, 0, 24, 430, 246)
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
        text = events.get_summary(),
        font = "bold",
        align = "left"
    })
    objects.set_rectangle(summary, 12, 6, 398, 18)
    objects.set_style(summary, {
        text_color = 0xFFB8D7FF
    })
    objects.set_data_binding(summary, {
        bind = "events.summary"
    })

    local pageSelector = objects.create("selector", "page_selector", {
        wrap = false
    })
    objects.set_rectangle(pageSelector, 318, 6, 94, 22)
    objects.set_data_binding(pageSelector, {
        current_bind = "events.current_tab",
        max_bind = "events.max_tabs",
        format_text = function(current, max)
            return string.format("%d / %d", current + 1, max)
        end
    })
    objects.set_events(pageSelector, {
        on_change = function(index)
            events.set_current_tab(index)
            event_list_bridge.sync_selected(nil)
        end
    })

    local eventListFrame = objects.create("panel", "event_list_frame")
    objects.set_rectangle(eventListFrame, 12, 34, 112, 166)
    objects.set_style(eventListFrame, {
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

    local eventList = objects.create("item_list", "event_buttons", {
        current_bind = "event_time.selected_index",
        bind_items = function()
            return event_list_bridge.build_items()
        end,
        row_height = 48,
        model_size = 0,
        text_color = 0xFFF0F0F0,
        count_color = 0xFFE0E0E0,
        hover_color = 0xD0181E28,
        selected_color = 0xD04A2412
    })
    objects.set_rectangle(eventList, 2, 2, 108, 162)
    objects.set_data_binding(eventList, {
        current_bind = "event_time.selected_index"
    })
    objects.set_events(eventList, {
        on_item_selected = function(index)
            event_list_bridge.sync_selected(index)
        end
    })

    local detailPanel = objects.create("panel", "event_detail_panel")
    objects.set_rectangle(detailPanel, 136, 34, 276, 198)
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
        text = "Sin eventos",
        font = "big",
        align = "left",
        bind_text = function()
            return get_selected_name()
        end
    })
    objects.set_rectangle(detailName, 12, 12, 250, 24)
    objects.set_style(detailName, {
        text_color = 0xFFFFD768
    })

    local detailTime = objects.create("text", "detail_time", {
        text = "--:--:--",
        font = "bold",
        align = "left",
        bind_text = function()
            return "Tiempo: " .. get_selected_time()
        end
    })
    objects.set_rectangle(detailTime, 12, 42, 180, 18)
    objects.set_style(detailTime, {
        text_color = 0xFFFFF6B4
    })

    local detailStatus = objects.create("text", "detail_status", {
        text = "Estado: --",
        font = "bold",
        align = "right",
        bind_text = function()
            return get_selected_status()
        end
    })
    objects.set_rectangle(detailStatus, 150, 42, 114, 18)
    objects.set_style(detailStatus, {
        text_color = 0xFF9AE8FF
    })

    local detailMeta = objects.create("text", "detail_meta", {
        text = "Indice: -- | Tipo: --",
        align = "left",
        bind_text = function()
            return get_selected_meta()
        end
    })
    objects.set_rectangle(detailMeta, 12, 66, 250, 18)
    objects.set_style(detailMeta, {
        text_color = 0xFFD0D0D0
    })

    local detailDescriptionTitle = objects.create("label", "detail_description_title", {
        text = "Informacion del Evento",
        font = "bold",
        align = "left"
    })
    objects.set_rectangle(detailDescriptionTitle, 12, 92, 250, 18)
    objects.set_style(detailDescriptionTitle, {
        text_color = 0xFFFFA644,
        background_color = 0x6A000000
    })

    local detailDescription = objects.create("text", "detail_description", {
        text = "Selecciona un evento en la lista lateral.",
        align = "left",
        bind_text = function()
            return get_selected_description()
        end
    })
    objects.set_rectangle(detailDescription, 12, 116, 250, 48)
    objects.set_style(detailDescription, {
        text_color = 0xFFF0F0F0
    })

    local detailFooter = objects.create("text", "detail_footer", {
        text = "Sin informacion adicional.",
        align = "left",
        bind_text = function()
            return get_selected_footer()
        end
    })
    objects.set_rectangle(detailFooter, 12, 170, 250, 18)
    objects.set_style(detailFooter, {
        text_color = 0xFFB0B0B0
    })

    local closeButton = objects.create("button", "close", {
        text = "Cerrar"
    })
    objects.set_rectangle(closeButton, 12, 210, 90, 22)
    objects.set_events(closeButton, {
        on_click = function()
            window:close()
        end
    })

    local refreshButton = objects.create("button", "refresh", {
        text = "Actualizar"
    })
    objects.set_rectangle(refreshButton, 112, 210, 90, 22)
    objects.set_events(refreshButton, {
        on_click = function()
            events.request_refresh()
            event_list_bridge.sync_selected(nil)
        end
    })

    local emptyHint = objects.create("text", "empty_hint", {
        text = "No hay eventos en esta categoria.",
        align = "center",
        bind_text = function()
            if event_list_bridge.get_count() > 0 then
                return ""
            end
            return "No hay eventos en esta categoria."
        end
    })
    objects.set_rectangle(emptyHint, 12, 120, 112, 24)
    objects.set_style(emptyHint, {
        text_color = 0xFFFF7A7A
    })

    window:add_obj(contentRoot)
    window:add_bound("event_time_content", summary)
    window:add_bound("event_time_content", pageSelector)
    window:add_bound("event_time_content", eventListFrame)
    window:add_bound("event_list_frame", eventList)
    window:add_bound("event_time_content", detailPanel)
    window:add_bound("event_detail_panel", detailName)
    window:add_bound("event_detail_panel", detailTime)
    window:add_bound("event_detail_panel", detailStatus)
    window:add_bound("event_detail_panel", detailMeta)
    window:add_bound("event_detail_panel", detailDescriptionTitle)
    window:add_bound("event_detail_panel", detailDescription)
    window:add_bound("event_detail_panel", detailFooter)
    window:add_bound("event_time_content", closeButton)
    window:add_bound("event_time_content", refreshButton)
    window:add_bound("event_time_content", emptyHint)
end
