local ui = SFUI.ui
local ranking = ui.import("systems.monster_damage_ranking")

local colors = {
    background = ui.color(7, 7, 9, 220),
    border = ui.color(116, 77, 35, 235),
    header = ui.color(41, 25, 15, 238),
    title = ui.color(255, 205, 112, 255),
    text = ui.color(238, 232, 218, 255),
    muted = ui.color(178, 168, 151, 255),
    gold = ui.color(255, 193, 73, 255),
}

local win = ui.window("monster_damage_ranking", {
    title = "",
    rect = ui.rect(175, 32, 290, 224),
    fade_time = 0.12,
    closable = false,
    movable = true,
    show_header = false,
    show_border = true,
    show_background = true,
    background_color = colors.background,
    border_color = colors.border,
})

win:text("ranking_title", {
    rect = ui.rect(10, 8, 270, 18),
    text = ranking.get_title(),
    bind = "monster_damage_ranking.title",
    font = "bold",
    color = colors.title,
    align = "center",
})

win:text("ranking_summary", {
    rect = ui.rect(10, 28, 270, 16),
    text = ranking.get_summary(),
    bind = "monster_damage_ranking.summary",
    color = colors.muted,
    align = "center",
})

win:meta_table("damage_rows", {
    rect = ui.rect(10, 49, 270, 165),
    header_height = 19,
    row_height = 14,
    show_header = true,
    source = "monster_damage_ranking.rows",
    columns = {
        { header = "#", field = "{$position}", width = 28, align = "center" },
        { header = "Personagem", field = "{$name}", width = 132, align = "left" },
        { header = "Dano", field = "{$damage_text}", width = 104, align = "right" },
    },
    style = {
        show_background = true,
        show_border = true,
        background_color = colors.background,
        border_color = colors.border,
        header_color = colors.header,
        header_text_color = colors.gold,
        row_text_color = colors.text,
        hover_row_color = ui.color(90, 54, 27, 160),
        selected_row_color = ui.color(116, 68, 28, 180),
    },
})

return win
