imports("package.windows")
imports("package.controls.objects")
imports("package.systems.rankings")

local window = windows.create({
    id = "rankings",
    title = rankings.get_title(),
    x = 40,
    y = 80,
    width = 360,
    height = 230,
    hotkey = "F6",
    fade_time = 0.15,
    closable = true,
    movable = true,
    on_open = function()
        rankings.request_refresh()
    end
})

if window then
    window:set_close_button_layout(345, 3, 13, 14)
    window:set_header_visible(false)
    window:set_border_visible(false)
    window:set_background_fill_visible(false)
    window:set_header_height(20)
    window:set_title_position(180, 0)
    window:set_title_align("center")

    window:set_background_texture({
        path = "Engine\\HUD\\panel_back08.tga",
        u = 0.0,
        v = 0.0,
        uw = 530.0,
        vh = 344.0
    })

    window:set_close_button_texture({
        path = "Lua\\Texture\\sfui_btn_exit.jpg",
        state_height = 56,
        default_over = true,
        default_click = true,
        default_disable = true,
        u = 0.0,
        v = 0.0,
        uw = 52.0,
        vh = 56.0
    })

    local contentRoot = objects.create("panel", "rankings_content")
    objects.set_rectangle(contentRoot, 0, 20, 360, 210)
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
        text = rankings.get_summary()
    })
    objects.set_rectangle(summary, 12, 3, 220, 18)
    objects.set_data_binding(summary, {
        bind = "rankings.summary"
    })

    local selector = objects.create("selector", "tabs", {
        wrap = false
    })
    objects.set_rectangle(selector, 140, 186, 94, 22)
    objects.set_data_binding(selector, {
        current_bind = "rankings.current_tab",
        max_bind = "rankings.max_tabs",
        format_text = function(current, max)
            return string.format("%d / %d", current + 1, max)
        end
    })
    objects.set_events(selector, {
        on_change = function(index)
            rankings.request_tab(index)
        end
    })

    local rankingTable = objects.create("meta_table", "ranking_table", {
        header_height = 18,
        row_height = 16,
        show_header = true,
        columns = {
            { header = "#", field = "{$idx}", width = 26, align = "center" },
            { header = "Personagem:", field = "{$name}", width = 110, align = "left" },
            { header = "Class", field = "{$class}", width = 70, align = "center" },
            { header = "Score", template = "{$score}", width = 60, align = "center" }
        }
    })
    objects.set_rectangle(rankingTable, 20, 16, 220, 160)
    objects.set_style(rankingTable, {
        border_color = 0xFF000000,
        selected_row_color = 0xA05A2A14,
        hover_row_color = 0x80383846,
        header_text_color = 0xFFFFE4C0,
        row_text_color = 0xFFF4F4F4
    })
    objects.set_data_binding(rankingTable, {
        source = "rankings.rows"
    })
    objects.set_events(rankingTable, {
        on_row_selected = function(rowIndex)
            rankings.request_character(rowIndex)
        end
    })

    local preview = objects.create("character_preview", "ranking_preview", {
        interactive = false,
        copy_hero_on_invalid = true,
        angle = 90.0,
        zoom = 0.80
    })
    objects.set_rectangle(preview, 268, 0, 90, 210)
    objects.set_data_binding(preview, {
        bind = "rankings.preview"
    })

    window:add_obj(contentRoot)
    window:add_bound("rankings_content", summary)
    window:add_bound("rankings_content", selector)
    window:add_bound("rankings_content", rankingTable)
    window:add_bound("rankings_content", preview)
end
