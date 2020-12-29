local _, GW = ...
local L = GW.L
local addOptionDropdown = GW.AddOptionDropdown
local addOptionSlider = GW.AddOptionSlider
local addOptionText = GW.AddOptionText
local createCat = GW.CreateCat
local InitPanel = GW.InitPanel
local StrUpper = GW.StrUpper

local function LoadPlayerPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(PLAYER)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Modify the player frame settings."])

    createCat(PLAYER, L["Modify the player frame settings."], p, 9)

    addOptionDropdown(
        p,
        L["Aura Style"],
        nil,
        "PLAYER_AURA_STYLE",
        nil,
        {"LEGACY", "SECURE"},
        {
            LFG_LIST_LEGACY,
            L["Secure"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionSlider(
        p,
        L["Auras per row"],
        nil,
        "PLAYER_AURA_WRAP_NUM",
        nil,
        1,
        20,
        nil,
        0,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionSlider(
        p,
        L["Buff size"],
        nil,
        "PlayerBuffFrame_ICON_SIZE",
        nil,
        16,
        60,
        nil,
        0,
        {["PLAYER_BUFFS_ENABLED"] = true},
        2
    )
    addOptionSlider(
        p,
        L["Debuff size"],
        nil,
        "PlayerDebuffFrame_ICON_SIZE",
        nil,
        16,
        60,
        nil,
        0,
        {["PLAYER_BUFFS_ENABLED"] = true},
        2
    )
    addOptionDropdown(
        p,
        L["Player Buff Growth Direction"],
        nil,
        "PlayerBuffFrame_GrowDirection",
        GW.UpdateHudScale(),
        {"UP", "DOWN", "UPR", "DOWNR"},
        {
            StrUpper(L["Up"], 1, 1),
            StrUpper(L["Down"], 1, 1),
            L["Up and right"],
            L["Down and right"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["Player Debuffs Growth Direction"],
        nil,
        "PlayerDebuffFrame_GrowDirection",
        GW.UpdateHudScale(),
        {"UP", "DOWN", "UPR", "DOWNR"},
        {
            StrUpper(L["Up"], 1, 1),
            StrUpper(L["Down"], 1, 1),
            L["Up and right"],
            L["Down and right"]
        },
        nil,
        {["PLAYER_BUFFS_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT,
        nil,
        "PLAYER_UNIT_HEALTH",
        nil,
        {"NONE", "PREC", "VALUE", "BOTH"},
        {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["Show Shield Value"],
        nil,
        "PLAYER_UNIT_ABSORB",
        nil,
        {"NONE", "PREC", "VALUE", "BOTH"},
        {NONE, STATUS_TEXT_PERCENT, STATUS_TEXT_VALUE, STATUS_TEXT_BOTH},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )

    addOptionDropdown(
        p,
        L["Class Totems Sorting"],
        nil,
        "TotemBar_SortDirection",
        nil,
        {"ASC", "DSC"},
        {L["Ascending"], L["Descending"]},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )
    addOptionDropdown(
        p,
        L["Class Totems Growth Direction"],
        nil,
        "TotemBar_GrowDirection",
        nil,
        {"HORIZONTAL", "VERTICAL"},
        {L["Horizontal"], L["Vertical"]},
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )
    addOptionText(p,
        L["Dodge Bar Ability"],
        L["Enter the spell ID which should be tracked by the dodge bar.\nIf no ID is entered, the default abilities based on your specialization and talents are tracked."],
        "PLAYER_TRACKED_DODGEBAR_SPELL",
        function(self)
            local spellId = self:GetNumber()
            local name = ""
            if spellId > 0 and IsSpellKnown(spellId) then
                name = GetSpellInfo(spellId)
            end
            self:SetText(name)
            GW.SetSetting("PLAYER_TRACKED_DODGEBAR_SPELL", name)
            GW.SetSetting("PLAYER_TRACKED_DODGEBAR_SPELL_ID", spellId)
            GW.initDodgebarSpell(GwDodgeBar)
            GW.setDodgebarSpell(GwDodgeBar)
        end,
        nil,
        nil,
        {["HEALTHGLOBE_ENABLED"] = true}
    )

    InitPanel(p)
end
GW.LoadPlayerPanel = LoadPlayerPanel
