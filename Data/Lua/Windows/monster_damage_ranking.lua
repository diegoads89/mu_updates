local ui = SFUI.ui
local ranking = ui.import("systems.monster_damage_ranking")

local function boss_name_only(title)
    title = title or ""
    return title:match("%-%s*(.+)$") or title
end

local function translate_summary(summary)
    summary = summary or ""

    local top, count = summary:match("^Top%s+(%d+)%s*|%s*Participantes:%s*(%d+)")
    if top then
        return string.format("Top %s | Participants: %s", top, count)
    end

    if summary:match("Ranking finalizado") then
        return "Ranking finished."
    end

    return summary
end

local colors = {
    background = ui.color(8, 9, 11, 224),
    border = ui.color(99, 70, 38, 185),
    header = ui.color(41, 25, 15, 238),
    title = ui.color(255, 202, 104, 255),
    text = ui.color(236, 232, 222, 255),
    muted = ui.color(166, 158, 148, 255),
    gold = ui.color(255, 188, 58, 255),
}

local win = ui.window("monster_damage_ranking", {
    title = "",
    rect = ui.rect(175, 32, 200, 170),
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
    rect = ui.rect(10, 8, 180, 16),
    text = boss_name_only(ranking.get_title()),
    font = "bold",
    text_color = colors.title,
    align = "left",
})

win:text("ranking_summary", {
    rect = ui.rect(10, 24, 180, 14),
    text = translate_summary(ranking.get_summary()),
    bind = "monster_damage_ranking.summary",
    text_color = colors.muted,
    align = "left",
})

win:panel("header_divider", {
    rect = ui.rect(8, 40, 184, 1),
    header_visible = false,
    show_background = true,
    show_border = false,
    background_color = colors.gold,
    padding_left = 0,
    padding_top = 0,
    padding_right = 0,
    padding_bottom = 0,
})

win:meta_table("damage_rows", {
    rect = ui.rect(8, 44, 184, 118),
    header_height = 16,
    row_height = 16,
    show_header = true,
    source = "monster_damage_ranking.rows",
    columns = {
        { header = "#", field = "{$position}", width = 24, align = "center" },
        { header = "Character", field = "{$name}", width = 90, align = "left" },
        { header = "Damage", field = "{$damage_text}", width = 70, align = "right" },
    },
    style = {
        show_background = true,
        show_border = true,
        background_color = colors.background,
        border_color = colors.border,
        header_color = colors.header,
        header_text_color = colors.gold,
        row_text_color = colors.text,
        hover_row_color = ui.color(54, 38, 24, 200),
        selected_row_color = ui.color(111, 44, 12, 225),
    },
})

return win
