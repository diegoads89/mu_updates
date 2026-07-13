imports("package.windows")
imports("package.binding")
imports("package.controls.objects")
imports("package.systems.jewelbank")

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

local function get_jewel_rows()
    local rows = jewelbank.get_rows()
    if type(rows) ~= "table" then
        return {}
    end
    return rows
end

local function build_jewel_item(row)
    local name = row.name or "Jewel"
    local count = tonumber(row.count) or 0

    return {
        item_index = row.item_index or row.index or -1,
        item_level = row.item_level or 0,
        header = "  ",
        name = name,
        footer = "",
        badge = string.format("x%d", count),
        count = count,
        text_color = 0xFFF0F0F0
    }
end

local jewel_list_bridge = create_item_list_bridge({
    rows_provider = get_jewel_rows,
    item_builder = build_jewel_item,
    selected_index_bind = "jewelbank_panel.selected_index",
    selected_value_bind = "jewelbank_panel.selected_value",
    selected_value_getter = function(row)
        return row and (row.item_index or row.index) or -1
    end
})

binding.set("jewelbank_panel.selected_index", -1)
binding.set("jewelbank_panel.selected_value", -1)

local detailWindow = nil

local function open_jewel_detail()
    local row = jewel_list_bridge.get_selected()
    if not row then
        return
    end

    if detailWindow then
        windows.close("jewelbank_detail")
    end

    local count = tonumber(row.count) or 0
    local jewel_index = row.item_index or row.index or -1

    detailWindow = windows.create({
        id = "jewelbank_detail",
        title = row.name or "Jewel",
        x = 350,
        y = 150,
        width = 380,
        height = 420,
        closable = true,
        movable = true,
        on_close = function()
            detailWindow = nil
        end
    })

    if detailWindow then
        local contentRoot = objects.create("panel", "detail_content")
        objects.set_rectangle(contentRoot, 0, 24, 380, 396)
        objects.set_style(contentRoot, {
            header_visible = false,
            show_background = true,
            show_border = true,
            background_color = 0xFF1A1A1A,
            border_color = 0xFF3A4A5A
        })

        local jewelName = objects.create("text", "jewel_name", {
            text = row.name or "Jewel",
            font = "big",
            align = "center"
        })
        objects.set_rectangle(jewelName, 20, 20, 340, 28)
        objects.set_style(jewelName, {
            text_color = 0xFFFFD768
        })

        local jewelCount = objects.create("text", "jewel_count", {
            text = string.format("Cantidad: %d", count),
            font = "bold",
            align = "center"
        })
        objects.set_rectangle(jewelCount, 20, 55, 340, 22)
        objects.set_style(jewelCount, {
            text_color = 0xFF9AE8FF
        })

        local withdrawLabel = objects.create("text", "withdraw_label", {
            text = "Retirar",
            font = "bold",
            align = "left"
        })
        objects.set_rectangle(withdrawLabel, 20, 90, 340, 20)
        objects.set_style(withdrawLabel, {
            text_color = 0xFFFFE8A0
        })

        local btn1 = objects.create("button", "btn_1", {
            text = "1"
        })
        objects.set_rectangle(btn1, 20, 120, 45, 30)
        objects.set_events(btn1, {
            on_click = function()
                jewelbank.withdraw(jewel_index, 1)
                jewelbank.request_refresh()
                jewel_list_bridge.sync_selected(nil)
                windows.close("jewelbank_detail")
            end
        })

        local btn10 = objects.create("button", "btn_10", {
            text = "10"
        })
        objects.set_rectangle(btn10, 75, 120, 45, 30)
        objects.set_events(btn10, {
            on_click = function()
                jewelbank.withdraw(jewel_index, 10)
                jewelbank.request_refresh()
                jewel_list_bridge.sync_selected(nil)
                windows.close("jewelbank_detail")
            end
        })

        local btn20 = objects.create("button", "btn_20", {
            text = "20"
        })
        objects.set_rectangle(btn20, 130, 120, 45, 30)
        objects.set_events(btn20, {
            on_click = function()
                jewelbank.withdraw(jewel_index, 20)
                jewelbank.request_refresh()
                jewel_list_bridge.sync_selected(nil)
                windows.close("jewelbank_detail")
            end
        })

        local btn30 = objects.create("button", "btn_30", {
            text = "30"
        })
        objects.set_rectangle(btn30, 185, 120, 45, 30)
        objects.set_events(btn30, {
            on_click = function()
                jewelbank.withdraw(jewel_index, 30)
                jewelbank.request_refresh()
                jewel_list_bridge.sync_selected(nil)
                windows.close("jewelbank_detail")
            end
        })

        local btn50 = objects.create("button", "btn_50", {
            text = "50"
        })
        objects.set_rectangle(btn50, 240, 120, 45, 30)
        objects.set_events(btn50, {
            on_click = function()
                jewelbank.withdraw(jewel_index, 50)
                jewelbank.request_refresh()
                jewel_list_bridge.sync_selected(nil)
                windows.close("jewelbank_detail")
            end
        })

        local btn100 = objects.create("button", "btn_100", {
            text = "100"
        })
        objects.set_rectangle(btn100, 295, 120, 65, 30)
        objects.set_events(btn100, {
            on_click = function()
                jewelbank.withdraw(jewel_index, 100)
                jewelbank.request_refresh()
                jewel_list_bridge.sync_selected(nil)
                windows.close("jewelbank_detail")
            end
        })

        local btnWithdrawMax = objects.create("button", "btn_withdraw_max", {
            text = "Retirar Todo"
        })
        objects.set_rectangle(btnWithdrawMax, 20, 160, 340, 35)
        objects.set_events(btnWithdrawMax, {
            on_click = function()
                jewelbank.withdraw(jewel_index, count)
                jewelbank.request_refresh()
                jewel_list_bridge.sync_selected(nil)
                windows.close("jewelbank_detail")
            end
        })

        local depositLabel = objects.create("text", "deposit_label", {
            text = "Depositar (Ctrl + Click Derecho en inventario)",
            font = "normal",
            align = "center"
        })
        objects.set_rectangle(depositLabel, 20, 210, 340, 18)
        objects.set_style(depositLabel, {
            text_color = 0xFF888888
        })

        local btnDepositAll = objects.create("button", "btn_deposit_all", {
            text = "Depositar Todo"
        })
        objects.set_rectangle(btnDepositAll, 20, 240, 340, 35)
        objects.set_events(btnDepositAll, {
            on_click = function()
                jewelbank.deposit(jewel_index, 999)
                jewelbank.request_refresh()
                jewel_list_bridge.sync_selected(nil)
                windows.close("jewelbank_detail")
            end
        })

        local btnCancel = objects.create("button", "btn_cancel", {
            text = "Cerrar"
        })
        objects.set_rectangle(btnCancel, 20, 290, 340, 35)
        objects.set_events(btnCancel, {
            on_click = function()
                windows.close("jewelbank_detail")
            end
        })

        detailWindow:add_obj(contentRoot)
        detailWindow:add_bound("detail_content", jewelName)
        detailWindow:add_bound("detail_content", jewelCount)
        detailWindow:add_bound("detail_content", withdrawLabel)
        detailWindow:add_bound("detail_content", btn1)
        detailWindow:add_bound("detail_content", btn10)
        detailWindow:add_bound("detail_content", btn20)
        detailWindow:add_bound("detail_content", btn30)
        detailWindow:add_bound("detail_content", btn50)
        detailWindow:add_bound("detail_content", btn100)
        detailWindow:add_bound("detail_content", btnWithdrawMax)
        detailWindow:add_bound("detail_content", depositLabel)
        detailWindow:add_bound("detail_content", btnDepositAll)
        detailWindow:add_bound("detail_content", btnCancel)
    end
end

local window = windows.create({
    id = "jewelbank_panel",
    title = "Banco de Jewels",
    x = 300,
    y = 100,
    width = 200,
    height = 320,
    hotkey = "J",
    closable = true,
    movable = true,
    on_open = function()
        jewelbank.request_refresh()
        jewel_list_bridge.sync_selected(nil)
    end,
    on_close = function()
        jewel_list_bridge.clear_selection()
        if detailWindow then
            windows.close("jewelbank_detail")
        end
    end
})

if window then
    window:set_close_button_layout(185, 3, 13, 14)
    window:set_title_align("center")
    
    local contentRoot = objects.create("panel", "jewelbank_content")
    objects.set_rectangle(contentRoot, 0, 24, 200, 296)
    objects.set_style(contentRoot, {
        header_visible = false,
        show_background = false,
        show_border = false,
        padding_left = 0,
        padding_top = 0,
        padding_right = 0,
        padding_bottom = 0
    })

    local jewelListFrame = objects.create("panel", "jewel_list_frame")
    objects.set_rectangle(jewelListFrame, 6, 6, 188, 284)
    objects.set_style(jewelListFrame, {
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

    local jewelList = objects.create("item_list", "jewel_list", {
        current_bind = "jewelbank_panel.selected_index",
        bind_items = function()
            return jewel_list_bridge.build_items()
        end,
        row_height = 40,
        model_size = 28,
        text_color = 0xFFF0F0F0,
        count_color = 0xFFE0E0E0,
        hover_color = 0xFF2A2A2A,
        selected_color = 0xFF4A3A2A
    })
    objects.set_rectangle(jewelList, 2, 2, 184, 280)
    objects.set_data_binding(jewelList, {
        current_bind = "jewelbank_panel.selected_index"
    })
    objects.set_events(jewelList, {
        on_item_selected = function(index)
            jewel_list_bridge.sync_selected(index)
            open_jewel_detail()
        end
    })

    local emptyHint = objects.create("text", "empty_hint", {
        text = "No hay joyas",
        align = "center",
        bind_text = function()
            if jewel_list_bridge.get_count() > 0 then
                return ""
            end
            return "No hay joyas"
        end
    })
    objects.set_rectangle(emptyHint, 6, 140, 188, 24)
    objects.set_style(emptyHint, {
        text_color = 0xFFFF7A7A
    })

    window:add_obj(contentRoot)
    window:add_bound("jewelbank_content", jewelListFrame)
    window:add_bound("jewel_list_frame", jewelList)
    window:add_bound("jewelbank_content", emptyHint)
end
