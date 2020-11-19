local _, GW = ...
local L = GW.L
local constBackdropFrame = GW.skins.constBackdropFrame
local SetSetting = GW.SetSetting
local GetSetting = GW.GetSetting

-- get local references
local eventFrame =  CreateFrame("FRAME");


local GuildFrame = nil

function GuildFrame_OnEvent(self, event, ...)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r " + event)
end

local function ClearMailTextures()
    _G.CommunitiesFrameBg:Hide()
    _G.CommunitiesFrameInset.NineSlice:Hide()
    _G.CommunitiesFrameInset:CreateBackdrop(constBackdropFrameBorder)

    CommunitiesFrame:StripTextures()
    CommunitiesFrame.NineSlice:Hide()
    CommunitiesFrame.TitleBg:Hide()
    CommunitiesFrame.TopTileStreaks:Hide()
    CommunitiesFrame:CreateBackdrop()

end

local function RegisterEvents()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r Registering Events for Guild frames " )

    eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE");
    eventFrame:RegisterEvent("PLAYER_GUILD_UPDATE");
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
    eventFrame:RegisterEvent("UPDATE_FACTION");
    eventFrame:RegisterEvent("GUILD_RENAME_REQUIRED");
    eventFrame:RegisterEvent("REQUIRED_GUILD_RENAME_RESULT");
    eventFrame:RegisterEvent("GUILD_MOTD");
    eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE");
    eventFrame:RegisterEvent("GUILD_RANKS_UPDATE");
    eventFrame:RegisterEvent("PLAYER_GUILD_UPDATE");
    eventFrame:RegisterEvent("LF_GUILD_POST_UPDATED");
    eventFrame:RegisterEvent("LF_GUILD_RECRUITS_UPDATED");
    eventFrame:RegisterEvent("LF_GUILD_RECRUIT_LIST_CHANGED");
    eventFrame:RegisterEvent("GUILD_CHALLENGE_UPDATED");
    eventFrame:RegisterEvent("GUILD_NEWS_UPDATE");
    eventFrame:RegisterEvent("GUILD_REWARDS_LIST");
    eventFrame:RegisterEvent("GUILD_TRADESKILL_UPDATE");
    eventFrame:RegisterEvent("GUILD_RECIPE_KNOWN_BY_MEMBERS");
    eventFrame:SetScript("OnEvent", GuildFrame_OnEvent)

end

local function SkinGuildFrames()

    RegisterEvents()

    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r loading guild frames " )

    if IsInGuild() and CanShowAchievementUI() then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r This should tell us if we can see the thing..." )
    end
    
    --have to force load the CommunitiesFrame first 
    if (not CommunitiesFrame) then
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r loading communities frames " )
        Communities_LoadUI();
        if not CommunitiesFrame:IsShown() then
            --ShowUIPanel(CommunitiesFrame);
            CommunitiesFrame:Show()
		end
    end
    --also need guild achieves
    if ( not AchievementFrame ) then
        
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r loading achievements frames " )
        AchievementFrame_LoadUI();
    end

    -- GuildFrame = _G.CommunitiesFrame

    local newWidth, newHeight = _G.CommunitiesFrame:GetSize()
    newWidth = (newWidth * 2.0) + 50
    newHeight = newHeight + 30
    _G.CommunitiesFrame:SetSize(newWidth, newHeight)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r finished loading guild frames " )
end
GW.SkinGuildFrames = SkinGuildFrames

SkinGuildFrames()