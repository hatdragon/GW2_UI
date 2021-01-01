local _, GW = ...
local L = GW.L

local newWidth = 853
local newHeight = 627
local IsCommunityHooked = false

--get local references
local communitiesFrame
local guildDetailsFrame 
local guildBenefitsFrame
local guildLogButton 

local constBackdropFrame = GW.skins.constBackdropFrame

local function setFontColorToWhite(self)
    self:SetTextColor(1, .93, .73)
end


local eventFrame =  CreateFrame("FRAME");

local COMMUNITIES_FRAME_EVENTS = {
    "ADDON_LOADED",
    "INITIAL_CLUBS_LOADED",
	"CLUB_STREAMS_LOADED",
	"CLUB_STREAM_ADDED",
	"CLUB_STREAM_REMOVED",
	"CLUB_ADDED",
	"CLUB_REMOVED",
	"CLUB_UPDATED",
	"CLUB_SELF_MEMBER_ROLE_UPDATED",
	"STREAM_VIEW_MARKER_UPDATED",
	"BN_DISCONNECTED",
	"PLAYER_GUILD_UPDATE",
	"CHANNEL_UI_UPDATE",
	"UPDATE_CHAT_COLOR",
	"GUILD_RENAME_REQUIRED",
	"REQUIRED_GUILD_RENAME_RESULT",
	"CLUB_FINDER_RECRUITMENT_POST_RETURNED",
	"CLUB_FINDER_ENABLED_OR_DISABLED",
};

local CLUB_FINDER_APPLICANT_LIST_EVENTS = {
	"GUILD_ROSTER_UPDATE",
    "CLUB_FINDER_RECRUITS_UPDATED",
    "CLUB_INVITATION_ADDED_FOR_SELF",
    "CLUB_INVITATION_REMOVED_FOR_SELF"
};

local GUILD_EVENTS = {
    "GUILD_MOTD",
    "GUILD_ROSTER_UPDATE",
    "GUILD_RANKS_UPDATE",
    "PLAYER_GUILD_UPDATE",
    "GUILD_CHALLENGE_UPDATED"
};

local tabNames = { -- Names of the tabs
	COMMUNITIES_CHAT_TAB_TOOLTIP,
	GUILD_TAB_NEWS,
	GUILD_TAB_ROSTER,
	GUILD_TAB_PERKS,
	GUILD_TAB_REWARDS,
	GUILD_TAB_INFO
}

local function debug(text)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI (DEBUG):|r " .. tostring(text))
end

-- local classicTabFrame = CreateFrame("FRAME")
-- local function wireUpTabs() 
    
--     debug("Begin wiring up tabs")
    
-- 	classicTabFrame.Tabs = classicTabFrame.Tabs or {}
-- 	if #classicTabFrame.Tabs >= 6 then return end -- Buttons already crated
-- 	for i = 1, 6 do
-- 		local tab = CreateFrame("Button", "ClassicTab"..i, classicTabFrame, "CharacterFrameTabButtonTemplate", i)
-- 		if i == 1 then
-- 			tab:SetPoint("BOTTOMLEFT", 0, -20)

-- 			local t = tab:CreateTexture("$parentHighlightGlow", "ARTWORK")
-- 			t:SetPoint("TOPLEFT", 12, -2)
-- 			t:SetPoint("BOTTOMRIGHT", -12, 7)
-- 			t:SetBlendMode("ADD")
-- 			t:Hide()
-- 			tab.Glow = t
-- 		else
-- 			tab:SetPoint("LEFT", classicTabFrame.Tabs[i-1], "RIGHT", -15, 0)
-- 		end
-- 		tab:SetText(tabNames[i])
-- 		tab:SetScript("OnShow", _TabShow)
-- 		tab:SetScript("OnClick", _TabClick)

-- 		classicTabFrame.Tabs[i] = tab
-- 	end
-- 	PanelTemplates_SetNumTabs(classicTabFrame, 6)
-- 	classicTabFrame:Hide()
-- end

local function CreateSubheadingFrame(title, width, height, x, y, textString, parent, fontsize, customBg)
    debug("Create " .. title .. " subheader frame")
    if parent == nil then return end

    local subheading = CreateFrame("FRAME", title.."Header", parent)

    subheading.HeadingBg = communitiesFrame:CreateTexture("bg", "BACKGROUND")
    subheading.HeadingBg:SetSize(width, height)
    subheading.HeadingBg:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", y, x)

    if customBg~=nil then
        subheading.HeadingBg:SetTexture(customBg)
    else
        subheading.HeadingBg:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")
    end

    subheading.HeadingBg.Title = communitiesFrame:CreateFontString(title.."FrameTitle", "ARTWORK")
    if customBg~=nil then
        subheading.HeadingBg.Title:SetPoint("TOPLEFT", subheading.HeadingBg, "TOPLEFT", 32, -7)
    else
        subheading.HeadingBg.Title:SetPoint("TOPLEFT", subheading.HeadingBg, "TOPLEFT", 10, -22)
    end
        -- body
    subheading.HeadingBg.Title:SetFont(DAMAGE_TEXT_FONT, fontsize)
    subheading.HeadingBg.Title:SetText(textString)
    subheading.HeadingBg.Title:SetTextColor(1, .93, .73)

    return subheading
end

local function CreateFrameSectionWithHeader(title, width, height, x, y, textString, parent, fontsize, customBg) 
    debug("Create " .. title .. " Frame with header")
    if parent == nil then return end
    
    local sectionFrame = CreateFrame("FRAME", title, parent);
    sectionFrame:SetParent(parent)
    sectionFrame:SetSize(width, height)
    sectionFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    sectionFrame.heading = CreateSubheadingFrame(title, width, 24, 10, 10, textString, sectionFrame, fontsize, customBg) 

    return sectionFrame
end


local function ConfigureMover()
    debug("Configure Mover")
    -- movable stuff
    local pos = GW.GetSetting("COMMUNITYFRAME_POSITION")

    communitiesFrame.mover = CreateFrame("Frame", nil, _G.CommunitiesFrame)
    communitiesFrame.mover:EnableMouse(true)
    communitiesFrame:SetMovable(true)
    communitiesFrame.mover:SetSize(newWidth, 30)
    communitiesFrame.mover:SetPoint("BOTTOMLEFT", communitiesFrame, "TOPLEFT", 0, 0)
    communitiesFrame.mover:SetPoint("BOTTOMRIGHT", communitiesFrame, "TOPRIGHT", 0, 0)
    communitiesFrame.mover:RegisterForDrag("LeftButton")
    communitiesFrame.mover.onMoveSetting = "COMMUNITYFRAME_POSITION"
    communitiesFrame:SetClampedToScreen(true)
    communitiesFrame.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving() 
    end)
    communitiesFrame.mover:SetScript("OnDragStop", function(self)
        local self = self:GetParent()

        self:StopMovingOrSizing()

        local x = self:GetLeft()
        local y = self:GetTop()

        -- re-anchor to UIParent after the move
        self.SetPoint = nil -- Make SetPoint accessable
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
        self.SetPoint = GW.NoOp -- Prevent Blizzard to reanchor that frame

        -- store the updated position
        if self.mover.onMoveSetting then
            local pos = GW.GetSetting(self.mover.onMoveSetting)
            if pos then
                wipe(pos)
            else
                pos = {}
            end
            pos.point = "TOPLEFT"
            pos.relativePoint = "BOTTOMLEFT"
            pos.xOfs = x
            pos.yOfs = y
            GW.SetSetting(self.mover.onMoveSetting, pos)
        end
    end)
    communitiesFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    communitiesFrame.SetPoint = GW.NoOp -- Prevent Blizzard to reanchor that frame
   
end

local function SkinMainPageChatArea()
    debug("Skin Main Page Chat Area")

    local listWidth = 275

    local myFrame = CreateFrameSectionWithHeader("theCommunitiesList", 200, listWidth, 0, -35, GUILD_AND_COMMUNITIES, communitiesFrame.CommunitiesList, 10, "Interface/AddOns/GW2_UI/textures/guild/guild-subhead-short")
    
    communitiesFrame.CommunitiesList:SetWidth(listWidth)
    communitiesFrame.CommunitiesList.ListScrollFrame:SetWidth(listWidth)
    CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar:Hide()
    
    local leaveButton = CreateFrame("Button", "leaveGuild", myFrame, "UIPanelButtonNoTooltipTemplate")
    leaveButton:ClearAllPoints()
    leaveButton:SetPoint("TOPLEFT",communitiesFrame.CommunitiesList, "BOTTOMLEFT", 0, 0)
    leaveButton:SetText("Leave Guild")
    leaveButton:SetWidth(communitiesFrame.CommunitiesList:GetWidth())
    leaveButton:SkinButton(false, true)
    leaveButton:SetScript("OnClick", function()
        debug("type /gquit then n00b.")
    end)

    local myFrame2 = CreateFrameSectionWithHeader("theChatFrame", 200, communitiesFrame.Chat:GetWidth(), listWidth-75, -45 ,COMMUNITIES_CHAT_TAB_TOOLTIP, communitiesFrame, 10, "Interface/AddOns/GW2_UI/textures/guild/guild-subhead-long")


    -- CommunitiesFrameCommunitiesList:ClearAllPoints()
    --CommunitiesFrameCommunitiesList:SetPoint("BOTTOMLEFT", myFrame.theCommunitiesList, "TOPLEFT", 0,0)
    -- CommunitiesFrameCommunitiesList:SetWidth(275)
    -- CommunitiesFrameCommunitiesList.InsetFrame:SetWidth(275)
    -- CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar:Hide()
    
    
    -- myFrame.Icon = myFrame:CreateTexture("sectionHeaderIcon", "ARTWORK")
    -- myFrame.Icon:SetSize(24,24)
    -- myFrame.Icon:SetPoint("TOPLEFT", myFrame, "TOPLEFT", 0, 35)
    -- myFrame.Icon:SetTexture("Interface/AddOns/GW2_UI/textures/guild/guild-flag-icon")
    -- myFrame.Icon:SetTexCoord(0, 0.7099, 0, 0.955);

    -- myFrame.headingRight = myFrame:CreateTexture("bg", "BACKGROUND")
    -- myFrame.headingRight:SetSize(160, 24)
    -- myFrame.headingRight:SetPoint("TOPLEFT", myFrame, "TOPLEFT", 0, 34)
    -- myFrame.headingRight:SetTexture("Interface/AddOns/GW2_UI/textures/guild/guild-subhead-short")


    
    -- communitiesFrame.MainPageChatFrame = CreateFrameSectionWithHeader("CommunitiesChatSection", newWidth-425, 392, 50, -100, COMMUNITIES_CHAT_TAB_TOOLTIP,  communitiesFrame.Chat, 14)


    -- communitiesFrame.MainPageChatFrame = CreateFrame("FRAME","ChatHeader", communitiesFrame.Chat)
    -- communitiesFrame.MainPageChatFrame:SetSize(newWidth-425, 392)
    -- communitiesFrame.MainPageChatFrame:SetPoint("TOPLEFT", communitiesFrame.MOTDFrame, "BOTTOMLEFT", 0, -10)

    -- communitiesFrame.MainPageChatFrame.Subheading = CreateSubheadingFrame("", 400, 42, 20, -10, COMMUNITIES_CHAT_TAB_TOOLTIP,  communitiesFrame.MainPageChatFrame, 12)
    -- communitiesFrame.Chat.MessageFrame:SetSize(newWidth-425, 350)
    -- communitiesFrame.Chat.MessageFrame:SetPoint("TOPLEFT", communitiesFrame.MainPageChatFrame.Subheading, "TOPLEFT", 150, -350)
    -- communitiesFrame.Chat.MessageFrame:SetSize(communitiesFrame.Chat:GetWidth(), 350)
    -- communitiesFrame.Chat.MessageFrame.ScrollBar:SetHeight(350)
    -- communitiesFrame.Chat.MessageFrame.FontStringContainer:SetSize(newWidth-325, 350)

    communitiesFrame.StreamDropDownMenu:SkinDropDownMenu()
    communitiesFrame.StreamDropDownMenu:ClearAllPoints()
    communitiesFrame.StreamDropDownMenu.Text:SetPoint("TOPRIGHT", communitiesFrame.StreamDropDownMenu, "TOPRIGHT", 50, -7 )
    communitiesFrame.StreamDropDownMenu:SetPoint("TOPLEFT", myFrame2, "TOPLEFT", 20, -20)
    -- communitiesFrame.StreamDropDownMenu:SetPoint("TOPLEFT",communitiesFrame.Chat.MessageFrame, "TOPLEFT", 340, 42 )
    -- communitiesFrame.AddToChatButton:SetPoint("TOPRIGHT",communitiesFrame.StreamDropDownMenu, "TOPLEFT", -10, -5 )
    
     GW.MutateInaccessableObject(communitiesFrame.AddToChatButton, "FontString", setFontColorToWhite)
    -- GW.MutateInaccessableObject(communitiesFrame.AddToChatButton, "Icon", setButtonStuff)

    -- -- communitiesFrame.AddToChatButton.icon:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    -- -- communitiesFrame.AddToChatButton.icon:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    -- -- communitiesFrame.AddToChatButton.icon:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    -- -- communitiesFrame.AddToChatButton.icon:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    
end


local function SkinMOTDArea()
    debug("Skin MOTD Area")
    -- --communitiesFrame.MOTDFrame = CreateFrameSectionWithHeader("CommunitiesMOTDSection", newWidth-425, 150, 1, 1, GUILD_MOTD_LABEL,  communitiesFrame.Chat, 12)
    
    -- communitiesFrame.MOTDFrame = CreateFrame("FRAME", "MOTD", communitiesFrame.Chat)
    -- communitiesFrame.MOTDFrame:SetParent(communitiesFrame.Chat)

    -- communitiesFrame.MOTDFrame:SetParent(communitiesFrame.Chat)
    -- communitiesFrame.MOTDFrame:SetSize(newWidth-325, 150)
    -- communitiesFrame.MOTDFrame:SetPoint("TOPLEFT", communitiesFrame.Chat, "TOPLEFT", 1, 1)
    -- communitiesFrame.MOTDFrame.Subheading = CreateSubheadingFrame("MOTD",newWidth-325, 42, -42, -10, GUILD_MOTD_LABEL, communitiesFrame.MOTDFrame, 12)

    -- guildDetailsFrame.Info.MOTDScrollFrame:SetParent(communitiesFrame.MOTDFrame)
    -- guildDetailsFrame.Info.MOTDScrollFrame:SetWidth(450)
    -- guildDetailsFrame.Info.MOTDScrollFrame.MOTD:SetWidth(450)
    -- guildDetailsFrame.Info.MOTDScrollFrame:SetPoint("TOPLEFT", communitiesFrame.MOTDFrame, "TOPLEFT", 10, -50)

    -- guildDetailsFrame.Info.EditMOTDButton:SetParent(communitiesFrame.MOTDFrame)
    -- guildDetailsFrame.Info.EditMOTDButton:StripTextures(true)
    -- guildDetailsFrame.Info.EditMOTDButton:SetText(EDIT)
    -- guildDetailsFrame.Info.EditMOTDButton:SetPoint("TOPRIGHT", communitiesFrame.MOTDFrame, "TOPRIGHT", -50, -20)
    -- guildDetailsFrame.Info.EditMOTDButton:SkinButton(false, true, false)
    
    
    
    -- -- communitiesFrame.MOTDFrame.ScrollFrame = communitiesFrame.CommunitiesFrameGuildDetailsFrameInfoScrollFrame
    -- -- communitiesFrame.MOTDFrame.ScrollFrame:SetAllPoints()

end

local function SkinMOTDEditor()
    debug("Skin MOTD Editor")
      --retexture the edit motd box
      CommunitiesGuildTextEditFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

      CommunitiesGuildTextEditFrame:StripTextures()
      CommunitiesGuildTextEditFrame:CreateBackdrop(constBackdropFrame)
  
      CommunitiesGuildTextEditFrameAcceptButton:SkinButton(false, true, false)
  
      CommunitiesGuildTextEditFrameCloseButton:SkinButton(true, false)
      CommunitiesGuildTextEditFrameCloseButton:SetSize(20, 20)
      CommunitiesGuildTextEditFrameCloseButton:ClearAllPoints()
      CommunitiesGuildTextEditFrameCloseButton:SetPoint("TOPRIGHT", CommunitiesGuildTextEditFrame, "TOPRIGHT", -10, -5)
      CommunitiesGuildTextEditFrameCloseButton:SetParent(CommunitiesGuildTextEditFrame)
  
      --GW.MutateInaccessableObject(CommunitiesGuildTextEditFrameCloseButton, "FRAME", skinInaccessibleCloseButton)
      CommunitiesGuildTextEditFrame.Title:SetTextColor(1, .93, .73)
      CommunitiesGuildTextEditFrameScrollBar:SkinScrollBar()
end

local function ReskinCloseButton()
    debug("Reskin Close Button")

    communitiesFrame.CloseButton:SkinButton(true, false)
    communitiesFrame.CloseButton:SetSize(20, 20)
    communitiesFrame.CloseButton:ClearAllPoints()
    communitiesFrame.CloseButton:SetPoint("TOPRIGHT", communitiesFrame, "TOPRIGHT", -10, 30)
    communitiesFrame.CloseButton:SetParent(communitiesFrame)
end

local function StripAndRetexture()
    debug("Strip and Retexture")
    --kills
    communitiesFrame.TitleBg:Kill()  
    communitiesFrame.TitleText:Kill()
    communitiesFrame.NineSlice:Kill()
    communitiesFrame.Inset:Kill()
    communitiesFrame.Chat.InsetFrame:Kill()
    communitiesFrame.MaximizeMinimizeFrame:Kill() -- we don't want the small frame view

    -- strips
    communitiesFrame:StripTextures(true)
    communitiesFrame.Chat:StripTextures(true)
    guildDetailsFrame:StripTextures(true)
    guildBenefitsFrame:StripTextures(true)
    guildLogButton:StripTextures(true)
    communitiesFrame.Chat:StripTextures(true)
    CommunitiesFrameInset:StripTextures(true)
    CommunitiesFrameCommunitiesList:StripTextures(true)
    communitiesFrame.MemberList.ListScrollFrame.scrollBar:StripTextures()
    communitiesFrame.Chat.MessageFrame:StripTextures()
    communitiesFrame.Chat.MessageFrame.ScrollBar:StripTextures()

    --scrollbars
    communitiesFrame.MemberList.ListScrollFrame.scrollBar:SkinScrollBar()
    communitiesFrame.Chat.MessageFrame.ScrollBar:SkinScrollBar()

    --Buttons
    ReskinCloseButton()
    communitiesFrame.InviteButton:SkinButton(false, true, false)
    communitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton:SkinButton(false, true, false)
    communitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton:SkinButton(false, true, false)
    ClubFinderCommunityAndGuildFinderFrame.OptionsList.Search:SkinButton(false, true, false)
    ClubFinderGuildFinderFrame.OptionsList.Search:SkinButton(false, true, false)

    --Dropdowns
    ClubFinderFilterDropdown:SkinDropDownMenu()
    ClubFinderSizeDropdown:SkinDropDownMenu()
    ClubFinderCommunityAndGuildFinderFrame.OptionsList.ClubFilterDropdown:SkinDropDownMenu()
    ClubFinderCommunityAndGuildFinderFrame.OptionsList.SortByDropdown:SkinDropDownMenu()
    
    --Text Color
    ClubFinderSizeDropdown.Label:SetTextColor(1, .93, .73)
    ClubFinderFilterDropdown.Label:SetTextColor(1, .93, .73)
    ClubFinderGuildFinderFrame.InsetFrame.GuildDescription:SetTextColor(1, .93, .73)
    ClubFinderCommunityAndGuildFinderFrame.InsetFrame.GuildDescription:SetTextColor(1, .93, .73)

end

local function ResetPositions()
    debug("Reset Positions")
    --Base form dimensions
    communitiesFrame:SetSize(newWidth, newHeight)

    --Online Member Counts
    communitiesFrame.MemberList.MemberCount:ClearAllPoints()
    communitiesFrame.MemberList.MemberCount:SetPoint("BOTTOMRIGHT", communitiesFrame.MemberList, "TOPRIGHT", 0, 40)
    communitiesFrame.MemberList.MemberCount:SetFont(DAMAGE_TEXT_FONT, 14)
    communitiesFrame.MemberList.MemberCount:SetTextColor(1, .93, .73)


end

local function SkinCommunitiesFrame()
    debug("Skin Communities Frame")

    -- Configure Frame Background
    communitiesFrame.CommunitiesFrameBgTexture = communitiesFrame:CreateTexture("communitiesFrameBgTexture", "BACKGROUND")
    communitiesFrame.CommunitiesFrameBgTexture:SetSize(newWidth, newHeight)
    communitiesFrame.CommunitiesFrameBgTexture:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 0, 5)
    communitiesFrame.CommunitiesFrameBgTexture:SetTexture("Interface/AddOns/GW2_UI/textures/guild/guild-window-background")
    communitiesFrame.CommunitiesFrameBgTexture:SetTexCoord(0, 0.7099, 0, 0.955);

    -- Configure Heading
    communitiesFrame.heading = communitiesFrame:CreateTexture("bg", "BACKGROUND")
    communitiesFrame.heading:SetSize(newWidth, 64)
    communitiesFrame.heading:SetPoint("BOTTOMLEFT", communitiesFrame, "TOPLEFT", 0, 0)
    communitiesFrame.heading:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")

    communitiesFrame.heading.Title = communitiesFrame:CreateFontString("communitiesFrameTitle", "ARTWORK")
    communitiesFrame.heading.Title:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 25, 30)
    communitiesFrame.heading.Title:SetFont(DAMAGE_TEXT_FONT, 20)
    communitiesFrame.heading.Title:SetText(GUILD_AND_COMMUNITIES)
    communitiesFrame.heading.Title:SetTextColor(1, .93, .73)

    communitiesFrame.icon = communitiesFrame:CreateTexture("communitiesFrameIcon", "ARTWORK")
    communitiesFrame.icon:SetSize(80, 80)
    communitiesFrame.icon:SetPoint("CENTER", communitiesFrame, "TOPLEFT", -20, 25)
    communitiesFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/guild/guild-shield-icon")

    communitiesFrame.headingRight = communitiesFrame:CreateTexture("bg", "BACKGROUND")
    communitiesFrame.headingRight:SetSize(newWidth, 64)
    communitiesFrame.headingRight:SetPoint("BOTTOMRIGHT", communitiesFrame, "TOPRIGHT", 0, 0)
    communitiesFrame.headingRight:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader-right")

    CommunitiesFrameTitleText:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 0, 0)

   
    -- Configure footer
    communitiesFrame.footer = communitiesFrame:CreateTexture("bg", "BACKGROUND")
    communitiesFrame.footer:SetSize(newWidth, 70)
    communitiesFrame.footer:SetPoint("TOPLEFT", communitiesFrame, "BOTTOMLEFT", 0, 5)
    communitiesFrame.footer:SetPoint("TOPRIGHT", communitiesFrame, "BOTTOMRIGHT", 0, 5)
    communitiesFrame.footer:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagfooter")
end

local function BuildGuildHeading()   
     debug("Build Guild Heading")


    -- communitiesFrame.PortraitOverlay:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 220, -15)
    -- communitiesFrame.PortraitOverlay:SetParent(communitiesFrame.Chat)
    
    -- --Guild header
    -- communitiesFrame.GuildHeaderBgTexture = communitiesFrame:CreateTexture("GuildHeaderBgTexture", "BACKGROUND")
    -- communitiesFrame.GuildHeaderBgTexture:SetSize(newWidth/2, 120)
    -- communitiesFrame.GuildHeaderBgTexture:SetPoint("TOPLEFT", communitiesFrame.PortraitOverlay, "TOPLEFT", 150, 5)
    -- communitiesFrame.GuildHeaderBgTexture:SetTexture("Interface/AddOns/GW2_UI/textures/guild/guild-heading-bg")
    -- communitiesFrame.GuildHeaderBgTexture:SetTexCoord(0, 0.7099, 0, 0.955);

end

local function RelocateMenu() 
    debug("Relocating Menu to Left")
    communitiesFrame.ChatTab:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", -40, -25)
end

local function SkinGuildUI()
    debug("Reskinning Communities Frame")


    StripAndRetexture()
    ResetPositions()
    BuildGuildHeading()
    SkinCommunitiesFrame()
    RelocateMenu()
    SkinMOTDArea()
    SkinMOTDEditor()
    SkinMainPageChatArea()

end


local function ClearCommunitiesTextures()
    debug("Clearing Textures for Communities List")
    -- if (CommunitiesFrame.CommunitiesList.communitiesList) ~= nil then
    --     debug("count = " .. GW.CountTable(CommunitiesFrame.CommunitiesList.communitiesList))

    --     for i = 1, GW.CountTable(CommunitiesFrame.CommunitiesList.ListScrollFrame.buttons) do
    --         if _G["CommunitiesFrameCommunitiesListListScrollFrameButton" .. i] ~= nil then
    --             --_G["CommunitiesFrameCommunitiesListListScrollFrameButton" .. i].Background:Kill()
    --             _G["CommunitiesFrameCommunitiesListListScrollFrameButton" .. i]:StripTextures()
    --             _G["CommunitiesFrameCommunitiesListListScrollFrameButton" .. i]:SetHeight(42)
    --         end
    --     end
    -- end
end

local function CheckMOTD()
    debug("Checking MOTD")
    -- GMOTD may have arrived before this frame registered for the event
    local motdMessage = ""
    if ( not communitiesFrame.checkedGMOTD and communitiesFrame:IsEventRegistered("GUILD_MOTD") ) then
        communitiesFrame.checkedGMOTD = true;
        motdMessage = GetGuildRosterMOTD();
    end
end

local function BuildCommunitiesFrame()
    debug("Build Communities Frame")
    
    communitiesFrame = _G.CommunitiesFrame
	guildDetailsFrame = _G.CommunitiesFrame.GuildDetailsFrame
	guildBenefitsFrame = _G.CommunitiesFrame.GuildBenefitsFrame
	guildLogButton = _G.CommunitiesFrame.GuildLogButton

    ClearCommunitiesTextures()
    CheckMOTD()

end

local function RefreshCommunitiesFrame() 
    debug("Refreshing Communities Frame")
    
    ClearCommunitiesTextures()
    SkinGuildUI()
    ConfigureMover();
    CheckMOTD()
end

function eventFrame:ADDON_LOADED(event, addon)
    debug("Begin GuildUI hooks")

	if addon == ADDON_NAME then
		if not IsCommunityHooked and IsAddOnLoaded("Blizzard_Communities") and _G.CommunitiesFrame then
			_G.CommunitiesFrame:HookScript("OnShow", RefreshCommunitiesFrame)
			hooksecurefunc(_G.CommunitiesFrame.MaximizeMinimizeFrame, "Minimize", GW.NoOp)
			hooksecurefunc(_G.CommunitiesFrame.MaximizeMinimizeFrame, "Maximize",  GW.NoOp)
			BuildCommunitiesFrame() -- Setup the Communities fixes
			IsCommunityHooked = true
			self:UnregisterEvent(event)
		end
	elseif addon == "Blizzard_Communities" then
		if not IsCommunityHooked and IsAddOnLoaded(addon) then
			_G.CommunitiesFrame:HookScript("OnShow", RefreshCommunitiesFrame)
			hooksecurefunc(_G.CommunitiesFrame.MaximizeMinimizeFrame, "Minimize",  GW.NoOp)
			hooksecurefunc(_G.CommunitiesFrame.MaximizeMinimizeFrame, "Maximize",  GW.NoOp)
			BuildCommunitiesFrame() -- Setup the Communities fixes

            IsCommunityHooked = true
			self:UnregisterEvent(event)
		end
    else return end

    debug("End GuildUI hooks")
end

local function _onEvent(self, event, ...)
    debug("Event Handler fired for " .. event)

    if (event == "ADDON_LOADED") then eventFrame:ADDON_LOADED(event) end
    if (event == "GUILD_ROSTER_UPDATE") then  ClearCommunitiesTextures() end
    if (event == "GUILD_RANKS_UPDATE") then  ClearCommunitiesTextures() end
    if (event == "GUILD_CHALLANGE_UPDATE") then  ClearCommunitiesTextures() end
    if (event == "STREAM_VIEW_MARKER_UPDATED") then  ClearCommunitiesTextures() end
end


function GW:SkinCommunities() 
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r Registering Events for Guild frames " )
    FrameUtil.RegisterFrameForEvents(eventFrame, COMMUNITIES_FRAME_EVENTS)
    FrameUtil.RegisterFrameForEvents(eventFrame, CLUB_FINDER_APPLICANT_LIST_EVENTS)
    FrameUtil.RegisterFrameForEvents(eventFrame, GUILD_EVENTS)
    eventFrame:SetScript("OnEvent", _onEvent)

    if not IsAddOnLoaded("Blizzard_Communities") then
        Communities_LoadUI()
    end

end