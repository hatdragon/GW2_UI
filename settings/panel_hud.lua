local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionButton = GW.AddOptionButton
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(UIOPTIONS_MENU)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])

    createCat(UIOPTIONS_MENU, L["Edit the HUD modules."], p, 3)

    addOption(p, L["Show HUD background"], L["The HUD background changes color in the following situations: In Combat, Not In Combat, In Water, Low HP, Ghost"], "HUD_BACKGROUND")
    addOption(p, L["Dynamic HUD"], L["Enable or disable the dynamically changing HUD background."], "HUD_SPELL_SWAP", nil, nil, {["HUD_BACKGROUND"] = true})
    addOption(p, L["Fade Chat"], L["Allow the chat to fade when not in use."], "CHATFRAME_FADE", nil, nil, {["CHATFRAME_ENABLED"] = true})
    addOption(p, L["Toggle Compass"], L["Enable or disable the quest tracker compass."], "SHOW_QUESTTRACKER_COMPASS", nil, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p, L["Advanced Casting Bar"], L["Enable or disable the advanced casting bar."], "CASTINGBAR_DATA", nil, nil, {["CASTINGBAR_ENABLED"] = true})
    addOption(p, L["Fade Menu Bar"], L["The main menu icons will fade when you move your cursor away."], "FADE_MICROMENU")
    addOption(p, DISPLAY_BORDERS, nil, "BORDER_ENABLED")
    addOption(p, WORLD_MARKER:format(0):gsub("%d", ""), L["Show menu for placing world markers when in raids."], "WORLD_MARKER_FRAME")
    addOption(p, L["Show Coordinates on World Map"], L["Show Coordinates on World Map"], "WORLDMAP_COORDS_TOGGLE", nil, nil)
    addOption(p, L["Show FPS on minimap"], L["Show FPS on minimap"], "MINIMAP_FPS", nil, nil, {["MINIMAP_ENABLED"] = true})
    addOption(p, L["Show Coordinates on Minimap"], L["Show Coordinates on Minimap"], "MINIMAP_COORDS_TOGGLE", nil, nil, {["MINIMAP_ENABLED"] = true})
    addOption(p, L["Fade Group Manage Button"], L["The Group Manage Button will fade when you move the cursor away."], "FADE_GROUP_MANAGE_FRAME", nil, nil, {["PARTY_FRAMES"] = true})
    addOption(
        p,
        L["Pixel Perfect Mode"],
        L["Scales the UI into a Pixel Perfect Mode. This is dependent on screen resolution."],
        "PIXEL_PERFECTION",
        function()
            SetCVar("useUiScale", 0)
            GW.PixelPerfection()
        end
    )
    addOption(p, L["AFK Mode"], L["When you go AFK, display the AFK screen."], "AFK_MODE")
    addOptionDropdown(
        p,
        COMBAT_TEXT_LABEL,
        COMBAT_SUBTEXT,
        "GW_COMBAT_TEXT_MODE",
        nil,
        {"GW2", "BLIZZARD", "OFF"},
        {L["GW2 UI Settings"], "Blizzard", OFF .. " / " .. OTHER .. " " .. ADDONS}
    )
    addOption(p, COMBAT_TEXT_LABEL .. L[": Use Blizzard colors"], nil, "GW_COMBAT_TEXT_BLIZZARD_COLOR", nil, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"})
    addOption(p, COMBAT_TEXT_LABEL .. L[": Show numbers with commas"], nil, "GW_COMBAT_TEXT_COMMA_FORMAT", nil, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"})
    addOptionSlider(
        p,
        L["HUD Scale"],
        L["Change the HUD size."],
        "HUD_SCALE",
        GW.UpdateHudScale,
        0.5,
        1.5,
        nil,
        2
    )
    addOptionButton(p, L["Apply UI scale to all scaleable frames"], L["Applies the UI scale to all frames, which can be scaled in 'Move HUD' mode."], nil, function()
        local scale = GetSetting("HUD_SCALE")
        for _, mf in pairs(GW.scaleableFrames) do
            mf.gw_frame:SetScale(scale)
            mf:SetScale(scale)
            GW.SetSetting(mf.gw_Settings .."_scale", scale)
        end
    end)
    addOptionDropdown(
        p,
        L["Minimap details"],
        L["Always show Minimap details."],
        "MINIMAP_HOVER",
        GW.SetMinimapHover,
        {"NONE", "ALL", "CLOCK", "ZONE", "COORDS", "CLOCKZONE", "CLOCKCOORDS", "ZONECOORDS"},
        {
            NONE_KEY,
            ALL,
            TIMEMANAGER_TITLE,
            ZONE,
            L["Coordinates"],
            TIMEMANAGER_TITLE .. " + " .. ZONE,
            TIMEMANAGER_TITLE .. " + " .. L["Coordinates"],
            ZONE .. " + " .. L["Coordinates"]
        },
        nil,
        {["MINIMAP_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["Minimap Scale"],
        L["Change the Minimap size."],
        "MINIMAP_SCALE",
        function()
            local size = GetSetting("MINIMAP_SCALE")
            Minimap:SetSize(size, size)
            Minimap.gwMover:SetSize(size, size)
        end,
        {250, 200, 170},
        {
            LARGE,
            TIME_LEFT_MEDIUM,
            DEFAULT
        },
        nil,
        {["MINIMAP_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["Auto Repair"],
        L["Automatically repair using the following method when visiting a merchant."],
        "AUTO_REPAIR",
        nil,
        {"NONE", "PLAYER", "GUILD"},
        {
            NONE_KEY,
            PLAYER,
            GUILD,
        }
    )

    InitPanel(p)
end
GW.LoadHudPanel = LoadHudPanel
