local _, GW = ...
local GetSetting = GW.GetSetting
local SetSetting = GW.SetSetting
local GetDefault = GW.GetDefault
local L = GW.L

local function CheckIfMoved(self, settingsName, new_point)
    -- check if we need to know if the frame is on its default position
    if self.gw_isMoved ~= nil then
        local defaultPoint = GetDefault(settingsName)
        local growDirection = GetSetting(settingsName .. "_GrowDirection")
        local frame = self.gw_frame
        if defaultPoint.point == new_point.point and defaultPoint.relativePoint == new_point.relativePoint and defaultPoint.xOfs == new_point.xOfs and defaultPoint.yOfs == new_point.yOfs and (growDirection and growDirection == "UP") then
            frame.isMoved = false
            frame:SetAttribute("isMoved", false)
        else
            frame.isMoved = true
            frame:SetAttribute("isMoved", true)
        end
    end
end

local function smallSettings_resetToDefault(self, btn)
    local mf = self:GetParent().child
    --local f = mf.gw_frame
    local settingsName = mf.gw_Settings

    local dummyPoint = GetDefault(settingsName)
    mf:ClearAllPoints()
    mf:SetPoint(
        dummyPoint["point"],
        UIParent,
        dummyPoint["relativePoint"],
        dummyPoint["xOfs"],
        dummyPoint["yOfs"]
    )

    local point, _, relativePoint, xOfs, yOfs = mf:GetPoint()

    local new_point = GetSetting(settingsName)
    new_point["point"] = point
    new_point["relativePoint"] = relativePoint
    new_point["xOfs"] = GW.RoundInt(xOfs)
    new_point["yOfs"] = GW.RoundInt(yOfs)
    SetSetting(settingsName, new_point)

    --if 'PlayerBuffFrame' or 'PlayerDebuffFrame', set also the grow direction to default
    if settingsName == "PlayerBuffFrame" or settingsName == "PlayerDebuffFrame" then
        SetSetting(settingsName .. "_GrowDirection", "UP")
    elseif settingsName == "MicromenuPos" then
        -- Hide/Show BG here
        mf.gw_frame.cf.bg:Show()
    end

    -- check if we need to know if the frame is on its default position
    CheckIfMoved(mf, settingsName, new_point)

    -- Set Scale back to default
    if mf.optionScaleable then
        local scale
        if mf.gw_mhf then
            scale = GetSetting("HUD_SCALE")
        else
            scale = GetDefault(settingsName .. "_scale")
        end
        mf:SetScale(scale)
        mf.gw_frame:SetScale(scale)
        SetSetting(settingsName .. "_scale", scale)
        self:GetParent().scaleSlider.slider:SetValue(scale)
    end

    -- Set height back to default
    if mf.optionHeight then
        local height = GetDefault(settingsName .. "_height")
        mf:SetHeight(height)
        mf.gw_frame:SetHeight(height)
        SetSetting(settingsName .. "_height", height)
        self:GetParent().heightSlider.slider:SetValue(height)
    end

    GW.UpdateHudScale()
end
GW.AddForProfiling("index", "smallSettings_resetToDefault", smallSettings_resetToDefault)

local function lockFrame_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:ClearLines()
    GameTooltip:SetText(SYSTEM_DEFAULT, 1, 1, 1)
    GameTooltip:Show()
end
GW.AddForProfiling("index", "lockFrame_OnEnter", lockFrame_OnEnter)

local function mover_OnDragStart(self)
    self.IsMoving = true
    self:StartMoving()
end
GW.AddForProfiling("index", "mover_OnDragStart", mover_OnDragStart)

local function mover_OnDragStop(self)
    local settingsName = self.gw_Settings
    local lockAble = self.gw_Lockable
    self:StopMovingOrSizing()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()

    local new_point = GetSetting(settingsName)
    new_point.point = point
    new_point.relativePoint = relativePoint
    new_point.xOfs = xOfs and math.floor(xOfs) or 0
    new_point.yOfs = yOfs and math.floor(yOfs) or 0
    SetSetting(settingsName, new_point)
    if lockAble ~= nil then
        SetSetting(lockAble, false)
    end
    -- check if we need to know if the frame is on its default position
    CheckIfMoved(self, settingsName, new_point)

    --check if we need to change the text string or button locations
    if settingsName == "AlertPos" then
        local _, y = self:GetCenter()
        local screenHeight = UIParent:GetTop()
        if y > (screenHeight / 2) then
            if self.frameName and self.frameName.SetText then
                self.frameName:SetText(L["ALERTFRAMES"] .. " (" .. COMBAT_TEXT_SCROLL_DOWN .. ")")
            end
        else
            if self.frameName and self.frameName.SetText then
                self.frameName:SetText(L["ALERTFRAMES"] .. " (" .. COMBAT_TEXT_SCROLL_UP .. ")")
            end
        end
    elseif settingsName == "MinimapPos" then
        local x = self:GetCenter()
        local screenWidth = UIParent:GetRight()
        if x > (screenWidth / 2) then
            GW.setMinimapButtons("left")
        else
            GW.setMinimapButtons("right")
        end
    elseif settingsName == "MicromenuPos" then
        -- Hide/Show BG here
        self.gw_frame.cf.bg:SetShown(not self.gw_frame.isMoved)
    end

    self.IsMoving = false
end
GW.AddForProfiling("index", "mover_OnDragStop", mover_OnDragStop)

local function mover_options(self, button)
    if button == "RightButton" then
        if GW.MoveHudScaleableFrame.child == self then
            GW.MoveHudScaleableFrame.child = nil
            GW.MoveHudScaleableFrame.childMover = nil
            GW.MoveHudScaleableFrame.headerString:SetText(L["SMALL_SETTINGS_HEADER"])
            GW.MoveHudScaleableFrame.scaleSlider:Hide()
            GW.MoveHudScaleableFrame.heightSlider:Hide()
            GW.MoveHudScaleableFrame.default:Hide()
            GW.MoveHudScaleableFrame.movers:Hide()
            GW.MoveHudScaleableFrame.desc:SetText(L["SMALL_SETTINGS_DEFAULT_DESC"])
            GW.MoveHudScaleableFrame.desc:Show()
            GW.StopFlash(GW.MoveHudScaleableFrame.activeFlasher)
        else
            GW.MoveHudScaleableFrame.child = self
            GW.MoveHudScaleableFrame.childMover = self
            GW.MoveHudScaleableFrame.headerString:SetText(self.frameName:GetText())
            GW.MoveHudScaleableFrame.desc:Hide()
            GW.MoveHudScaleableFrame.default:Show()
            GW.MoveHudScaleableFrame.movers:Show()
            -- options 
            GW.MoveHudScaleableFrame.scaleSlider:SetShown(self.optionScaleable)
            GW.MoveHudScaleableFrame.heightSlider:SetShown(self.optionHeight)
            if self.optionScaleable then
                local scale = GetSetting(self.gw_Settings .. "_scale")
                GW.MoveHudScaleableFrame.scaleSlider.slider:SetValue(scale)
                GW.MoveHudScaleableFrame.scaleSlider.input:SetNumber(scale)
            end
            if self.optionHeight then
                local height = GetSetting(self.gw_Settings .. "_height")
                GW.MoveHudScaleableFrame.heightSlider.slider:SetValue(height)
                GW.MoveHudScaleableFrame.heightSlider.input:SetNumber(height)
            end

            if GW.MoveHudScaleableFrame.activeFlasher then
                GW.StopFlash(GW.MoveHudScaleableFrame.activeFlasher)
                UIFrameFadeOut(GW.MoveHudScaleableFrame.activeFlasher, 0.5, GW.MoveHudScaleableFrame.activeFlasher:GetAlpha(), 0.5)
            end
            GW.MoveHudScaleableFrame.activeFlasher = self
            GW.FrameFlash(self, 1.5, 0.5, 1, true)
        end
    end
end

local function sliderValueChange(self)
    local roundValue = GW.RoundDec(self:GetValue(), 2)
    local moverFrame = self:GetParent():GetParent().child
    moverFrame:SetScale(roundValue)
    moverFrame.gw_frame:SetScale(roundValue)
    self:GetParent().input:SetText(roundValue)
    SetSetting(moverFrame.gw_Settings .."_scale", roundValue)

    self:GetParent():GetParent().child.gw_frame.isMoved = true
    self:GetParent():GetParent().child.gw_frame:SetAttribute("isMoved", true)
end

local function sliderEditBoxValueChanged(self)
    local roundValue = GW.RoundDec(self:GetNumber(), 2) or 0.5
    local moverFrame = self:GetParent():GetParent().child

    self:ClearFocus()
    if tonumber(roundValue) > 1.5 then self:SetText(1.5) end
    if tonumber(roundValue) < 0.5 then self:SetText(0.5) end
    roundValue = GW.RoundDec(self:GetNumber(), 2) or 0.5

    self:GetParent().slider:SetValue(roundValue)
    self:SetText(roundValue)
    SetSetting(moverFrame.gw_Settings .."_scale", roundValue)

    self:GetParent():GetParent().child.gw_frame.isMoved = true
    self:GetParent():GetParent().child.gw_frame:SetAttribute("isMoved", true)
end

local function heightSliderValueChange(self)
    local roundValue = GW.RoundDec(self:GetValue())
    local moverFrame = self:GetParent():GetParent().child
    moverFrame:SetHeight(roundValue)
    moverFrame.gw_frame:SetHeight(roundValue)
    self:GetParent().input:SetText(roundValue)
    SetSetting(moverFrame.gw_Settings .."_height", roundValue)
end

local function heightEditBoxValueChanged(self)
    local roundValue = GW.RoundDec(self:GetNumber()) or 1
    local moverFrame = self:GetParent():GetParent().child

    self:ClearFocus()
    if tonumber(roundValue) > 1500 then self:SetText(1500) end
    if tonumber(roundValue) < 1 then self:SetText(1) end

    SetSetting(moverFrame.gw_Settings .."_height", roundValue)

    moverFrame.gw_frame:SetHeight(roundValue)
    moverFrame:SetHeight(roundValue)
end

local function moverframe_OnEnter(self)
    if self.IsMoving then
        return
    end

    for _, moverframe in pairs(GW.MOVABLE_FRAMES) do
        if moverframe:IsShown() and moverframe ~= self then
            UIFrameFadeOut(moverframe, 0.5, moverframe:GetAlpha(), 0.5)
        end
    end
end

local function moverframe_OnLeave(self)
    if self.IsMoving then
        return
    end

    for _, moverframe in pairs(GW.MOVABLE_FRAMES) do
        if moverframe:IsShown() and moverframe ~= self then
            UIFrameFadeIn(moverframe, 0.5, moverframe:GetAlpha(), 1)
        end
    end
end

local function RegisterMovableFrame(frame, displayName, settingsName, dummyFrame, size, isMoved, smallOptions, mhf)
    local moveframe = CreateFrame("Frame", nil, UIParent, dummyFrame)
    frame.gwMover = moveframe
    if size then
        moveframe:SetSize(unpack(size))
    else
        moveframe:SetSize(frame:GetSize())
    end
    moveframe:SetScale(frame:GetScale())
    moveframe.gw_Settings = settingsName
    moveframe.gw_Lockable = lockAble
    moveframe.gw_isMoved = isMoved
    moveframe.gw_frame = frame
    moveframe.gw_mhf = mhf

    if moveframe.frameName and moveframe.frameName.SetText then
        moveframe.frameName:SetSize(moveframe:GetSize())
        moveframe.frameName:SetText(displayName)
    end

    moveframe:SetClampedToScreen(true)

    -- position mover
    local framePoint = GetSetting(settingsName)
    moveframe:ClearAllPoints()
    moveframe:SetPoint(framePoint.point, UIParent, framePoint.relativePoint, framePoint.xOfs, framePoint.yOfs)

    local num = #GW.MOVABLE_FRAMES
    GW.MOVABLE_FRAMES[num + 1] = moveframe
    moveframe:Hide()
    moveframe:RegisterForDrag("LeftButton")
    moveframe:SetScript("OnEnter", moverframe_OnEnter)
    moveframe:SetScript("OnLeave", moverframe_OnLeave)

    if isMoved ~= nil then
        local defaultPoint = GetDefault(settingsName)

        if defaultPoint.point == framePoint.point and defaultPoint.relativePoint == framePoint.relativePoint and defaultPoint.xOfs == framePoint.xOfs and defaultPoint.yOfs == framePoint.yOfs then
            frame.isMoved = false
            frame:SetAttribute("isMoved", false)
        else
            frame.isMoved = true
            frame:SetAttribute("isMoved", true)
        end
    end

    if mhf then
        GW.scaleableMainHudFrames[#GW.scaleableMainHudFrames + 1] = moveframe
    end

    -- set all options default as off
    moveframe.optionScaleable = false
    moveframe.optionHeight = false

    if smallOptions then
        for k, v in pairs(smallOptions) do
            if v == "scaleable" then
                moveframe.optionScaleable = true
            elseif v == "height" then
                moveframe.optionHeight = true
            end
        end
    end

    if smallOptions and #smallOptions > 0 then
        if moveframe.optionScaleable then
            local scale = GetSetting(settingsName .. "_scale")
            moveframe.gw_frame:SetScale(scale)
            moveframe:SetScale(scale)
            GW.scaleableFrames[#GW.scaleableFrames + 1] = moveframe
        end
        if moveframe.optionHeight then
            local height = GetSetting(settingsName .. "_height")
            moveframe.gw_frame:SetHeight(height)
            moveframe:SetHeight(height)
        end
        moveframe:SetScript("OnMouseDown", mover_options)
    else
        moveframe:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" then
                if GW.MoveHudScaleableFrame.child == "nil" then
                    GW.MoveHudScaleableFrame.child = nil
                    GW.MoveHudScaleableFrame.childMover = nil
                    GW.MoveHudScaleableFrame.headerString:SetText(L["SMALL_SETTINGS_HEADER"])
                    GW.MoveHudScaleableFrame.scaleSlider:Hide()
                    GW.MoveHudScaleableFrame.heightSlider:Hide()
                    GW.MoveHudScaleableFrame.default:Hide()
                    GW.MoveHudScaleableFrame.movers:Hide()
                    GW.MoveHudScaleableFrame.desc:SetText(L["SMALL_SETTINGS_DEFAULT_DESC"])
                    GW.MoveHudScaleableFrame.desc:Show()
                    GW.StopFlash(GW.MoveHudScaleableFrame.activeFlasher)
                else
                    GW.MoveHudScaleableFrame.child = "nil"
                    GW.MoveHudScaleableFrame.childMover = self
                    GW.MoveHudScaleableFrame.headerString:SetText(displayName)
                    GW.MoveHudScaleableFrame.scaleSlider:Hide()
                    GW.MoveHudScaleableFrame.heightSlider:Hide()
                    GW.MoveHudScaleableFrame.default:Hide()
                    GW.MoveHudScaleableFrame.movers:Show()
                    GW.MoveHudScaleableFrame.desc:SetText(format(L["SMALL_SETTINGS_NO_SETTINGS_FOR"], displayName))
                    GW.MoveHudScaleableFrame.desc:Show()
                    if GW.MoveHudScaleableFrame.activeFlasher then
                        GW.StopFlash(GW.MoveHudScaleableFrame.activeFlasher)
                        UIFrameFadeOut(GW.MoveHudScaleableFrame.activeFlasher, 0.5, GW.MoveHudScaleableFrame.activeFlasher:GetAlpha(), 0.5)
                    end
                    GW.MoveHudScaleableFrame.activeFlasher = self
                    GW.FrameFlash(self, 1.5, 0.5, 1, true)
                end
            end
        end)
    end

    moveframe:SetScript("OnDragStart", mover_OnDragStart)
    moveframe:SetScript("OnDragStop", mover_OnDragStop)
end
GW.RegisterMovableFrame = RegisterMovableFrame

local function MoveFrameByPixel(nudgeX, nudgeY)
    local mover = GwSmallSettingsWindow.childMover

    local point, anchor, anchorPoint, x, y = mover:GetPoint()
    x = x + nudgeX
    y = y + nudgeY
    mover:ClearAllPoints()
    mover:SetPoint(point, UIParent, anchorPoint, x, y)

    mover_OnDragStop(mover)
end

local function LoadMovers()
    -- Create mover settings frame
    local fnMf_OnDragStart = function(self)
        self:StartMoving()
    end
    local fnMf_OnDragStop = function(self)
        self:StopMovingOrSizing()
    end
    local mf = CreateFrame("Frame", "GwSmallSettingsMoverFrame", UIParent, "GwSmallSettingsMoverFrame")
    mf:RegisterForDrag("LeftButton")
    mf:SetScript("OnDragStart", fnMf_OnDragStart)
    mf:SetScript("OnDragStop", fnMf_OnDragStop)

    local moverSettingsFrame = CreateFrame("Frame", "GwSmallSettingsWindow", UIParent, "GwSmallSettings")
    moverSettingsFrame.scaleSlider.slider:SetMinMaxValues(0.5, 1.5)
    moverSettingsFrame.scaleSlider.slider:SetValue(1)
    moverSettingsFrame.scaleSlider.slider:SetScript("OnValueChanged", sliderValueChange)
    moverSettingsFrame.scaleSlider.input:SetNumber(1)
    moverSettingsFrame.scaleSlider.input:SetFont(UNIT_NAME_FONT, 8)
    moverSettingsFrame.scaleSlider.input:SetScript("OnEnterPressed", sliderEditBoxValueChanged)

    moverSettingsFrame.heightSlider.slider:SetMinMaxValues(1, 1500)
    moverSettingsFrame.heightSlider.slider:SetValue(1)
    moverSettingsFrame.heightSlider.slider:SetScript("OnValueChanged", heightSliderValueChange)
    moverSettingsFrame.heightSlider.input:SetNumber(1)
    moverSettingsFrame.heightSlider.input:SetFont(UNIT_NAME_FONT, 7)
    moverSettingsFrame.heightSlider.input:SetScript("OnEnterPressed", heightEditBoxValueChanged)

    moverSettingsFrame.desc:SetText(L["SMALL_SETTINGS_DEFAULT_DESC"])
    moverSettingsFrame.desc:SetFont(UNIT_NAME_FONT, 12)
    moverSettingsFrame.scaleSlider.title:SetFont(UNIT_NAME_FONT, 12)
    moverSettingsFrame.scaleSlider.title:SetText(L["SMALL_SETTINGS_OPTION_SCALE"])
    moverSettingsFrame.heightSlider.title:SetFont(UNIT_NAME_FONT, 12)
    moverSettingsFrame.heightSlider.title:SetText(COMPACT_UNIT_FRAME_PROFILE_FRAMEHEIGHT)
    moverSettingsFrame.headerString:SetFont(UNIT_NAME_FONT, 14)
    moverSettingsFrame.headerString:SetText(L["SMALL_SETTINGS_HEADER"])

    moverSettingsFrame.movers.title:SetText(NPE_MOVE )
    moverSettingsFrame.movers.title:SetFont(UNIT_NAME_FONT, 12)
    GW.HandleNextPrevButton(moverSettingsFrame.movers.left, "left")
    GW.HandleNextPrevButton(moverSettingsFrame.movers.right, "right")
    GW.HandleNextPrevButton(moverSettingsFrame.movers.up, "up")
    GW.HandleNextPrevButton(moverSettingsFrame.movers.down, "down")
    moverSettingsFrame.movers.left:SetScript("OnClick", function() MoveFrameByPixel(-1, 0) end)
    moverSettingsFrame.movers.right:SetScript("OnClick", function() MoveFrameByPixel(1, 0) end)
    moverSettingsFrame.movers.up:SetScript("OnClick", function() MoveFrameByPixel(0, 1) end)
    moverSettingsFrame.movers.down:SetScript("OnClick", function() MoveFrameByPixel(0, -1) end)

    moverSettingsFrame:SetScript("OnShow", function(self)
        mf:Show()
    end)
    moverSettingsFrame:SetScript("OnHide", function(self)
        mf:Hide()
    end)

    moverSettingsFrame.default:SetScript("OnClick", smallSettings_resetToDefault)

    moverSettingsFrame:Hide()
    mf:Hide()
    GW.MoveHudScaleableFrame = moverSettingsFrame
end
GW.LoadMovers = LoadMovers
