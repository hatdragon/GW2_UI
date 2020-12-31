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

local eventFrame =  CreateFrame("FRAME");

local constBackdropFrame = GW.skins.constBackdropFrame

local IsCommunityHooked = false
local hasBeenLoaded = false
local _motdScrollFrame 


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


local function CreateSubheadingFrame(width, height, x, y, textString, parent, fontsize)
    if parent == nil then return end

    local subheading = CreateFrame("FRAME")

    subheading.HeadingBg = communitiesFrame:CreateTexture("bg", "BACKGROUND")
    subheading.HeadingBg:SetSize(width, height)
    subheading.HeadingBg:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", y, x)
    subheading.HeadingBg:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")

    subheading.HeadingBg.Title = communitiesFrame:CreateFontString("communitiesFrameTitle", "ARTWORK")
    subheading.HeadingBg.Title:SetPoint("TOPLEFT", subheading.HeadingBg, "TOPLEFT", 10, -22)
    subheading.HeadingBg.Title:SetFont(DAMAGE_TEXT_FONT, fontsize)
    subheading.HeadingBg.Title:SetText(textString)
    subheading.HeadingBg.Title:SetTextColor(1, .93, .73)

    return subheading
end


local function ConfigureMover()
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
    communitiesFrame.Chat:StripTextures(true)
    communitiesFrame.MainPageChatFrame = CreateFrame("FRAME","ChatHeader", communitiesFrame.Chat)
    communitiesFrame.MainPageChatFrame:SetSize(newWidth-325, 42)
    communitiesFrame.MainPageChatFrame:SetPoint("TOPLEFT", communitiesFrame.MOTDFrame, "BOTTOMLEFT", 0, -10)

    communitiesFrame.MainPageChatFrame.Subheading = CreateSubheadingFrame(400, 42, 20, -10, COMMUNITIES_CHAT_TAB_TOOLTIP,  communitiesFrame.MainPageChatFrame, 12)
    communitiesFrame.Chat.MessageFrame:SetSize(newWidth-425, 350)
    communitiesFrame.Chat.MessageFrame:SetPoint("TOPLEFT", communitiesFrame.MainPageChatFrame.Subheading, "TOPLEFT", 150, -350)
    communitiesFrame.Chat.MessageFrame:SetSize(communitiesFrame.Chat:GetWidth(), 350)
    -- communitiesFrame.Chat.MessageFrame.ScrollBar:SetHeight(350)
    -- communitiesFrame.Chat.MessageFrame.FontStringContainer:SetSize(newWidth-325, 350)

    communitiesFrame.StreamDropDownMenu:SkinDropDownMenu()
    communitiesFrame.StreamDropDownMenu:ClearAllPoints()

    communitiesFrame.StreamDropDownMenu.Text:SetPoint("TOPLEFT", communitiesFrame.StreamDropDownMenu, "TOPLEFT", 30, -10 )
    --communitiesFrame.StreamDropDownMenu:SetPoint("TOPLEFT", communitiesFrame.MainPageRosterFrame.heading, "TOPLEFT", 50, -20)
    communitiesFrame.StreamDropDownMenu:SetPoint("TOPLEFT",communitiesFrame.Chat.MessageFrame, "TOPLEFT", 340, 42 )
    communitiesFrame.AddToChatButton:SetPoint("TOPRIGHT",communitiesFrame.StreamDropDownMenu, "TOPLEFT", -10, -5 )

    -- communitiesFrame.AddToChatButton.icon:SetNormalTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    -- communitiesFrame.AddToChatButton.icon:SetHighlightTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    -- communitiesFrame.AddToChatButton.icon:SetPushedTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
    -- communitiesFrame.AddToChatButton.icon:SetDisabledTexture("Interface/AddOns/GW2_UI/textures/uistuff/arrowdown_up")
end


local function SkinMOTDArea()
    communitiesFrame.MOTDFrame = CreateFrame("FRAME", "MOTD", communitiesFrame.Chat)
    communitiesFrame.MOTDFrame:SetParent(communitiesFrame.Chat)
    communitiesFrame.MOTDFrame:SetSize(newWidth-325, 150)
    communitiesFrame.MOTDFrame:SetPoint("TOPLEFT", communitiesFrame.Chat, "TOPLEFT", 1, 1)
    communitiesFrame.MOTDFrame.Subheading = CreateSubheadingFrame(newWidth-325, 42, -42, -10, GUILD_MOTD_LABEL, communitiesFrame.MOTDFrame, 12)

    guildDetailsFrame.Info.MOTDScrollFrame:SetParent(communitiesFrame.MOTDFrame)
    guildDetailsFrame.Info.MOTDScrollFrame:SetWidth(450)
    guildDetailsFrame.Info.MOTDScrollFrame.MOTD:SetWidth(450)
    guildDetailsFrame.Info.MOTDScrollFrame:SetPoint("TOPLEFT", communitiesFrame.MOTDFrame, "TOPLEFT", 10, -50)

    guildDetailsFrame.Info.EditMOTDButton:SetParent(communitiesFrame.MOTDFrame)
    guildDetailsFrame.Info.EditMOTDButton:StripTextures(true)
    guildDetailsFrame.Info.EditMOTDButton:SetText(EDIT)
    guildDetailsFrame.Info.EditMOTDButton:SetPoint("TOPRIGHT", communitiesFrame.MOTDFrame, "TOPRIGHT", -50, -20)
    guildDetailsFrame.Info.EditMOTDButton:SkinButton(false, true, false)
    
    
    
    -- communitiesFrame.MOTDFrame.ScrollFrame = communitiesFrame.CommunitiesFrameGuildDetailsFrameInfoScrollFrame
    -- communitiesFrame.MOTDFrame.ScrollFrame:SetAllPoints()

    -- GMOTD may have arrived before this frame registered for the event
    local motdMessage = ""
    if ( not communitiesFrame.checkedGMOTD and communitiesFrame:IsEventRegistered("GUILD_MOTD") ) then
        communitiesFrame.checkedGMOTD = true;
        motdMessage = GetGuildRosterMOTD();
    end
end

local function StripAndRetexture()
    --kills
    communitiesFrame.TitleBg:Kill()  
    communitiesFrame.TitleText:Kill()
    communitiesFrame.NineSlice:Kill()
    communitiesFrame.Inset:Kill()
    communitiesFrame.Chat.InsetFrame:Kill()
    communitiesFrame.MaximizeMinimizeFrame:Kill() -- we don't want the small frame view

    -- strips
    communitiesFrame:StripTextures(true)
    guildDetailsFrame:StripTextures(true)
    guildBenefitsFrame:StripTextures(true)
    guildLogButton:StripTextures(true)
    communitiesFrame.Chat:StripTextures(true)
    CommunitiesFrameInset:StripTextures(true)
    CommunitiesFrameCommunitiesList:StripTextures(true)

end

local function ResetPositions()
    --Base form dimensions
    communitiesFrame:SetSize(newWidth, newHeight)

    --Online Member Counts
    communitiesFrame.MemberList.MemberCount:ClearAllPoints()
    communitiesFrame.MemberList.MemberCount:SetPoint("BOTTOMRIGHT", communitiesFrame.MemberList, "TOPRIGHT", 0, 40)
    communitiesFrame.MemberList.MemberCount:SetFont(DAMAGE_TEXT_FONT, 14)
    communitiesFrame.MemberList.MemberCount:SetTextColor(1, .93, .73)


end

local function SkinCommunitiesFrame()
    
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r Reskinning Communities Frame ")
    communitiesFrame = _G.CommunitiesFrame
	guildDetailsFrame = _G.CommunitiesFrame.GuildDetailsFrame
	guildBenefitsFrame = _G.CommunitiesFrame.GuildBenefitsFrame
	guildLogButton = _G.CommunitiesFrame.GuildLogButton

    StripAndRetexture()
    ResetPositions()

 
    CommunitiesFrameCommunitiesList:SetWidth(450)
    CommunitiesFrameCommunitiesList.InsetFrame:SetWidth(450)
    CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar:Hide()
    CommunitiesFrameCommunitiesList.HeadingBg = CreateSubheadingFrame(100, 32, -20, 0, GUILD_AND_COMMUNITIES, CommunitiesFrameCommunitiesList, 12)

    communitiesFrame.PortraitOverlay:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 180, -15)
    
    

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

    communitiesFrame.CloseButton:SkinButton(true, false)
    communitiesFrame.CloseButton:SetSize(20, 20)
    communitiesFrame.CloseButton:ClearAllPoints()
    communitiesFrame.CloseButton:SetPoint("TOPRIGHT", communitiesFrame, "TOPRIGHT", -10, 30)
    communitiesFrame.CloseButton:SetParent(communitiesFrame)

    -- Configure footer
    communitiesFrame.footer = communitiesFrame:CreateTexture("bg", "BACKGROUND")
    communitiesFrame.footer:SetSize(newWidth, 70)
    communitiesFrame.footer:SetPoint("TOPLEFT", communitiesFrame, "BOTTOMLEFT", 0, 5)
    communitiesFrame.footer:SetPoint("TOPRIGHT", communitiesFrame, "BOTTOMRIGHT", 0, 5)
    communitiesFrame.footer:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagfooter")


    communitiesFrame.ChatTab:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", -40, -25)



    SkinMOTDArea()
    SkinMainPageChatArea()
    

    --ConfigureMover()

end




local function BuildCommunitiesFrame()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r BuildCommunitiesFrame")

    SkinCommunitiesFrame()
end

local function RefreshCommunitiesFrame() 
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r RefreshCommunitiesFrame")
    
    ConfigureMover();
end

function eventFrame:ADDON_LOADED(event, addon)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r Begin GuildUI hooks")

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
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r End GuildUI hooks")
end

local function _onEvent(self, event, ...)
    if (event == "ADDON_LOADED") then eventFrame:ADDON_LOADED(event) end

    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r EVENTDATA:" .. tostring(event) .. tostring(arg1) )
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