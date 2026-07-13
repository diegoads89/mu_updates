imports("package.windows")
imports("package.binding")
imports("package.controls.objects")
imports("package.client.attributes")
imports("package.systems.resets")

local function to_number(value, fallback)
    local parsed = tonumber(value)
    if parsed == nil then
        return fallback or 0
    end

    return parsed
end

local function format_number(value)
    local text = tostring(math.floor(to_number(value, 0)))
    local formatted = text

    while true do
        local next_text, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1.%2")
        formatted = next_text
        if count == 0 then
            break
        end
    end

    return formatted
end

local function get_current_reset_tab()
    return to_number(binding.get("reset_panel.tab"), 0)
end

local function get_active_reset_info()
    if get_current_reset_tab() == 1 then
        return resets.get_master_reset_info()
    end

    return resets.get_reset_info()
end

local function sync_reset_panel()
    local info = get_active_reset_info() or {}
    local name = info.name or "Reset"
    local enabled = info.enabled == true
    local current = to_number(info.current, 0)
    local max = to_number(info.max, 0)
    local min_level = to_number(info.min_level, 0)
    local min_reset = to_number(info.min_reset, 0)
    local req_money = to_number(info.req_money, 0)
    local reward_point = to_number(info.reward_point, 0)
    local target_count = current + 1
    local reward_label = "Reward"
    local requirements_label = attributes.get_global_text(2809) or "Requirements"
    local inactive_text = enabled and "" or "Sistema no disponible"
    local current_level = to_number(info.current_level, 0)
    local current_reset = to_number(info.current_reset, 0)
    local current_zen = to_number(info.current_zen, 0)
    local met_level = info.met_level == true
    local met_reset = info.met_reset == true
    local met_zen = info.met_zen == true

    binding.set("reset_panel.current_info", info)
    binding.set("reset_panel.required_items", info.required_items or {})
    binding.set("reset_panel.section_title", string.format("%s %d", name, target_count))
    binding.set("reset_panel.progress", string.format("%s: %d / %d", name, current, max))
    binding.set("reset_panel.requirements_title", requirements_label)
    binding.set("reset_panel.level_text", string.format("Level: %s / %s", format_number(current_level), format_number(min_level)))
    binding.set("reset_panel.reset_text", min_reset > 0 and string.format("Reset: %s / %s", format_number(current_reset), format_number(min_reset)) or "")
    binding.set("reset_panel.zen_text", string.format("Zen: %s / %s", format_number(current_zen), format_number(req_money)))
    binding.set("reset_panel.reward_title", reward_label)
    binding.set("reset_panel.reward_text", string.format("Reward Points: %s", format_number(reward_point)))
    binding.set("reset_panel.summary", info.summary or resets.get_summary())
    binding.set("reset_panel.inactive_text", inactive_text)
    binding.set("reset_panel.action_text", enabled and "Listo para revisar requisitos" or "Sin informacion disponible")
    binding.set("reset_panel.level_met", met_level and enabled)
    binding.set("reset_panel.reset_met", met_reset and enabled)
    binding.set("reset_panel.zen_met", met_zen and enabled)
end

binding.set("reset_panel.tab", 0)
sync_reset_panel()

local window = windows.create({
    id = "windowsresets",
    title = resets.get_title(),
    x = 600,
    y = 80,
    width = 292,
    height = 408,
    hotkey = "F8",
    fade_time = 0.25,
    closable = true,
    movable = true,
    on_open = function()
        resets.request_refresh()
        sync_reset_panel()
    end
})

if window then
    local contentRoot = objects.create("panel", "reset_content")
    objects.set_rectangle(contentRoot, 0, 24, 292, 384)
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
        text = resets.get_summary(),
        align = "center",
        font = "bold"
    })
    objects.set_rectangle(summary, 16, 40, 252, 18)
    objects.set_style(summary, {
        text_color = 0xFF9AE8FF
    })
    objects.set_data_binding(summary, {
        bind = "reset_panel.summary"
    })

    local tabs = objects.create("tabs", "reset_tabs", {
        spacing = 4,
        current_bind = "reset_panel.tab",
        texture = {
            path = "Lua\\Texture\\sfui_btn_tab.tga",
            u = 0,
            v = 0,
            uw = 224.0,
            vh = 88.0
        },
        tabs = {
            { text = "Reset", value = 0 },
            { text = "Master Reset", value = 1 }
        }
    })
    objects.set_rectangle(tabs, 34, 14, 56, 22)
    objects.set_events(tabs, {
        on_change = function(index, value)
            binding.set("reset_panel.tab", value)
            sync_reset_panel()
        end
    })

    local sectionTitle = objects.create("text", "section_title", {
        text = "Reset 1",
        align = "center",
        font = "big"
    })
    objects.set_rectangle(sectionTitle, 20, 64, 240, 24)
    objects.set_style(sectionTitle, {
        text_color = 0xFFFFD768
    })
    objects.set_data_binding(sectionTitle, {
        bind = "reset_panel.section_title"
    })

    local progress = objects.create("text", "progress", {
        text = "Reset: 0 / 0",
        align = "center",
        font = "bold"
    })
    objects.set_rectangle(progress, 20, 92, 240, 18)
    objects.set_style(progress, {
        text_color = 0xFFFFF6B4
    })
    objects.set_data_binding(progress, {
        bind = "reset_panel.progress"
    })

    local inactiveText = objects.create("text", "inactive_text", {
        text = "",
        align = "center",
        font = "bold"
    })
    objects.set_rectangle(inactiveText, 20, 112, 240, 18)
    objects.set_style(inactiveText, {
        text_color = 0xFFFF7A7A
    })
    objects.set_data_binding(inactiveText, {
        bind = "reset_panel.inactive_text"
    })

    local requirementsTitle = objects.create("text", "requirements_title", {
        text = attributes.get_global_text(2809),
        font = "bold"
    })
    objects.set_rectangle(requirementsTitle, 20, 130, 240, 18)
    objects.set_style(requirementsTitle, {
        text_color = 0xFFFFA644,
        background_color = 0x6A000000
    })
    objects.set_data_binding(requirementsTitle, {
        bind = "reset_panel.requirements_title"
    })

    local levelText = objects.create("text", "level_text", {
        text = "Level: 0"
    })
    objects.set_rectangle(levelText, 20, 152, 240, 18)
    objects.set_style(levelText, {
        text_color = 0xFF59FF7A,
        disabled_text_color = 0xFF9A9A9A
    })
    objects.set_data_binding(levelText, {
        bind = "reset_panel.level_text",
        enabled_bind = "reset_panel.level_met"
    })

    local resetText = objects.create("text", "reset_text", {
        text = ""
    })
    objects.set_rectangle(resetText, 20, 170, 240, 18)
    objects.set_style(resetText, {
        text_color = 0xFF59FF7A,
        disabled_text_color = 0xFF9A9A9A
    })
    objects.set_data_binding(resetText, {
        bind = "reset_panel.reset_text",
        enabled_bind = "reset_panel.reset_met"
    })

    local zenText = objects.create("text", "zen_text", {
        text = "Zen: 0"
    })
    objects.set_rectangle(zenText, 20, 188, 240, 18)
    objects.set_style(zenText, {
        text_color = 0xFF59FF7A,
        disabled_text_color = 0xFF9A9A9A
    })
    objects.set_data_binding(zenText, {
        bind = "reset_panel.zen_text",
        enabled_bind = "reset_panel.zen_met"
    })

    local rewardTitle = objects.create("text", "reward_title", {
        text = "Reward",
        font = "bold"
    })
    objects.set_rectangle(rewardTitle, 20, 218, 240, 18)
    objects.set_style(rewardTitle, {
        text_color = 0xFFFFA644,
        background_color = 0x6A000000
    })
    objects.set_data_binding(rewardTitle, {
        bind = "reset_panel.reward_title"
    })

    local rewardText = objects.create("text", "reward_text", {
        text = "Reward Points: 0"
    })
    objects.set_rectangle(rewardText, 20, 240, 240, 18)
    objects.set_style(rewardText, {
        text_color = 0xFF59FF7A
    })
    objects.set_data_binding(rewardText, {
        bind = "reset_panel.reward_text"
    })

    local requiredItemsTitle = objects.create("label", "required_items_title", {
        text = "Required Items",
        font = "bold"
    })
    objects.set_rectangle(requiredItemsTitle, 20, 270, 240, 18)
    objects.set_style(requiredItemsTitle, {
        text_color = 0xFFFFA644,
        background_color = 0x6A000000
    })

    local requiredItems = objects.create("item_list", "required_items", {
        row_height = 26,
        model_size = 22
    })
    objects.set_rectangle(requiredItems, 20, 292, 240, 54)
    objects.set_data_binding(requiredItems, {
        bind = "reset_panel.required_items"
    })
    objects.set_events(requiredItems, {
        on_item_selected = function(index)
        end
    })

    local refreshButton = objects.create("button", "refresh", {
        text = "Actualizar"
    })
    objects.set_rectangle(refreshButton, 20, 358, 100, 20)
    objects.set_events(refreshButton, {
        on_click = function()
            resets.request_refresh()
            sync_reset_panel()
        end
    })

    local closeButton = objects.create("button", "close", {
        text = "Cerrar"
    })
    objects.set_rectangle(closeButton, 160, 358, 100, 20)
    objects.set_events(closeButton, {
        on_click = function()
            window:close()
        end
    })

    window:add_obj(contentRoot)
    window:add_bound("reset_content", summary)
    window:add_bound("reset_content", tabs)
    window:add_bound("reset_content", sectionTitle)
    window:add_bound("reset_content", progress)
    window:add_bound("reset_content", inactiveText)
    window:add_bound("reset_content", requirementsTitle)
    window:add_bound("reset_content", levelText)
    window:add_bound("reset_content", resetText)
    window:add_bound("reset_content", zenText)
    window:add_bound("reset_content", rewardTitle)
    window:add_bound("reset_content", rewardText)
    window:add_bound("reset_content", requiredItemsTitle)
    window:add_bound("reset_content", requiredItems)
    window:add_bound("reset_content", refreshButton)
    window:add_bound("reset_content", closeButton)
end
