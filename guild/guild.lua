local _, GW = ...
local L = GW.L

local constBackdropFrame = GW.skins.constBackdropFrame
local SetSetting = GW.SetSetting
local GetSetting = GW.GetSetting

local IsCommunityHooked = false
local _motdScrollFrame 

local COMMUNITIES_FRAME_EVENTS = {
    "ADDON_LOADED",
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
};

local GUILD_EVENTS = {
    "GUILD_MOTD",
    "GUILD_ROSTER_UPDATE",
    "GUILD_RANKS_UPDATE",
    "PLAYER_GUILD_UPDATE",
    "GUILD_CHALLENGE_UPDATED"
};

--get local references
local communitiesFrame
local eventFrame =  CreateFrame("FRAME");

local newWidth = 853
local newHeight = 627

local commSecure_OnShow =
    [=[
    local keyEsc = GetBindingKey("TOGGLEGAMEMENU")
    if keyEsc ~= nil then
        self:SetBinding(false, keyEsc, "CLICK GWCommunitiesWindowClick:Close")
    end
    ]=]

local commSecure_OnHide = [=[
    self:ClearBindings()
    ]=]

local commCloseSecure_OnClick = [=[
    self:GetParent():SetAttribute("windowpanelopen", nil)
    ]=]



local function _onEvent(self, event, arg1)
    -- if ( event == "GUILD_MOTD" ) then
    --     CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame.MOTD:SetText(arg1, true);	--Ignores markup.
    --     communitiesFrame.MOTDFrame.Text.SetText(arg1, true)
    -- end
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r EVENTDATA:" .. tostring(event) .. tostring(arg1) )
end

-- local function CreateSubheadingFrame(width, height, x, y, textString, parent)
--     if parent == nil then return end

--     local subheading = CreateFrame("FRAME")

--     subheading.HeadingBg = communitiesFrame:CreateTexture("bg", "BACKGROUND")
--     subheading.HeadingBg:SetSize(width, height)
--     subheading.HeadingBg:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", y, x)
--     subheading.HeadingBg:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")

--     subheading.HeadingBg.Title = communitiesFrame:CreateFontString("communitiesFrameTitle", "ARTWORK")
--     subheading.HeadingBg.Title:SetPoint("TOPLEFT", subheading.HeadingBg, "TOPLEFT", 10, -22)
--     subheading.HeadingBg.Title:SetFont(DAMAGE_TEXT_FONT, 14)
--     subheading.HeadingBg.Title:SetText(textString)
--     subheading.HeadingBg.Title:SetTextColor(1, .93, .73)

--     return subheading
-- end


local function ConfigureMover()
    -- movable stuff
    local pos = GetSetting("COMMUNITYFRAME_POSITION")
    GWCommunitiesWindow.mover = CreateFrame("Frame", nil)
    GWCommunitiesWindow.mover:EnableMouse(true)
    GWCommunitiesWindow:SetMovable(true)
    GWCommunitiesWindow.mover:SetSize(newWidth, 30)
    GWCommunitiesWindow.mover:SetPoint("BOTTOMLEFT", GWCommunitiesWindow, "TOPLEFT", 0, 0)
    GWCommunitiesWindow.mover:SetPoint("BOTTOMRIGHT", GWCommunitiesWindow, "TOPRIGHT", 0, 0)
    GWCommunitiesWindow.mover:RegisterForDrag("LeftButton")
    GWCommunitiesWindow.mover.onMoveSetting = "COMMUNITYFRAME_POSITION"
    GWCommunitiesWindow:SetClampedToScreen(true)
    GWCommunitiesWindow.mover:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
    end)
    GWCommunitiesWindow.mover:SetScript("OnDragStop", function(self)
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
            local pos = GetSetting(self.mover.onMoveSetting)
            if pos then
                wipe(pos)
            else
                pos = {}
            end
            pos.point = "TOPLEFT"
            pos.relativePoint = "BOTTOMLEFT"
            pos.xOfs = x
            pos.yOfs = y
            SetSetting(self.mover.onMoveSetting, pos)
        end
    end)
    GWCommunitiesWindow:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    GWCommunitiesWindow.SetPoint = GW.NoOp -- Prevent Blizzard to reanchor that frame
   
end

-- local function SkinMainPageChatArea()
    
--     communitiesFrame.Chat:StripTextures(true)
--     communitiesFrame.MainPageChatFrame = CreateFrame("FRAME","ChatHeader", communitiesFrame.Chat)
--     communitiesFrame.MainPageChatFrame:SetSize(newWidth-325, 42)
--     communitiesFrame.MainPageChatFrame:SetPoint("TOPLEFT", communitiesFrame.MOTDFrame, "BOTTOMLEFT", 0, -10)

--     communitiesFrame.MainPageChatFrame.Subheading = CreateSubheadingFrame(newWidth-325, 42, 0, -5, COMMUNITIES_CHAT_TAB_TOOLTIP,  communitiesFrame.MainPageChatFrame )
   

--     -- communitiesFrame.Chat:Hide()
--     -- communitiesFrame.Chat:SetSize(newWidth-325, 350)
--     communitiesFrame.Chat.MessageFrame:SetSize(newWidth-425, 350)
    
--     --communitiesFrame.Chat.MessageFrame:SetPoint("TOPLEFT", communitiesFrame.Chat, "TOPLEFT", -350, 0)
--     communitiesFrame.Chat.MessageFrame:SetPoint("TOPLEFT", communitiesFrame.MainPageChatFrame.Subheading, "TOPLEFT", 150, -350)

--     communitiesFrame.Chat.MessageFrame:SetSize(communitiesFrame.Chat:GetWidth(), 350)
--     -- communitiesFrame.Chat.MessageFrame.ScrollBar:SetHeight(350)
--     -- communitiesFrame.Chat.MessageFrame.FontStringContainer:SetSize(newWidth-325, 350)

--     --communitiesFrame.StreamDropDownMenu:SkinDropDownMenu()
--     --communitiesFrame.StreamDropDownMenu.Text:SetPoint("TOPLEFT", communitiesFrame.StreamDropDownMenu, "TOPLEFT", 30, -10 )
-- --    communitiesFrame.StreamDropDownMenu:SetPoint("TOPLEFT", communitiesFrame.MainPageRosterFrame.heading, "TOPLEFT", 50, -20)
-- end


-- local function SkinMOTDArea()
--     communitiesFrame.MOTDFrame = CreateFrame("FRAME", "MOTD", communitiesFrame.Chat)

--     -- communitiesFrame.MOTDFrame = CommunitiesFrameGuildDetailsFrameInfoHeader2
--     -- communitiesFrame.MOTDFrame.Scrollframe= CommunitiesFrameGuildDetailsFrameInfoScrollFrame
--     -- _motdScrollFrame = _G.CommunitiesFrameGuildDetailsFrameInfoScrollFrame
--     -- communitiesFrame.MOTDFrame.Scrollframe.OnVerticleScroll =  _motdScrollFrame.OnVerticleScroll()
    
--     communitiesFrame.MOTDFrame:SetParent(communitiesFrame.Chat)
--     communitiesFrame.MOTDFrame:SetSize(newWidth-325, 150)
--     communitiesFrame.MOTDFrame:SetPoint("TOPLEFT", communitiesFrame.Chat, "TOPLEFT", 1, 1)
--     communitiesFrame.MOTDFrame.HeadingBg = CreateSubheadingFrame(newWidth-325, 42, -75, -10, GUILD_MOTD_LABEL, communitiesFrame.MOTDFrame)

--     -- communitiesFrame.MOTDFrame.Scrollframe = _G.CommunitiesFrameGuildDetailsFrameInfoScrollFrame
--     -- communitiesFrame.MOTDFrame.Scrollframe:SetAllPoints()

--     -- GMOTD may have arrived before this frame registered for the event
--     local motdMessage = ""
--     if ( not communitiesFrame.checkedGMOTD and communitiesFrame:IsEventRegistered("GUILD_MOTD") ) then
--         communitiesFrame.checkedGMOTD = true;
--         motdMessage = GetGuildRosterMOTD();
--     end
    

-- --    CommunitiesFrameGuildDetailsFrameInfo.EditMOTDButton:SkinButton()
--     -- local newMOTDEditButton = CreateFrame("BUTTON", communitiesFrame)
--     -- newMOTDEditButton:SetSize(CommunitiesFrameGuildDetailsFrameInfo.EditMOTDButton:GetSize())
--     -- newMOTDEditButton:SetPoint("TOPLEFT", communitiesFrame.MOTDheading, "TOPLEFT", 50, -20)
--     -- newMOTDEditButton:SetText(EDIT)
--     -- newMOTDEditButton:SetPoint("CENTER", communitiesFrame.MOTDheading.Title, "TOPLEFT", 50, 0)

--     -- communitiesFrame.newMOTDEditButton = newMOTDEditButton
--     -- communitiesFrame.newMOTDEditButton:SkinButton()

-- end

-- local function SkinCommunitiesFrame()
    
--     DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r Reskinning Communities Frame ")
--     communitiesFrame = _G.CommunitiesFrame
--     communitiesFrame:StripTextures(true)
--     CommunitiesFrameInset:StripTextures(true)
--     communitiesFrame.NineSlice:Kill()
--     communitiesFrame.Inset:Kill()
--     communitiesFrame.Chat.InsetFrame:Kill()
--     communitiesFrame.Chat:StripTextures(true)
--     CommunitiesFrameCommunitiesList:StripTextures(true)

--     --communitiesFrame.PortraitOverlay:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 180, -15)
    
--     communitiesFrame:SetSize(newWidth, newHeight)
--     -- Configure Frame Background
--     communitiesFrame.CommunitiesFrameBgTexture = communitiesFrame:CreateTexture("communitiesFrameBgTexture", "BACKGROUND")
--     communitiesFrame.CommunitiesFrameBgTexture:SetSize(newWidth, newHeight)
--     communitiesFrame.CommunitiesFrameBgTexture:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 0, 5)
--     communitiesFrame.CommunitiesFrameBgTexture:SetTexture("Interface/AddOns/GW2_UI/textures/guild/guild-window-background")
--     communitiesFrame.CommunitiesFrameBgTexture:SetTexCoord(0, 0.7099, 0, 0.955);

--     -- Configure Heading
--     communitiesFrame.heading = communitiesFrame:CreateTexture("bg", "BACKGROUND")
--     communitiesFrame.heading:SetSize(newWidth, 64)
--     communitiesFrame.heading:SetPoint("BOTTOMLEFT", communitiesFrame, "TOPLEFT", 0, 0)
--     communitiesFrame.heading:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader")

--     communitiesFrame.heading.Title = communitiesFrame:CreateFontString("communitiesFrameTitle", "ARTWORK")
--     communitiesFrame.heading.Title:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 25, 30)
--     communitiesFrame.heading.Title:SetFont(DAMAGE_TEXT_FONT, 20)
--     communitiesFrame.heading.Title:SetText(GUILD_AND_COMMUNITIES)
--     communitiesFrame.heading.Title:SetTextColor(1, .93, .73)

--     communitiesFrame.icon = communitiesFrame:CreateTexture("communitiesFrameIcon", "ARTWORK")
--     communitiesFrame.icon:SetSize(80, 80)
--     communitiesFrame.icon:SetPoint("CENTER", communitiesFrame, "TOPLEFT", -20, 25)
--     communitiesFrame.icon:SetTexture("Interface/AddOns/GW2_UI/textures/guild/guild-shield-icon")

--     communitiesFrame.headingRight = communitiesFrame:CreateTexture("bg", "BACKGROUND")
--     communitiesFrame.headingRight:SetSize(newWidth, 64)
--     communitiesFrame.headingRight:SetPoint("BOTTOMRIGHT", communitiesFrame, "TOPRIGHT", 0, 0)
--     communitiesFrame.headingRight:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagheader-right")

--     CommunitiesFrameTitleText:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", 0, 0)

--     communitiesFrame.MaximizeMinimizeFrame:Kill() -- we don't want the small frame view

--     communitiesFrame.CloseButton:SkinButton(true, false)
--     communitiesFrame.CloseButton:SetSize(20, 20)
--     communitiesFrame.CloseButton:ClearAllPoints()
--     communitiesFrame.CloseButton:SetPoint("TOPRIGHT", communitiesFrame, "TOPRIGHT", -10, 30)
--     communitiesFrame.CloseButton:SetParent(communitiesFrame)

--     -- Configure footer
--     communitiesFrame.footer = communitiesFrame:CreateTexture("bg", "BACKGROUND")
--     communitiesFrame.footer:SetSize(newWidth, 70)
--     communitiesFrame.footer:SetPoint("TOPLEFT", communitiesFrame, "BOTTOMLEFT", 0, 5)
--     communitiesFrame.footer:SetPoint("TOPRIGHT", communitiesFrame, "BOTTOMRIGHT", 0, 5)
--     communitiesFrame.footer:SetTexture("Interface/AddOns/GW2_UI/textures/bag/bagfooter")

--     communitiesFrame.TitleBg:Hide()
--     communitiesFrame.TitleText:SetTextColor(1, .93, .73)

--     communitiesFrame.ChatTab:SetPoint("TOPLEFT", communitiesFrame, "TOPLEFT", -40, -25)



--     SkinMOTDArea()
--     SkinMainPageChatArea()
    

--     ConfigureMover()

-- end

function Copy_Table(src, dest)
	for index, value in pairs(src) do
		if type(value) == "table" then
			dest[index] = {}
			Copy_Table(value, dest[index])
		else
			dest[index] = value
		end
	end
end 


local function BuildCommunitiesFrame()
    
    local sWindow = CreateFrame("Frame", "GWCommunitiesWindow", UIParent, "GwCommunitiesWindowTemplate")
    --sWindow:SetClampedToScreen(true)
    tinsert(UISpecialFrames, "GWCommunitiesWindow")
    ConfigureMover()

    sWindow.WindowHeader:SetFont(DAMAGE_TEXT_FONT, 20)
    sWindow.WindowHeader:SetTextColor(255 / 255, 241 / 255, 209 / 255)


    sWindow.PortraitOverlay = CreateFrame("Frame", sWindow)
    Copy_Table(_G.CommunitiesFrame.PortraitOverlay, sWindow.PortraitOverlay)
    sWindow.PortraitOverlay:SetSize(100,100)
    sWindow.PortraitOverlay:SetPoint("TOPLEFT", sWindow.WindowHeader, "BOTTOMLEFT", 0, 5)


    -- -- secure hook ESC to close char window when it is showing
    -- sWindow:WrapScript(sWindow, "OnShow", commSecure_OnShow)
    -- sWindow:WrapScript(sWindow, "OnHide", commSecure_OnHide)

    -- -- the close button securely closes the char window
    -- sWindow.close:SetAttribute("_onclick", commCloseSecure_OnClick)

    ShowUIPanel(sWindow)
    UIFrameFadeIn(sWindow, 0.2, 0, 1)
end



local function RegisterEvents()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r Registering Events for Guild frames " )
    FrameUtil.RegisterFrameForEvents(eventFrame, COMMUNITIES_FRAME_EVENTS)
    FrameUtil.RegisterFrameForEvents(eventFrame, CLUB_FINDER_APPLICANT_LIST_EVENTS)
    FrameUtil.RegisterFrameForEvents(eventFrame, GUILD_EVENTS)
    eventFrame:SetScript("OnEvent", _onEvent)
end

local function noOp()
--    DEFAULT_CHAT_FRAME:AddMessage("|cffffedbaGW2 UI:|r HOOKED MIN")
--    NOOP, we aren't doing min/max
end

function GW:SkinGuildFrames()
    RegisterEvents()

    if not IsAddOnLoaded("Blizzard_Communities") then
        Communities_LoadUI()
    end

    if not IsCommunityHooked and IsAddOnLoaded("Blizzard_Communities") and _G.CommunitiesFrame then
        _G.CommunitiesFrame:HookScript("OnShow", BuildCommunitiesFrame)
        hooksecurefunc(_G.CommunitiesFrame.MaximizeMinimizeFrame, "Minimize", noOp)
        hooksecurefunc(_G.CommunitiesFrame.MaximizeMinimizeFrame, "Maximize", noOp)
        IsCommunityHooked = true
    end
end
GW:SkinGuildFrames()

