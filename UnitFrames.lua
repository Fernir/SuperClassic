local module = {}
module.name = "Unit Frames"
module.Init = function()
    if not SCDB.modules[module.name] then return end
    if SCDB[module.name] == nil then SCDB[module.name] = {} end
    if SCDB[module.name]["3D portaits"] == nil then SCDB[module.name]["3D portaits"] = true end
    if SCDB[module.name]["Debuffs On Top"] == nil then SCDB[module.name]["Debuffs On Top"] = true end
    
    local config = {
        largeAuraSize = 32,
        smallAuraSize = 24,
        pos = {
            [1] = { a = "CENTER",     x = -150, y = -250 }, -- PlayerFrame
            [2] = { a = "CENTER",     x =  150, y = -250 }, -- TargetFrame
            [3] = { a = "CENTER",     x = -440, y =   40 }, -- PartyFrame
        },
    }
    
    hooksecurefunc(getmetatable(PlayerFrameHealthBar).__index, "Show", function(self, ...)
        if self:GetParent().unit then
            if self.styled == nil then
                self:SetStatusBarTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton")
                self:GetStatusBarTexture():SetDesaturated(1)
                self:GetStatusBarTexture():SetTexCoord(0, 1, 0.609375, 0.796875)
                self:GetStatusBarTexture():SetHorizTile(true)
                self.bg = self:CreateTexture(self:GetName().."Background", "BACKGROUND")
                self.bg:SetTexture(0,0,0,.8)
                self.bg:SetAllPoints(self)
                self.styled = true
            end
        end
    end)
    
    local cc = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[select(2, UnitClass("player"))] or RAID_CLASS_COLORS[select(2, UnitClass("player"))] or  { r=.5, g=.5, b=.5 }

    for i,v in pairs({
        MainMenuBarTexture0,
        MainMenuBarTexture1,
        MainMenuBarTexture2,
        MainMenuBarTexture3,
        MainMenuBarTexture4,
        MainMenuBarLeftEndCap,
        MainMenuBarRightEndCap,
        MainMenuMaxLevelBar0,
        MainMenuMaxLevelBar1,
        PlayerFrameTexture,
        TargetFrameTextureFrameTexture,
        PetFrameTextureFrameTexture,
        FocusFrameTextureFrameTexture,
        TargetFrameToTTextureFrameTexture,
        FocusFrameToTTextureFrameTexture,
        MinimapBorder,
        select(1, TimeManagerClockButton:GetRegions()),
    }) do
        if SCDB["Main"].ClassColored == true then
            v:SetVertexColor(cc.r, cc.g, cc.b)
        else
            v:SetVertexColor(.5,.5,.5)
        end
    end
    
    local allframes = {
        PlayerFrame,
        TargetFrame,
        TargetFrameToT,
        PartyMemberFrame1,
        ArenaEnemyFrame1,
        PetFrame,
    }
   
    SCDB[module.name].opt = SCDB[module.name].opt or {}
    
    PlayerFrame:SetUserPlaced(false)
    
    for i,v in pairs(allframes) do
        SCDB[module.name].opt[v:GetName()] = SCDB[module.name].opt[v:GetName()] or {}
        
        v.default = v:GetWidth()
        
        v.drag = CreateFrame("frame", v:GetName().."Drag", UIParent)
        
        if SCDB[module.name].opt[v:GetName()].w ~= nil then
            v.drag:SetWidth(SCDB[module.name].opt[v:GetName()].w)
            v.drag:SetHeight(SCDB[module.name].opt[v:GetName()].h)
        else
            v.drag:SetWidth(v:GetWidth())
            v.drag:SetHeight(v:GetHeight())
        end
        
        v:RegisterForDrag()
        
        if SCDB[module.name].opt[v:GetName()].x == nil then
            local point, relativeTo, relativePoint, xOfs, yOfs = v:GetPoint(v:GetNumPoints())
            v.drag:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
        else
            v.drag:SetPoint("CENTER", UIParent, "BOTTOMLEFT", SCDB[module.name].opt[v:GetName()].x, SCDB[module.name].opt[v:GetName()].y)
        end
        
        v.drag:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", })
        v.drag:SetBackdropColor(1, 1, 1, .4)
        
        v.drag:SetMovable(true)
        v.drag:SetResizable(true)
        v.drag:EnableMouse(false)
        v.drag:SetClampedToScreen(true)
        v.drag:RegisterForDrag("LeftButton")
        v.drag:SetScript("OnDragStart", function(self) 
            self:StartMoving()
        end)
        v.drag:SetScript("OnDragStop", function(self) 
            self:StopMovingOrSizing()
            local x, y = self:GetCenter()
            if SCDB[module.name].opt[v:GetName()] == nil then SCDB[module.name].opt[v:GetName()] = {} end
            SCDB[module.name].opt[v:GetName()].x = x
            SCDB[module.name].opt[v:GetName()].y = y
        end)
        v.drag:Hide()
        v.drag.txt = v.drag:CreateFontString(v.drag:GetName().."DragText", "OVERLAY", "GameFontHighlight")
        v.drag.txt:SetPoint("CENTER")
        v.drag.txt:SetText(v:GetName())
        
        v.drag.resize = CreateFrame("button", v.drag:GetName().."ResizeButton", v.drag)
        v.drag:SetMinResize(16, 16)
        v.drag:SetMaxResize(600, 400)
        v.drag.resize:SetPoint("BOTTOMRIGHT")
        v.drag.resize:SetWidth(16)
        v.drag.resize:SetHeight(16)
        v.drag.resize:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
        v.drag.resize:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight")
        v.drag.resize:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")
        v.drag.resize:SetScript("OnMouseDown", function(self) v.drag:StartSizing() end)
        v.drag.resize:SetScript("OnMouseUp", function(self)
            local parent = v.drag
            parent:StopMovingOrSizing()
            if v:GetName():find("1") then
                local tmp = v:GetName():sub(1, #v:GetName()-1)
                for k=1,4 do
                    _G[tmp..k]:SetScale(v.drag:GetWidth()/v.default)
                end
            else
                v:SetScale(v.drag:GetWidth()/v.default)
            end
            local w, h = parent:GetWidth(), parent:GetHeight()
            if SCDB[module.name].opt[v:GetName()] == nil then SCDB[module.name].opt[v:GetName()] = {} end
            SCDB[module.name].opt[v:GetName()].w = w
            SCDB[module.name].opt[v:GetName()].h = h
        end)
        
        v.drag.reset = CreateFrame("button", v:GetName().."ResetButton", v.drag, "UIPanelCloseButton")
        v.drag.reset:SetWidth(22)
        v.drag.reset:SetHeight(22)
        v.drag.reset:SetPoint("TOPRIGHT", 4, 4)
        v.drag.reset:SetScript("OnClick", function()
            if v:GetScale() ~= 1 then
                v:SetScale(1)
                local w, h = v:GetWidth(), v:GetHeight()
                v.drag:SetWidth(w)
                v.drag:SetHeight(h)
                if SCDB[module.name].opt[v:GetName()] == nil then SCDB[module.name].opt[v:GetName()] = {} end
                SCDB[module.name].opt[v:GetName()].w = w
                SCDB[module.name].opt[v:GetName()].h = h
                print("Size of |cff0077dd"..v:GetName().."|r was rezet to default")
            end
        end)
        
        v.locked = true
    end
    
    local exprep = CreateFrame("StatusBar", "exprep", PlayerFrame)
    exprep:SetStatusBarTexture("Interface\\WorldStateFrame\\WorldState-CaptureBar")
    exprep:GetStatusBarTexture():SetTexCoord(0.8203125, 1.0, 0.34375, 0.484375)
    exprep:SetStatusBarColor(0, .8, 0)

    ---------------------------------------------------
    -- PLAYER
    ---------------------------------------------------
    local function UpdatePlayerFrame()
        if not UnitHasVehicleUI("player") then
            PlayerName:SetWidth(0.01)
            PlayerFrameGroupIndicatorText:ClearAllPoints()
            PlayerFrameGroupIndicatorText:SetPoint("BOTTOMLEFT", PlayerFrame, "TOP", 0, -20)
            PlayerFrameGroupIndicatorLeft:Hide()
            PlayerFrameGroupIndicatorMiddle:Hide()
            PlayerFrameGroupIndicatorRight:Hide()
            PlayerFrameHealthBar:ClearAllPoints()
            PlayerFrameHealthBar:SetPoint("TOPLEFT", 106, -24)
            PlayerFrameHealthBar:SetHeight(18)
            PlayerFrameHealthBarText:ClearAllPoints()
            PlayerFrameHealthBarText:SetPoint("RIGHT", PlayerFrameHealthBar, 0, 0)
            PlayerFrameManaBar:ClearAllPoints()
            PlayerFrameManaBar:SetPoint("TOPLEFT", 106, -43)
            PlayerFrameManaBar:SetHeight(10)
            PlayerFrameManaBarText:ClearAllPoints()
            PlayerFrameManaBarText:SetPoint("RIGHT", PlayerFrameManaBar, 0, 0)
            PlayerFrameManaBarText:SetFont(PlayerFrameManaBarText:GetFont(), 10, "OUTLINE")
            
            PlayerFrameFlash:SetTexture("")
            PlayerFrameFlash.SetTexture = function() end
            
            PlayerFrameAlternateManaBarBorder:Hide()
            PlayerFrameAlternateManaBarBorder.Show = function() end
            PlayerFrameAlternateManaBarBackground:Hide()
            PlayerFrameAlternateManaBarBackground.Show = function() end
            PlayerFrameAlternateManaBar:ClearAllPoints()
            PlayerFrameAlternateManaBar:SetPoint("TOPLEFT", 106, -53)
            PlayerFrameAlternateManaBar:SetHeight(10)
            PlayerFrameAlternateManaBar:SetWidth(PlayerFrameManaBar:GetWidth())
            PlayerFrameAlternateManaBar.SetWidth = function() end
            PlayerFrameAlternateManaBarText:ClearAllPoints()
            PlayerFrameAlternateManaBarText:SetPoint("CENTER", PlayerFrameAlternateManaBar, 0, 0)
            PlayerFrameAlternateManaBarText:SetFont(PlayerFrameAlternateManaBarText:GetFont(), 10, "OUTLINE")
            PlayerStatusTexture:Hide()
            PlayerStatusTexture.Show = function() end
            
            if not PlayerFrameAlternateManaBar:IsShown() then
                if MainMenuExpBar:IsShown() and not ReputationWatchBar:IsShown() then
                    exprep:Show()
                    exprep:SetMinMaxValues(MainMenuExpBar:GetMinMaxValues())
                    exprep:SetValue(MainMenuExpBar:GetValue())
                    exprep:SetStatusBarColor(MainMenuExpBar:GetStatusBarColor())
                    exprep:SetScript("OnEnter", function(self)
                        GameTooltip:ClearLines()
                        GameTooltip:SetOwner(self, ANCHOR_TOPLEFT)
                        GameTooltip:AddLine(MainMenuBarExpText:GetText())
                        GameTooltip:Show()
                    end)
                    exprep:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
                elseif ReputationWatchBar:IsShown() then
                    exprep:Show()
                    exprep:SetMinMaxValues(ReputationWatchStatusBar:GetMinMaxValues())
                    exprep:SetValue(ReputationWatchStatusBar:GetValue())
                    exprep:SetStatusBarColor(ReputationWatchStatusBar:GetStatusBarColor())
                    exprep:SetScript("OnEnter", function(self)
                        GameTooltip:ClearLines()
                        GameTooltip:SetOwner(self, ANCHOR_TOPLEFT)
                        GameTooltip:AddLine(ReputationWatchStatusBarText:GetText())
                        GameTooltip:Show()
                    end)
                    exprep:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
                else
                    if exprep:IsShown() then exprep:Hide() end
                end
                exprep:ClearAllPoints()
                exprep:SetHeight(10)
                exprep:SetWidth(PlayerFrameHealthBar:GetWidth())
                exprep.SetWidth = function() end
                exprep:SetPoint("TOPLEFT", 106, -53)
            else
               if exprep:IsShown() then exprep:Hide() end
            end
            ---------------------------------------------------
            -- DK RUNES
            ---------------------------------------------------
            if class == "DEATHKNIGHT" then
                RuneButtonIndividual1:ClearAllPoints()
                RuneButtonIndividual1:SetPoint("TOPLEFT", PlayerFrameManaBar, "BOTTOMLEFT", -1, -5)
            end

        else
            PlayerFrameHealthBar:SetHeight(12)
            PlayerFrameManaBar:SetHeight(12)
        end
    end
    hooksecurefunc("PlayerFrame_UpdateArt", UpdatePlayerFrame)
    hooksecurefunc("PlayerFrame_SequenceFinished", UpdatePlayerFrame)
    
    function MovePlayerFrame() 
        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint("TOPLEFT", PlayerFrame.drag, 0, 0)
        TargetFrame:ClearAllPoints()
        TargetFrame:SetPoint("TOPLEFT", TargetFrame.drag, 0, 0)
        PetFrame:SetPoint("TOPLEFT", PetFrame.drag, 0, 0)
        UpdatePlayerFrame()
        for i,v in pairs(allframes) do
            v:ClearAllPoints()
            v:SetPoint("TOPLEFT", v.drag, 0, 0)
            if v:GetName():find("1") then
                local tmp = v:GetName():sub(1, #v:GetName()-1)
                for k=1,4 do
                    _G[tmp..k]:SetScale(v.drag:GetWidth()/v.default)
                end
            else
                v:SetScale(v.drag:GetWidth()/v.default)
            end
        end
    end
    
    ---------------------------------------------------
    -- PARTY
    ---------------------------------------------------
    PartyMemberFrame1:ClearAllPoints()
    PartyMemberFrame1:SetPoint("TOPLEFT", PartyMemberFrame1.drag, 0, 0)
    
    ---------------------------------------------------
    -- TARGET
    ---------------------------------------------------
    TargetFrame.nameBackground:Hide()
    TargetFrame:SetHitRectInsets(0,0,0,0)
    TargetFrame.deadText:ClearAllPoints()
    TargetFrame.deadText:SetPoint("CENTER", TargetFrameHealthBar, "CENTER", 0, 0)
    TargetFrameTextureFrameName:ClearAllPoints()
    TargetFrameTextureFrameName:SetPoint("BOTTOMRIGHT", TargetFrame, "TOP", 0, -20)
    TargetFrameHealthBar:ClearAllPoints()
    TargetFrameHealthBar:SetPoint("TOPLEFT", 5, -24)
    TargetFrameHealthBar:SetHeight(18)
    TargetFrameTextureFrameHealthBarText:ClearAllPoints()
    TargetFrameTextureFrameHealthBarText:SetPoint("RIGHT", TargetFrameHealthBar, 0, 0)
    TargetFrameManaBar:ClearAllPoints()
    TargetFrameManaBar:SetPoint("TOPLEFT", 5, -43)
    TargetFrameManaBar:SetHeight(10)
    TargetFrameTextureFrameManaBarText:ClearAllPoints()
    TargetFrameTextureFrameManaBarText:SetPoint("RIGHT", TargetFrameManaBar, 0, 0)
    TargetFrameTextureFrameManaBarText:SetFont(TargetFrameTextureFrameManaBarText:GetFont(), 10, "OUTLINE")

    TargetFrame.threatNumericIndicator:SetPoint("BOTTOM", PlayerFrame, "TOP", 75, -22)

 
    ---------------------------------------------------
    -- FOCUS
    --------------------------------------------------- 
    FocusFrame.nameBackground:Hide()
    FocusFrame.deadText:ClearAllPoints()
    FocusFrame.deadText:SetPoint("CENTER", FocusFrameHealthBar, "CENTER", 0, 0)
    FocusFrameTextureFrameName:ClearAllPoints()
    FocusFrameTextureFrameName:SetPoint("BOTTOMRIGHT", FocusFrame, "TOP", 0, -20)
    FocusFrameHealthBar:ClearAllPoints()
    FocusFrameHealthBar:SetPoint("TOPLEFT", 5, -24)
    FocusFrameHealthBar:SetHeight(18)
    FocusFrameTextureFrameHealthBarText:ClearAllPoints()
    FocusFrameTextureFrameHealthBarText:SetPoint("RIGHT", FocusFrameHealthBar, 0, 0)
    FocusFrameManaBar:ClearAllPoints()
    FocusFrameManaBar:SetPoint("TOPLEFT", 5, -43)
    FocusFrameManaBar:SetHeight(10)
    FocusFrameTextureFrameManaBarText:ClearAllPoints()
    FocusFrameTextureFrameManaBarText:SetPoint("RIGHT", FocusFrameManaBar, 0, 0)
    FocusFrame.threatNumericIndicator:SetWidth(0.01)
    FocusFrame.threatNumericIndicator.bg:Hide()
    FocusFrame.threatNumericIndicator.text:Hide()

    function ColorGradient(perc, ...)
        if(perc ~= perc or perc == inf) then perc = 0 end

        if perc >= 1 then
            local r, g, b = select(select('#', ...) - 2, ...)
            return r, g, b
        elseif perc <= 0 then
            local r, g, b = ...
            return r, g, b
        end

        local num = select('#', ...) / 3
        local segment, relperc = math.modf(perc*(num-1))
        local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

        return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
    end
    
    ---------------------------------------------------
    -- CLASS COLOR
    ---------------------------------------------------
    local colour = function(bar, unit)
        if unit == bar.unit then
            local t = { r=0, g=1, b=0 }
            
            if (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
                t = { r=.6, g=.6, b=.6}
            elseif (not UnitIsConnected(unit)) then
                t = { r=.6, g=.6, b=.6}
            elseif(UnitIsUnit(unit, "pet") and GetPetHappiness()) then
                local happiness = {
                 [1] = {1, 0, 0}, -- need.... | unhappy
                 [2] = {1, 1, 0}, -- new..... | content
                 [3] = {0, 1, 0}, -- colors.. | happy
                }
                t = happiness[GetPetHappiness()] or { r=0, g=1, b=0 }
            elseif UnitIsPlayer(unit) then
                local _, class = UnitClass(unit)
                t = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class] or  { r=0, g=1, b=0 }
            elseif UnitReaction(unit, "player") then
                t = FACTION_BAR_COLORS and FACTION_BAR_COLORS[UnitReaction(unit, "player")] or { r=0, g=1, b=0 }
            else
                t = {r=0, g=1, b=0}
            end
            
            bar:SetStatusBarColor(t.r, t.g, t.b)
        end
    end
    
    hooksecurefunc("UnitFrameHealthBar_Update", colour)
    hooksecurefunc("HealthBar_OnValueChanged", function(self)
       colour(self, self.unit)
    end)

    ---------------------------------------------------
    -- TARGET AURA STYLE & SET POINT
    ---------------------------------------------------
    local setStyleAura = function(bname, index, isDebuff)
        local button = _G[bname..index]
        local icon   = _G[bname..index.."Icon"]
        local cd     = _G[bname..index.."Cooldown"]
        local count  = _G[bname..index.."Count"]

        if button.bd==nil then
            button.bd = button:CreateTexture(bname..index.."Overlay", "BORDER")
            button.bd:SetAllPoints(button)
            button.bd:SetTexture("Interface\\Buttons\\UI-TotemBar")
            button.bd:SetTexCoord(1 / 128, 35 / 128, 207 / 256, 240 / 256)
            button.bd:SetDesaturated(1)
            button.bd:SetVertexColor(.4, .4, .4)
        end
        
        if icon then
            icon:SetTexCoord(.1, .9, .1, .9)
            icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
            icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
            if cd then
                cd:SetAllPoints(icon)
            end
        end
        
        if count then
            count:SetDrawLayer("OVERLAY")
            count:ClearAllPoints()
            count:SetFont(count:GetFont(), 10, "OUTLINE")
            count:SetPoint("TOPRIGHT", button, 0, 0)
        end
        
        if isDebuff then
            local dtype = select(5, UnitDebuff("target",index))
            local color
            if (dtype ~= nil) then color = DebuffTypeColor[dtype] else color = DebuffTypeColor["none"] end
            button.bd:SetVertexColor(color.r * .4, color.g * .4, color.b * .4)
        end
    end

    ---------------------------------------------------
    -- TARGET AURA SIZE
    ---------------------------------------------------
    hooksecurefunc("TargetFrame_UpdateAuraPositions", function(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX)
        local AURA_OFFSET_Y = 1
        local LARGE_AURA_SIZE = config.largeAuraSize
        local SMALL_AURA_SIZE = config.smallAuraSize
        local size
        local offsetY = AURA_OFFSET_Y
        local rowWidth = 0
        local firstBuffOnRow = 1
        for i=1, numAuras do
            if ( largeAuraList[i] ) then
                size = LARGE_AURA_SIZE
                offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y
            else
                size = SMALL_AURA_SIZE
            end
            if ( i == 1 ) then
                rowWidth = size
                self.auraRows = self.auraRows + 1
            else
                rowWidth = rowWidth + size + offsetX
            end
            if ( rowWidth > maxRowWidth ) then
                updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY)
                rowWidth = size
                self.auraRows = self.auraRows + 1
                firstBuffOnRow = i
                offsetY = AURA_OFFSET_Y
            else
                updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY)
            end
            setStyleAura(auraName, i, auraName:find("debuff"))
        end
    end)
    

    if SCDB[module.name]["Debuffs On Top"] == true then
        hooksecurefunc("TargetFrame_UpdateDebuffAnchor", function(self, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY)
            local buff = _G[debuffName..index]
            buff:ClearAllPoints()
            if ( index == 1 ) then
                buff:SetPoint("TOPLEFT", self, "TOPLEFT", 5, 32)
            elseif ( anchorIndex ~= (index-1) ) then
                buff:SetPoint("BOTTOMLEFT", _G[debuffName..anchorIndex], "TOPLEFT", 0, offsetY)
            else
                buff:SetPoint("TOPLEFT", _G[debuffName..(index-1)], "TOPRIGHT", offsetX, 0)
            end
        end)
    
        hooksecurefunc("TargetFrame_UpdateBuffAnchor", function(self, buffName, index, numDebuffs, anchorIndex, size, offsetX, offsetY)
           local buff = _G[buffName..index]
           if ( index == 1 ) then
              buff:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 32)
           elseif ( anchorIndex ~= (index-1) ) then
              buff:SetPoint("TOPLEFT", _G[buffName..anchorIndex], "BOTTOMLEFT", 0, -offsetY)
           else
              buff:SetPoint("TOPLEFT", _G[buffName..anchorIndex], "TOPRIGHT", offsetX, 0)
           end
        end)
    end
    
    ---------------------------------------------------
    -- SEXY 3D PORTAITS
    ---------------------------------------------------
    function ChangePortaits(self)
        if self.portrait then
            if SCDB[module.name]["3D portaits"] == true then
                if not self.ap then
                    self.ap = _G[self.portrait:GetName().."Model"] or CreateFrame("PlayerModel", self.portrait:GetName().."Model", self.portrait:GetParent())
                    local guid = UnitGUID(self.unit)
                    if (not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit)) then
                        self.ap:SetModelScale(4.25)
                        self.ap:SetPosition(0, 0, -1.5)
                        self.ap:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
                    elseif(self.ap.guid ~= guid or (self.unit=="pet" and self.ap.guid == guid)) then
                        self.ap:SetUnit(self.unit)
                        self.ap:SetCamera(0)
                        self.ap.guid = guid
                    end
                    self.ap:SetWidth(self.portrait:GetWidth()*.75)
                    self.ap:SetHeight(self.portrait:GetHeight()*.75)
                    self.ap:SetPoint("CENTER", self.portrait, "CENTER", 0, 0)
                    if self.unit ~= "player" then
                        self.ap:SetFrameLevel(self:GetFrameLevel()-1)
                    else
                        self.ap:SetFrameLevel(self:GetFrameLevel())
                    end
                    self.ap.back = self.ap:CreateTexture(nil, "BACKGROUND")
                    self.ap.back:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMaskSmall")
                    self.ap.back:SetAllPoints(self.portrait)
                    self.ap.back:SetVertexColor(0,0,0)
                    self.ap.border = CreateFrame("frame", nil, self)
                    self.ap.border:SetAllPoints(self.portrait)
                    if self.unit ~= "player" then
                        self.ap.border:SetFrameLevel(self:GetFrameLevel())
                    else
                        self.ap.border:SetFrameLevel(self:GetFrameLevel()+1)
                    end
                    self.ap.border.tex = self.ap.border:CreateTexture(nil, "BORDER")
                    self.ap.border.tex:SetTexture("Interface\\CHARACTERFRAME\\TotemBorder")
                    self.ap.border.tex:SetWidth(self.portrait:GetWidth()+16)
                    self.ap.border.tex:SetHeight(self.portrait:GetWidth()+16)
                    self.ap.border.tex:SetPoint("CENTER")
                    self.ap.border.tex:SetVertexColor(0,0,0,.9)
                    
                    self:SetFrameStrata("LOW")
                    self.portrait:SetTexture("")
                else
                    self.portrait:SetTexture("")
                    self.ap:SetCamera(0)
                    local guid = UnitGUID(self.unit)
                    if (not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit)) then
                        self.ap:SetModelScale(4.25)
                        self.ap:SetPosition(0, 0, -1.5)
                        self.ap:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
                    elseif (self.ap.guid ~= guid  or (self.unit=="pet" or self.unit=="player" or self.unit:find("party"))) then
                        self.ap:SetUnit(self.unit)
                        self.ap:SetCamera(0)
                        self.ap.guid = guid
                    end
                end
            else
                if (not UnitExists(self.unit) or not UnitIsConnected(self.unit) or not UnitIsVisible(self.unit)) then
                    self.portrait:SetTexture("Interface\\CharacterFrame\\TempPortrait")
                else
                    if self.unit == "player" or self.unit == "pet" then return end
                    local t = CLASS_ICON_TCOORDS[select(2,UnitClass(self.unit))]
                    if t then
                       self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
                       self.portrait:SetTexCoord(unpack(t))
                    end
                end
            end
        end
    end
    
    hooksecurefunc("UnitFramePortrait_Update", ChangePortaits)
    
    ---------------------------------------------------
    -- FIX TEXT VALUES FOR HP AND MANA BARS
    ---------------------------------------------------
    local cround = function(n, dp) return math.floor((n * 10^dp) + .5) / (10^dp) end

    local function fixvalue(n)
        local strLen = strlen(n)
        if strLen > 9 then
            return cround(n/1e9, 1).." g"
        elseif strLen > 6 then
            return cround(n/1e6, 1).." m"
        elseif strLen > 5 then
            return cround(n/1e3, 0).." k"
        else
            local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)')
            return left..(num:reverse():gsub('(%d%d%d)', '%1'.."."):reverse())..right
        end
    end
    
    local function FixBarText()
        -- focus
        local frames = {FocusFrame, PlayerFrame, TargetFrame}
        for i, v in pairs(frames) do
            local unit = frames[i].unit
            local healthtext, manatext
            local healthbar = _G[frames[i]:GetName().."HealthBar"]
            local manabar = _G[frames[i]:GetName().."ManaBar"]
            local hp = healthbar:GetValue()
            local mp = manabar:GetValue()
            if unit == "focus" or unit == "target" then
                healthtext = _G[frames[i]:GetName().."TextureFrameHealthBarText"]
                manatext = _G[frames[i]:GetName().."TextureFrameManaBarText"]
            elseif unit == "player" then
                healthtext = _G[frames[i]:GetName().."HealthBarText"]
                manatext = _G[frames[i]:GetName().."ManaBarText"]
            end
            
            if not healthtext then return end
            if not manatext then return end
            
            if hp > 0 then
                if UnitIsDeadOrGhost(unit) then
                    if UnitIsGhost(unit) then
                        healthtext:SetText("Ghost")
                    else
                        healthtext:SetText("Dead")
                    end
                else
                    healthtext:SetText(fixvalue(hp))
                    if GetCVarBool("statusTextPercentage") then
                        _, maxhp = healthbar:GetMinMaxValues()
                        hppercent = math.floor((hp / maxhp) * 100)
                        healthtext:SetText(hppercent.."%")
                    end
                end
            end
            
            if mp > 0 then
                if UnitIsDeadOrGhost(unit) then
                    manatext:SetText()
                else
                    manatext:SetText(fixvalue(mp))
                end
            else
                manatext:SetText()
            end
            
            if not UnitIsConnected(unit) then
                manatext:SetText("Offline")
            end
        end
    end
    
    hooksecurefunc("TextStatusBar_UpdateTextString", FixBarText)
    hooksecurefunc("TextStatusBar_OnValueChanged", FixBarText)
    hooksecurefunc("TextStatusBar_Initialize", FixBarText)
    hooksecurefunc("TextStatusBar_OnEvent", FixBarText)
    hooksecurefunc("HideTextStatusBarText", FixBarText)

    
    -- setup slash command /tcb
    SLASH_MoveFrames1 = "/mf";
    SlashCmdList["MoveFrames"] = function()
        for i, frame in pairs(allframes) do
            frame.locked = not frame.locked
            if frame.locked then
                frame.drag:EnableMouse(false)
                frame.drag:Hide()
            else
                frame.drag:EnableMouse(true)
                frame.drag:Show()
            end
        end
    end
    
end
tinsert(SuperClassic.modules, module) -- finish him!